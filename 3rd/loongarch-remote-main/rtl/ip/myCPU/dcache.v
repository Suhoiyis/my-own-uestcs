/*==============================================================================
 * 数据Cache模块 (DCache)
 * 规格：8KB，两路组相联，Cache行大小16字节，VIPT访问方式
 * 采用伪随机替换算法，写回写分配策略，阻塞式设计
 *==============================================================================*/
module dcache
(
    input               clk          ,  // 时钟信号
    input               reset        ,  // 复位信号，高电平有效
    
    //================= CPU接口 =================
    input               valid        ,  // 请求有效信号
    input               op           ,  // 操作类型：1-写操作，0-读操作
    input  [ 2:0]       size         ,  // 访问大小：3'b000-字节，3'b001-半字，3'b010-字
    input  [ 7:0]       index        ,  // Cache索引（虚地址[11:4]）
    input  [19:0]       tag          ,  // Cache标签（物理地址[31:12]）
    input  [ 3:0]       offset       ,  // Cache行内偏移（地址[3:0]）
    input  [ 3:0]       wstrb        ,  // 写字节使能
    input  [31:0]       wdata        ,  // 写数据
    output              addr_ok      ,  // 地址传输完成信号
    output              data_ok      ,  // 数据传输完成信号
    output [31:0]       rdata        ,  // 读数据
    
    // Cache控制信号
    input               uncache_en   ,  // 非缓存访问使能(from mem_stage)
    input               dcacop_op_en ,  // Cache操作指令使能
    input  [ 1:0]       cacop_op_mode,  // Cache操作模式：00-索引无效，01-索引写回无效，10-命中无效，11-命中写回无效
    input  [ 4:0]       preld_hint   ,  // 预取提示
    input               preld_en     ,  // 预取使能
    
    // 例外取消信号
    input               tlb_excp_cancel_req,  // TLB例外取消请求(from mem_stage)
    input               sc_cancel_req,        // SC指令取消请求(from mem_stage)
	output              dcache_empty ,         // DCache空闲信号
    
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
    
    // 写请求通道
    output reg          wr_req       ,  // 写请求有效
    output [ 2:0]       wr_type      ,  // 写请求类型
    output [31:0]       wr_addr      ,  // 写请求地址
    output [ 3:0]       wr_wstrb     ,  // 写字节掩码
    output [127:0]      wr_data      ,  // 写数据（Cache行大小）
    input               wr_rdy       ,  // 写请求就绪
    
    //================= 性能计数器接口 =================
    output              cache_miss     // Cache缺失信号
);

/*==============================================================================
 * 内部寄存器和线网声明
 *==============================================================================*/

// Dirty位寄存器数组（256个index，每个index有2路）
reg [1:0] way_d_reg [255:0];

//================= Request Buffer（请求缓冲区）=================
// 用于锁存CPU发来的请求信息，供Tag比较和Miss处理使用
wire        request_uncache_en        ;  // 当前请求是否为非缓存访问
reg         request_buffer_op         ;  // 缓存的操作类型
reg         request_buffer_preld      ;  // 缓存的预取信号
reg [ 2:0]  request_buffer_size       ;  // 缓存的访问大小
reg [ 7:0]  request_buffer_index      ;  // 缓存的索引
reg [19:0]  request_buffer_tag        ;  // 缓存的标签
reg [ 3:0]  request_buffer_offset     ;  // 缓存的偏移
reg [ 3:0]  request_buffer_wstrb      ;  // 缓存的写字节使能
reg [31:0]  request_buffer_wdata      ;  // 缓存的写数据
reg         request_buffer_uncache_en ;  // 缓存的非缓存访问标志
reg         request_buffer_dcacop     ;  // 缓存的Cache操作标志
reg [ 1:0]  request_buffer_cacop_op_mode;  // 缓存的Cache操作模式

//================= Miss Buffer（缺失处理缓冲区）=================
// 记录Cache缺失时的替换路信息和返回数据计数
reg  [ 1:0]  miss_buffer_replace_way ;  // 要替换的路号
reg  [ 1:0]  miss_buffer_ret_num     ;  // 已返回的32位数据个数
wire [ 1:0]  ret_num_add_one         ;  // 返回数据计数加1

//================= Write Buffer（写缓冲区）=================
// 用于缓存命中写操作的信息，避免RAM输出到输入的时序路径
reg [ 7:0]  write_buffer_index      ;  // 写操作的索引
reg [ 3:0]  write_buffer_wstrb      ;  // 写操作的字节使能
reg [31:0]  write_buffer_wdata      ;  // 写操作的数据
reg [ 1:0]  write_buffer_way        ;  // 写操作的路号
reg [ 3:0]  write_buffer_offset     ;  // 写操作的偏移

 
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
wire 		wr_match_way_bank[1:0][3:0];  // 写操作与Bank的匹配信号

wire [ 1:0] way_d       ;  // 当前访问的Dirty位
wire [ 1:0] way_hit     ;  // 各路的命中信号
wire        cache_hit   ;  // Cache命中信号

// 数据选择相关信号
wire [31:0]  way_load_word [1:0];  // 各路选出的32位数据
wire [127:0] way_data      [1:0];  // 各路的完整Cache行数据
wire [31:0]  load_res           ;  // 读操作的最终结果
 
 
//================= 替换算法相关信号 =================
wire [127:0] replace_data    ;  // 要替换出的Cache行数据
wire         replace_d       ;  // 要替换Cache行的Dirty位
wire         replace_v       ;  // 要替换Cache行的Valid位
wire [19:0]  replace_tag     ;  // 要替换Cache行的Tag
wire [ 1:0]  random_val      ;  // 伪随机数
wire [ 3:0]  chosen_way      ;  // 随机选择的路（独热码）
wire [ 1:0]  replace_way     ;  // 最终选择的替换路
wire [ 1:0]  invalid_way     ;  // 无效路（独热码）
wire         has_invalid_way ;  // 是否存在无效路
wire [ 1:0]  rand_repl_way   ;  // 随机替换路选择结果
wire [ 3:0]  cacop_chose_way ;  // Cache操作选择的路（独热码）

//================= 状态机控制信号 =================
wire         main_idle2lookup  ;    // 主状态机：空闲→查找转换条件
wire         main_lookup2lookup;    // 主状态机：查找→查找转换条件

// 主状态机状态指示信号
wire         main_state_is_idle   ;  // 当前处于空闲状态
wire         main_state_is_lookup ;  // 当前处于查找状态
wire         main_state_is_miss   ;  // 当前处于缺失状态
wire         main_state_is_replace;  // 当前处于替换状态
wire         main_state_is_refill ;  // 当前处于重填状态

// 写缓冲区状态机状态指示信号
wire         write_state_is_idle;   // 写缓冲区空闲
wire         write_state_is_full;   // 写缓冲区满载（有待写数据）

//================= 非缓存访问控制信号 =================
wire         uncache_wr     ;        // 非缓存写操作标志
reg          uncache_wr_buffer;      // 缓存的非缓存写操作标志
wire [ 2:0]  uncache_wr_type;        // 非缓存写操作类型

//================= Cache操作相关信号 =================
wire         cacop_op_mode0;         // Cache操作模式0：索引无效
wire         cacop_op_mode1;         // Cache操作模式1：索引写回无效
wire         cacop_op_mode2;         // Cache操作模式2：命中无效

wire         cacop_op_mode2_hit;  // Cache操作模式2命中写操作
reg          cacop_op_mode2_hit_buffer;  // 缓存的模式2命中写操作标志

//================= 其他控制信号 =================
wire [ 1:0]  way_wr_en;              // 路写使能
wire [31:0]  refill_data;            // 重填数据
wire [31:0]  write_in;               // 写入数据（合并后）

// 预取相关信号
wire         preld_st_en;            // 预取存储使能
wire         preld_ld_en;            // 预取加载使能
wire         preld_ld_st_en;         // 预取加载存储使能

wire         req_or_inst_valid;      // 请求或指令有效

reg [1:0]    lookup_way_hit_buffer;  // 查找阶段命中路缓存

//================= 状态机状态定义 =================
// 主状态机状态定义
localparam main_idle    = 5'b00001;  // 空闲状态：等待新请求
localparam main_lookup  = 5'b00010;  // 查找状态：进行Tag比较，判断命中/缺失
localparam main_miss    = 5'b00100;  // 缺失状态：等待写请求被AXI总线接受
localparam main_replace = 5'b01000;  // 替换状态：等待读请求被AXI总线接受
localparam main_refill  = 5'b10000;  // 重填状态：等待并接收缺失数据

// 写缓冲区状态机状态定义  
localparam write_buffer_idle  = 1'b0;  // 空闲：无待写数据
localparam write_buffer_write = 1'b1;  // 写入：将缓存数据写入Cache

genvar i,j;  // 循环生成变量

//================= 状态机寄存器 =================
reg [4:0] main_state;        // 主状态机当前状态
reg       write_buffer_state; // 写缓冲区状态机当前状态

reg       rd_req_buffer;     // 读请求缓冲（用于REFILL状态判断）

// wire      invalid_way;    // 未使用

// 取消请求信号（TLB例外或SC指令取消）
wire cancel_req = tlb_excp_cancel_req || sc_cancel_req;

/*==============================================================================
 * 主状态机
 *==============================================================================*/
always @(posedge clk) begin
    if (reset) begin
        // 复位时初始化所有寄存器
        main_state <= main_idle;

        request_buffer_op         <=  1'b0;
        request_buffer_preld      <=  1'b0;
        request_buffer_size       <=  3'b0;
        request_buffer_index      <=  8'b0;
        request_buffer_tag        <= 20'b0;
        request_buffer_offset     <=  4'b0;
        request_buffer_wstrb      <=  4'b0;
        request_buffer_wdata      <= 32'b0;
        request_buffer_uncache_en <=  1'b0;
        request_buffer_cacop_op_mode <= 2'b0;
        request_buffer_dcacop        <= 1'b0;

        miss_buffer_replace_way <= 2'b0;

		wr_req <= 1'b0;
    end
    else case (main_state)
        main_idle: begin
            // 空闲状态：等待新的有效请求
            if (req_or_inst_valid && main_idle2lookup) begin
                main_state <= main_lookup;

                // 将请求信息锁存到Request Buffer中
                request_buffer_op         <= op        ;
                request_buffer_preld      <= preld_en     ;
                request_buffer_size       <= size      ;
                request_buffer_index      <= index     ;
                request_buffer_offset     <= offset    ;
                request_buffer_wstrb      <= wstrb     ;
                request_buffer_wdata      <= wdata     ;

                request_buffer_cacop_op_mode <= cacop_op_mode ;
                request_buffer_dcacop        <= dcacop_op_en  ;
            end
        end
        main_lookup: begin
            // 查找状态：进行Tag比较，决定下一步操作
            if (req_or_inst_valid && main_lookup2lookup) begin
                // 命中且可以接收新请求，继续在查找状态
                main_state <= main_lookup;

                // 更新Request Buffer为新请求
                request_buffer_op         <= op        ;
                request_buffer_preld      <= preld_en  ;
                request_buffer_size       <= size      ;
                request_buffer_index      <= index     ;
                request_buffer_offset     <= offset    ;
                request_buffer_wstrb      <= wstrb     ;
                request_buffer_wdata      <= wdata     ;

                request_buffer_cacop_op_mode <= cacop_op_mode ;
                request_buffer_dcacop        <= dcacop_op_en  ;
            end
            else if (cancel_req) begin
                // 取消请求，返回空闲状态
                main_state <= main_idle;
            end
            else if (!cache_hit) begin
                // Cache缺失，需要进行替换和重填操作
                // TODO(lab3): 写回操作判断，判断何时需要进入miss状态，何时直接进入replace状态
				// 提示：判断是否需要进行写回“内存”操作：
				// - 非缓存写操作直接写回
				// - 普通访问或cacop(1/2)：cache行脏有效 && (普通cache请求 || cacop模式1 || cacop模式2命中)
				if (uncache_wr || ((replace_d && replace_v) && (!request_uncache_en || cacop_op_mode1 || cacop_op_mode2_hit)))
                	main_state <= main_miss;  // 需要写回，进入缺失状态
				else
					main_state <= main_replace;  // 无需写回，直接进入替换状态

                // 保存Tag和相关控制信息
                request_buffer_tag        <= tag;
                request_buffer_uncache_en <= request_uncache_en;
				uncache_wr_buffer         <= uncache_wr;
                miss_buffer_replace_way   <= replace_way;
				cacop_op_mode2_hit_buffer <= cacop_op_mode2_hit;
            end
            else begin
                // Cache命中，返回空闲状态
                main_state <= main_idle;
            end
        end
        main_miss: begin
            // TODO(lab3): 缺失状态等待AXI总线接受写请求
            // 提示：状态转移到replace 并 发起写请求
            // 写请求比较特殊，仅当总线接受写请求后被置高1周期
            if (wr_rdy) begin
                main_state <= main_replace;
				wr_req <= 1'b1;  // 发起写请求
            end
        end
        main_replace: begin
            // TODO(lab3): 替换状态等待AXI总线接受读请求
            // 提示：
            // - 状态转移到refill
            // - 重置返回数据计数器
            // - 清除写请求
            if (rd_rdy) begin
                main_state <= main_refill;
                miss_buffer_ret_num <= 2'b0;   // 重置返回数据计数器
            end
			wr_req <= 1'b0;  // 清除写请求
        end
        main_refill: begin
            // TODO(lab3): 重填状态接收并写入缺失的Cache行数据
            // 提示：
            // - if 接收到最后一个返回数据或无读请求，返回空闲状态
            // - else 接收到有效数据，更新返回数据计数器
            if ((ret_valid && ret_last) || !rd_req_buffer) begin   
                // 接收完所有数据或无读请求，返回空闲状态
                main_state <= main_idle;
            end
            else begin
                // 接收到有效数据，更新返回数据计数器
                if (ret_valid) miss_buffer_ret_num <= ret_num_add_one;
            end
        end
        default: begin
            main_state <= main_idle;
        end
    endcase
end

/*==============================================================================
 * 写缓冲区状态机
 * 处理Cache命中的写操作
 *==============================================================================*/
always @(posedge clk) begin
    if (reset) begin
        write_buffer_state  <= write_buffer_idle;

        write_buffer_index  <= 8'b0;
        write_buffer_wstrb  <= 4'b0;
        write_buffer_wdata  <= 32'b0;
        write_buffer_offset <= 4'b0;
        write_buffer_way    <= 2'b0;
    end
    else case (write_buffer_state)
        write_buffer_idle: begin
            // 空闲状态：检测是否有命中的写操作
            if (main_state_is_lookup && cache_hit && request_buffer_op && !cancel_req) begin
                // 有新的命中写操作，进入写入状态
                write_buffer_state  <= write_buffer_write;

                // 锁存写操作信息
                write_buffer_index  <= request_buffer_index;
                write_buffer_wstrb  <= request_buffer_wstrb;
                write_buffer_wdata  <= request_buffer_wdata;
                write_buffer_offset <= request_buffer_offset;
                write_buffer_way    <= way_hit;  // 命中的路
            end
        end
        write_buffer_write: begin
            // 写入状态：将数据写入Cache或接收新的写操作
            if (main_state_is_lookup && cache_hit && request_buffer_op && !cancel_req) begin
                // 有新的命中写操作，更新写缓冲区
                write_buffer_state  <= write_buffer_write;

                write_buffer_index  <= request_buffer_index;
                write_buffer_wstrb  <= request_buffer_wstrb;
                write_buffer_wdata  <= request_buffer_wdata;
                write_buffer_offset <= request_buffer_offset;
                write_buffer_way    <= way_hit;
            end
            else begin
                // 无新写操作，返回空闲状态
                write_buffer_state <= write_buffer_idle;
            end
        end
    endcase
end

/*==============================================================================
 * 主状态机状态转换控制逻辑
 *==============================================================================*/

// 请求有效信号：普通访问、Cache操作或预取操作
assign req_or_inst_valid = valid || dcacop_op_en || preld_en;

// 空闲->查找状态转换条件
// 不能与写缓冲区的写操作bank冲突
assign main_idle2lookup   = !(write_state_is_full && (write_buffer_offset[3:2] == offset[3:2]));

// Cache空闲信号：仅当主状态机处于空闲状态时为真
assign dcache_empty = main_state_is_idle;

// 查找->查找状态转换条件：命中且无读写bank冲突
assign main_lookup2lookup = !(write_state_is_full && (write_buffer_offset[3:2] == offset[3:2])) && 
                            !(request_buffer_op && (request_buffer_offset[3:2] == offset[3:2])) &&
                            cache_hit;
 
// 地址传输完成信号：可以接收新请求
assign addr_ok = (main_state_is_idle && main_idle2lookup) || (main_state_is_lookup && main_lookup2lookup);

// 普通非缓存访问判断
assign request_uncache_en = (uncache_en && !request_buffer_dcacop);

// 非缓存写操作判断
assign uncache_wr = request_uncache_en && request_buffer_op;

/*==============================================================================
 * Tag比较和Cache命中判断逻辑
 *==============================================================================*/

// 各路Tag比较：比较读出的Tag与锁存的物理地址Tag
generate for(i=0;i<2;i=i+1) begin:gen_way_hit
	assign way_hit[i] = way_tagv_douta[i][0] && (tag == way_tagv_douta[i][20:1]); 
end endgenerate

// 普通Cache命中判断：任一路命中且非uncache和cacop
assign cache_hit = |way_hit && !(uncache_en || request_buffer_dcacop);  

/*==============================================================================
 * 数据选择逻辑
 *==============================================================================*/

// 从各路Cache行中选择对应偏移的32位数据
generate for(i=0;i<2;i=i+1) begin:gen_way_data
	// 将4个Bank的数据拼接成完整的128位Cache行
	assign way_data[i] = {way_bank_douta[i][3],way_bank_douta[i][2],way_bank_douta[i][1],way_bank_douta[i][0]};

	// 根据偏移选择对应的32位数据
	assign way_load_word[i] = way_data[i][request_buffer_offset[3:2]*32 +: 32];
end endgenerate

// 根据命中路选择最终的读数据
assign load_res = {32{way_hit[0]}} & way_load_word[0] |
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
                     {2{!request_buffer_dcacop}}           & rand_repl_way;          // 随机路

// 当前访问地址的Dirty位（考虑写缓冲区影响）
assign way_d = way_d_reg[request_buffer_index] |
	           {2{(write_buffer_index==request_buffer_index)&&write_state_is_full}}&write_buffer_way;

// 替换Cache行的属性
assign replace_d    = |(replace_way & way_d);                                      // Dirty位
assign replace_v    = |(replace_way & {way_tagv_douta[1][0],way_tagv_douta[0][0]});  // Valid位

/*==============================================================================
 * AXI写请求接口逻辑（MISS状态）
 *==============================================================================*/

// 替换Cache行的Tag和数据选择，即计算要替换的Cache行的Tag和数据，写回内存
assign replace_tag  = {20{miss_buffer_replace_way[0]}} & way_tagv_douta[0][20:1] |
					  {20{miss_buffer_replace_way[1]}} & way_tagv_douta[1][20:1] ;

assign replace_data = {128{miss_buffer_replace_way[0]}} & way_data[0] | 
				      {128{miss_buffer_replace_way[1]}} & way_data[1] ;

// 写请求类型：非缓存写或Cache行写回
assign wr_type  = uncache_wr_buffer ? uncache_wr_type : 3'b100;

// 写请求地址
assign wr_addr  = uncache_wr_buffer ? {request_buffer_tag, request_buffer_index, request_buffer_offset} :
 	                                  {replace_tag, request_buffer_index, 4'b0};

// 写数据：非缓存写的单字数据或完整Cache行数据                                  
assign wr_data  = uncache_wr_buffer ? {96'b0, request_buffer_wdata} : replace_data;

// 写字节掩码
assign wr_wstrb = uncache_wr_buffer ? request_buffer_wstrb : 4'hf;

/*==============================================================================
 * AXI读请求接口逻辑（REPLACE状态）
 *==============================================================================*/

// 非缓存写请求类型
assign uncache_wr_type = request_buffer_size;

// 读请求：非特定操作模式下发起读请求
assign rd_req  = main_state_is_replace && !(uncache_wr_buffer || request_buffer_dcacop);

// 读请求类型：非缓存访问按原始大小，缓存访问按Cache行大小
assign rd_type = request_buffer_uncache_en ? request_buffer_size : 3'b100;

// 读请求地址
assign rd_addr = request_buffer_uncache_en ? {request_buffer_tag, request_buffer_index, request_buffer_offset} : 
                                             {request_buffer_tag, request_buffer_index, 4'b0};
/*==============================================================================
 * 数据传输完成和重填逻辑（REFILL状态）
 *==============================================================================*/

// TODO(lab3): 数据传输完成信号
// 提示：根据主状态机状态和请求缓冲区操作判断是否从cache中读出有效数据
// - 命中情况：查找状态且命中，或写操作，或取消请求
// - 缺失情况：重填状态且接收到对应偏移的数据
// - 全局条件：未进行预取或cacop操作
assign data_ok = ((main_state_is_lookup && (cache_hit || request_buffer_op || cancel_req)) || 
                  (main_state_is_refill && (!request_buffer_op && (ret_valid && ((miss_buffer_ret_num == request_buffer_offset[3:2]) || request_buffer_uncache_en))))) && 
                  !(request_buffer_preld || request_buffer_dcacop);

// TODO(lab3): 写入数据合并
// 提示：将写数据与返回数据按字节掩码合并
assign write_in = {(request_buffer_wstrb[3] ? request_buffer_wdata[31:24] : ret_data[31:24]), 
                   (request_buffer_wstrb[2] ? request_buffer_wdata[23:16] : ret_data[23:16]),
                   (request_buffer_wstrb[1] ? request_buffer_wdata[15: 8] : ret_data[15: 8]),
                   (request_buffer_wstrb[0] ? request_buffer_wdata[ 7: 0] : ret_data[ 7: 0])};

// TODO(lab3): 重填数据选择
// 提示：写操作且偏移匹配时使用合并数据，否则使用返回数据
assign refill_data = (request_buffer_op && (request_buffer_offset[3:2] == miss_buffer_ret_num)) ? write_in : ret_data; 

// TODO(lab3): 路写使能
// 提示：返回数据有效时写入对应的替换路
assign way_wr_en = miss_buffer_replace_way & {2{ret_valid}};

// Cache缺失信号(for perf log)
assign cache_miss = main_state_is_refill && ret_last && !(request_buffer_uncache_en || request_buffer_dcacop || request_buffer_preld);  

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
 * Dirty位寄存器更新逻辑
 *==============================================================================*/
always @(posedge clk) begin
    // 重填完成时更新Dirty位
    if (main_state_is_refill && ((ret_valid && ret_last) || !rd_req_buffer) && (!(request_buffer_uncache_en || cacop_op_mode0))) begin
		// 对替换路refill：写操作设置Dirty位，读操作清除Dirty位
		way_d_reg[request_buffer_index][0] <= miss_buffer_replace_way[0] ? request_buffer_op : way_d_reg[request_buffer_index][0];
		way_d_reg[request_buffer_index][1] <= miss_buffer_replace_way[1] ? request_buffer_op : way_d_reg[request_buffer_index][1];
    end
    // 写命中时设置对应路的Dirty位
    else if (write_state_is_full) begin
		way_d_reg[write_buffer_index] <= way_d_reg[write_buffer_index] | write_buffer_way;
    end
end

/*==============================================================================
 * Cache操作控制信号
 *==============================================================================*/
// Cache操作模式判断
assign cacop_op_mode0 = request_buffer_dcacop && (request_buffer_cacop_op_mode == 2'b00);
assign cacop_op_mode1 = request_buffer_dcacop && ((request_buffer_cacop_op_mode == 2'b01) || (request_buffer_cacop_op_mode == 2'b11));
assign cacop_op_mode2 = request_buffer_dcacop && (request_buffer_cacop_op_mode == 2'b10);

// Cache操作模式2的命中写操作
assign cacop_op_mode2_hit = cacop_op_mode2 && |way_hit;

/*==============================================================================
 * 输出数据选择
 *==============================================================================*/
// TODO(lab3): 读数据输出
// 提示：查找状态返回命中数据，重填状态返回AXI数据
assign rdata = {32{main_state_is_lookup}} & load_res |
               {32{main_state_is_refill}} & ret_data ;

/*==============================================================================
 * Data Bank RAM控制逻辑生成
 * 每路4个Bank，每个Bank存储32位数据，支持字节级写使能
 *==============================================================================*/
generate 
for(i=0;i<2;i=i+1) begin:gen_data_way  // i遍历way
	for(j=0;j<4;j=j+1) begin:gen_data_bank  // j遍历bank

/*===============================Bank地址逻辑=================================*/
		// TODO(lab3): 写bank选择
        // 提示：写缓冲区操作与当前Bank匹配
		assign wr_match_way_bank[i][j] = write_state_is_full && (write_buffer_way[i] && (write_buffer_offset[3:2] == j[1:0]));

		// TODO(lab3): Bank地址选择
        // 提示：
        // - 写缓冲区匹配时使用写缓冲区索引
        // - Look Up阶段查询数据时使用输入地址索引
        // - 其他阶段使用请求缓冲区索引
		assign way_bank_addra[i][j] = wr_match_way_bank[i][j] ? write_buffer_index :  // write_buffer写入
		                              addr_ok                 ? index              :  // Look Up阶段查询数据
						                                        request_buffer_index; // 其他阶段

/*===============================Bank写使能逻辑===============================*/
		// TODO(lab3): 写使能
        // 提示：写缓冲区匹配时使用缓冲区写使能，重填时全字写入
		assign way_bank_wea[i][j] = {4{wr_match_way_bank[i][j]}} & write_buffer_wstrb | 
									{4{main_state_is_refill && (way_wr_en[i] && (miss_buffer_ret_num == j[1:0]))}} & 4'hf;

/*===============================Bank写数据逻辑===============================*/
		// TODO(lab3): 写数据
        // 提示：写缓冲区数据或重填数据
		assign way_bank_dina[i][j] = {32{write_state_is_full}}  & write_buffer_wdata |
                                     {32{main_state_is_refill}} & refill_data        ;

/*===============================Bank使能逻辑=================================*/
		// TODO(lab3): Bank使能
        // 非缓存访问和特定Cache操作时禁用，其他情况使能
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
	// 地址选择：Look Up阶段使用输入地址，其他阶段使用缓冲区地址
	assign way_tagv_addra[i] = {8{addr_ok }} & index                |
	                           {8{!addr_ok}} & request_buffer_index ; 

/*===============================TagV使能逻辑=================================*/
	// 使能控制：缓存访问 或 idle/lookup阶段启用
	assign way_tagv_ena[i] = (!request_buffer_uncache_en) || main_state_is_idle || main_state_is_lookup;

/*===============================TagV写使能逻辑===============================*/
	// 写使能：重填完成或Cache操作时写入
	assign way_tagv_wea[i] = miss_buffer_replace_way[i] && main_state_is_refill &&
		                     ((ret_valid && ret_last) || cacop_op_mode0 || cacop_op_mode1 || cacop_op_mode2_hit_buffer);

/*===============================TagV写数据逻辑===============================*/
	// 写数据：Cache操作时写入全0（无效），否则写入Tag和Valid=1
	assign way_tagv_dina[i] = (cacop_op_mode0 || cacop_op_mode1 || cacop_op_mode2_hit_buffer) ? 21'b0 : 
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
    		.addra      (way_bank_addra[i][j]),  // 地址输入
    		.clka       (clk                 ),  // 时钟输入
    		.dina       (way_bank_dina[i][j] ),  // 写数据输入
    		.douta      (way_bank_douta[i][j]),  // 读数据输出
    		.ena        (way_bank_ena[i][j]  ),  // 使能输入
    		.wea        (way_bank_wea[i][j]  )   // 写使能输入（字节级）
		);
	end
end
endgenerate

// Tag+Valid RAM实例化：每路一个，共2个RAM实例
generate
for(i=0;i<2;i=i+1) begin:tagv_ram_way
	// [20:1] Tag域     [0:0] Valid域
	tagv_sram u( 
	    .addra      (way_tagv_addra[i]),     // 地址输入
	    .clka       (clk              ),     // 时钟输入
	    .dina       (way_tagv_dina[i] ),     // 写数据输入
	    .douta      (way_tagv_douta[i]),     // 读数据输出
	    .ena        (way_tagv_ena[i]  ),     // 使能输入
	    .wea        (way_tagv_wea[i]  )      // 写使能输入
	);
end
endgenerate

// 伪随机数生成器：用于替换算法
lfsr lfsr(
    .clk        (clk        ),               // 时钟输入
    .reset      (reset      ),               // 复位输入
    .random_val (random_val )                // 随机数输出
);

/*==============================================================================
 * 状态机状态指示信号
 *==============================================================================*/
// 主状态机状态判断
assign main_state_is_idle    = main_state == main_idle   ;  // 空闲状态
assign main_state_is_lookup  = main_state == main_lookup ;  // 查找状态
assign main_state_is_miss    = main_state == main_miss   ;  // 缺失状态
assign main_state_is_replace = main_state == main_replace;  // 替换状态
assign main_state_is_refill  = main_state == main_refill ;  // 重填状态

// 写缓冲区状态判断
assign write_state_is_idle  = (write_buffer_state == write_buffer_idle) ;  // 写缓冲区空闲
assign write_state_is_full = (write_buffer_state == write_buffer_write);   // 写缓冲区有待写数据

endmodule


