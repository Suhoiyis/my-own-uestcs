`include "mycpu.vh"
`include "csr.vh"

// LoongArch五级流水线处理器的写回阶段(Write Back Stage)
// 主要功能：
// 1. 将计算结果写回寄存器文件
// 2. 处理异常和中断
// 3. 管理CSR寄存器读写
// 4. 处理TLB相关指令
// 5. 实现流水线控制信号
module wb_stage(
    input                           clk            , // 时钟信号
    input                           reset          , // 复位信号
    
    // 流水线控制信号 - 允许流入控制
    output                          ws_allowin     , // 当前阶段允许新指令流入
    
    // 来自访存阶段(MS)的信号
    input                           ms_to_ws_valid , // 访存阶段传来的有效信号
    input  [`MS_TO_WS_BUS_WD -1:0]  ms_to_ws_bus   , // 访存阶段传来的数据总线
    
    // 寄存器文件写回信号
    output [`WS_TO_RF_BUS_WD -1:0]  ws_to_rf_bus   , // 向寄存器文件的写回总线
    
    // 向译码阶段(DS)的反馈信号
    output                          ws_to_ds_valid , // 写回阶段有效信号(用于数据冒险检测)
    
    // 异常和中断处理信号
    output [31:0] csr_era                          , // CSR异常返回地址寄存器
    output [ 8:0] csr_esubcode                     , // CSR异常子码
    output [ 5:0] csr_ecode                        , // CSR异常码
    output        excp_flush                       , // 异常刷新信号
    output        ertn_flush                       , // 异常返回刷新信号
    output        refetch_flush                    , // 重取指刷新信号
    output        icacop_flush                     , // 指令Cache操作刷新信号
    
    // CSR寄存器写操作信号
    output        csr_wr_en                        , // CSR写使能
    output [13:0] wr_csr_addr                      , // 写CSR地址
    output [31:0] wr_csr_data                      , // 写CSR数据
    
    // 虚拟地址异常信号
    output        va_error                         , // 虚拟地址错误标志
    output [31:0] bad_va                           , // 错误的虚拟地址
    
    // TLB异常信号
    output        excp_tlbrefill                   , // TLB重填异常
    output        excp_tlb                         , // TLB异常
    output [18:0] excp_tlb_vppn                    , // TLB异常虚拟页号
    
    // 空闲刷新信号
    output        idle_flush                       , // 空闲状态刷新信号
    
    // 原子操作链接位(Load-Linked/Store-Conditional)信号
    output        ws_llbit_set                     , // 链接位设置信号
    output        ws_llbit                         , // 链接位值
    output        ws_lladdr_set                    , // 链接地址设置信号
    output [27:0] ws_lladdr                        , // 链接地址(高28位)
    
    // TLB指令控制信号
    output        tlb_inst_stall                   , // TLB指令停顿信号
    output        tlbsrch_en                       , // TLB搜索使能
    output        tlbsrch_found                    , // TLB搜索结果
    output [ 4:0] tlbsrch_index                    , // TLB搜索索引
    output        tlbfill_en                       , // TLB填充使能
    output        tlbwr_en                         , // TLB写使能
    output        tlbrd_en                         , // TLB读使能
    output        invtlb_en                        , // 无效TLB使能
    output [ 9:0] invtlb_asid                      , // 无效TLB的ASID
    output [18:0] invtlb_vpn                       , // 无效TLB的虚拟页号
    output [ 4:0] invtlb_op                        , // 无效TLB操作码
    
    // 性能计数器信号
    output        real_valid                       , // 真实有效信号(无异常的有效指令)
    output        real_br_inst                     , // 真实分支指令
    output        real_icache_miss                 , // 真实指令Cache缺失
    output        real_dcache_miss                 , // 真实数据Cache缺失
    output        real_mem_inst                    , // 真实访存指令
    output        real_br_pre                      , // 真实分支预测
    output        real_br_pre_error                , // 真实分支预测错误
    
    // 调试信号
    output        debug_ws_valid                     , // 调试用写回阶段有效信号
    input         debug_break_point                  , // 调试断点信号
    
    // 跟踪调试接口
    output [31:0] debug_wb_pc                      , // 调试用PC值
    output [ 3:0] debug_wb_rf_wen                  , // 调试用寄存器写使能
    output [ 4:0] debug_wb_rf_wnum                 , // 调试用寄存器写编号
    output [31:0] debug_wb_rf_wdata                , // 调试用寄存器写数据
    output [31:0] debug_wb_inst                    // 调试用指令
    // Difftest功能信号(用于difftest)
`ifdef DIFFTEST_EN
    ,
    output        ws_valid_diff                    , // difftest的有效信号
    output        ws_cnt_inst_diff                 , // difftest的指令计数
    output [63:0] ws_timer_64_diff                 , // difftest的64位定时器
    output [ 7:0] ws_inst_ld_en_diff               , // difftest的加载指令使能
    output [31:0] ws_ld_paddr_diff                 , // difftest的加载物理地址
    output [31:0] ws_ld_vaddr_diff                 , // difftest的加载虚拟地址
    output [ 7:0] ws_inst_st_en_diff               , // difftest的存储指令使能
    output [31:0] ws_st_paddr_diff                 , // difftest的存储物理地址
    output [31:0] ws_st_vaddr_diff                 , // difftest的存储虚拟地址
    output [31:0] ws_st_data_diff                  , // difftest的存储数据
    output        ws_csr_rstat_en_diff             , // difftest的CSR状态读使能
    output [31:0] ws_csr_data_diff                   // difftest的CSR数据
`endif
);

// ======================== 内部信号定义 ========================
reg         ws_valid;        // 写回阶段的有效信号寄存器
wire        ws_ready_go;     // 写回阶段准备完成信号

wire        flush_sign;      // 刷新信号(异常、中断等引起的流水线刷新)

// 来自访存阶段的数据总线寄存器
reg [`MS_TO_WS_BUS_WD -1:0] ms_to_ws_bus_r;

// 从访存阶段总线解析出的信号
wire        ws_gr_we;        // 通用寄存器写使能
wire        ws_excp;         // 异常标志
wire [15:0] ws_excp_num;     // 异常编号(位向量,每位代表一种异常)
wire        ws_ertn;         // 异常返回指令标志
wire [ 4:0] ws_dest;         // 目标寄存器编号
wire [31:0] ws_final_result; // 最终计算结果
wire [31:0] ws_pc;           // 当前指令PC值
wire [31:0] ws_csr_result;   // CSR操作结果
wire [13:0] ws_csr_idx;      // CSR寄存器索引
wire        ws_csr_we;       // CSR写使能
wire        ws_ll_w;         // Load-Linked指令标志
wire        ws_sc_w;         // Store-Conditional指令标志
wire [31:0] ws_error_va;     // 错误虚拟地址
wire        ws_tlbsrch;      // TLB搜索指令标志
wire        ws_tlbfill;      // TLB填充指令标志
wire        ws_tlbwr;        // TLB写指令标志
wire        ws_tlbrd;        // TLB读指令标志
wire        ws_refetch;      // 重取指标志
wire        ws_invtlb;       // 无效TLB指令标志
wire        ws_icacop_op_en; // 指令Cache操作使能
wire        ws_br_inst;      // 分支指令标志
wire        ws_icache_miss;  // 指令Cache缺失
wire        ws_access_mem;   // 访存指令标志
wire        ws_dcache_miss;  // 数据Cache缺失
wire        ws_br_pre;       // 分支预测标志
wire        ws_br_pre_error; // 分支预测错误标志
wire        ws_idle;         // 空闲指令标志
wire [31:0] ws_paddr;        // 物理地址
wire        ws_data_uc;      // 数据非缓存标志

// Difftest相关信号(用于功能验证和difftest)
wire [31:0] ws_inst         ; // 指令码
wire        ws_cnt_inst     ; // 指令计数使能
wire [63:0] ws_timer_64     ; // 64位定时器值
wire [ 7:0] ws_inst_ld_en   ; // 加载指令字节使能
wire [31:0] ws_ld_paddr     ; // 加载物理地址
wire [31:0] ws_ld_vaddr     ; // 加载虚拟地址
wire [ 7:0] ws_inst_st_en   ; // 存储指令字节使能
wire [31:0] ws_st_data      ; // 存储数据
wire        ws_csr_rstat_en ; // CSR状态读使能
wire [31:0] ws_csr_data     ; // CSR数据

// ======================== 数据总线解析 ========================
// 从访存阶段传来的数据总线中解析各个信号
// 总线宽度为493位,按功能分组排列
assign {ws_csr_data    ,  //492:461 CSR数据(用于difftest)
        ws_csr_rstat_en,  //460:460 CSR状态读使能(用于difftest)
        ws_st_data     ,  //459:428 存储数据(用于difftest)
        ws_inst_st_en  ,  //427:420 存储指令字节使能(用于difftest)
        ws_ld_vaddr    ,  //419:388 加载虚拟地址(用于difftest)
        ws_ld_paddr    ,  //387:356 加载物理地址(用于difftest)
        ws_inst_ld_en  ,  //355:348 加载指令字节使能(用于difftest)
        ws_cnt_inst    ,  //347:347 指令计数使能(用于difftest)
        ws_timer_64    ,  //346:283 64位定时器值(用于difftest)
        ws_inst        ,  //282:251 指令码(用于difftest)
		ws_data_uc     ,  //250:250 数据非缓存标志
		ws_paddr       ,  //249:218 物理地址
        ws_idle        ,  //217:217 空闲指令标志
        ws_br_pre_error,  //216:216 分支预测错误标志
        ws_br_pre      ,  //215:215 分支预测标志
        ws_dcache_miss ,  //214:214 数据Cache缺失
        ws_access_mem  ,  //213:213 访存指令标志
        ws_icache_miss ,  //212:212 指令Cache缺失
        ws_br_inst     ,  //211:211 分支指令标志
        ws_icacop_op_en,  //210:210 指令Cache操作使能
        invtlb_vpn     ,  //209:191 无效TLB虚拟页号
        invtlb_asid    ,  //190:181 无效TLB的ASID
        ws_invtlb      ,  //180:180 无效TLB指令标志
        ws_tlbrd       ,  //179:179 TLB读指令标志
        ws_refetch     ,  //178:178 重取指标志
        ws_tlbfill     ,  //177:177 TLB填充指令标志
        ws_tlbwr       ,  //176:176 TLB写指令标志
        tlbsrch_index  ,  //175:171 TLB搜索索引
        tlbsrch_found  ,  //170:170 TLB搜索结果
        ws_tlbsrch     ,  //169:169 TLB搜索指令标志
        ws_error_va    ,  //168:137 错误虚拟地址
        ws_sc_w        ,  //136:136 Store-Conditional指令标志
        ws_ll_w        ,  //135:135 Load-Linked指令标志
        ws_excp_num    ,  //134:119 异常编号(16位,每位代表一种异常)
        ws_csr_we      ,  //118:118 CSR写使能
        ws_csr_idx     ,  //117:104 CSR寄存器索引
        ws_csr_result  ,  //103:72  CSR操作结果
        ws_ertn        ,  //71:71   异常返回指令标志
        ws_excp        ,  //70:70   异常标志
        ws_gr_we       ,  //69:69   通用寄存器写使能
        ws_dest        ,  //68:64   目标寄存器编号
        ws_final_result,  //63:32   最终计算结果
        ws_pc             //31:0    当前指令PC值
       } = ms_to_ws_bus_r;

// ======================== 输出信号分配 ========================
// 向译码阶段输出有效信号(用于数据冒险检测)
assign ws_to_ds_valid = ws_valid;

// 流水线刷新信号,任一刷新条件满足都会引起流水线刷新
assign flush_sign = excp_flush || ertn_flush || refetch_flush || icacop_flush || idle_flush;

// 寄存器文件写回信号
wire        rf_we;    // 寄存器文件写使能
wire [4 :0] rf_waddr; // 寄存器文件写地址
wire [31:0] rf_wdata; // 寄存器文件写数据
assign ws_to_rf_bus = {rf_we   ,  //37:37 写使能
                       rf_waddr,  //36:32 写地址
                       rf_wdata   //31:0  写数据
                      };

// 流水线控制逻辑
assign ws_ready_go = ~debug_break_point; // 当没有调试断点时,写回阶段准备完成
assign ws_allowin  = !ws_valid || ws_ready_go; // 当前阶段无效或准备完成时允许新指令流入
// ======================== 时序逻辑 ========================
// 写回阶段的流水线寄存器更新逻辑
always @(posedge clk) begin
    // 复位或刷新时,清除有效标志
    if (reset || flush_sign) begin
        ws_valid <= 1'b0;
    end
    // 当允许新指令流入时,更新有效标志
    else if (ws_allowin) begin
        ws_valid <= ms_to_ws_valid;
    end

    // 当访存阶段有有效数据且写回阶段允许流入时,锁存数据总线
    if (ms_to_ws_valid && ws_allowin) begin
        ms_to_ws_bus_r <= ms_to_ws_bus;
    end
end

// ======================== 性能计数器相关信号 ========================
// 这些信号用于统计处理器性能指标,只有在指令真实有效(无异常)时才计数
assign real_br_inst = ws_br_inst && real_valid;           // 真实分支指令统计
assign real_icache_miss = ws_icache_miss && real_valid;   // 真实指令Cache缺失统计
assign real_dcache_miss = ws_dcache_miss && real_valid;   // 真实数据Cache缺失统计
assign real_mem_inst = ws_access_mem && real_valid;       // 真实访存指令统计
assign real_br_pre = ws_br_pre && real_valid;             // 真实分支预测统计
assign real_br_pre_error = ws_br_pre_error && real_valid; // 真实分支预测错误统计

// 真实有效信号:指令有效且没有异常
assign real_valid = ws_valid & ~ws_excp;

// ======================== 寄存器文件写回逻辑 ========================
assign rf_we    = ws_gr_we & real_valid; // 只有在指令真实有效时才写回寄存器
assign rf_waddr = ws_dest;                // 目标寄存器地址
assign rf_wdata = ws_final_result;        // 写回数据

// ======================== 异常和刷新控制 ========================
// 总的来说所有改变CSR状态的指令都需要刷新流水线（tlbsrch由于可通过阻塞同步处理器状态，不需要flush）
// 各种刷新信号的生成逻辑,这些信号会导致流水线前级被刷新
assign excp_flush   = ws_excp & ws_valid;  // 异常刷新:发生异常且指令有效时
assign ertn_flush   = ws_ertn & real_valid; // 异常返回刷新:执行ERTN指令且无异常时
// 重取指刷新:CSR写操作、LL/SC指令(无异常)、或显式重取指请求
assign refetch_flush = (ws_csr_we || ((ws_ll_w || ws_sc_w) && !ws_excp) || ws_refetch) && ws_valid;
assign csr_era      = ws_pc;               // CSR异常返回地址设为当前PC
assign csr_wr_en    = ws_csr_we && real_valid; // CSR写使能:只有在指令真实有效时
assign wr_csr_addr  = ws_csr_idx;          // CSR写地址
assign wr_csr_data  = ws_csr_result;       // CSR写数据

assign icacop_flush = ws_icacop_op_en && ws_valid; // 指令Cache操作刷新

assign idle_flush = ws_idle && real_valid;  // 空闲指令刷新

// ======================== TLB指令控制 ========================
// TLB相关指令会导致流水线停顿,直到指令完成
assign tlb_inst_stall = (ws_tlbsrch || ws_tlbrd) && ws_valid;

// TLB指令使能信号:只有在指令真实有效时才执行TLB操作
assign {tlbsrch_en  ,   // TLB搜索使能
        tlbwr_en ,      // TLB写使能  
        tlbfill_en ,    // TLB填充使能
        tlbrd_en  ,     // TLB读使能
        invtlb_en } = {ws_tlbsrch  ,   // TLB搜索指令
                       ws_tlbwr ,      // TLB写指令
                       ws_tlbfill ,    // TLB填充指令
                       ws_tlbrd  ,     // TLB读指令
                       ws_invtlb } & {5{real_valid}}; // 与真实有效信号做与操作

// ======================== Load-Linked/Store-Conditional支持 ========================
// LL/SC指令用于实现原子操作,需要维护链接位(llbit)和链接地址(lladdr)
assign ws_llbit_set  = (ws_ll_w | ws_sc_w) & real_valid;  // 链接位设置条件
assign ws_llbit      = ((ws_ll_w&&!ws_data_uc) & 1'b1) | (ws_sc_w & 1'b0); // LL设置为1,SC设置为0
assign ws_lladdr_set =  ws_ll_w && !ws_data_uc && real_valid; // 链接地址设置条件(LL指令且数据可缓存)
assign ws_lladdr     =  ws_paddr[31:4]; // 链接地址为物理地址的高28位(忽略低4位)

// ======================== 异常处理逻辑 ========================
/*
异常编号对应表(ws_excp_num各位含义):
excp_num[0]  INT     - 中断            TODO(lab2)
        [1]  ADEF    - 取指地址错误     TODO(lab2)
        [2]  TLBR    - 指令TLB重填异常  TODO(lab4)
        [3]  PIF     - 指令页无效异常   TODO(lab4)
        [4]  PPI     - 指令页权限异常   TODO(lab4)
        [5]  SYSCALL - 系统调用         TODO(lab2)
        [6]  BRK     - 断点异常         TODO(lab2)
        [7]  INE     - 指令不存在异常   TODO(lab2)
        [8]  IPE     - 指令权限异常     TODO(lab2)
        [9]  ALE     - 地址非对齐异常   TODO(lab2)
        [10] <保留>   - 未使用
        [11] TLBR    - 数据TLB重填异常  TODO(lab4)
        [12] PME     - 页修改异常       TODO(lab4)
        [13] PPI     - 数据页权限异常   TODO(lab4)
        [14] PIS     - 数据页无效存储异常 TODO(lab4)
        [15] PIL     - 数据页无效加载异常 TODO(lab4)
*/

// TODO(lab2/4): 异常处理优先级编码器
// 提示：信号含义 => {异常码, 虚拟地址错误标志, 错误地址, 异常子码, TLB重填异常, TLB异常, TLB虚拟页号}
assign {csr_ecode,      // 6位异常码 
        va_error,       // 虚拟地址错误标志
        bad_va,         // 32位错误虚拟地址
        csr_esubcode,   // 9位异常子码
        excp_tlbrefill, // TLB重填异常标志
        excp_tlb,       // TLB异常标志
        excp_tlb_vppn}  // 19位TLB异常虚拟页号
        = ws_excp_num[ 0] ? {`ECODE_INT , 1'b0    , 32'b0      , 9'b0          , 1'b0    , 1'b0    , 19'b0             } : // TODO(lab2): 中断
          ws_excp_num[ 1] ? {`ECODE_ADEF, ws_valid, ws_pc      , `ESUBCODE_ADEF, 1'b0    , 1'b0    , 19'b0             } : // TODO(lab2): 取指地址错误
          ws_excp_num[ 2] ? {`ECODE_TLBR, ws_valid, ws_pc      , 9'b0          , ws_valid, ws_valid, ws_pc[31:13]      } : // TODO(lab4): 指令TLB重填
          ws_excp_num[ 3] ? {`ECODE_PIF , ws_valid, ws_pc      , 9'b0          , 1'b0    , ws_valid, ws_pc[31:13]      } : // TODO(lab4): 指令页无效
          ws_excp_num[ 4] ? {`ECODE_PPI , ws_valid, ws_pc      , 9'b0          , 1'b0    , ws_valid, ws_pc[31:13]      } : // TODO(lab4): 指令页权限
          ws_excp_num[ 5] ? {`ECODE_SYS , 1'b0    , 32'b0      , 9'b0          , 1'b0    , 1'b0    , 19'b0             } : // TODO(lab2): 系统调用
          ws_excp_num[ 6] ? {`ECODE_BRK , 1'b0    , 32'b0      , 9'b0          , 1'b0    , 1'b0    , 19'b0             } : // TODO(lab2): 断点
          ws_excp_num[ 7] ? {`ECODE_INE , 1'b0    , 32'b0      , 9'b0          , 1'b0    , 1'b0    , 19'b0             } : // TODO(lab2): 指令不存在
          ws_excp_num[ 8] ? {`ECODE_IPE , 1'b0    , 32'b0      , 9'b0          , 1'b0    , 1'b0    , 19'b0             } : // TODO(lab4): 指令权限异常(暂不考虑)
          ws_excp_num[ 9] ? {`ECODE_ALE , ws_valid, ws_error_va, 9'b0          , 1'b0    , 1'b0    , 19'b0             } : // TODO(lab2): 地址非对齐
          ws_excp_num[11] ? {`ECODE_TLBR, ws_valid, ws_error_va, 9'b0          , ws_valid, ws_valid, ws_error_va[31:13]} : // TODO(lab4): 数据TLB重填
          ws_excp_num[12] ? {`ECODE_PME , ws_valid, ws_error_va, 9'b0          , 1'b0    , ws_valid, ws_error_va[31:13]} : // TODO(lab4): 页修改异常
          ws_excp_num[13] ? {`ECODE_PPI , ws_valid, ws_error_va, 9'b0          , 1'b0    , ws_valid, ws_error_va[31:13]} : // TODO(lab4): 数据页权限
          ws_excp_num[14] ? {`ECODE_PIS , ws_valid, ws_error_va, 9'b0          , 1'b0    , ws_valid, ws_error_va[31:13]} : // TODO(lab4): 数据页无效存储
          ws_excp_num[15] ? {`ECODE_PIL , ws_valid, ws_error_va, 9'b0          , 1'b0    , ws_valid, ws_error_va[31:13]} : // TODO(lab4): 数据页无效加载
          69'b0; // 默认值:无异常

// ======================== INVTLB指令支持 ========================
// INVTLB指令的操作码通过目标寄存器编号传递
assign invtlb_op = ws_dest;

// ======================== 调试信息生成 ========================
// 这些信号用于仿真调试和跟踪分析
assign debug_wb_pc       = ws_pc;           // 调试用PC值
assign debug_wb_rf_wen   = {4{rf_we}};      // 调试用寄存器写使能(4位全部设为相同值)
assign debug_wb_rf_wnum  = ws_dest;         // 调试用寄存器写编号
assign debug_wb_rf_wdata = ws_final_result; // 调试用寄存器写数据
assign debug_wb_inst     = ws_inst;         // 调试用指令码
assign debug_ws_valid    = ws_valid;        // 调试用写回阶段有效信号

// ======================== Difftest信号输出 ========================
// Difftest用于与参考模型进行对比验证
`ifdef DIFFTEST_EN
assign ws_valid_diff        = real_valid        ; // difftest的有效信号
assign ws_timer_64_diff     = ws_timer_64       ; // difftest的定时器值
assign ws_cnt_inst_diff     = ws_cnt_inst       ; // difftest的指令计数

assign ws_inst_ld_en_diff   = ws_inst_ld_en     ; // difftest的加载指令使能
assign ws_ld_paddr_diff     = ws_ld_paddr       ; // difftest的加载物理地址
assign ws_ld_vaddr_diff     = ws_ld_vaddr       ; // difftest的加载虚拟地址

assign ws_inst_st_en_diff   = ws_inst_st_en     ; // difftest的存储指令使能
assign ws_st_paddr_diff     = ws_ld_paddr_diff  ; // difftest的存储物理地址(复用加载地址)
assign ws_st_vaddr_diff     = ws_ld_vaddr_diff  ; // difftest的存储虚拟地址(复用加载地址)
assign ws_st_data_diff      = ws_st_data        ; // difftest的存储数据

assign ws_csr_rstat_en_diff = ws_csr_rstat_en   ; // difftest的CSR状态读使能
assign ws_csr_data_diff     = ws_csr_data       ; // difftest的CSR数据
`endif

endmodule
