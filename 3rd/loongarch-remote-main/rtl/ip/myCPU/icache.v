/*==============================================================================
 * 指令Cache模块 (ICache)
 * 规格：8KB，两路组相联，Cache行大小16字节，VIPT访问方式
 * 采用伪随机替换算法，只读Cache（无写操作），阻塞式设计
 * 与DCache的主要区别：无写缓冲区状态机，无Dirty位管理
 *==============================================================================*/
module icache
(
    input               clk            ,  // 时钟信号
    input               reset          ,  // 复位信号，高电平有效
    
    //================= CPU接口 =================
    input               valid          ,  // 请求有效信号
    input               op             ,  // 操作类型（ICache中无实际写操作）
    input  [ 7:0]       index          ,  // Cache索引（虚地址[11:4]）
    input  [19:0]       tag            ,  // Cache标签（物理地址[31:12]）
    input  [ 3:0]       offset         ,  // Cache行内偏移（地址[3:0]）
    input  [ 3:0]       wstrb          ,  // 写字节使能（ICache中未使用）
    input  [31:0]       wdata          ,  // 写数据（ICache中未使用）
    output              addr_ok        ,  // 地址传输完成信号
    output              data_ok        ,  // 数据传输完成信号
    output [31:0]       rdata          ,  // 读数据
    
    // Cache控制信号
    input               uncache_en     ,  // 非缓存访问使能
    input               icacop_op_en   ,  // ICache操作指令使能
    input  [ 1:0]       cacop_op_mode  ,  // Cache操作模式：00-索引无效，01-索引写回无效，10-命中无效，11-命中写回无效
    input  [ 7:0]       cacop_op_addr_index , // Cache操作地址索引（来自访存阶段的虚地址）
    input  [19:0]       cacop_op_addr_tag   , // Cache操作地址标签
    input  [ 3:0]       cacop_op_addr_offset, // Cache操作地址偏移
    output              icache_unbusy,         // ICache非忙信号
    
    // 例外取消信号
    input               tlb_excp_cancel_req,  // TLB例外取消请求
    
    //================= AXI总线接口 =================
    // 读请求通道
    output              rd_req       ,  // 读请求有效
    output [ 2:0]       rd_type      ,  // 读请求类型
    output [31:0]       rd_addr      ,  // 读请求地址
    input               rd_rdy       ,  // 读请求就绪
    
    // 读响应通道
    input               ret_valid    ,  // 返回数据有效
    input               ret_last     ,  // 最后一个返回数据
    input  [31:0]       ret_data     ,  // 返回数据
    
    // 写请求通道（ICache基本不使用，但保持接口一致性）
    output reg          wr_req       ,  // 写请求有效
    output [ 2:0]       wr_type      ,  // 写请求类型
    output [31:0]       wr_addr      ,  // 写请求地址
    output [ 3:0]       wr_wstrb     ,  // 写字节掩码
    output [127:0]      wr_data      ,  // 写数据
    input               wr_rdy       ,  // 写请求就绪
    
    //================= 性能计数器接口 =================
    output              cache_miss     // Cache缺失信号
); 

/*==============================================================================
 * 内部寄存器和线网声明
 *==============================================================================*/

//================= Request Buffer（请求缓冲区）=================
// 用于锁存CPU发来的请求信息，供Tag比较和Miss处理使用
reg         request_buffer_op         ;  // 缓存的操作类型
reg [ 7:0]  request_buffer_index      ;  // 缓存的索引
reg [19:0]  request_buffer_tag        ;  // 缓存的标签
reg [ 3:0]  request_buffer_offset     ;  // 缓存的偏移
reg [ 3:0]  request_buffer_wstrb      ;  // 缓存的写字节使能（ICache中未使用）
reg [31:0]  request_buffer_wdata      ;  // 缓存的写数据（ICache中未使用）
reg         request_buffer_uncache_en ;  // 缓存的非缓存访问标志
reg         request_buffer_icacop     ;  // 缓存的ICache操作标志
reg [ 1:0]  request_buffer_cacop_op_mode;  // 缓存的Cache操作模式

//================= Miss Buffer（缺失处理缓冲区）=================
// 记录Cache缺失时的替换路信息和返回数据计数
reg  [ 1:0]  miss_buffer_replace_way ;  // 要替换的路号
reg  [ 1:0]  miss_buffer_ret_num     ;  // 已返回的32位数据个数
wire [ 1:0]  ret_num_add_one         ;  // 返回数据计数加1
 
 
//================= Cache RAM接口信号 =================
// Data Bank RAM接口（每路4个Bank，每个Bank 256×32位）
wire [ 7:0] way_bank_addra [1:0][3:0];  // Bank RAM地址
wire [31:0] way_bank_dina  [1:0][3:0];  // Bank RAM写数据
wire [31:0] way_bank_douta [1:0][3:0];  // Bank RAM读数据
wire        way_bank_ena   [1:0][3:0];  // Bank RAM使能
wire [ 3:0] way_bank_wea   [1:0][3:0];  // Bank RAM写使能（字节级）

// Tag+Valid RAM接口（每路一个，256×21位，[20:1]为Tag，[0]为Valid）
wire [ 7:0] way_tagv_addra [1:0];       // Tag+V RAM地址
wire [20:0] way_tagv_dina  [1:0];       // Tag+V RAM写数据
wire [20:0] way_tagv_douta [1:0];       // Tag+V RAM读数据
wire        way_tagv_ena   [1:0];       // Tag+V RAM使能
wire        way_tagv_wea   [1:0];       // Tag+V RAM写使能

//================= 内部控制信号 =================
wire [ 1:0] way_hit     ;  // 各路的命中信号
wire        cache_hit   ;  // Cache命中信号

// 数据选择相关信号
wire [ 31:0] way_load_word [1:0];  // 各路选出的32位数据
wire [127:0] way_data      [1:0];  // 各路的完整Cache行数据
wire [31:0]  load_res        ;     // 读操作的最终结果

//================= 状态机控制信号 =================
wire         main_idle2lookup  ;    // 主状态机：空闲→查找转换条件
wire         main_lookup2lookup;    // 主状态机：查找→查找转换条件

// 主状态机状态指示信号
wire         main_state_is_idle   ;  // 当前处于空闲状态
wire         main_state_is_lookup ;  // 当前处于查找状态
wire         main_state_is_replace;  // 当前处于替换状态
wire         main_state_is_refill ;  // 当前处于重填状态

//================= 其他控制信号 =================
wire [1:0]   way_wr_en;              // 路写使能
wire [31:0]  refill_data;            // 重填数据

//================= Cache操作相关信号 =================
wire         cacop_op_mode0;         // Cache操作模式0：索引无效
wire         cacop_op_mode1;         // Cache操作模式1：索引写回无效
wire         cacop_op_mode2;         // Cache操作模式2：命中无效

//================= 替换算法相关信号 =================
wire [1:0]   random_val;             // 伪随机数
wire [3:0]   chosen_way;             // 随机选择的路（独热码）
wire [1:0]   replace_way;            // 最终选择的替换路
wire [1:0]   invalid_way;            // 无效路（独热码）
wire         has_invalid_way;        // 是否存在无效路
wire [1:0]   rand_repl_way;          // 随机替换路选择结果
wire [3:0]   cacop_chose_way;        // Cache操作选择的路（独热码）
wire         cacop_op_mode2_hit_wr;  // Cache操作模式2命中写操作
wire         cacop_op_mode2_no_hit;  // Cache操作模式2未命中

reg  [ 1:0]  lookup_way_hit_buffer;  // 查找阶段命中路缓存

//================= 地址选择信号 =================
wire [ 3:0]  real_offset;            // 实际使用的偏移（普通访问或Cache操作）
wire [19:0]  real_tag   ;            // 实际使用的标签
wire [ 7:0]  real_index ;            // 实际使用的索引

wire         req_or_inst_valid ;     // 请求或指令有效   

//================= 状态机状态定义 =================
// 主状态机状态定义（ICache无MISS状态，直接从LOOKUP到REPLACE）
localparam main_idle    = 5'b00001;  // 空闲状态：等待新请求
localparam main_lookup  = 5'b00010;  // 查找状态：进行Tag比较，判断命中/缺失
localparam main_replace = 5'b01000;  // 替换状态：等待读请求被AXI总线接受
localparam main_refill  = 5'b10000;  // 重填状态：等待并接收缺失数据

// 写缓冲区状态定义（ICache中未使用，保留以保持接口一致性）
localparam write_buffer_idle  = 1'b0;  
localparam write_buffer_write = 1'b1; 

//================= 状态机寄存器 =================
reg [4:0] main_state;        // 主状态机当前状态
reg       rd_req_buffer;     // 读请求缓冲（用于REFILL状态判断）

genvar i,j;  // 循环生成变量

/*==============================================================================
 * 主状态机
 * 控制ICache的主要操作流程：空闲→查找→替换→重填→空闲
 * 与DCache的区别：无MISS状态（因为ICache无写回操作）
 *==============================================================================*/
always @(posedge clk) begin
    if (reset) begin
        // 复位时初始化所有寄存器
        main_state <= main_idle;

        request_buffer_op         <=  1'b0;
        request_buffer_index      <=  8'b0;
        request_buffer_tag        <= 20'b0;
        request_buffer_offset     <=  4'b0;
        request_buffer_wstrb      <=  4'b0;
        request_buffer_wdata      <= 32'b0;
        request_buffer_uncache_en <=  1'b0;

        request_buffer_cacop_op_mode <= 2'b0;
        request_buffer_icacop        <= 1'b0;

        miss_buffer_replace_way <= 2'b0;

        wr_req <= 1'b0;  // ICache基本不使用写请求
    end
    else case (main_state)
        main_idle: begin
            // 空闲状态：等待新的有效请求
            if (req_or_inst_valid && main_idle2lookup) begin
                main_state <= main_lookup;

                // 将请求信息锁存到Request Buffer中
                request_buffer_op         <= op   ;
                request_buffer_index      <= real_index ;
                request_buffer_offset     <= real_offset;
                request_buffer_wstrb      <= wstrb;
                request_buffer_wdata      <= wdata;

                request_buffer_cacop_op_mode <= cacop_op_mode;
                request_buffer_icacop        <= icacop_op_en ;
            end
        end
        main_lookup: begin
            // 查找状态：进行Tag比较，决定下一步操作
            if (req_or_inst_valid && main_lookup2lookup) begin
                // 命中且可以接收新请求，继续在查找状态
                main_state <= main_lookup;

                // 更新Request Buffer为新请求
                request_buffer_op         <= op   ;
                request_buffer_index      <= real_index ;
                request_buffer_offset     <= real_offset;
                request_buffer_wstrb      <= wstrb;
                request_buffer_wdata      <= wdata;

                request_buffer_cacop_op_mode <= cacop_op_mode;
                request_buffer_icacop        <= icacop_op_en  ;
            end
            else if (tlb_excp_cancel_req) begin
                // TLB例外取消请求，返回空闲状态
                main_state <= main_idle;
            end
            else if (!cache_hit) begin
                // Cache缺失，直接进入替换状态（ICache无写回操作）
                main_state <= main_replace;

                // 保存Tag和相关控制信息
                request_buffer_tag <= real_tag;
                request_buffer_uncache_en <= (uncache_en && !request_buffer_icacop);
                miss_buffer_replace_way <= replace_way;
            end
            else begin
                // Cache命中，返回空闲状态
                main_state <= main_idle;
            end
        end
        main_replace: begin
            // 替换状态：等待AXI总线接受读请求
            if (rd_rdy) begin
                main_state <= main_refill;
                miss_buffer_ret_num <= 2'b0;   // 重置返回数据计数器
            end
        end
        main_refill: begin
            // 重填状态：接收并写入缺失的Cache行数据
            if ((ret_valid && ret_last) || !rd_req_buffer) begin   
                // 接收完所有数据或无读请求，返回空闲状态
                main_state <= main_idle;
            end
            else begin
                if (ret_valid) begin
                    // 更新返回数据计数器
                    miss_buffer_ret_num <= ret_num_add_one;
                end
            end
        end
        default: begin
            main_state <= main_idle;
        end
    endcase
end

/*==============================================================================
 * 地址选择逻辑
 * 根据是否为Cache操作选择使用的地址信号
 *==============================================================================*/
// 地址选择：Cache操作时使用专用地址，否则使用输入地址
assign real_offset = icacop_op_en ? cacop_op_addr_offset : offset;
assign real_index  = icacop_op_en ? cacop_op_addr_index  : index ;
assign real_tag    = request_buffer_icacop ? cacop_op_addr_tag    : tag   ;

/*==============================================================================
 * 主状态机状态转换控制逻辑
 *==============================================================================*/

// 请求有效信号：普通取指访问或ICache操作
assign req_or_inst_valid = valid || icacop_op_en;

// 空闲->查找状态转换条件（ICache无冲突检测，始终允许转换）
assign main_idle2lookup   = 1'b1;

// ICache非忙信号：仅当主状态机处于空闲状态时为真
assign icache_unbusy = main_state_is_idle;

/*==============================================================================
 * Tag比较和Cache命中判断逻辑
 *==============================================================================*/

// 各路Tag比较：比较读出的Tag与实际使用的Tag
generate for(i=0;i<2;i=i+1) begin:gen_way_hit
	assign way_hit[i] = way_tagv_douta[i][0] && (real_tag == way_tagv_douta[i][20:1]); 
end endgenerate

// Cache命中判断：任一路命中且非特殊访问类型
assign cache_hit = |way_hit && !(uncache_en || cacop_op_mode0 || cacop_op_mode1 || cacop_op_mode2);  

// 查找→查找状态转换条件：仅需命中即可（ICache无写冲突）
assign main_lookup2lookup = cache_hit;

// 地址传输完成信号：可以接收新请求且非Cache操作
assign addr_ok = ((main_state_is_idle && main_idle2lookup) || (main_state_is_lookup && main_lookup2lookup)) && !icacop_op_en;

/*==============================================================================
 * 数据选择逻辑
 *==============================================================================*/

// 从各路Cache行中选择对应偏移的32位数据
generate for(i=0;i<2;i=i+1) begin: gen_data
	// 将4个Bank的数据拼接成完整的128位Cache行
	assign way_data[i] = {way_bank_douta[i][3],way_bank_douta[i][2],way_bank_douta[i][1],way_bank_douta[i][0]};

	// 根据偏移选择对应的32位数据
	assign way_load_word[i] = way_data[i][request_buffer_offset[3:2]*32 +: 32];
end endgenerate

// 根据命中路选择最终的读数据
assign load_res  = {32{way_hit[0]}} & way_load_word[0] |
                   {32{way_hit[1]}} & way_load_word[1] ;

/*==============================================================================
 * 替换算法逻辑
 *==============================================================================*/

// 2选4译码器：生成随机路选择的独热码
decoder_2_4 dec_rand_way (.in({1'b0,random_val[0]}),.out(chosen_way));

// 查找无效路：优先选择无效路进行替换
one_valid_n #(2) sel_one_invalid (.in(~{way_tagv_douta[1][0],way_tagv_douta[0][0]}),.out(invalid_way),.nozero(has_invalid_way));

// 随机替换路选择：优先选择无效路，否则随机选择
assign rand_repl_way = has_invalid_way ? invalid_way : chosen_way[1:0]; 

// Cache操作路选择译码器
decoder_2_4 dec_cacop_way (.in({1'b0,request_buffer_offset[0]}),.out(cacop_chose_way));

// 最终替换路选择
assign replace_way = {2{cacop_op_mode0 || cacop_op_mode1}} & cacop_chose_way[1:0] |  // Cache操作指定路
                     {2{cacop_op_mode2}}                   & way_hit              |  // 命中路
                     {2{!request_buffer_icacop}}           & rand_repl_way;          // 随机路

/*==============================================================================
 * AXI读请求接口逻辑（REPLACE状态）
 *==============================================================================*/

// 读请求：非特定Cache操作模式下发起读请求
assign rd_req  = main_state_is_replace && !(cacop_op_mode0 || cacop_op_mode1 || cacop_op_mode2);

/*==============================================================================
 * 数据传输完成和重填逻辑（REFILL状态）
 *==============================================================================*/

// 读请求类型：非缓存访问按字大小，缓存访问按Cache行大小
assign rd_type = request_buffer_uncache_en ? 3'b10 : 3'b100;

// 读请求地址
assign rd_addr = request_buffer_uncache_en ? {request_buffer_tag, request_buffer_index, request_buffer_offset} : 
                                             {request_buffer_tag, request_buffer_index, 4'b0};

// 数据传输完成信号
// 命中情况：查找状态且命中，或TLB例外取消
// 缺失情况：重填状态且接收到对应偏移的数据
assign data_ok = (main_state_is_lookup && (cache_hit || tlb_excp_cancel_req)) || 
                 (main_state_is_refill && ((ret_valid && ((miss_buffer_ret_num == request_buffer_offset[3:2]) || request_buffer_uncache_en)))) &&
                 !request_buffer_icacop;  

// 重填数据：直接使用返回数据（ICache无写合并需求）
assign refill_data = ret_data;

// 路写使能：返回数据有效时写入对应的替换路
assign way_wr_en = miss_buffer_replace_way & {2{ret_valid}}; 

// Cache缺失信号：重填完成且非特殊访问
assign cache_miss = main_state_is_refill && ret_last && !(request_buffer_uncache_en || request_buffer_icacop);

// 返回数据计数器加1逻辑
assign ret_num_add_one[0] = miss_buffer_ret_num[0] ^ 1'b1;
assign ret_num_add_one[1] = miss_buffer_ret_num[1] ^ miss_buffer_ret_num[0];

/*==============================================================================
 * 读请求缓冲区管理
 *==============================================================================*/
always @(posedge clk) begin
    if (reset) begin
        rd_req_buffer <= 1'b0;
    end
    else if (rd_req) begin
        // 发起读请求时置1
        rd_req_buffer <= 1'b1;
    end
    else if (main_state_is_refill && (ret_valid && ret_last)) begin
        // 接收完所有返回数据时清0
        rd_req_buffer <= 1'b0;
    end
end

/*==============================================================================
 * Cache操作控制信号和命中缓冲逻辑
 *==============================================================================*/

// Cache操作模式判断
assign cacop_op_mode0 = request_buffer_icacop && (request_buffer_cacop_op_mode == 2'b00);  // 索引无效
assign cacop_op_mode1 = request_buffer_icacop && ((request_buffer_cacop_op_mode == 2'b01) || (request_buffer_cacop_op_mode == 2'b11));  // 索引写回无效
assign cacop_op_mode2 = request_buffer_icacop && (request_buffer_cacop_op_mode == 2'b10);  // 命中无效

// Cache操作模式2的命中/未命中判断
assign cacop_op_mode2_hit_wr = cacop_op_mode2 && |lookup_way_hit_buffer;
assign cacop_op_mode2_no_hit = cacop_op_mode2 && ~|lookup_way_hit_buffer;

// Cache操作模式2的命中路缓冲
always @(posedge clk) begin
    if (reset) begin
        lookup_way_hit_buffer <= 2'b0;
    end
    else if (cacop_op_mode2 && main_state_is_lookup) begin
        // 在查找状态缓存命中路信息
        lookup_way_hit_buffer <= way_hit;
    end
end

/*==============================================================================
 * 输出数据选择
 *==============================================================================*/
// 读数据输出：查找状态返回命中数据，重填状态返回AXI数据
assign rdata = {32{main_state_is_lookup}} & load_res |
               {32{main_state_is_refill}} & ret_data ;

/*==============================================================================
 * Data Bank RAM控制逻辑生成
 * 每路4个Bank，每个Bank存储32位数据，支持字节级写使能
 * ICache特点：仅在重填时写入，无写缓冲区逻辑
 *==============================================================================*/
generate 
for(i=0;i<2;i=i+1) begin:gen_data_way
	for(j=0;j<4;j=j+1) begin:gen_data_bank

/*===============================Bank地址逻辑=================================*/
		// Bank地址选择：Look Up阶段使用实际索引，其他阶段使用缓冲区索引
		assign way_bank_addra[i][j] = {8{addr_ok}}  & real_index           |  // Look Up阶段
	                                  {8{!addr_ok}} & request_buffer_index ;  // 其他阶段

/*===============================Bank写使能逻辑===============================*/
		// 写使能：仅在重填状态且当前Bank接收数据时写入
		assign way_bank_wea[i][j] = {4{main_state_is_refill && 
                                    (way_wr_en[i] && (miss_buffer_ret_num == j[1:0]))}} & 4'hf;

/*===============================Bank写数据逻辑===============================*/
		// 写数据：重填数据（ICache无写合并需求）
		assign way_bank_dina[i][j] = {32{main_state_is_refill}} & refill_data;

/*===============================Bank使能逻辑=================================*/
		// Bank使能：非缓存访问和特定Cache操作时禁用，其他情况使能
		assign way_bank_ena[i][j] = (!(request_buffer_uncache_en || cacop_op_mode0)) || main_state_is_idle || main_state_is_lookup;
	end
end
endgenerate

/*==============================================================================
 * Tag+Valid RAM控制逻辑生成
 * 每路一个Tag+Valid RAM，存储Tag[20:1]和Valid[0]位
 *==============================================================================*/
generate 
for(i=0;i<2;i=i+1) begin:gen_tagv_way

/*===============================TagV地址逻辑=================================*/
	// 地址选择：Look Up阶段或Cache操作时使用实际索引，其他阶段使用缓冲区索引
	assign way_tagv_addra[i] = {8{addr_ok || (icacop_op_en && 
                               (main_state_is_idle || main_state_is_lookup))}} & real_index              | 
                               {8{main_state_is_replace || main_state_is_refill}} & request_buffer_index ;

/*===============================TagV使能逻辑=================================*/
	// 使能控制：非缓存访问时禁用，其他情况使能
	assign way_tagv_ena[i] = (!request_buffer_uncache_en) || main_state_is_idle || main_state_is_lookup;

/*===============================TagV写使能逻辑===============================*/
	// 写使能：重填完成或Cache操作时写入
	assign way_tagv_wea[i] = miss_buffer_replace_way[i] && main_state_is_refill && 
							 ((ret_valid && ret_last) || cacop_op_mode0 || cacop_op_mode1 || cacop_op_mode2_hit_wr);

/*===============================TagV写数据逻辑===============================*/
	// 写数据：Cache操作时写入全0（无效），否则写入Tag和Valid=1
	assign way_tagv_dina[i] = (cacop_op_mode0 || cacop_op_mode1 || cacop_op_mode2_hit_wr) ? 21'b0 : 
	                          {request_buffer_tag, 1'b1};
end
endgenerate
/*==============================================================================
 * RAM实例化
 *==============================================================================*/

// Data Bank RAM实例化：每路4个Bank，共8个RAM实例
generate 
for(i=0;i<2;i=i+1) begin:data_ram_way
	for(j=0;j<4;j=j+1) begin:data_ram_bank
		data_bank_sram u(
    		.addra      (way_bank_addra[i][j])  ,  // 地址输入
    		.clka       (clk                 )  ,  // 时钟输入
    		.dina       (way_bank_dina[i][j] )  ,  // 写数据输入
    		.douta      (way_bank_douta[i][j])  ,  // 读数据输出
    		.ena        (way_bank_ena[i][j]  )  ,  // 使能输入
    		.wea        (way_bank_wea[i][j]  )     // 写使能输入（字节级）
		);
	end
end
endgenerate

// Tag+Valid RAM实例化：每路一个，共2个RAM实例
generate
for(i=0;i<2;i=i+1) begin:tagv_ram_way
	// [20:1] Tag域     [0:0] Valid域
	tagv_sram u( 
	    .addra      (way_tagv_addra[i])  ,     // 地址输入
	    .clka       (clk              )  ,     // 时钟输入
	    .dina       (way_tagv_dina[i] )  ,     // 写数据输入
	    .douta      (way_tagv_douta[i])  ,     // 读数据输出
	    .ena        (way_tagv_ena[i]  )  ,     // 使能输入
	    .wea        (way_tagv_wea[i]  )        // 写使能输入
	);
end
endgenerate

// 伪随机数生成器：用于替换算法
lfsr lfsr(
    .clk        (clk        )   ,              // 时钟输入
    .reset      (reset      )   ,              // 复位输入
    .random_val (random_val )                  // 随机数输出
);

/*==============================================================================
 * 状态机状态指示信号
 *==============================================================================*/
// 主状态机状态判断
assign main_state_is_idle    = main_state == main_idle   ;  // 空闲状态
assign main_state_is_lookup  = main_state == main_lookup ;  // 查找状态
assign main_state_is_replace = main_state == main_replace;  // 替换状态
assign main_state_is_refill  = main_state == main_refill ;  // 重填状态

endmodule
