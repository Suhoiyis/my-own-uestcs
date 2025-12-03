`include "mycpu.vh"
`include "csr.vh"

/*
 * 访存阶段 (Memory Stage) - 五级流水线的第四级
 * 主要功能：
 * 1. 处理访存指令的数据读写操作
 * 2. 处理TLB相关指令和地址转换
 * 3. 处理缓存操作指令
 * 4. 异常检测和处理
 * 5. 数据前递给译码阶段
 */
module mem_stage(
    // 时钟和复位信号
    input                              clk           ,
    input                              reset         ,
    
    // 流水线控制信号 - allowin机制控制流水线暂停
    input                              ws_allowin    ,    // 写回阶段允许新数据进入
    output                             ms_allowin    ,    // 访存阶段允许新数据进入
    
    // 来自执行阶段的数据
    input                              es_to_ms_valid,    // 执行阶段数据有效
    input  [`ES_TO_MS_BUS_WD -1:0]     es_to_ms_bus  ,    // 执行阶段传来的数据总线
    
    // 到写回阶段的数据
    output                             ms_to_ws_valid,    // 访存阶段数据有效
    output [`MS_TO_WS_BUS_WD -1:0]     ms_to_ws_bus  ,    // 传给写回阶段的数据总线
    
    // 数据前递通路 - 解决数据相关
    output [`MS_TO_DS_FORWARD_BUS-1:0] ms_to_ds_forward_bus,  // 前递数据到译码阶段
    output                             ms_to_ds_valid,
    
    // 乘除法运算结果
    input  [31:0]     div_result    ,    // 除法结果
    input  [31:0]     mod_result    ,    // 取模结果
    input  [63:0]     mul_result    ,    // 乘法结果(64位)
    
    // 异常和刷新信号
    input             excp_flush    ,    // 异常刷新
    input             ertn_flush    ,    // 异常返回刷新
    input             refetch_flush ,    // 重取指刷新
    input             icacop_flush  ,    // 指令缓存操作刷新
    
    // 空闲刷新
    input             idle_flush    ,
    
    // TLB指令相关
    output            tlb_inst_stall,    // TLB指令暂停
    
    // 到执行阶段的信号
    output            ms_wr_tlbehi  ,    // 写TLB EHI寄存器
    output            ms_flush      ,    // 访存阶段刷新信号
    
    // 数据缓存接口
    input             data_data_ok   ,   // 数据缓存数据准备好
    input             dcache_miss    ,   // 数据缓存缺失
    input  [31:0]     data_rdata     ,   // 数据缓存读数据
    
    // 到数据缓存的控制信号
    output            data_uncache_en,        // 数据不缓存使能
    output            tlb_excp_cancel_req,    // TLB异常取消请求
    output            sc_cancel_req  ,        // 条件存储取消请求
    
    // CSR寄存器相关信号
    input             csr_pg         ,   // 页式管理使能
    input             csr_da         ,   // 直接地址转换模式
    input  [31:0]     csr_dmw0       ,   // 直接映射窗口0
    input  [31:0]     csr_dmw1       ,   // 直接映射窗口1
    input  [ 1:0]     csr_plv        ,   // 当前特权级
    input  [ 1:0]     csr_datm       ,   // 数据地址转换模式
    input  [27:0]     lladdr         ,   // 链接地址寄存器
    
    // difftest相关信号 - 用于验证
    input  [ 7:0]     data_index_diff   ,  // 数据索引(用于difftest)
    input  [19:0]     data_tag_diff     ,  // 数据标签(用于difftest)
    input  [ 3:0]     data_offset_diff  ,  // 数据偏移(用于difftest)
    
    // 地址转换控制信号
    output            dmw0_en           ,   // 直接映射窗口0使能
    output            dmw1_en           ,   // 直接映射窗口1使能
    output            cacop_op_mode_di  ,   // 缓存操作模式
    
    // TLB查询结果
    input             data_tlb_found ,  // TLB条目找到
    input  [ 4:0]     data_tlb_index ,  // TLB条目索引
    input             data_tlb_v     ,  // TLB条目有效位
    input             data_tlb_d     ,  // TLB条目脏位
    input  [ 1:0]     data_tlb_mat   ,  // TLB条目内存访问类型
    input  [ 1:0]     data_tlb_plv   ,  // TLB条目特权级
    input  [19:0]     data_tlb_ppn      // TLB条目物理页号
);

// =========== 流水线控制逻辑 ===========
reg         ms_valid;        // 访存阶段数据有效标志
wire        ms_ready_go;     // 访存阶段准备就绪信号

wire        dep_need_stall;  // 数据相关需要暂停

// 执行阶段传来的数据总线寄存器
reg [`ES_TO_MS_BUS_WD -1:0] es_to_ms_bus_r;
// =========== 解析执行阶段传来的数据总线 ===========
// 从执行阶段传来的信号定义
wire [ 3:0] ms_mul_div_op;      // 乘除法操作类型
wire [ 1:0] sram_addr_low2bit;  // 地址低2位(用于字节/半字访问)
wire [ 1:0] ms_mem_size;        // 访存大小: 00-字, 01-字节, 10-半字
wire        ms_load_op;         // 加载操作
wire        ms_gr_we;           // 通用寄存器写使能
wire [ 4:0] ms_dest;            // 目标寄存器号
wire [31:0] ms_exe_result;      // 执行阶段计算结果
wire [31:0] ms_pc;              // 程序计数器
wire        ms_excp;            // 异常标志
wire [ 9:0] ms_excp_num;        // 异常号
wire        ms_ertn;            // 异常返回指令
wire [31:0] ms_csr_result;      // CSR操作结果
wire [13:0] ms_csr_idx;         // CSR寄存器索引
wire        ms_csr_we;          // CSR写使能
wire        ms_ll_w;            // 链接加载指令
wire        ms_sc_w;            // 条件存储指令
wire        ms_store_op;        // 存储操作
wire        ms_tlbsrch;         // TLB搜索指令
wire        ms_tlbfill;         // TLB填充指令
wire        ms_tlbwr;           // TLB写指令
wire        ms_tlbrd;           // TLB读指令
wire        ms_refetch;         // 重取指指令
wire        ms_invtlb;          // TLB无效指令
wire [ 9:0] ms_invtlb_asid;     // TLB无效ASID
wire [18:0] ms_invtlb_vpn;      // TLB无效虚拟页号
wire        ms_mem_sign_exted;  // 内存符号扩展
wire        ms_icacop_op_en;    // 指令缓存操作使能
wire        ms_br_inst;         // 分支指令
wire        ms_icache_miss;     // 指令缓存缺失
wire        ms_br_pre;          // 分支预测
wire        ms_br_pre_error;    // 分支预测错误
wire        ms_preld_inst;      // 预取指令
wire        ms_cacop;           // 缓存操作指令
wire        ms_idle;            // 空闲指令
wire [31:0] ms_error_va;        // 错误虚拟地址

// difftest相关信号定义
wire        ms_cnt_inst     ;   // 计数指令
wire [63:0] ms_timer_64     ;   // 64位定时器
wire [31:0] ms_inst         ;   // 指令
wire [ 7:0] ms_inst_ld_en   ;   // 加载指令使能
wire [31:0] ms_ld_paddr     ;   // 加载物理地址
wire [31:0] ms_ld_vaddr     ;   // 加载虚拟地址
wire [ 7:0] ms_inst_st_en   ;   // 存储指令使能
wire [31:0] ms_st_data      ;   // 存储数据
wire        ms_csr_rstat_en ;   // CSR读状态使能
wire [31:0] ms_csr_data     ;   // CSR数据

// =========== 数据总线解包 ===========
// 将执行阶段传来的打包数据解包为各个信号
assign {ms_csr_data      ,  //424:393  for difftest
        ms_csr_rstat_en  ,  //392:392  for difftest
        ms_st_data       ,  //391:360  for difftest
        ms_inst_st_en    ,  //359:352  for difftest
        ms_ld_vaddr      ,  //351:320  for difftest
        ms_inst_ld_en    ,  //319:312  for difftest
        ms_cnt_inst      ,  //311:311  for difftest
        ms_timer_64      ,  //310:247  for difftest
        ms_inst          ,  //246:215  for difftest
        ms_error_va      ,  //214:183  错误虚拟地址
        ms_idle          ,  //182:182  空闲指令
        ms_cacop         ,  //181:181  缓存操作指令
        ms_preld_inst    ,  //180:180  预取指令
        ms_br_pre_error  ,  //179:179  分支预测错误
        ms_br_pre        ,  //178:178  分支预测
        ms_icache_miss   ,  //177:177  指令缓存缺失
        ms_br_inst       ,  //176:176  分支指令
        ms_icacop_op_en  ,  //175:175  指令缓存操作使能
        ms_mem_sign_exted,  //174:174  内存符号扩展
        ms_invtlb_vpn    ,  //173:155  TLB无效虚拟页号
        ms_invtlb_asid   ,  //154:145  TLB无效ASID
        ms_invtlb        ,  //144:144  TLB无效指令
        ms_tlbrd         ,  //143:143  TLB读指令
        ms_refetch       ,  //142:142  重取指指令
        ms_tlbfill       ,  //141:141  TLB填充指令
        ms_tlbwr         ,  //140:140  TLB写指令
        ms_tlbsrch       ,  //139:139  TLB搜索指令
        ms_store_op      ,  //138:138  存储操作
        ms_sc_w          ,  //137:137  条件存储指令
        ms_ll_w          ,  //136:136  链接加载指令
        ms_excp_num      ,  //135:126  异常号
        ms_csr_we        ,  //125:125  CSR写使能
        ms_csr_idx       ,  //124:111  CSR寄存器索引
        ms_csr_result    ,  //110:79   CSR操作结果
        ms_ertn          ,  //78:78    异常返回指令
        ms_excp          ,  //77:77    异常标志
        ms_mem_size      ,  //76:75    访存大小
        ms_mul_div_op    ,  //74:71    乘除法操作类型
        ms_load_op       ,  //70:70    加载操作
        ms_gr_we         ,  //69:69    通用寄存器写使能
        ms_dest          ,  //68:64    目标寄存器号
        ms_exe_result    ,  //63:32    执行阶段计算结果
        ms_pc               //31:0     程序计数器
       } = es_to_ms_bus_r;

// =========== 数据处理相关信号 ===========
wire [31:0] mem_result;      // 内存读取结果
wire [31:0] ms_final_result; // 最终结果
wire        flush_sign;      // 刷新信号

wire [31:0] ms_rdata;        // 内存读数据
reg  [31:0] data_rd_buff;    // 数据读缓冲
reg         data_buff_enable; // 数据缓冲使能

wire        access_mem;      // 访存标志

// 缓存操作相关
wire [ 4:0] cacop_op;        // 缓存操作码
wire [ 1:0] cacop_op_mode;   // 缓存操作模式

// 前递控制
wire        forward_enable;  // 前递使能
wire        dest_zero;       // 目标寄存器为0

wire [31:0] paddr;          // 物理地址

// 异常处理
wire [15:0] excp_num;       // 异常号(扩展)
wire        excp;           // 异常标志

// TLB相关异常
wire        excp_tlbr;      // TLB重填异常
wire        excp_pil ;      // 页无效异常(加载)
wire        excp_pis ;      // 页无效异常(存储)
wire        excp_pme ;      // 页修改异常
wire        excp_ppi ;      // 页特权异常

// 地址转换模式
wire        data_addr_trans_en;   // 数据地址转换使能
wire        da_mode  ;      // 直接地址转换模式
wire        pg_mode  ;      // 页式管理模式

wire        sc_addr_eq;     // 条件存储地址匹配

// =========== 传递给写回阶段的数据总线 ===========
// 将当前阶段的各种信号打包传递给写回阶段
assign ms_to_ws_bus = {ms_csr_data    ,  //492:461 for difftest
                       ms_csr_rstat_en,  //460:460 for difftest
                       ms_st_data     ,  //459:428 for difftest
                       ms_inst_st_en  ,  //427:420 for difftest
                       ms_ld_vaddr    ,  //419:388 for difftest
                       ms_ld_paddr    ,  //387:356 for difftest
                       ms_inst_ld_en  ,  //355:348 for difftest
                       ms_cnt_inst    ,  //347:347 for difftest
                       ms_timer_64    ,  //346:283 for difftest
                       ms_inst        ,  //282:251 for difftest
					   data_uncache_en,  //250:250 不缓存使能
					   paddr          ,  //249:218 物理地址
                       ms_idle        ,  //217:217 空闲指令
                       ms_br_pre_error,  //216:216 分支预测错误
                       ms_br_pre      ,  //215:215 分支预测
                       dcache_miss    ,  //214:214 数据缓存缺失
                       access_mem     ,  //213:213 访存标志
                       ms_icache_miss ,  //212:212 指令缓存缺失
                       ms_br_inst     ,  //211:211 分支指令
                       ms_icacop_op_en,  //210:210 指令缓存操作使能
                       ms_invtlb_vpn  ,  //209:191 TLB无效虚拟页号
                       ms_invtlb_asid ,  //190:181 TLB无效ASID
                       ms_invtlb      ,  //180:180 TLB无效指令
                       ms_tlbrd       ,  //179:179 TLB读指令
                       ms_refetch     ,  //178:178 重取指指令
                       ms_tlbfill     ,  //177:177 TLB填充指令
                       ms_tlbwr       ,  //176:176 TLB写指令
                       data_tlb_index ,  //175:171 数据TLB索引
                       data_tlb_found ,  //170:170 数据TLB找到
                       ms_tlbsrch     ,  //169:169 TLB搜索指令
                       ms_error_va    ,  //168:137 错误虚拟地址
                       ms_sc_w        ,  //136:136 条件存储指令
                       ms_ll_w        ,  //135:135 链接加载指令
                       excp_num       ,  //134:119 异常号
                       ms_csr_we      ,  //118:118 CSR写使能
                       ms_csr_idx     ,  //117:104 CSR寄存器索引
                       ms_csr_result  ,  //103:72  CSR操作结果
                       ms_ertn        ,  //71:71   异常返回指令
                       excp           ,  //70:70   异常标志
                       ms_gr_we       ,  //69:69   通用寄存器写使能
                       ms_dest        ,  //68:64   目标寄存器号
                       ms_final_result,  //63:32   最终结果
                       ms_pc             //31:0    程序计数器
                      };

assign ms_to_ds_valid = ms_valid;

// =========== 流水线控制逻辑 ===========
// TODO(lab1): 访存阶段准备就绪条件
// 提示：
// 1. dcache数据准备好 或 数据缓冲区有效
// 3. 不访问内存
// 4. 异常发生
// 5. 条件存储取消请求
assign ms_ready_go    = (data_data_ok || data_buff_enable) || !access_mem || excp || sc_cancel_req;
// TODO(lab1): 访存阶段允许接收新数据
// 提示：(当前无有效数据(ms_valid为假 或 准备就绪) 且 写回阶段允许接收新数据(ws_allowin))
assign ms_allowin     = !ms_valid || ms_ready_go && ws_allowin;
// TODO(lab1): 传给写回阶段的数据有效
// 提示：数据有效且准备就绪
assign ms_to_ws_valid = ms_valid && ms_ready_go;

// 流水线寄存器更新逻辑
always @(posedge clk) begin
    if (reset || flush_sign) begin
        ms_valid <= 1'b0;              // 复位或刷新时清除有效标志
    end
    else if (ms_allowin) begin
        ms_valid <= es_to_ms_valid;    // 允许进入时更新有效标志
    end

    if (es_to_ms_valid && ms_allowin) begin
        es_to_ms_bus_r <= es_to_ms_bus;    // 锁存执行阶段传来的数据
    end
end                            

// =========== 内存访问控制 ===========
assign access_mem = ms_store_op || ms_load_op;     // 访存标志：存储或加载操作

// 刷新信号：任何一种刷新情况都会导致流水线刷新
assign flush_sign = excp_flush || ertn_flush || refetch_flush || icacop_flush || idle_flush;

// 内存读数据选择：如果缓冲区有效则使用缓冲数据，否则使用直接读取的数据
assign ms_rdata = data_buff_enable ? data_rd_buff : data_rdata;

// 获取地址的低2位，用于字节和半字访问的字节选择
assign sram_addr_low2bit = {ms_exe_result[1], ms_exe_result[0]};

// =========== 内存数据处理逻辑 ===========
// 字节数据选择：根据地址低2位选择对应的字节
wire [7:0] mem_byteLoaded = ({8{sram_addr_low2bit==2'b00}} & ms_rdata[ 7: 0]) |    // 地址[1:0]=00，选择字节0
                            ({8{sram_addr_low2bit==2'b01}} & ms_rdata[15: 8]) |    // 地址[1:0]=01，选择字节1
                            ({8{sram_addr_low2bit==2'b10}} & ms_rdata[23:16]) |    // 地址[1:0]=10，选择字节2
                            ({8{sram_addr_low2bit==2'b11}} & ms_rdata[31:24]) ;    // 地址[1:0]=11，选择字节3

// 半字数据选择：根据地址低2位选择对应的半字（只有00和10两种情况）
wire [15:0] mem_halfLoaded = ({16{sram_addr_low2bit==2'b00}} & ms_rdata[15: 0]) |  // 地址[1:0]=00，选择低半字
                             ({16{sram_addr_low2bit==2'b10}} & ms_rdata[31:16]) ;  // 地址[1:0]=10，选择高半字

// 内存读取结果处理：根据访存大小和符号扩展要求进行数据整理
assign mem_result = ({32{ms_mem_size[0] &&  ms_mem_sign_exted}} & {{24{mem_byteLoaded[ 7]}}, mem_byteLoaded}) |  // 字节有符号扩展
                    ({32{ms_mem_size[0] && ~ms_mem_sign_exted}} & { 24'b0                  , mem_byteLoaded}) |  // 字节无符号扩展
                    ({32{ms_mem_size[1] &&  ms_mem_sign_exted}} & {{16{mem_halfLoaded[15]}}, mem_halfLoaded}) |  // 半字有符号扩展
                    ({32{ms_mem_size[1] && ~ms_mem_sign_exted}} & { 16'b0                  , mem_halfLoaded}) |  // 半字无符号扩展
                    ({32{ms_mem_size == 2'b00}}                 &   ms_rdata                                  ) ; // 字访问，直接使用

// =========== 最终结果选择 ===========
// 根据指令类型选择最终的结果数据
assign ms_final_result = ({32{ms_load_op      }} & mem_result       )  |     // 加载指令：使用内存读取结果
                         ({32{ms_mul_div_op[0]}} & mul_result[31:0] )  |     // 乘法低32位
                         ({32{ms_mul_div_op[1]}} & mul_result[63:32])  |     // 乘法高32位
                         ({32{ms_mul_div_op[2]}} & div_result       )  |     // 除法结果
                         ({32{ms_mul_div_op[3]}} & mod_result       )  |     // 取模结果
                         ({32{ms_mul_div_op == 4'b0000 && !ms_load_op}} & (ms_exe_result&{32{!sc_cancel_req}})); // 其他指令：使用执行结果

// =========== 数据前递逻辑 ===========
// 检查目标寄存器是否为0号寄存器（0号寄存器不能写入）
assign dest_zero            = (ms_dest == 5'b0);
// TODO(lab1): 前递使能条件
// 提示：写寄存器、目标不为0、当前阶段有效
assign forward_enable       = ms_gr_we & ~dest_zero & ms_valid;
// TODO(lab1): 加载指令需要暂停
// 提示：当加载指令还没到写回阶段时，后续指令需要等待
assign dep_need_stall       = ms_load_op && !ms_to_ws_valid;
// 前递数据总线：包含暂停信号、前递使能、目标寄存器号和数据
assign ms_to_ds_forward_bus = {dep_need_stall,  //38:38  暂停需求
                               forward_enable,  //37:37  前递使能
                               ms_dest       ,  //36:32  目标寄存器号
                               ms_final_result  //31:0   前递数据
                              };

// =========== 地址转换模式判断 ===========
assign pg_mode = !csr_da && csr_pg;     // 页式管理模式：非直接地址且页式管理使能
assign da_mode =  csr_da && !csr_pg;    // 直接地址转换模式：直接地址且页式管理禁用

// 数据地址转换使能：页式管理模式且不使用直接映射窗口且不是缓存操作
assign data_addr_trans_en = pg_mode && !dmw0_en && !dmw1_en && !cacop_op_mode_di;

// 物理地址组合：TLB物理页号 + 虚拟地址的页内偏移
assign paddr = {data_tlb_ppn, ms_error_va[11:0]};

// 条件存储地址匹配检查：比较链接地址寄存器与当前物理地址
assign sc_addr_eq = (lladdr == paddr[31:4]);
// 条件存储取消请求：地址不匹配或不可缓存的条件存储指令
assign sc_cancel_req = (!sc_addr_eq||data_uncache_en) && ms_sc_w && access_mem;

// =========== 直接映射窗口使能判断 ===========
// TODO(lab4): DMW0使能条件
// 提示：特权级匹配 && 虚拟段匹配 && 页式管理模式
assign dmw0_en = ((csr_dmw0[`PLV0] && csr_plv == 2'd0) || (csr_dmw0[`PLV3] && csr_plv == 2'd3)) && 
                 (ms_error_va[31:29] == csr_dmw0[`VSEG]) && pg_mode;

// TODO(lab4): DMW1使能条件
// 提示：特权级匹配 && 虚拟段匹配 && 页式管理模式
assign dmw1_en = ((csr_dmw1[`PLV0] && csr_plv == 2'd0) || (csr_dmw1[`PLV3] && csr_plv == 2'd3)) && 
                 (ms_error_va[31:29] == csr_dmw1[`VSEG]) && pg_mode;

// =========== 异常处理逻辑 ===========
// 综合异常标志：TLB异常 || 原有异常
assign excp = excp_tlbr || excp_pil || excp_pis || excp_ppi || excp_pme || ms_excp;
// 扩展异常号：将各种TLB异常编码加入异常号中
assign excp_num = {excp_pil, excp_pis, excp_ppi, excp_pme, excp_tlbr, 1'b0, ms_excp_num};

// TODO(lab4): TLB相关异常检测（预取指令preld不应该产生这些异常）
// 提示：
// 1. TLB重填异常：当访问内存或执行缓存操作(cacop)时，TLB未找到且地址转换使能
// 2. 页无效异常(加载)：当加载操作或执行缓存操作时，TLB条目无效且地址转换使能
// 3. 页无效异常(存储)：当存储操作时，TLB条目无效且地址转换使能
// 4. 页特权异常：当访问内存时，TLB条目有效但特权级不匹配且地址转换使能
// 5. 页修改异常：当存储操作时，TLB条目有效且特权级匹配但脏位未设置且地址转换使能
assign excp_tlbr = (access_mem || ms_cacop) && !data_tlb_found && data_addr_trans_en;  // TLB重填异常
assign excp_pil  = (ms_load_op || ms_cacop) && !data_tlb_v && data_addr_trans_en;      // 页无效异常(加载)
assign excp_pis  = ms_store_op && !data_tlb_v && data_addr_trans_en;                   // 页无效异常(存储)
assign excp_ppi  = access_mem && data_tlb_v && (csr_plv > data_tlb_plv) && data_addr_trans_en;  // 页特权异常
assign excp_pme  = ms_store_op && data_tlb_v && (csr_plv <= data_tlb_plv) && !data_tlb_d && data_addr_trans_en; // 页修改异常

// TLB异常取消请求：发生任何TLB异常时取消内存访问请求
assign tlb_excp_cancel_req = excp_tlbr || excp_pil || excp_pis || excp_ppi || excp_pme;

// =========== 缓存控制逻辑 ===========
// TODO(lab3/4): 判断访存地址是否为uncache属性
// 提示，满足以下条件则为uncache地址：
// 1. TODO(lab3)直接地址模式且数据地址转换模式为0
// 2. TODO(lab3)DMW0使能且内存访问类型为0
// 3. TODO(lab3)DMW1使能且内存访问类型为0
// 4. TODO(lab4)地址转换使能且TLB内存访问类型为0
assign data_uncache_en = (da_mode && (csr_datm == 2'b0))                 ||  // 直接地址模式且数据地址转换模式为0
                         (dmw0_en && (csr_dmw0[`DMW_MAT] == 2'b0))       ||  // DMW0使能且内存访问类型为0
                         (dmw1_en && (csr_dmw1[`DMW_MAT] == 2'b0))       ||  // DMW1使能且内存访问类型为0
                         (data_addr_trans_en && (data_tlb_mat == 2'b0))  ;   // 地址转换使能且TLB内存访问类型为0

// =========== 流水线刷新控制 ===========
// 访存阶段刷新条件：异常 || 异常返回 || CSR写入 || LL/SC指令 || 重取指 || 空闲指令
assign ms_flush = (excp | ms_ertn | (ms_csr_we | (ms_ll_w | ms_sc_w) & !excp) | ms_refetch | ms_idle) & ms_valid;

// =========== TLB指令暂停控制 ===========
// TLB搜索或读指令需要暂停流水线
assign tlb_inst_stall = (ms_tlbsrch || ms_tlbrd) && ms_valid;

// =========== 数据缓冲逻辑 ===========
// 当缓存数据准备好但写回阶段不允许进入时，需要缓冲数据
// 因为dcache只维持1拍有效数据，故需要缓冲
always @(posedge clk) begin
   if (reset || (ms_ready_go && ws_allowin) || flush_sign) begin
       data_rd_buff <= 32'b0;      // 清空缓冲区
       data_buff_enable <= 1'b0;   // 禁用缓冲
   end
   else if (data_data_ok && !ws_allowin) begin
       data_rd_buff <= data_rdata;     // 缓冲读取的数据
       data_buff_enable <= 1'b1;       // 使能缓冲
   end
end

// =========== CSR写入控制 ===========
// 当写入TLBEHI寄存器时需要通知执行阶段暂停TLB搜索
assign ms_wr_tlbehi = ms_csr_we && (ms_csr_idx == 14'h11) && ms_valid;

// =========== 缓存操作控制(for addr trans) ===========
assign cacop_op = ms_dest;                           // 缓存操作码从目标寄存器号获取
assign cacop_op_mode    = cacop_op[4:3];             // 缓存操作模式
assign cacop_op_mode_di = ms_cacop && ((cacop_op_mode == 2'b0) || (cacop_op_mode == 2'b1)); // 直接索引模式

// =========== difftest相关逻辑 ===========
// 用于验证的物理地址计算
reg  [ 7:0] tmp_data_index  ;
reg  [ 3:0] tmp_data_offset ;
always @(posedge clk) begin
    tmp_data_index  <= data_index_diff;    // 缓存数据索引
    tmp_data_offset <= data_offset_diff;   // 缓存数据偏移
end

// 组合物理地址：标签 + 索引 + 偏移
assign ms_ld_paddr = {data_tag_diff, tmp_data_index, tmp_data_offset};

endmodule
