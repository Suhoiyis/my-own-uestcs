`include "mycpu.vh"
`include "csr.vh"

// LoongArch CSR (Control and Status Register) 模块
// 实现了龙芯架构32位精简版中定义的控制状态寄存器。
// 主要功能包括：
// 1. 寄存器状态的读写和维护。
// 2. 例外和中断的处理与状态记录。
// 3. TLB相关寄存器的管理。
// 4. 定时器和LLBit的逻辑实现。
// 5. 将CSR状态提供给CPU流水线的其他模块。
module csr 
#(
    parameter TLBNUM = 32 // TLB的条目数，默认为32
)
(
    input                                 clk          , // 时钟信号
    input                                 reset        , // 复位信号
    //-- CSR读端口 (来自译码阶段) --//
    input  [13:0]                         rd_addr      , // 要读取的CSR地址
    output [31:0]                         rd_data      , // 读取出的CSR数据
    //-- 定时器相关 --//
    output [63:0]                         timer_64_out , // 64位恒定频率计时器的计数值
    output [31:0]                         tid_out      , // 定时器ID (TID)
    //-- CSR写端口 (来自执行/访存/写回阶段) --//
    input                                 csr_wr_en    , // CSR写使能信号
    input  [13:0]                         wr_addr      , // 要写入的CSR地址
    input  [31:0]                         wr_data      , // 要写入的数据
    //-- 中断输入 --//
    input  [ 7:0]                         interrupt    , // 外部硬件中断信号 HWI[7:0]
    output                                has_int      , // 存在待处理的中断信号
    //-- 例外与例外返回控制信号 (来自执行/访存阶段) --//
    input                                 excp_flush   , // 发生例外，需要刷新流水线
    input                                 ertn_flush   , // 执行ERTN指令，需要刷新流水线
    input  [31:0]                         era_in       , // 例外发生时，用于写入ERA的PC值
    input  [ 8:0]                         esubcode_in  , // 例外二级编码
    input  [ 5:0]                         ecode_in     , // 例外一级编码
    input                                 va_error_in  , // 发生地址相关例外
    input  [31:0]                         bad_va_in    , // 发生例外时的错误虚拟地址，用于写入BADV
    //-- TLB指令相关 --//
    input                                 tlbsrch_en    , // TLBSRCH指令执行
    input                                 tlbsrch_found , // TLBSRCH查找命中
    input  [ 4:0]                         tlbsrch_index , // TLBSRCH命中项的索引
    input                                 excp_tlbrefill, // 发生TLB重填例外
    input                                 excp_tlb      , // 发生其他TLB相关例外 (PIL, PIS, PIF等)
    input  [18:0]                         excp_tlb_vppn , // 发生TLB例外时的VPPN，用于写入TLBEHI
    //-- LLBit相关 (来自执行/访存阶段) --//
    input                                 llbit_in      , // LL.W指令执行后要设置的LLbit值 (通常为1)
    input                                 llbit_set_in  , // LLbit写使能
    input  [27:0]                         lladdr_in     , // LL.W指令的访存地址，用于记录
    input                                 lladdr_set_in , // LLAddr写使能
    //-- CSR输出信号 (到流水线各阶段) --//
    output                                llbit_out     , // LLbit状态 (到执行阶段)
    output [18:0]                         vppn_out      , // VPPN (到地址翻译单元)
    output [27:0]                         lladdr_out    , // LLAddr (到访存阶段)
    output [31:0]                         eentry_out    , // 普通例外入口地址 (到取指阶段)
    output [31:0]                         era_out       , // 例外返回地址 (到取指阶段, ERTN时)
    output [31:0]                         tlbrentry_out , // TLB重填例外入口地址 (到取指阶段)
    //-- CSR输出信号 (到地址翻译单元) --//
    output [ 9:0]                         asid_out      , // 当前ASID
    output [ 4:0]                         rand_index    , // 用于TLBFILL的硬件随机选择索引
    output [31:0]                         tlbehi_out    , // TLBEHI寄存器内容
    output [31:0]                         tlbelo0_out   , // TLBELO0寄存器内容
    output [31:0]                         tlbelo1_out   , // TLBELO1寄存器内容
    output [31:0]                         tlbidx_out    , // TLBIDX寄存器内容
    output                                pg_out        , // CRMD.PG位 (到取指阶段)
    output                                da_out        , // CRMD.DA位 (到取指阶段)
    output [31:0]                         dmw0_out      , // DMW0寄存器内容
    output [31:0]                         dmw1_out      , // DMW1寄存器内容
    output [ 1:0]                         datf_out      , // CRMD.DATF位 (到取指阶段)
    output [ 1:0]                         datm_out      , // CRMD.DATM位 (到访存阶段)
    output [ 5:0]                         ecode_out     , // ESTAT.Ecode位
    //-- 地址翻译单元输入信号 (TLBRD指令) --//
    input                                 tlbrd_en      , // TLBRD指令执行
    input  [31:0]                         tlbehi_in     , // 从TLB读取的表项高位部分
    input  [31:0]                         tlbelo0_in    , // 从TLB读取的表项低位0部分
    input  [31:0]                         tlbelo1_in    , // 从TLB读取的表项低位1部分
    input  [31:0]                         tlbidx_in     , // 从TLB读取的索引及PS, NE位信息
    input  [ 9:0]                         asid_in       , // 从TLB读取的ASID
    //-- 通用CSR输出 --//
    output [ 1:0]                         plv_out         // 当前特权等级PLV (到流水线各阶段)
    
    //-- 用于difftest的CSR寄存器输出 --//
`ifdef DIFFTEST_EN
    ,
    output [31:0]                         csr_crmd_diff,
    output [31:0]                         csr_prmd_diff,
    output [31:0]                         csr_ectl_diff,
    output [31:0]                         csr_estat_diff,
    output [31:0]                         csr_era_diff,
    output [31:0]                         csr_badv_diff,
    output [31:0]                         csr_eentry_diff,
    output [31:0]                         csr_tlbidx_diff,
    output [31:0]                         csr_tlbehi_diff,
    output [31:0]                         csr_tlbelo0_diff,
    output [31:0]                         csr_tlbelo1_diff,
    output [31:0]                         csr_asid_diff,
    output [31:0]                         csr_save0_diff,
    output [31:0]                         csr_save1_diff,
    output [31:0]                         csr_save2_diff,
    output [31:0]                         csr_save3_diff,
    output [31:0]                         csr_tid_diff,
    output [31:0]                         csr_tcfg_diff,
    output [31:0]                         csr_tval_diff,
    output [31:0]                         csr_ticlr_diff,
    output [31:0]                         csr_llbctl_diff,
    output [31:0]                         csr_tlbrentry_diff,
    output [31:0]                         csr_dmw0_diff,
    output [31:0]                         csr_dmw1_diff,
    output [31:0]                         csr_pgdl_diff,
    output [31:0]                         csr_pgdh_diff
`endif
);

// LoongArch32-Reduced CSR地址定义，参考手册 表7-1
localparam CRMD      = 14'h0;   // 当前模式信息
localparam PRMD      = 14'h1;   // 例外前模式信息
localparam ECTL      = 14'h4;   // 例外配置 (手册为ECFG)
localparam ESTAT     = 14'h5;   // 例外状态
localparam ERA       = 14'h6;   // 例外返回地址
localparam BADV      = 14'h7;   // 出错虚地址
localparam EENTRY    = 14'hc;   // 例外入口地址
localparam TLBIDX    = 14'h10;  // TLB 索引
localparam TLBEHI    = 14'h11;  // TLB 表项高位
localparam TLBELO0   = 14'h12;  // TLB 表项低位0
localparam TLBELO1   = 14'h13;  // TLB 表项低位1
localparam ASID      = 14'h18;  // 地址空间标识符
localparam PGDL      = 14'h19;  // 低半地址空间全局目录基址
localparam PGDH      = 14'h1a;  // 高半地址空间全局目录基址
localparam PGD       = 14'h1b;  // 全局目录基址 (只读)
localparam CPUID     = 14'h20;  // 处理器编号
localparam SAVE0     = 14'h30;  // 数据保存寄存器0
localparam SAVE1     = 14'h31;  // 数据保存寄存器1
localparam SAVE2     = 14'h32;  // 数据保存寄存器2
localparam SAVE3     = 14'h33;  // 数据保存寄存器3
localparam TID       = 14'h40;  // 定时器编号
localparam TCFG      = 14'h41;  // 定时器配置
localparam TVAL      = 14'h42;  // 定时器值 (只读)
localparam CNTC      = 14'h43;  // (非手册标准) 64位计时器的高32位扩展
localparam TICLR     = 14'h44;  // 定时中断清除
localparam LLBCTL    = 14'h60;  // LLBit 控制
localparam TLBRENTRY = 14'h88;  // TLB 重填例外入口地址
localparam DMW0      = 14'h180; // 直接映射配置窗口0
localparam DMW1      = 14'h181; // 直接映射配置窗口1
// 参见LA完整版手册2.2.10.5
localparam CPUCFG_1  = 14'hb1;
localparam CPUCFG_2  = 14'hb2;
localparam CPUCFG_10 = 14'hc0;
localparam CPUCFG_11 = 14'hc1;
localparam CPUCFG_12 = 14'hc2;
localparam CPUCFG_13 = 14'hc3;


// CSR写使能信号译码
wire crmd_wen      = csr_wr_en & (wr_addr == CRMD);
wire prmd_wen      = csr_wr_en & (wr_addr == PRMD);
wire ectl_wen      = csr_wr_en & (wr_addr == ECTL);
wire estat_wen     = csr_wr_en & (wr_addr == ESTAT);
wire era_wen       = csr_wr_en & (wr_addr == ERA);
wire badv_wen      = csr_wr_en & (wr_addr == BADV);
wire eentry_wen    = csr_wr_en & (wr_addr == EENTRY);
wire tlbidx_wen    = csr_wr_en & (wr_addr == TLBIDX);
wire tlbehi_wen    = csr_wr_en & (wr_addr == TLBEHI);
wire tlbelo0_wen   = csr_wr_en & (wr_addr == TLBELO0);
wire tlbelo1_wen   = csr_wr_en & (wr_addr == TLBELO1);
wire asid_wen      = csr_wr_en & (wr_addr == ASID);
wire pgdl_wen      = csr_wr_en & (wr_addr == PGDL);
wire pgdh_wen      = csr_wr_en & (wr_addr == PGDH);
wire pgd_wen       = csr_wr_en & (wr_addr == PGD);
wire cpuid_wen     = csr_wr_en & (wr_addr == CPUID);
wire save0_wen     = csr_wr_en & (wr_addr == SAVE0);
wire save1_wen     = csr_wr_en & (wr_addr == SAVE1);
wire save2_wen     = csr_wr_en & (wr_addr == SAVE2);
wire save3_wen     = csr_wr_en & (wr_addr == SAVE3);
wire tid_wen       = csr_wr_en & (wr_addr == TID);
wire tcfg_wen      = csr_wr_en & (wr_addr == TCFG);
wire tval_wen      = csr_wr_en & (wr_addr == TVAL);
wire cntc_wen      = csr_wr_en & (wr_addr == CNTC);
wire ticlr_wen     = csr_wr_en & (wr_addr == TICLR);
wire llbctl_wen    = csr_wr_en & (wr_addr == LLBCTL);
wire tlbrentry_wen = csr_wr_en & (wr_addr == TLBRENTRY);
wire DMW0_wen      = csr_wr_en & (wr_addr == DMW0);
wire DMW1_wen      = csr_wr_en & (wr_addr == DMW1);

// CSR寄存器实体
reg [31:0] csr_crmd;
reg [31:0] csr_prmd;
reg [31:0] csr_ectl;
reg [31:0] csr_estat;
reg [31:0] csr_era;
reg [31:0] csr_badv;
reg [31:0] csr_eentry;
reg [31:0] csr_tlbidx;
reg [31:0] csr_tlbehi;
reg [31:0] csr_tlbelo0;
reg [31:0] csr_tlbelo1;
reg [31:0] csr_asid;
reg [31:0] csr_cpuid;
reg [31:0] csr_save0;
reg [31:0] csr_save1;
reg [31:0] csr_save2;
reg [31:0] csr_save3;
reg [31:0] csr_tid;
reg [31:0] csr_tcfg;
reg [31:0] csr_tval;
reg [31:0] csr_cntc;
reg [31:0] csr_ticlr;
reg [31:0] csr_llbctl;
reg [31:0] csr_tlbrentry;
reg [31:0] csr_dmw0;
reg [31:0] csr_dmw1;
reg [31:0] csr_pgdl;
reg [31:0] csr_pgdh;
reg [31:0] csr_cpucfg1;
reg [31:0] csr_cpucfg2;
reg [31:0] csr_cpucfg10;
reg [31:0] csr_cpucfg11;
reg [31:0] csr_cpucfg12;
reg [31:0] csr_cpucfg13;


wire [31:0] csr_pgd;

reg        timer_en; // 定时器使能标志
reg [63:0] timer_64; // 64位恒定频率计时器

reg        llbit;    // LL.W/SC.W 指令对使用的LLbit
reg [27:0] lladdr;   // 记录LL.W指令的地址

wire tlbrd_valid_wr_en;   // TLBRD读取到有效表项
wire tlbrd_invalid_wr_en; // TLBRD读取到无效表项

wire eret_tlbrefill_excp; // 是否从TLB重填例外返回

// CSR.PGD 是一个只读寄存器，其值根据BADV的最高位动态选择PGDL或PGDH
// 手册章节: 7.5.7
assign csr_pgd = csr_badv[31] ? csr_pgdh : csr_pgdl;

// 判断当前是否处于从TLB重填例外(Ecode=0x3F)返回的过程中
assign eret_tlbrefill_excp = csr_estat[`ECODE] == 6'h3f;

// TLBRD指令执行时，根据读取到的TLB表项是否有效(NE位)来产生不同的写使能信号
assign tlbrd_valid_wr_en   = tlbrd_en && !tlbidx_in[`NE];
assign tlbrd_invalid_wr_en = tlbrd_en &&  tlbidx_in[`NE];

// TODO(lab2): 中断触发条件
// 提示：全局中断使能(CRMD.IE)为1，且存在一个局部中断使能(ECFG.LIE)和中断状态(ESTAT.IS)都为1的中断源
// 手册章节: 6.1.4
assign has_int = ((csr_ectl[`LIE] & csr_estat[`IS]) != 13'b0) & csr_crmd[`IE];

// -- CSR输出端口连接 --
assign eentry_out   = csr_eentry;
assign era_out      = csr_era;
assign timer_64_out = timer_64 + {{32{csr_cntc[31]}}, csr_cntc}; // 仿真扩展，允许软件写入高32位
assign tid_out      = csr_tid;
assign llbit_out    = llbit;
assign lladdr_out   = lladdr;
assign asid_out     = csr_asid[`TLB_ASID];
// VPPN的输出需要考虑前递，如果当前周期有对TLBEHI的写操作，则立即将新值传给地址翻译单元
assign vppn_out     = (csr_wr_en && wr_addr == TLBEHI) ? wr_data[`VPPN] : csr_tlbehi[`VPPN];
assign tlbehi_out   = csr_tlbehi;
assign tlbelo0_out  = csr_tlbelo0;
assign tlbelo1_out  = csr_tlbelo1;
assign tlbidx_out   = csr_tlbidx;
// TLBFILL指令使用硬件随机选择的索引，这里用计时器低位模拟
assign rand_index   = timer_64[4:0];

// CRMD.PG/DA输出逻辑：考虑tlb重填例外、例外返回、CSR写的前递
// 手册章节: 7.4.1 (CRMD)
assign pg_out       = excp_tlbrefill                      ? 1'b0           : // TLB重填例外时, PG=0
                      (eret_tlbrefill_excp && ertn_flush) ? 1'b1           : // 从TLBR返回时, PG=1
                      crmd_wen                            ? wr_data[`PG]   : // CSR写时，前递新值
                                                            csr_crmd[`PG]  ; // 默认情况

assign da_out       = excp_tlbrefill                      ? 1'b1           : // TLB重填例外时, DA=1
                      (eret_tlbrefill_excp && ertn_flush) ? 1'b0           : // 从TLBR返回时, DA=0
                      crmd_wen                            ? wr_data[`DA]   : // CSR写时，前递新值
                                                            csr_crmd[`DA]  ; // 默认情况

// DMW输出逻辑，考虑前递
assign dmw0_out     = DMW0_wen ? wr_data : csr_dmw0;
assign dmw1_out     = DMW1_wen ? wr_data : csr_dmw1;

// PLV输出逻辑，考虑前递
assign plv_out      = {2{excp_flush}} & 2'b0                                       | // 例外时, PLV=0
                      {2{ertn_flush}} & csr_prmd[`PPLV]                            | // ERTN时, PLV恢复
                      {2{crmd_wen  }} & wr_data[`PLV]                              | // CSR写时，前递新值
                      {2{!excp_flush && !ertn_flush && !crmd_wen}} & csr_crmd[`PLV]; // 默认情况

assign tlbrentry_out= csr_tlbrentry;
assign datf_out     = csr_crmd[`DATF];
assign datm_out     = csr_crmd[`DATM];

assign ecode_out    = csr_estat[`ECODE];

// CSR读端口多路选择器
assign rd_data = {32{rd_addr == CRMD      }}  & csr_crmd      |
                 {32{rd_addr == PRMD      }}  & csr_prmd      |
                 {32{rd_addr == ECTL      }}  & csr_ectl      |
                 {32{rd_addr == ESTAT     }}  & csr_estat     |
                 {32{rd_addr == ERA       }}  & csr_era       |
                 {32{rd_addr == BADV      }}  & csr_badv      |
                 {32{rd_addr == EENTRY    }}  & csr_eentry    |
                 {32{rd_addr == TLBIDX    }}  & csr_tlbidx    |
                 {32{rd_addr == TLBEHI    }}  & csr_tlbehi    |
                 {32{rd_addr == TLBELO0   }}  & csr_tlbelo0   |
                 {32{rd_addr == TLBELO1   }}  & csr_tlbelo1   |
                 {32{rd_addr == ASID      }}  & csr_asid      |
                 {32{rd_addr == PGDL      }}  & csr_pgdl      |
                 {32{rd_addr == PGDH      }}  & csr_pgdh      |
                 {32{rd_addr == PGD       }}  & csr_pgd       |
                 {32{rd_addr == CPUID     }}  & csr_cpuid     |
                 {32{rd_addr == SAVE0     }}  & csr_save0     |
                 {32{rd_addr == SAVE1     }}  & csr_save1     |
                 {32{rd_addr == SAVE2     }}  & csr_save2     |
                 {32{rd_addr == SAVE3     }}  & csr_save3     |
                 {32{rd_addr == TID       }}  & csr_tid       |
                 {32{rd_addr == TCFG      }}  & csr_tcfg      |
                 {32{rd_addr == CNTC      }}  & csr_cntc      |
                 {32{rd_addr == TICLR     }}  & csr_ticlr     |
                 {32{rd_addr == LLBCTL    }}  & {csr_llbctl[31:1], llbit} | // LLBCTL的第0位ROLLB是LLBit的只读快照
                 {32{rd_addr == TVAL      }}  & csr_tval      |
                 {32{rd_addr == TLBRENTRY}}  & csr_tlbrentry |
                 {32{rd_addr == DMW0}}       & csr_dmw0      |
                 {32{rd_addr == DMW1}}       & csr_dmw1      |
                 {32{rd_addr == CPUCFG_1 }}  & csr_cpucfg1   |
                 {32{rd_addr == CPUCFG_2 }}  & csr_cpucfg2   |
                 {32{rd_addr == CPUCFG_10 }} & csr_cpucfg10  |
                 {32{rd_addr == CPUCFG_11 }} & csr_cpucfg11  |
                 {32{rd_addr == CPUCFG_12 }} & csr_cpucfg12  |
                 {32{rd_addr == CPUCFG_13 }} & csr_cpucfg13  ;

// CSR: CRMD (当前模式信息寄存器), 地址: 0x0
// 手册章节: 7.4.1
// 功能: 决定处理器核当前所处的特权等级、全局中断使能和地址翻译模式
always @(posedge clk) begin
    if (reset) begin              // 复位状态，根据手册6.3节
        csr_crmd[`PLV]  <= 2'b0;  // PLV = 0 (最高特权等级)
        csr_crmd[`IE]   <= 1'b0;  // IE = 0 (全局中断关闭)
        csr_crmd[`DA]   <= 1'b1;  // DA = 1 (进入直接地址翻译模式)
        csr_crmd[`PG]   <= 1'b0;  // PG = 0
        csr_crmd[`DATF] <= 2'b0;  // DATF = 0 (取指操作的存储访问类型)
        csr_crmd[`DATM] <= 2'b0;  // DATM = 0 (load/store操作的存储访问类型)
        csr_crmd[31:9]  <= 23'b0; // 保留位清零
    end
    // TODO(lab2): 发生例外时，根据手册6.2.3节
    // 提示：
    // - 陷入后处于最高特权等级 PLV0
    // - 陷入后屏蔽中断
    // - 特别地, 对于TLB重填例外(TLBR), 硬件自动进入直接地址翻译模式
    else if (excp_flush) begin 
        csr_crmd[`PLV] <= 2'b0;   // 陷入后处于最高特权等级 PLV0
        csr_crmd[`IE]  <= 1'b0;   // 陷入后屏蔽中断
        // 对于TLB重填例外(TLBR)，硬件自动进入直接地址翻译模式
        if (excp_tlbrefill) begin 
            csr_crmd[`DA] <= 1'b1;
            csr_crmd[`PG] <= 1'b0;
        end
    end
    // TODO(lab2): 执行ERTN指令从例外返回时，根据手册6.2.3节
    // 提示：
    // - 恢复例外前的特权等级 PLV，从PRMD.PPLV恢复PLV
    // - 恢复全局中断使能 IE，从PRMD.PIE恢复IE
    // - 如果是从TLB重填例外返回, 硬件自动恢复到页表映射模式
    else if (ertn_flush) begin
        csr_crmd[`PLV] <= csr_prmd[`PPLV]; // 从PRMD.PPLV恢复PLV
        csr_crmd[`IE]  <= csr_prmd[`PIE];  // 从PRMD.PIE恢复IE
        // 如果是从TLB重填例外返回硬件自动恢复到页表映射模式
        if (eret_tlbrefill_excp) begin 
            csr_crmd[`DA] <= 1'b0; 
            csr_crmd[`PG] <= 1'b1;
        end
    end
    // TODO(lab2): CSR写指令更新CRMD寄存器
    // 提示：
    // - PLV, IE, DA, PG, DATF, DATM位通过CSR写指令更新
    else if (crmd_wen) begin
        csr_crmd[`PLV]  <= wr_data[`PLV];
        csr_crmd[`IE]   <= wr_data[`IE];
        csr_crmd[`DA]   <= wr_data[`DA];
        csr_crmd[`PG]   <= wr_data[`PG];
        csr_crmd[`DATF] <= wr_data[`DATF];
        csr_crmd[`DATM] <= wr_data[`DATM];
    end
end

// CSR: PRMD (例外前模式信息寄存器), 地址: 0x1
// 手册章节: 7.4.2
// 功能: 保存例外发生前的CRMD.PLV和CRMD.IE位，用于例外返回时恢复现场
always @(posedge clk) begin
    if (reset) begin
        csr_prmd[31:3] <= 29'b0;
    end
    // TODO(lab2): 发生例外时，保存当前CRMD的PLV和IE
    // 提示：当发生例外时，PRMD.PPLV和PRMD.PIE分别保存CRMD.PLV和CRMD.IE
    else if (excp_flush) begin
        csr_prmd[`PPLV] <= csr_crmd[`PLV];
        csr_prmd[`PIE]  <= csr_crmd[`IE];
    end
    // TODO(lab2): CSR写指令更新PRMD
    // 提示：PRMD.PPLV和PRMD.PIE通过CSR写指令更新
    else if (prmd_wen) begin
        csr_prmd[`PPLV] <= wr_data[`PPLV];
        csr_prmd[`PIE]  <= wr_data[`PIE];
    end
end

// CSR: ECFG (例外配置寄存器), 代码中为ECTL, 地址: 0x4
// 手册章节: 7.4.4
// 功能: 控制各中断的局部使能(LIE)
always @(posedge clk) begin
    if (reset) begin
        csr_ectl <= 32'b0; // 复位后所有局部中断使能关闭
    end
    else if (ectl_wen) begin // CSR写指令更新ECFG
        csr_ectl[`LIE_1] <= wr_data[`LIE_1];
        csr_ectl[`LIE_2] <= wr_data[`LIE_2];
    end
end

// CSR: ESTAT (例外状态寄存器), 地址: 0x5
// 手册章节: 7.4.5
// 功能: 记录例外的一二级编码(Ecode, EsubCode)和各中断的状态(IS)
always @(posedge clk) begin
    if (reset) begin
        csr_estat[1:0]   <= 2'b0;  // 软中断位清零
        csr_estat[10]    <= 1'b0;  // 保留位
        csr_estat[12]    <= 1'b0;  // 核间中断位清零
        csr_estat[15:13] <= 3'b0;  // 保留位
        csr_estat[31]    <= 1'b0;  // 保留位
        csr_estat[21:16] <= 6'b0;  // Ecode清零
    end
    else begin
        // TODO(lab2): 定时器中断清除逻辑，手册章节7.6.4
        // 提示：向IS[11]写1清除定时器中断状态位
        if (ticlr_wen && wr_data[`CLR]) csr_estat[11] <= 1'b0;
        // TODO(lab2): 定时器中断置位逻辑，手册章节7.6.2
        // 提示：// 定时器倒计时到0，置起中断
        else if (timer_en && (csr_tval == 32'b0)) csr_estat[11] <= 1'b1;
        
        // TODO(lab2): 硬中断状态位，直接采样外部中断信号
        csr_estat[9:2] <= interrupt;

        // TODO(lab2): 例外发生时，硬件写入Ecode和Esubcode
        if (excp_flush) begin
            csr_estat[`ECODE]    <= ecode_in;
            csr_estat[`ESUBCODE] <= esubcode_in;
        end
        // TODO(lab2): 软中断由软件写入ESTAT的IS[1:0]来置起或清除
        else if (estat_wen) begin
            csr_estat[1:0] <= wr_data[1:0];
        end
    end
end

// CSR: ERA (例外返回地址寄存器), 地址: 0x6
// 手册章节: 7.4.6
// 功能: 记录触发例外指令的PC值
always @(posedge clk) begin
    // TODO(lab2): 发生例外时保存出错PC
    if (excp_flush) begin
        csr_era <= era_in;
    end
    else if (era_wen) begin
        csr_era <= wr_data;
    end
end

// CSR: BADV (出错虚地址寄存器), 地址: 0x7
// 手册章节: 7.4.7
// 功能: 记录地址错误相关例外时的出错虚地址
always @(posedge clk) begin
    // TODO(lab2): 发生地址错误相关例外时保存出错虚地址
    if (badv_wen) begin
        csr_badv <= wr_data;
    end
    else if (va_error_in) begin
        csr_badv <= bad_va_in;
    end
end

// CSR: EENTRY (例外入口地址寄存器), 地址: 0xc
// 手册章节: 7.4.8
// 功能: 配置除TLB重填例外之外的所有例外和中断的入口地址
always @(posedge clk) begin
    if (reset) begin
        csr_eentry[5:0] <= 6'b0; // 低6位恒为0
    end
    else if (eentry_wen) begin
        csr_eentry[31:6] <= wr_data[31:6];
    end
end

// CSR: TLBIDX (TLB索引寄存器), 地址: 0x10
// 手册章节: 7.5.1
// 功能: 提供TLB指令操作的索引，并记录TLBSRCH的结果
always @(posedge clk) begin
    if (reset) begin
        csr_tlbidx[23:5]  <= 19'b0; // [15:n] 和 [23:16] 保留域
        csr_tlbidx[30]    <= 1'b0;  // 保留域
        csr_tlbidx[`INDEX]<= 5'b0;
    end
    else if (tlbidx_wen) begin // CSR写操作
        csr_tlbidx[$clog2(TLBNUM)-1:0] <= wr_data[$clog2(TLBNUM)-1:0];
        csr_tlbidx[`PS]   <= wr_data[`PS];
        csr_tlbidx[`NE]   <= wr_data[`NE];
    end
    else if (tlbsrch_en) begin // TLBSRCH指令执行
        if (tlbsrch_found) begin // 命中
            csr_tlbidx[`INDEX] <= tlbsrch_index; // 记录命中项的索引
            csr_tlbidx[`NE]    <= 1'b0;          // NE位置0
        end
        else begin // 未命中
            csr_tlbidx[`NE] <= 1'b1; // NE位置1
        end
    end
    else if (tlbrd_valid_wr_en) begin // TLBRD读取到有效表项
        csr_tlbidx[`PS] <= tlbidx_in[`PS];
        csr_tlbidx[`NE] <= tlbidx_in[`NE];
    end
    else if (tlbrd_invalid_wr_en) begin // TLBRD读取到无效表项
        csr_tlbidx[`PS] <= 6'b0; // PS域清零
        csr_tlbidx[`NE] <= tlbidx_in[`NE];
    end
end

// CSR: TLBEHI (TLB表项高位寄存器), 地址: 0x11
// 手册章节: 7.5.2
// 功能: 存放TLB表项的VPPN(虚双页号)
always @(posedge clk) begin
    if (reset) begin
        csr_tlbehi[12:0] <= 13'b0; // 低13位恒为0
    end
    else if (tlbehi_wen) begin // CSR写
        csr_tlbehi[`VPPN] <= wr_data[`VPPN];
    end
    else if (tlbrd_valid_wr_en) begin // TLBRD读
        csr_tlbehi[`VPPN] <= tlbehi_in[`VPPN];
    end
    else if (tlbrd_invalid_wr_en) begin // TLBRD读无效项
        csr_tlbehi[`VPPN] <= 19'b0;
    end
    else if (excp_tlb) begin // 发生TLB相关例外
        csr_tlbehi[`VPPN] <= excp_tlb_vppn; // 硬件自动填入出错虚地址的[31:13]位
    end
end

// CSR: TLBELO0 (TLB表项低位寄存器0, 偶数页), 地址: 0x12
// 手册章节: 7.5.3
// 功能: 存放偶数页的物理转换信息 (PPN, PLV, MAT, V, D, G)
always @(posedge clk) begin
    if (reset) begin
        csr_tlbelo0[7] <= 1'b0; // 保留位
    end
    else if (tlbelo0_wen) begin // CSR写
        csr_tlbelo0[`TLB_V]   <= wr_data[`TLB_V];
        csr_tlbelo0[`TLB_D]   <= wr_data[`TLB_D];
        csr_tlbelo0[`TLB_PLV] <= wr_data[`TLB_PLV];
        csr_tlbelo0[`TLB_MAT] <= wr_data[`TLB_MAT];
        csr_tlbelo0[`TLB_G]   <= wr_data[`TLB_G];
        csr_tlbelo0[`TLB_PPN_EN] <= wr_data[`TLB_PPN_EN];
    end
    else if (tlbrd_valid_wr_en) begin // TLBRD读
        csr_tlbelo0[`TLB_V]   <= tlbelo0_in[`TLB_V];
        csr_tlbelo0[`TLB_D]   <= tlbelo0_in[`TLB_D];
        csr_tlbelo0[`TLB_PLV] <= tlbelo0_in[`TLB_PLV];
        csr_tlbelo0[`TLB_MAT] <= tlbelo0_in[`TLB_MAT];
        csr_tlbelo0[`TLB_G]   <= tlbelo0_in[`TLB_G];
        csr_tlbelo0[`TLB_PPN_EN] <= tlbelo0_in[`TLB_PPN_EN];
    end
    else if (tlbrd_invalid_wr_en) begin // TLBRD读无效项
        csr_tlbelo0[`TLB_V]   <= 1'b0;
        csr_tlbelo0[`TLB_D]   <= 1'b0;
        csr_tlbelo0[`TLB_PLV] <= 2'b0;
        csr_tlbelo0[`TLB_MAT] <= 2'b0;
        csr_tlbelo0[`TLB_G]   <= 1'b0;
        csr_tlbelo0[`TLB_PPN_EN] <= 20'b0;
    end
end

// CSR: TLBELO1 (TLB表项低位寄存器1, 奇数页), 地址: 0x13
// 手册章节: 7.5.3
// 功能: 存放奇数页的物理转换信息
always @(posedge clk) begin
    if (reset) begin
        csr_tlbelo1[7] <= 1'b0;
    end
    else if (tlbelo1_wen) begin // CSR写
        csr_tlbelo1[`TLB_V]   <= wr_data[`TLB_V];
        csr_tlbelo1[`TLB_D]   <= wr_data[`TLB_D];
        csr_tlbelo1[`TLB_PLV] <= wr_data[`TLB_PLV];
        csr_tlbelo1[`TLB_MAT] <= wr_data[`TLB_MAT];
        csr_tlbelo1[`TLB_G]   <= wr_data[`TLB_G];
        csr_tlbelo1[`TLB_PPN_EN] <= wr_data[`TLB_PPN_EN];
    end
    else if (tlbrd_valid_wr_en) begin // TLBRD读
        csr_tlbelo1[`TLB_V]   <= tlbelo1_in[`TLB_V];
        csr_tlbelo1[`TLB_D]   <= tlbelo1_in[`TLB_D];
        csr_tlbelo1[`TLB_PLV] <= tlbelo1_in[`TLB_PLV];
        csr_tlbelo1[`TLB_MAT] <= tlbelo1_in[`TLB_MAT];
        csr_tlbelo1[`TLB_G]   <= tlbelo1_in[`TLB_G];
        csr_tlbelo1[`TLB_PPN_EN] <= tlbelo1_in[`TLB_PPN_EN];
    end
    else if (tlbrd_invalid_wr_en) begin // TLBRD读无效项
        csr_tlbelo1[`TLB_V]   <= 1'b0;
        csr_tlbelo1[`TLB_D]   <= 1'b0;
        csr_tlbelo1[`TLB_PLV] <= 2'b0;
        csr_tlbelo1[`TLB_MAT] <= 2'b0;
        csr_tlbelo1[`TLB_G]   <= 1'b0;
        csr_tlbelo1[`TLB_PPN_EN] <= 20'b0;
    end
end

// CSR: ASID (地址空间标识符寄存器), 地址: 0x18
// 手册章节: 7.5.4
// 功能: 存放当前程序的ASID，以及ASID的位宽信息
always @(posedge clk) begin
    if (reset) begin
        csr_asid[31:10] <= 22'h280; // ASIDBITS = 10, 即10位ASID
    end
    else if (asid_wen) begin // CSR写
        csr_asid[`TLB_ASID] <= wr_data[`TLB_ASID];
    end
    else if (tlbrd_valid_wr_en) begin // TLBRD读
        csr_asid[`TLB_ASID] <= asid_in;
    end
    else if (tlbrd_invalid_wr_en) begin // TLBRD读无效项
        csr_asid[`TLB_ASID] <= 10'b0;
    end
end

// CSR: TLBRENTRY (TLB重填例外入口地址寄存器), 地址: 0x88
// 手册章节: 7.5.8
// 功能: 配置TLB重填例外的入口物理地址
always @(posedge clk) begin
    if (reset) begin
        csr_tlbrentry[5:0] <= 6'b0; // 低6位恒为0
    end
    else if (tlbrentry_wen) begin
        csr_tlbrentry[`TLBRENTRY_PA] <= wr_data[`TLBRENTRY_PA];
    end
end

// CSR: DMW0 (直接映射配置窗口0), 地址: 0x180
// 手册章节: 7.5.9
// 功能: 配置一个直接地址映射窗口
always @(posedge clk) begin
    if (reset) begin
        csr_dmw0[2:1]  <= 2'b0;
        csr_dmw0[24:6] <= 19'b0;
        csr_dmw0[28]   <= 1'b0;
    end
    else if (DMW0_wen) begin
        csr_dmw0[`PLV0]    <= wr_data[`PLV0];
        csr_dmw0[`PLV3]    <= wr_data[`PLV3];
        csr_dmw0[`DMW_MAT] <= wr_data[`DMW_MAT];
        csr_dmw0[`PSEG]    <= wr_data[`PSEG];
        csr_dmw0[`VSEG]    <= wr_data[`VSEG];
    end
end

// CSR: DMW1 (直接映射配置窗口1), 地址: 0x181
// 手册章节: 7.5.9
// 功能: 配置另一个直接地址映射窗口
always @(posedge clk) begin
    if (reset) begin
        csr_dmw1[2:1]  <= 2'b0;
        csr_dmw1[24:6] <= 19'b0;
        csr_dmw1[28]   <= 1'b0;
    end
    else if (DMW1_wen) begin
        csr_dmw1[`PLV0]    <= wr_data[`PLV0];
        csr_dmw1[`PLV3]    <= wr_data[`PLV3];
        csr_dmw1[`DMW_MAT] <= wr_data[`DMW_MAT];
        csr_dmw1[`PSEG]    <= wr_data[`PSEG];
        csr_dmw1[`VSEG]    <= wr_data[`VSEG];
    end
end

// CSR: CPUID (处理器编号寄存器), 地址: 0x20
// 手册章节: 7.4.9
// 功能: 只读寄存器，存放处理器核的编号
always @(posedge clk) begin
    if (reset) begin
        csr_cpuid <= 32'b0; // CoreID由硬件设置，此处简化为0
    end 
end

// CSR: SAVE0-3 (数据保存寄存器), 地址: 0x30-0x33
// 手册章节: 7.4.10
// 功能: 供系统软件暂存数据
always @(posedge clk) begin
    if (save0_wen) begin
        csr_save0 <= wr_data;
    end 
end
always @(posedge clk) begin
    if (save1_wen) begin
        csr_save1 <= wr_data;
    end 
end
always @(posedge clk) begin
    if (save2_wen) begin
        csr_save2 <= wr_data;
    end 
end
always @(posedge clk) begin
    if (save3_wen) begin
        csr_save3 <= wr_data;
    end 
end

// CSR: TID (定时器编号寄存器), 地址: 0x40
// 手册章节: 7.6.1
// 功能: 配置定时器的唯一编号
always @(posedge clk) begin
    if (reset) begin
        csr_tid <= 32'b0;
    end
    else if (tid_wen) begin
        csr_tid <= wr_data;
    end
end

// CSR: TCFG (定时器配置寄存器), 地址: 0x41
// 手册章节: 7.6.2
// 功能: 配置定时器的使能、循环模式和初始值
always @(posedge clk) begin
    if (reset) begin
        csr_tcfg[`EN] <= 1'b0; // 复位后定时器关闭
    end
    else if (tcfg_wen) begin
        csr_tcfg[`EN]       <= wr_data[`EN];
        csr_tcfg[`PERIODIC] <= wr_data[`PERIODIC];
        csr_tcfg[`INITVAL]  <= wr_data[`INITVAL];
    end
end

// CSR: CNTC (非标准，用于仿真)
// 功能: 用于软件设置64位计时器的高32位
always @(posedge clk) begin
    if (reset) begin
        csr_cntc <= 32'b0;
    end
    else if (cntc_wen) begin
        csr_cntc <= wr_data;
    end
end

// CSR: TVAL (定时器数值寄存器), 地址: 0x42
// 手册章节: 7.6.3
// 功能: 只读，反映定时器当前的计数值
always @(posedge clk) begin
    // 写TCFG时，TVAL装载初始值
    if (tcfg_wen) begin
        csr_tval <= {wr_data[`INITVAL], 2'b0};
    end
    else if (timer_en) begin
        // TODO(lab2): 定时器使能时，进行倒计时
        if (csr_tval != 32'b0) begin
            csr_tval <= csr_tval - 32'b1;
        end
        // TODO(lab2): csr_tval周期模式逻辑
        // 提示：如果是周期模式，重装初始值
        //      否则停止计数，设置值为32'hffffffff，避免出发中断
        else if (csr_tval == 32'b0) begin // 倒计时到0
            csr_tval <= csr_tcfg[`PERIODIC] ? {csr_tcfg[`INITVAL], 2'b0} : 32'hffffffff;
        end
    end
end

// 定时器使能状态寄存器逻辑
always @(posedge clk) begin
    if (reset) begin
        timer_en <= 1'b0;
    end
    else begin
        // 写TCFG时更新定时器使能状态
        if (tcfg_wen) timer_en <= wr_data[`EN];
        // 如果是周期模式，自动重装载并继续计时
        else if (timer_en && (csr_tval == 32'b0)) timer_en <= csr_tcfg[`PERIODIC]; 
    end
end

// CSR: TICLR (定时中断清除寄存器), 地址: 0x44
// 手册章节: 7.6.4
// 功能: 写1清除定时中断信号，本身只读为0
always @(posedge clk) begin
    if (reset) begin
        csr_ticlr <= 32'b0;
    end
end

// CSR: LLBCTL (LLBit控制寄存器), 地址: 0x60
// 手册章节: 7.4.11
// 功能: 控制LLbit的读写和在例外返回时的行为
always @(posedge clk) begin
    if (reset) begin
        csr_llbctl[`KLO]   <= 1'b0;
        csr_llbctl[31:3]   <= 29'b0;
        csr_llbctl[`WCLLB] <= 1'b0;
        llbit <= 1'b0; // 复位时清零LLbit
    end 
    else if (ertn_flush) begin // ERTN指令执行时
        if (csr_llbctl[`KLO]) begin // KLO=1, ERTN不清除LLbit，但KLO自身被清零
            csr_llbctl[`KLO] <= 1'b0;
        end
        else begin // KLO=0, ERTN清除LLbit
            llbit <= 1'b0;
        end
    end
    else if (llbctl_wen) begin // CSR写LLBCTL
        csr_llbctl[`KLO] <= wr_data[`KLO];
        if (wr_data[`WCLLB] == 1'b1) begin // 写WCLLB为1，清零LLbit
            llbit <= 1'b0;
        end
    end
    else if (llbit_set_in) begin // LL.W指令执行，设置LLbit
        llbit <= llbit_in;
    end
end

// 记录LL.W指令的访存地址
always @(posedge clk) begin
    if (reset) begin
        lladdr <= 28'b0;
    end
    else if (lladdr_set_in) begin
        lladdr <= lladdr_in;
    end
end

// 64位恒定频率计时器逻辑 由RDCNT指令定义
always @(posedge clk) begin
    if (reset) begin
        timer_64 <= 64'b0;
    end
    else begin
        timer_64 <= timer_64 + 1'b1; // 每个时钟周期自增1
    end
end

// CSR: PGDL (低半地址空间全局目录基址寄存器), 地址: 0x19
// 手册章节: 7.5.5
always @(posedge clk) begin
    if (pgdl_wen) begin
        csr_pgdl[`BASE] <= wr_data[`BASE];
    end
end

// CSR: PGDH (高半地址空间全局目录基址寄存器), 地址: 0x1a
// 手册章节: 7.5.6
always @(posedge clk) begin
    if (pgdh_wen) begin
        csr_pgdh[`BASE] <= wr_data[`BASE];
    end
end

// CPU_CFG：软件可通过这些配置读出CPU的设计参数
// 详细见LA完整版手册2.2.10.5
always @(posedge clk) begin
    if (reset) begin
        csr_cpucfg1 <= 32'h1f1f4;
    end 
end

always @(posedge clk) begin
    if (reset) begin
        csr_cpucfg2 <= 32'h0;
    end 
end

always @(posedge clk) begin
    if (reset) begin
        csr_cpucfg10 <= 32'h5;
    end 
end

always @(posedge clk) begin
    if (reset) begin
        csr_cpucfg11 <= 32'h04080001;
    end 
end

always @(posedge clk) begin
    if (reset) begin
        csr_cpucfg12 <= 32'h04080001;
    end 
end

always @(posedge clk) begin
    if (reset) begin
        csr_cpucfg13 <= 32'h0;
    end 
end

// difftest 端口连接
`ifdef DIFFTEST_EN
assign csr_crmd_diff      = csr_crmd;
assign csr_prmd_diff      = csr_prmd;
assign csr_ectl_diff      = csr_ectl;
assign csr_estat_diff     = csr_estat;
assign csr_era_diff       = csr_era;
assign csr_badv_diff      = csr_badv;
assign csr_eentry_diff    = csr_eentry;
assign csr_tlbidx_diff    = csr_tlbidx;
assign csr_tlbehi_diff    = csr_tlbehi;
assign csr_tlbelo0_diff   = csr_tlbelo0;
assign csr_tlbelo1_diff   = csr_tlbelo1;
assign csr_asid_diff      = csr_asid;
assign csr_save0_diff     = csr_save0;
assign csr_save1_diff     = csr_save1;
assign csr_save2_diff     = csr_save2;
assign csr_save3_diff     = csr_save3;
assign csr_tid_diff       = csr_tid;
assign csr_tcfg_diff      = csr_tcfg;
assign csr_tval_diff      = csr_tval;
assign csr_ticlr_diff     = csr_ticlr;
assign csr_llbctl_diff    = {csr_llbctl[31:1], llbit};
assign csr_tlbrentry_diff = csr_tlbrentry;
assign csr_dmw0_diff      = csr_dmw0;
assign csr_dmw1_diff      = csr_dmw1;
assign csr_pgdl_diff      = csr_pgdl;
assign csr_pgdh_diff      = csr_pgdh;
`endif

endmodule
