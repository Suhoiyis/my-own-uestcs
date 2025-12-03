/**
 * LoongArch TLB表项模块 (Translation Lookaside Buffer Entry)
 * 
 * 功能说明：
 * - 实现TLB表项的存储和查找功能
 * - 支持双端口并发查找（指令和数据）
 * - 支持TLB表项的读写操作
 * - 支持多种TLB无效化操作
 * - 支持4KB和大页(2MB/1GB)的页大小
 * - 每个TLB表项包含奇偶两个页的信息
 */
module tlb_entry
#(
    parameter TLBNUM = 32  // TLB表项数量，默认32项
)
(
    input        clk,  // 时钟信号
    
    // 查找端口0 (通常用于指令地址转换)
    input                        s0_fetch    ,  // 查找请求信号
    input   [18:0]               s0_vppn     ,  // 虚拟页号 (Virtual Page Number)
    input                        s0_odd_page ,  // 奇偶页选择 (0=偶数页, 1=奇数页)
    input   [ 9:0]               s0_asid     ,  // 地址空间标识符
    output                       s0_found    ,  // 查找命中标志
    output  [ 4:0]               s0_index    ,  // 命中的TLB表项索引
    output  [ 5:0]               s0_ps       ,  // 页大小 (12=4KB, 21=2MB, 30=1GB)
    output  [19:0]               s0_ppn      ,  // 物理页号 (Physical Page Number)
    output                       s0_v        ,  // 有效位 (Valid)
    output                       s0_d        ,  // 脏位 (Dirty)
    output  [ 1:0]               s0_mat      ,  // 内存访问类型 (Memory Access Type)
    output  [ 1:0]               s0_plv      ,  // 特权等级 (Privilege Level)
    
    // 查找端口1 (通常用于数据地址转换)
    input                        s1_fetch    ,  // 查找请求信号
    input   [18:0]               s1_vppn     ,  // 虚拟页号
    input                        s1_odd_page ,  // 奇偶页选择
    input   [ 9:0]               s1_asid     ,  // 地址空间标识符
    output                       s1_found    ,  // 查找命中标志
    output  [ 4:0]               s1_index    ,  // 命中的TLB表项索引
    output  [ 5:0]               s1_ps       ,  // 页大小
    output  [19:0]               s1_ppn      ,  // 物理页号
    output                       s1_v        ,  // 有效位
    output                       s1_d        ,  // 脏位
    output  [ 1:0]               s1_mat      ,  // 内存访问类型
    output  [ 1:0]               s1_plv      ,  // 特权等级
    
    // TLB写入端口 (TLBFILL/TLBWR指令使用)
    input                       we          ,  // 写使能
    input  [$clog2(TLBNUM)-1:0] w_index     ,  // 写入的表项索引
    input  [18:0]               w_vppn      ,  // 写入的虚拟页号
    input  [ 9:0]               w_asid      ,  // 写入的地址空间标识符
    input                       w_g         ,  // 全局标志位 (Global)
    input  [ 5:0]               w_ps        ,  // 写入的页大小
    input                       w_e         ,  // 表项存在标志 (Entry exists)
    input                       w_v0        ,  // 偶数页有效位
    input                       w_d0        ,  // 偶数页脏位
    input  [ 1:0]               w_mat0      ,  // 偶数页内存访问类型
    input  [ 1:0]               w_plv0      ,  // 偶数页特权等级
    input  [19:0]               w_ppn0      ,  // 偶数页物理页号
    input                       w_v1        ,  // 奇数页有效位
    input                       w_d1        ,  // 奇数页脏位
    input  [ 1:0]               w_mat1      ,  // 奇数页内存访问类型
    input  [ 1:0]               w_plv1      ,  // 奇数页特权等级
    input  [19:0]               w_ppn1      ,  // 奇数页物理页号
    
    // TLB读取端口 (TLBR指令使用)
    input  [$clog2(TLBNUM)-1:0] r_index     ,  // 读取的表项索引
    output [18:0]               r_vppn      ,  // 读取的虚拟页号
    output [ 9:0]               r_asid      ,  // 读取的地址空间标识符
    output                      r_g         ,  // 读取的全局标志位
    output [ 5:0]               r_ps        ,  // 读取的页大小
    output                      r_e         ,  // 读取的表项存在标志
    output                      r_v0        ,  // 读取的偶数页有效位
    output                      r_d0        ,  // 读取的偶数页脏位
    output [ 1:0]               r_mat0      ,  // 读取的偶数页内存访问类型
    output [ 1:0]               r_plv0      ,  // 读取的偶数页特权等级
    output [19:0]               r_ppn0      ,  // 读取的偶数页物理页号
    output                      r_v1        ,  // 读取的奇数页有效位
    output                      r_d1        ,  // 读取的奇数页脏位
    output [ 1:0]               r_mat1      ,  // 读取的奇数页内存访问类型
    output [ 1:0]               r_plv1      ,  // 读取的奇数页特权等级
    output [19:0]               r_ppn1      ,  // 读取的奇数页物理页号
    
    // TLB无效化端口 (INVTLB指令使用)
    input                       inv_en      ,  // 无效化使能
    input  [ 4:0]               inv_op      ,  // 无效化操作类型
    input  [ 9:0]               inv_asid    ,  // 无效化的地址空间标识符
    input  [18:0]               inv_vpn        // 无效化的虚拟页号
);

/**
 * TLB表项存储数组
 * LoongArch TLB每个表项包含一个虚拟页对应的两个物理页(奇偶页)
 */
reg [18:0] tlb_vppn     [TLBNUM-1:0];  // 虚拟页号数组
reg        tlb_e        [TLBNUM-1:0];  // 表项存在标志数组
reg [ 9:0] tlb_asid     [TLBNUM-1:0];  // 地址空间标识符数组
reg        tlb_g        [TLBNUM-1:0];  // 全局标志位数组
reg [ 5:0] tlb_ps       [TLBNUM-1:0];  // 页大小数组
// 偶数页 (页号最低位为0)
reg [19:0] tlb_ppn0     [TLBNUM-1:0];  // 偶数页物理页号数组
reg [ 1:0] tlb_plv0     [TLBNUM-1:0];  // 偶数页特权等级数组
reg [ 1:0] tlb_mat0     [TLBNUM-1:0];  // 偶数页内存访问类型数组
reg        tlb_d0       [TLBNUM-1:0];  // 偶数页脏位数组
reg        tlb_v0       [TLBNUM-1:0];  // 偶数页有效位数组
// 奇数页 (页号最低位为1)
reg [19:0] tlb_ppn1     [TLBNUM-1:0];  // 奇数页物理页号数组
reg [ 1:0] tlb_plv1     [TLBNUM-1:0];  // 奇数页特权等级数组
reg [ 1:0] tlb_mat1     [TLBNUM-1:0];  // 奇数页内存访问类型数组
reg        tlb_d1       [TLBNUM-1:0];  // 奇数页脏位数组
reg        tlb_v1       [TLBNUM-1:0];  // 奇数页有效位数组

/**
 * 查找请求缓存寄存器
 * 用于流水线处理，在时钟上升沿缓存查找请求
 */
reg		   s0_fetch_r   ;  // 端口0查找请求缓存
reg [18:0] s0_vppn_r    ;  // 端口0虚拟页号缓存
reg        s0_odd_page_r;  // 端口0奇偶页标志缓存
reg [ 9:0] s0_asid_r    ;  // 端口0地址空间标识符缓存
reg		   s1_fetch_r   ;  // 端口1查找请求缓存
reg [18:0] s1_vppn_r    ;  // 端口1虚拟页号缓存
reg        s1_odd_page_r;  // 端口1奇偶页标志缓存
reg [ 9:0] s1_asid_r    ;  // 端口1地址空间标识符缓存

/**
 * TLB匹配和编码信号
 */
wire [TLBNUM-1:0] match0;     // 端口0匹配结果向量
wire [TLBNUM-1:0] match1;     // 端口1匹配结果向量

wire [$clog2(TLBNUM)-1:0] match0_en;  // 端口0匹配索引编码
wire [$clog2(TLBNUM)-1:0] match1_en;  // 端口1匹配索引编码

wire [TLBNUM-1:0] s0_odd_page_buffer;  // 端口0奇偶页选择缓存
wire [TLBNUM-1:0] s1_odd_page_buffer;  // 端口1奇偶页选择缓存

/**
 * 查找请求流水线寄存器
 * 在fetch信号有效时缓存查找参数，实现流水线处理
 */
always @(posedge clk) begin
	s0_fetch_r <= s0_fetch;  // 缓存端口0查找请求
	if (s0_fetch) begin
		s0_vppn_r      <= s0_vppn;     // 缓存虚拟页号
        s0_odd_page_r  <= s0_odd_page; // 缓存奇偶页标志
        s0_asid_r      <= s0_asid;     // 缓存地址空间标识符
	end
	s1_fetch_r <= s1_fetch;  // 缓存端口1查找请求
	if (s1_fetch) begin
		s1_vppn_r      <= s1_vppn;     // 缓存虚拟页号
        s1_odd_page_r  <= s1_odd_page; // 缓存奇偶页标志
        s1_asid_r      <= s1_asid;     // 缓存地址空间标识符
	end
end

/**
 * TLB匹配逻辑
 * 对每个TLB表项并行进行匹配检查
 */
genvar i;
generate
    for (i = 0; i < TLBNUM; i = i + 1)
        begin: match
            // TODO(lab4): 端口0奇偶页选择逻辑
            // 提示：对于4KB页面(ps=12)，使用输入的odd_page；对于大页面，使用vppn[8]
            assign s0_odd_page_buffer[i] = (tlb_ps[i] == 6'd12) ? s0_odd_page_r : s0_vppn_r[8];
            
            // TODO(lab4): 端口0匹配
            // 提示（匹配条件）：
            // 1. 表项存在 (tlb_e[i])
            // 2. 虚拟页号匹配：4KB页完全匹配or大页面(4MB)匹配
            // 3. ASID匹配或全局页面
            assign match0[i] = tlb_e[i] && 
                              ((tlb_ps[i] == 6'd12) ? s0_vppn_r == tlb_vppn[i] : s0_vppn_r[18: 9] == tlb_vppn[i][18: 9]) && 
                              ((s0_asid_r == tlb_asid[i]) || tlb_g[i]);
            
            // TODO(lab4): 端口1奇偶页选择逻辑
            assign s1_odd_page_buffer[i] = (tlb_ps[i] == 6'd12) ? s1_odd_page_r : s1_vppn_r[8];
            
            // TODO(lab4): 端口1匹配条件（同端口0）
            assign match1[i] = tlb_e[i] && 
                              ((tlb_ps[i] == 6'd12) ? s1_vppn_r == tlb_vppn[i] : s1_vppn_r[18: 9] == tlb_vppn[i][18: 9]) && 
                              ((s1_asid_r == tlb_asid[i]) || tlb_g[i]);
        end
endgenerate

/**
 * 匹配结果编码
 * 将匹配向量编码为索引，用于后续的数据选择
 */
encoder_32_5 en_match0 (.in({{(32-TLBNUM){1'b0}},match0}), .out(match0_en));  // 端口0匹配编码
encoder_32_5 en_match1 (.in({{(32-TLBNUM){1'b0}},match1}), .out(match1_en));  // 端口1匹配编码

/**
 * 端口0查找结果输出
 * 根据匹配结果选择对应的TLB表项数据
 */
assign s0_found = |match0;  // 查找命中标志：任意表项匹配即为命中
assign s0_index = {{(5-$clog2(TLBNUM)){1'b0}},match0_en};  // 命中表项索引
assign s0_ps    = tlb_ps[match0_en];    // 页大小
// 根据奇偶页选择对应的物理页号和属性
assign s0_ppn   = s0_odd_page_buffer[match0_en] ? tlb_ppn1[match0_en] : tlb_ppn0[match0_en];    // 物理页号
assign s0_v     = s0_odd_page_buffer[match0_en] ? tlb_v1[match0_en]   : tlb_v0[match0_en]  ;    // 有效位
assign s0_d     = s0_odd_page_buffer[match0_en] ? tlb_d1[match0_en]   : tlb_d0[match0_en]  ;    // 脏位
assign s0_mat   = s0_odd_page_buffer[match0_en] ? tlb_mat1[match0_en] : tlb_mat0[match0_en];    // 内存访问类型
assign s0_plv   = s0_odd_page_buffer[match0_en] ? tlb_plv1[match0_en] : tlb_plv0[match0_en];    // 特权等级

/**
 * 端口1查找结果输出
 * 逻辑同端口0
 */
assign s1_found = |match1;  // 查找命中标志
assign s1_index = {{(5-$clog2(TLBNUM)){1'b0}},match1_en};  // 命中表项索引
assign s1_ps    = tlb_ps[match1_en];    // 页大小
// 根据奇偶页选择对应的物理页号和属性
assign s1_ppn   = s1_odd_page_buffer[match1_en] ? tlb_ppn1[match1_en] : tlb_ppn0[match1_en];    // 物理页号
assign s1_v     = s1_odd_page_buffer[match1_en] ? tlb_v1[match1_en]   : tlb_v0[match1_en]  ;    // 有效位
assign s1_d     = s1_odd_page_buffer[match1_en] ? tlb_d1[match1_en]   : tlb_d0[match1_en]  ;    // 脏位
assign s1_mat   = s1_odd_page_buffer[match1_en] ? tlb_mat1[match1_en] : tlb_mat0[match1_en];    // 内存访问类型
assign s1_plv   = s1_odd_page_buffer[match1_en] ? tlb_plv1[match1_en] : tlb_plv0[match1_en];    // 特权等级

/**
 * TLB表项写入逻辑
 * TLBFILL和TLBWR指令使用此端口写入TLB表项
 * 注意：tlb_e(表项存在标志)在后面的无效化逻辑中单独处理
 */
always @(posedge clk) begin
    if (we) begin
        tlb_vppn [w_index] <= w_vppn;   // 写入虚拟页号
        tlb_asid [w_index] <= w_asid;   // 写入地址空间标识符
        tlb_g    [w_index] <= w_g;      // 写入全局标志位
        tlb_ps   [w_index] <= w_ps;     // 写入页大小
        // 偶数页信息
        tlb_ppn0 [w_index] <= w_ppn0;   // 偶数页物理页号
        tlb_plv0 [w_index] <= w_plv0;   // 偶数页特权等级
        tlb_mat0 [w_index] <= w_mat0;   // 偶数页内存访问类型
        tlb_d0   [w_index] <= w_d0;     // 偶数页脏位
        tlb_v0   [w_index] <= w_v0;     // 偶数页有效位
        // 奇数页信息
        tlb_ppn1 [w_index] <= w_ppn1;   // 奇数页物理页号
        tlb_plv1 [w_index] <= w_plv1;   // 奇数页特权等级
        tlb_mat1 [w_index] <= w_mat1;   // 奇数页内存访问类型
        tlb_d1   [w_index] <= w_d1;     // 奇数页脏位
        tlb_v1   [w_index] <= w_v1;     // 奇数页有效位
    end
end

/**
 * TLB读取端口输出
 * TLBR指令使用此端口读取指定索引的TLB表项
 */
assign r_vppn  =  tlb_vppn [r_index];  // 读取虚拟页号
assign r_asid  =  tlb_asid [r_index];  // 读取地址空间标识符
assign r_g     =  tlb_g    [r_index];  // 读取全局标志位
assign r_ps    =  tlb_ps   [r_index];  // 读取页大小
assign r_e     =  tlb_e    [r_index];  // 读取表项存在标志
// 偶数页信息读取
assign r_v0    =  tlb_v0   [r_index];  // 偶数页有效位
assign r_d0    =  tlb_d0   [r_index];  // 偶数页脏位
assign r_mat0  =  tlb_mat0 [r_index];  // 偶数页内存访问类型
assign r_plv0  =  tlb_plv0 [r_index];  // 偶数页特权等级
assign r_ppn0  =  tlb_ppn0 [r_index];  // 偶数页物理页号
// 奇数页信息读取
assign r_v1    =  tlb_v1   [r_index];  // 奇数页有效位
assign r_d1    =  tlb_d1   [r_index];  // 奇数页脏位
assign r_mat1  =  tlb_mat1 [r_index];  // 奇数页内存访问类型
assign r_plv1  =  tlb_plv1 [r_index];  // 奇数页特权等级
assign r_ppn1  =  tlb_ppn1 [r_index];  // 奇数页物理页号 

/**
 * TODO(lab4): TLB表项无效化逻辑
 * INVTLB指令支持多种无效化操作，通过设置tlb_e为0来标记表项无效
 * 
 * LoongArch INVTLB操作类型：
 * - op=0/1: 无效化所有表项
 * - op=2: 无效化所有全局表项  
 * - op=3: 无效化所有非全局表项
 * - op=4: 无效化指定ASID的非全局表项
 * - op=5: 无效化指定ASID和VPN的非全局表项
 * - op=6: 无效化指定VPN的表项(不区分ASID和全局标志)
 */
generate 
    for (i = 0; i < TLBNUM; i = i + 1) 
        begin: invalid_tlb_entry 
            always @(posedge clk) begin
                if (we && (w_index == i)) begin
                    // 写入操作：设置表项存在标志
                    tlb_e[i] <= w_e;
                end
                else if (inv_en) begin
                    // 无效化操作：根据操作类型决定是否清除表项
                    if (inv_op == 5'd0 || inv_op == 5'd1) begin
                        // TODO(lab4): 无效化所有表项
                        tlb_e[i] <= 1'b0;
                    end
                    else if (inv_op == 5'd2) begin
                        // TODO(lab4): 无效化所有全局表项
                        if (tlb_g[i]) begin
                            tlb_e[i] <= 1'b0;
                        end
                    end
                    else if (inv_op == 5'd3) begin
                        // TODO(lab4): 无效化所有非全局表项
                        if (!tlb_g[i]) begin
                            tlb_e[i] <= 1'b0;
                        end
                    end
                    else if (inv_op == 5'd4) begin
                        // TODO(lab4): 无效化指定ASID的非全局表项
                        if (!tlb_g[i] && (tlb_asid[i] == inv_asid)) begin
                            tlb_e[i] <= 1'b0;
                        end
                    end
                    else if (inv_op == 5'd5) begin
                        // TODO(lab4): 无效化指定ASID和VPN的非全局表项
                        if (!tlb_g[i] && (tlb_asid[i] == inv_asid) && 
                           ((tlb_ps[i] == 6'd12) ? (tlb_vppn[i] == inv_vpn) : (tlb_vppn[i][18:9] == inv_vpn[18:9]))) begin
                            tlb_e[i] <= 1'b0;
                        end
                    end
                    else if (inv_op == 5'd6) begin
                        // TODO(lab4): 无效化指定VPN的表项(全局或匹配ASID)
                        if ((tlb_g[i] || (tlb_asid[i] == inv_asid)) && 
                           ((tlb_ps[i] == 6'd12) ? (tlb_vppn[i] == inv_vpn) : (tlb_vppn[i][18:9] == inv_vpn[18:9]))) begin
                            tlb_e[i] <= 1'b0;
                        end
                    end
                end
            end
        end 
endgenerate

endmodule
