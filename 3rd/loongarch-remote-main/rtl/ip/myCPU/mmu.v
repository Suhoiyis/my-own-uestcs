`include "csr.vh"

/**
 * LoongArch地址转换模块 (Address Translation Unit)
 * 
 * 功能说明：
 * - 负责虚拟地址到物理地址的转换
 * - 支持TLB(Translation Lookaside Buffer)查找
 * - 支持直接映射窗口(DMW)转换
 * - 处理指令地址转换和数据地址转换
 * - 支持TLB的读写和无效化操作
 */
module mmu
#(
    parameter TLBNUM = 32  // TLB表项数量
)
(
    input                  clk                  ,  // 时钟信号
    input  [ 9:0]          asid                 ,  // 地址空间标识符(Address Space Identifier)
    
    // 指令地址转换接口
    input                  inst_fetch           ,  // 指令取址请求
    input  [31:0]          inst_vaddr           ,  // 指令虚拟地址
    input                  inst_dmw0_en         ,  // 指令DMW0使能
    input                  inst_dmw1_en         ,  // 指令DMW1使能
    output [ 7:0]          inst_index           ,  // 指令缓存索引
    output [19:0]          inst_tag             ,  // 指令缓存标签
    output [ 3:0]          inst_offset          ,  // 指令缓存偏移
    output                 inst_tlb_found       ,  // 指令TLB命中标志
    output                 inst_tlb_v           ,  // 指令TLB有效位
    output                 inst_tlb_d           ,  // 指令TLB脏位
    output [ 1:0]          inst_tlb_mat         ,  // 指令TLB内存访问类型
    output [ 1:0]          inst_tlb_plv         ,  // 指令TLB特权等级
    
    // 数据地址转换接口
    input                  data_fetch           ,  // 数据访问请求
    input  [31:0]          data_vaddr           ,  // 数据虚拟地址
    input                  data_dmw0_en         ,  // 数据DMW0使能
    input                  data_dmw1_en         ,  // 数据DMW1使能
    input                  cacop_op_mode_di     ,  // Cache操作直接索引模式
    output [ 7:0]          data_index           ,  // 数据缓存索引
    output [19:0]          data_tag             ,  // 数据缓存标签
    output [ 3:0]          data_offset          ,  // 数据缓存偏移
    output                 data_tlb_found       ,  // 数据TLB命中标志
    output [ 4:0]          data_tlb_index       ,  // 数据TLB索引
    output                 data_tlb_v           ,  // 数据TLB有效位
    output                 data_tlb_d           ,  // 数据TLB脏位
    output [ 1:0]          data_tlb_mat         ,  // 数据TLB内存访问类型
    output [ 1:0]          data_tlb_plv         ,  // 数据TLB特权等级
    
    // TLB写入接口 (TLBFILL/TLBWR指令)
    input                  tlbfill_en           ,  // TLBFILL使能
    input                  tlbwr_en             ,  // TLBWR使能
    input  [ 4:0]          rand_index           ,  // 随机索引
    input  [31:0]          tlbehi_in            ,  // TLB高位寄存器输入
    input  [31:0]          tlbelo0_in           ,  // TLB偶数页寄存器输入
    input  [31:0]          tlbelo1_in           ,  // TLB奇数页寄存器输入
    input  [31:0]          tlbidx_in            ,  // TLB索引寄存器输入
    input  [ 5:0]          ecode_in             ,  // 异常编码
    
    // TLB读取接口 (TLBR指令)
    output [31:0]          tlbehi_out           ,  // TLB高位寄存器输出
    output [31:0]          tlbelo0_out          ,  // TLB偶数页寄存器输出
    output [31:0]          tlbelo1_out          ,  // TLB奇数页寄存器输出
    output [31:0]          tlbidx_out           ,  // TLB索引寄存器输出
    output [ 9:0]          asid_out             ,  // ASID输出
    
    // TLB无效化接口 (INVTLB指令)
    input                  invtlb_en            ,  // INVTLB使能
    input  [ 9:0]          invtlb_asid          ,  // 无效化ASID
    input  [18:0]          invtlb_vpn           ,  // 无效化虚拟页号
    input  [ 4:0]          invtlb_op            ,  // 无效化操作类型
    
    // CSR寄存器接口
    input  [31:0]          csr_dmw0             ,  // 直接映射窗口0配置
    input  [31:0]          csr_dmw1             ,  // 直接映射窗口1配置
    input                  csr_da               ,  // 直接地址转换模式
    input                  csr_pg               // 分页模式
);

// TLB查找端口0信号 (指令地址转换)
wire [18:0] s0_vppn     ;  // 虚拟页号
wire        s0_odd_page ;  // 奇偶页标志
wire [ 5:0] s0_ps       ;  // 页大小
wire [19:0] s0_ppn      ;  // 物理页号

// TLB查找端口1信号 (数据地址转换)
wire [18:0] s1_vppn     ;  // 虚拟页号
wire        s1_odd_page ;  // 奇偶页标志
wire [ 5:0] s1_ps       ;  // 页大小
wire [19:0] s1_ppn      ;  // 物理页号

// TLB写入端口信号
wire        we          ;  // 写使能
wire [ 4:0] w_index     ;  // 写入索引
wire [18:0] w_vppn      ;  // 写入虚拟页号
wire        w_g         ;  // 全局标志
wire [ 5:0] w_ps        ;  // 页大小
wire        w_e         ;  // 表项存在标志
wire        w_v0        ;  // 偶数页有效位
wire        w_d0        ;  // 偶数页脏位
wire [ 1:0] w_mat0      ;  // 偶数页内存访问类型
wire [ 1:0] w_plv0      ;  // 偶数页特权等级
wire [19:0] w_ppn0      ;  // 偶数页物理页号
wire        w_v1        ;  // 奇数页有效位
wire        w_d1        ;  // 奇数页脏位
wire [ 1:0] w_mat1      ;  // 奇数页内存访问类型
wire [ 1:0] w_plv1      ;  // 奇数页特权等级
wire [19:0] w_ppn1      ;  // 奇数页物理页号

// TLB读取端口信号
wire [ 4:0] r_index     ;  // 读取索引
wire [18:0] r_vppn      ;  // 读取虚拟页号
wire [ 9:0] r_asid      ;  // 读取ASID
wire        r_g         ;  // 全局标志
wire [ 5:0] r_ps        ;  // 页大小
wire        r_e         ;  // 表项存在标志
wire        r_v0        ;  // 偶数页有效位
wire        r_d0        ;  // 偶数页脏位
wire [ 1:0] r_mat0      ;  // 偶数页内存访问类型
wire [ 1:0] r_plv0      ;  // 偶数页特权等级
wire [19:0] r_ppn0      ;  // 偶数页物理页号
wire        r_v1        ;  // 奇数页有效位
wire        r_d1        ;  // 奇数页脏位
wire [ 1:0] r_mat1      ;  // 奇数页内存访问类型
wire [ 1:0] r_plv1      ;  // 奇数页特权等级
wire [19:0] r_ppn1      ;  // 奇数页物理页号

// 虚拟地址缓存寄存器 (用于地址转换的流水线延时)
reg  [31:0] inst_vaddr_buffer  ;  // 指令虚拟地址缓存
reg  [31:0] data_vaddr_buffer  ;  // 数据虚拟地址缓存

// 地址转换模式控制
wire        pg_mode;  // 分页模式
wire        da_mode;  // 直接地址转换模式

/**
 * 虚拟地址缓存逻辑
 * 在fetch信号有效时缓存虚拟地址，用于地址转换的流水线处理
 */
always @(posedge clk) begin
    if (inst_fetch) begin
        inst_vaddr_buffer <= inst_vaddr;  // 缓存指令虚拟地址
    end

    if (data_fetch) begin
        data_vaddr_buffer <= data_vaddr;  // 缓存数据虚拟地址
    end
end

/**
 * TLB查找端口信号组装
 */
// 指令地址转换查找信号
assign s0_vppn     = inst_vaddr[31:13];  // 虚拟页号 = 虚拟地址[31:13]
assign s0_odd_page = inst_vaddr[12];     // 奇偶页标志 = 虚拟地址[12]

// 数据地址转换查找信号
assign s1_vppn     = data_vaddr[31:13];  // 虚拟页号 = 虚拟地址[31:13]
assign s1_odd_page = data_vaddr[12];     // 奇偶页标志 = 虚拟地址[12]

/**
 * TLB写入端口信号组装
 * 支持TLBFILL和TLBWR两种写入方式
 */
assign we      = tlbfill_en || tlbwr_en;  // 写使能：TLBFILL或TLBWR有效
assign w_index = ({5{tlbfill_en}} & rand_index) | ({5{tlbwr_en}} & tlbidx_in[`INDEX]);  // 索引选择
assign w_vppn  = tlbehi_in[`VPPN];        // 虚拟页号
assign w_g     = tlbelo0_in[`TLB_G] && tlbelo1_in[`TLB_G];  // 全局位：两页都为全局才设置
assign w_ps    = tlbidx_in[`PS];          // 页大小
assign w_e     = (ecode_in == 6'h3f) ? 1'b1 : !tlbidx_in[`NE];  // 表项存在：异常时强制有效
assign w_v0    = tlbelo0_in[`TLB_V];      // 偶数页有效位
assign w_d0    = tlbelo0_in[`TLB_D];      // 偶数页脏位
assign w_plv0  = tlbelo0_in[`TLB_PLV];    // 偶数页特权等级
assign w_mat0  = tlbelo0_in[`TLB_MAT];    // 偶数页内存访问类型
assign w_ppn0  = tlbelo0_in[`TLB_PPN_EN]; // 偶数页物理页号
assign w_v1    = tlbelo1_in[`TLB_V];      // 奇数页有效位
assign w_d1    = tlbelo1_in[`TLB_D];      // 奇数页脏位
assign w_plv1  = tlbelo1_in[`TLB_PLV];    // 奇数页特权等级
assign w_mat1  = tlbelo1_in[`TLB_MAT];    // 奇数页内存访问类型
assign w_ppn1  = tlbelo1_in[`TLB_PPN_EN]; // 奇数页物理页号

/**
 * TLB读取端口信号组装
 * 用于TLBR指令读取TLB表项
 */
assign r_index      = tlbidx_in[`INDEX];  // 读取索引
assign tlbehi_out   = {r_vppn, 13'b0};   // 组装TLBEHI寄存器
assign tlbelo0_out  = {4'b0, r_ppn0, 1'b0, r_g, r_mat0, r_plv0, r_d0, r_v0};  // 组装TLBELO0寄存器
assign tlbelo1_out  = {4'b0, r_ppn1, 1'b0, r_g, r_mat1, r_plv1, r_d1, r_v1};  // 组装TLBELO1寄存器
assign tlbidx_out   = {!r_e, 1'b0, r_ps, 24'b0};  // 组装TLBIDX寄存器 (注意：不写入索引字段)
assign asid_out     = r_asid;             // ASID输出

/**
 * TLB表项模块实例化
 * 提供TLB的查找、读写和无效化功能
 */
tlb_entry #(
    .TLBNUM(TLBNUM)  // TLB表项数量参数
) tlb_entry(
    .clk            (clk            ),
    // 查找端口0 (指令地址转换)
    .s0_fetch       (inst_fetch     ),    // 查找请求
    .s0_vppn        (s0_vppn        ),    // 虚拟页号
    .s0_odd_page    (s0_odd_page    ),    // 奇偶页标志
    .s0_asid        (asid           ),    // 地址空间标识符
    .s0_found       (inst_tlb_found ),    // 查找命中
    .s0_index       (),                   // 命中索引 (指令端口不需要)
    .s0_ps          (s0_ps          ),    // 页大小
    .s0_ppn         (s0_ppn         ),    // 物理页号
    .s0_v           (inst_tlb_v     ),    // 有效位
    .s0_d           (inst_tlb_d     ),    // 脏位
    .s0_mat         (inst_tlb_mat   ),    // 内存访问类型
    .s0_plv         (inst_tlb_plv   ),    // 特权等级
    // 查找端口1 (数据地址转换)
    .s1_fetch       (data_fetch     ),    // 查找请求
    .s1_vppn        (s1_vppn        ),    // 虚拟页号
    .s1_odd_page    (s1_odd_page    ),    // 奇偶页标志
    .s1_asid        (asid           ),    // 地址空间标识符
    .s1_found       (data_tlb_found ),    // 查找命中
    .s1_index       (data_tlb_index ),    // 命中索引
    .s1_ps          (s1_ps          ),    // 页大小
    .s1_ppn         (s1_ppn         ),    // 物理页号
    .s1_v           (data_tlb_v     ),    // 有效位
    .s1_d           (data_tlb_d     ),    // 脏位
    .s1_mat         (data_tlb_mat   ),    // 内存访问类型
    .s1_plv         (data_tlb_plv   ),    // 特权等级
    // 写入端口 (TLBFILL/TLBWR指令)
    .we             (we             ),    // 写使能
    .w_index        (w_index        ),    // 写入索引
    .w_vppn         (w_vppn         ),    // 虚拟页号
    .w_asid         (asid           ),    // 地址空间标识符
    .w_g            (w_g            ),    // 全局标志
    .w_ps           (w_ps           ),    // 页大小
    .w_e            (w_e            ),    // 表项存在标志
    .w_v0           (w_v0           ),    // 偶数页有效位
    .w_d0           (w_d0           ),    // 偶数页脏位
    .w_plv0         (w_plv0         ),    // 偶数页特权等级
    .w_mat0         (w_mat0         ),    // 偶数页内存访问类型
    .w_ppn0         (w_ppn0         ),    // 偶数页物理页号
    .w_v1           (w_v1           ),    // 奇数页有效位
    .w_d1           (w_d1           ),    // 奇数页脏位
    .w_plv1         (w_plv1         ),    // 奇数页特权等级
    .w_mat1         (w_mat1         ),    // 奇数页内存访问类型
    .w_ppn1         (w_ppn1         ),    // 奇数页物理页号
    // 读取端口 (TLBR指令)
    .r_index        (r_index        ),    // 读取索引
    .r_vppn         (r_vppn         ),    // 虚拟页号
    .r_asid         (r_asid         ),    // 地址空间标识符
    .r_g            (r_g            ),    // 全局标志
    .r_ps           (r_ps           ),    // 页大小
    .r_e            (r_e            ),    // 表项存在标志
    .r_v0           (r_v0           ),    // 偶数页有效位
    .r_d0           (r_d0           ),    // 偶数页脏位
    .r_mat0         (r_mat0         ),    // 偶数页内存访问类型
    .r_plv0         (r_plv0         ),    // 偶数页特权等级
    .r_ppn0         (r_ppn0         ),    // 偶数页物理页号
    .r_v1           (r_v1           ),    // 奇数页有效位
    .r_d1           (r_d1           ),    // 奇数页脏位
    .r_mat1         (r_mat1         ),    // 奇数页内存访问类型
    .r_plv1         (r_plv1         ),    // 奇数页特权等级
    .r_ppn1         (r_ppn1         ),    // 奇数页物理页号
    // 无效化端口 (INVTLB指令)
    .inv_en         (invtlb_en      ),    // 无效化使能
    .inv_op         (invtlb_op      ),    // 无效化操作类型
    .inv_asid       (invtlb_asid    ),    // 无效化ASID
    .inv_vpn        (invtlb_vpn     )     // 无效化虚拟页号
);

/**
 * 地址转换模式控制
 * LoongArch支持两种地址转换模式，且两种模式互斥：
 * 1. DA模式：直接地址转换模式 (Direct Address Translation)
 * 2. PG模式：分页模式 (Paging Mode)
 */
assign pg_mode = !csr_da &&  csr_pg;  // 分页模式：DA=0且PG=1
assign da_mode =  csr_da && !csr_pg;  // 直接地址转换模式：DA=1且PG=0

// ====== 指令地址转换逻辑 ======
// Cache采用VIPT策略，index和offs直接输出，无延迟直出
assign inst_offset = inst_vaddr[3:0];   // 缓存行内偏移 (4位)
assign inst_index  = inst_vaddr[11:4];  // 缓存组索引 (8位)
// TODO(lab4): 计算物理tag
// 提示: 依次考虑DA模式、DMW窗口和TLB转换（包括大小页）的不同情况
//       由于等待TLB读取，相比index和offset有1周期的延迟
assign inst_tag    = da_mode        ? inst_vaddr_buffer[31:12] :
                     inst_dmw0_en   ? {csr_dmw0[`PSEG], inst_vaddr_buffer[28:12]} :  // DMW0窗口
                     inst_dmw1_en   ? {csr_dmw1[`PSEG], inst_vaddr_buffer[28:12]} :  // DMW1窗口
                     s0_ps == 6'd12 ? s0_ppn                                      :  // TLB转换（小页4kB）
                                      {s0_ppn[19:10], inst_vaddr_buffer[21:12]}   ;  // TLB转换（大页4MB）

// ====== 数据地址转换逻辑 ======
// Cache采用VIPT策略，index和offs直接输出，无延迟直出
assign data_offset = data_vaddr[3:0];   // 缓存行内偏移 (4位)
assign data_index  = data_vaddr[11:4];  // 缓存组索引 (8位)
// TODO(lab4): 计算物理tag
// 提示: 依次考虑DA模式、DMW窗口和TLB转换（包括大小页）的不同情况
//       注意：Cache操作直接索引模式下不使用地址翻译
//       由于等待TLB读取，相比index和offset有1周期的延迟
assign data_tag    = da_mode || cacop_op_mode_di ? data_vaddr_buffer[31:12] :
                     data_dmw0_en                ? {csr_dmw0[`PSEG], data_vaddr_buffer[28:12]} :  // DMW0窗口
                     data_dmw1_en                ? {csr_dmw1[`PSEG], data_vaddr_buffer[28:12]} :  // DMW1窗口
                     s1_ps == 6'd12              ? s1_ppn                                     :  // TLB转换（小页4kB）
                                                   {s1_ppn[19:10], data_vaddr_buffer[21:12]}  ;  // TLB转换（大页4MB）

endmodule
