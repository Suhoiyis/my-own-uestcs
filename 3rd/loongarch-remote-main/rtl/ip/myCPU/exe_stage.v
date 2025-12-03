// LoongArch架构五级流水线处理器 - 执行阶段(Execute Stage)
// 主要功能：
// 1. 执行ALU运算和乘除法运算
// 2. 处理访存指令的地址计算和数据格式化
// 3. 处理CSR指令和异常
// 4. 处理TLB相关指令
// 5. 处理Cache操作指令
// 6. 实现数据前递机制

`include "mycpu.vh" 
`include "csr.vh"

module exe_stage(
    //========================= 时钟与复位 =========================
    input         clk                , // 时钟信号
    input         reset              , // 复位信号

    //======================= 流水线控制信号 =======================
    input         ms_allowin         , // 访存阶段允许接收新指令
    output        es_allowin         , // 执行阶段允许接收新指令

    //======================= 译码阶段接口 =========================
    input         ds_to_es_valid     , // 译码阶段传来数据有效
    input  [`DS_TO_ES_BUS_WD-1:0] ds_to_es_bus , // 译码阶段数据总线

    //======================= 访存阶段接口 =========================
    output        es_to_ms_valid     , // 传给访存阶段数据有效
    output [`ES_TO_MS_BUS_WD-1:0] es_to_ms_bus , // 传给访存阶段数据总线

    //======================= 数据前递接口 =========================
    output [`ES_TO_DS_FORWARD_BUS-1:0] es_to_ds_forward_bus, // 前递数据总线
    output        es_to_ds_valid     , // 前递数据有效

    //======================= 乘除法单元接口 =======================
    output        es_div_enable      , // 除法使能信号
    output        es_mul_div_sign    , // 乘除法符号位
    output [31:0] es_rj_value        , // 源寄存器1的值
    output [31:0] es_rkd_value       , // 源寄存器2/目标寄存器的值
    input         div_complete       , // 除法完成信号

    //======================= 异常/特殊指令刷新 ====================
    input         excp_flush         , // 异常刷新
    input         ertn_flush         , // 异常返回刷新
    input         refetch_flush      , // 重取指刷新
    input         icacop_flush       , // 指令Cache操作刷新

    //======================= 空闲指令刷新 =========================
    input         idle_flush         , // 空闲指令刷新

    //======================= TLB指令控制 ==========================
    output        tlb_inst_stall     , // TLB指令停顿信号

    //======================= Cache操作指令控制 ====================
    output        icacop_op_en       , // 指令Cache操作使能
    output        dcacop_op_en       , // 数据Cache操作使能
    output [ 1:0] cacop_op_mode      , // Cache操作模式

    //======================= 指令Cache信号 ========================
    input         icache_unbusy      , // 指令Cache空闲

    //======================= 预取指令控制 =========================
    output [ 4:0] preld_hint         , // 预取提示
    output        preld_en           , // 预取使能

    //======================= 数据Cache接口 ========================
    output        data_valid         , // 数据请求有效
    output        data_op            , // 数据操作类型（读/写）
    output [ 2:0] data_size          , // 数据大小
    output [ 3:0] data_wstrb         , // 写字节使能
    output [31:0] data_wdata         , // 写数据
    input         data_addr_ok       , // 数据地址握手成功

    //======================= CSR相关信号 ==========================
    input  [18:0] csr_vppn           , // CSR中的虚拟页号

    //======================= 地址转换接口 =========================
    output [31:0] data_addr          , // 数据地址
    output        data_fetch         , // 数据获取信号

    //======================= 访存阶段信号 =========================
    input         ms_wr_tlbehi       , // 访存阶段写TLB Entry Hi
    input         ms_flush             // 访存阶段刷新信号
);


//===================================================================================
//                              内部信号定义
//===================================================================================

// 流水线控制信号
reg         es_valid      ;  // 执行阶段数据有效标志
wire        es_ready_go   ;  // 执行阶段准备就绪信号

wire [31:0] error_va      ;  // 异常虚拟地址

// 译码阶段传来的数据寄存器
reg  [`DS_TO_ES_BUS_WD -1:0] ds_to_es_bus_r;

// 从数据总线中解析出的各种控制信号和数据
wire [13:0] es_alu_op      ;  // ALU操作码
wire        es_src1_is_pc  ;  // 源操作数1是否为PC
wire        es_src2_is_imm ;  // 源操作数2是否为立即数
wire        es_src2_is_4   ;  // 源操作数2是否为常数4
wire        es_gr_we       ;  // 通用寄存器写使能
wire        es_store_op    ;  // 存储操作标志
wire [ 4:0] es_dest        ;  // 目标寄存器编号
wire [31:0] es_imm         ;  // 立即数
wire [31:0] es_pc          ;  // 程序计数器
wire [ 3:0] es_mul_div_op  ;  // 乘除法操作码
wire [ 1:0] es_mem_size    ;  // 内存操作大小
wire [31:0] es_csr_data    ;  // CSR数据
wire [13:0] es_csr_idx     ;  // CSR索引
wire [31:0] es_csr_result  ;  // CSR操作结果
wire [31:0] csr_mask_result;  // CSR掩码操作结果
wire        es_res_from_csr;  // 结果来自CSR
wire        es_csr_we      ;  // CSR写使能
wire        es_csr_mask    ;  // CSR掩码操作
wire        es_excp        ;  // 异常标志
wire        excp           ;  // 最终异常标志
wire [ 8:0] es_excp_num    ;  // 异常编号
wire [ 9:0] excp_num       ;  // 最终异常编号
wire        es_ertn        ;  // 异常返回指令
wire        es_mul_enable  ;  // 乘法使能
wire        div_stall      ;  // 除法停顿
wire        es_ll_w        ;  // LL指令（原子加载）
wire        es_sc_w        ;  // SC指令（原子存储）
wire        es_tlbsrch     ;  // TLB搜索指令
wire        es_tlbwr       ;  // TLB写指令
wire        es_tlbfill     ;  // TLB填充指令
wire        es_tlbrd       ;  // TLB读指令
wire        es_refetch     ;  // 重取指指令
wire        es_invtlb      ;  // TLB无效化指令
wire [ 9:0] es_invtlb_asid ;  // TLB无效化ASID
wire [18:0] es_invtlb_vpn  ;  // TLB无效化虚拟页号
wire        es_cacop       ;  // Cache操作指令
wire        es_preld       ;  // 预取指令
wire        es_br_inst     ;  // 分支指令
wire        es_icache_miss ;  // 指令Cache缺失
wire        es_idle        ;  // 空闲指令

wire        es_load_op     ;  // 加载操作标志

// 数据前递相关信号
wire        dep_need_stall ;  // 数据依赖需要停顿
wire        forward_enable ;  // 前递使能
wire        dest_zero      ;  // 目标寄存器为0

// 异常相关信号
wire        excp_ale       ;  // 地址不对齐异常

// 控制信号
wire        es_flush_sign  ;  // 刷新信号
wire [ 3:0] wr_byte_en     ;  // 写字节使能

// 内存访问相关信号
wire        access_mem      ;       // 访问内存标志
wire        es_mem_sign_exted;      // 内存符号扩展
wire [ 1:0] sram_addr_low2bit;      // 地址低2位

wire        tlbsrch_stall  ;        // TLB搜索停顿

wire [31:0] pv_addr        ;        // 物理/虚拟地址

wire [ 4:0] cacop_op        ;       // Cache操作码

wire        dcache_req_or_inst_en;  // 数据Cache请求或cacop指令使能

// Cache和预取指令标志
wire        icacop_inst      ;      // 指令Cache操作指令
wire        icacop_inst_stall;      // 指令Cache操作停顿
wire        dcacop_inst      ;      // 数据Cache操作指令
wire        preld_inst       ;      // 预取指令

// 分支预测相关信号
wire        es_br_pre_error  ;      // 分支预测错误
wire        es_br_pre        ;      // 分支预测

// difftest相关信号（用于仿真验证）
wire [31:0] es_inst         ;       // 指令
wire [63:0] es_timer_64     ;       // 64位计时器
wire        es_cnt_inst     ;       // 指令计数
wire [ 7:0] es_inst_ld_en   ;       // 加载指令使能
wire [ 7:0] es_inst_st_en   ;       // 存储指令使能
wire        es_csr_rstat_en ;       // CSR读状态使能

//===================================================================================
//                              数据总线解析
//===================================================================================
// 从译码阶段传来的数据总线中解析各个字段
// 数据总线包含了执行阶段需要的所有控制信号和数据
assign {es_csr_rstat_en  ,  //349:349  CSR读状态使能
        es_inst_st_en    ,  //348:341  存储指令使能
        es_inst_ld_en    ,  //340:333  加载指令使能
        es_cnt_inst      ,  //332:332  指令计数
        es_timer_64      ,  //331:268  64位计时器
        es_inst          ,  //236:267  指令本身
        es_idle          ,  //235:235  空闲指令标志
        es_br_pre_error  ,  //234:234  分支预测错误
        es_br_pre        ,  //233:233  分支预测标志
        es_icache_miss   ,  //232:232  指令Cache缺失
        es_br_inst       ,  //231:231  分支指令标志
        es_preld         ,  //230:230  预取指令标志
        es_cacop         ,  //229:229  Cache操作指令标志
        es_mem_sign_exted,  //228:228  内存符号扩展标志
        es_invtlb        ,  //227:227  TLB无效化指令标志
        es_tlbrd         ,  //226:226  TLB读指令标志
        es_refetch       ,  //225:225  重取指指令标志
        es_tlbfill       ,  //224:224  TLB填充指令标志
        es_tlbwr         ,  //223:223  TLB写指令标志
        es_tlbsrch       ,  //222:222  TLB搜索指令标志
        es_sc_w          ,  //221:221  SC（原子存储）指令标志
        es_ll_w          ,  //220:220  LL（原子加载）指令标志
        es_excp_num      ,  //219:211  异常编号
        es_csr_mask      ,  //210:210  CSR掩码操作标志
        es_csr_we        ,  //209:209  CSR写使能
        es_csr_idx       ,  //208:195  CSR索引
        es_res_from_csr  ,  //194:194  结果来自CSR标志
        es_csr_data      ,  //193:162  CSR数据
        es_ertn          ,  //161:161  异常返回指令标志
        es_excp          ,  //160:160  异常标志
        es_mem_size      ,  //159:158  内存操作大小
        es_mul_div_op    ,  //157:154  乘除法操作码
        es_mul_div_sign  ,  //153:153  乘除法符号位
        es_alu_op        ,  //152:139  ALU操作码
        es_load_op       ,  //138:138  加载操作标志
        es_src1_is_pc    ,  //137:137  源操作数1是PC标志
        es_src2_is_imm   ,  //136:136  源操作数2是立即数标志
        es_src2_is_4     ,  //135:135  源操作数2是常数4标志
        es_gr_we         ,  //134:134  通用寄存器写使能
        es_store_op      ,  //133:133  存储操作标志
        es_dest          ,  //132:128  目标寄存器编号
        es_imm           ,  //127:96   立即数
        es_rj_value      ,  //95 :64   源寄存器1的值
        es_rkd_value     ,  //63 :32   源寄存器2/目标寄存器的值
        es_pc               //31 :0    程序计数器
       } = ds_to_es_bus_r;

//===================================================================================
//                              数据总线组装
//===================================================================================

// ALU运算相关信号
wire [31:0] es_alu_src1   ;  // ALU源操作数1
wire [31:0] es_alu_src2   ;  // ALU源操作数2
wire [31:0] es_alu_result ;  // ALU运算结果
wire [31:0] exe_result    ;  // 执行阶段最终结果

// 传给访存阶段的数据总线组装
// 包含执行阶段的所有结果和控制信号
assign es_to_ms_bus = {es_csr_data      ,  //424:393  CSR数据
                       es_csr_rstat_en  ,  //392:392  CSR读状态使能
                       data_wdata       ,  //391:360  写数据
                       es_inst_st_en    ,  //359:352  存储指令使能
                       data_addr        ,  //351:320  数据地址
                       es_inst_ld_en    ,  //319:312  加载指令使能 
                       es_cnt_inst      ,  //311:311  指令计数
                       es_timer_64      ,  //310:247  64位计时器
                       es_inst          ,  //246:215  指令
                       error_va         ,  //214:183  异常虚拟地址
                       es_idle          ,  //182:182  空闲指令标志
                       es_cacop         ,  //181:181  Cache操作指令标志
                       preld_inst       ,  //180:180  预取指令标志
                       es_br_pre_error  ,  //179:179  分支预测错误
                       es_br_pre        ,  //178:178  分支预测标志
                       es_icache_miss   ,  //177:177  指令Cache缺失
                       es_br_inst       ,  //176:176  分支指令标志
                       icacop_op_en     ,  //175:175  指令Cache操作使能
                       es_mem_sign_exted,  //174:174  内存符号扩展标志
                       es_invtlb_vpn    ,  //173:155  TLB无效化虚拟页号
                       es_invtlb_asid   ,  //154:145  TLB无效化ASID
                       es_invtlb        ,  //144:144  TLB无效化指令标志
                       es_tlbrd         ,  //143:143  TLB读指令标志
                       es_refetch       ,  //142:142  重取指指令标志
                       es_tlbfill       ,  //141:141  TLB填充指令标志
                       es_tlbwr         ,  //140:140  TLB写指令标志
                       es_tlbsrch       ,  //139:139  TLB搜索指令标志
                       es_store_op      ,  //138:138  存储操作标志
                       es_sc_w          ,  //137:137  SC指令标志
                       es_ll_w          ,  //136:136  LL指令标志
                       excp_num         ,  //135:126  异常编号
                       es_csr_we        ,  //125:125  CSR写使能
                       es_csr_idx       ,  //124:111  CSR索引
                       es_csr_result    ,  //110:79   CSR操作结果
                       es_ertn          ,  //78:78    异常返回指令标志
                       excp             ,  //77:77    异常标志
                       es_mem_size      ,  //76:75    内存操作大小
                       es_mul_div_op    ,  //74:71    乘除法操作码
                       es_load_op       ,  //70:70    加载操作标志
                       es_gr_we         ,  //69:69    通用寄存器写使能
                       es_dest          ,  //68:64    目标寄存器编号
                       exe_result       ,  //63:32    执行结果
                       es_pc               //31:0     程序计数器
                      };

//===================================================================================
//                              流水线控制逻辑
//===================================================================================

// 传给译码阶段的数据有效信号
assign es_to_ds_valid = es_valid;

// 内存访问判断：加载操作或存储操作
assign access_mem = es_load_op || es_store_op;

// 刷新信号组合：任何一种刷新都会导致流水线清空
assign es_flush_sign  = excp_flush || ertn_flush || refetch_flush || icacop_flush || idle_flush;

// 指令Cache操作停顿：当执行指令Cache操作且Cache忙碌时需要停顿
assign icacop_inst_stall = icacop_op_en && !icache_unbusy;

// TODO(lab1): 执行阶段准备就绪条件
// 提示：
// 1. 除法不停顿 
// 2. 如果是内存访问/Cache操作/预取指令，需要等待地址握手成功
// 3. TLB搜索不停顿
// 4. 指令Cache操作不停顿
// 5. 或者发生异常时可以直接准备就绪
assign es_ready_go    = (!div_stall && ((dcache_req_or_inst_en && data_addr_ok) || !(access_mem || dcacop_inst || preld_inst)) && !tlbsrch_stall && !icacop_inst_stall) || excp;

// TODO(lab1): 执行阶段允许接收新数据
// 提示：当前无有效数据 或 (准备就绪且访存阶段允许接收)
assign es_allowin     = !es_valid || es_ready_go && ms_allowin;

// TODO(lab1): 传给访存阶段的数据有效
// 提示：当前有效且准备就绪
assign es_to_ms_valid =  es_valid && es_ready_go;

// 执行阶段有效标志和数据寄存器的时序逻辑
always @(posedge clk) begin
    // 复位或刷新时清空有效标志
    if (reset || es_flush_sign) begin     
        es_valid <= 1'b0;
    end
    // 当允许接收新数据时，更新有效标志
    else if (es_allowin) begin 
        es_valid <= ds_to_es_valid;
    end

    // 当译码阶段数据有效且执行阶段允许接收时，保存数据
    if (ds_to_es_valid && es_allowin) begin
        ds_to_es_bus_r <= ds_to_es_bus;
    end
end

//===================================================================================
//                              ALU运算和结果选择
//===================================================================================

// ALU操作数选择
// 源操作数1：PC 或 寄存器值
assign es_alu_src1 = es_src1_is_pc ? es_pc : es_rj_value;
                                      
// 源操作数2：立即数、常数4 或 寄存器值
assign es_alu_src2 = (es_src2_is_imm) ? es_imm : 
                     (es_src2_is_4)   ? 32'd4  : es_rkd_value;

// 乘除法控制信号
assign es_div_enable = (es_mul_div_op[2] | es_mul_div_op[3]) & es_valid;  // 除法使能
assign es_mul_enable = es_mul_div_op[0] | es_mul_div_op[1];               // 乘法使能

// 除法停顿：执行除法且未完成时需要停顿
assign div_stall     = es_div_enable & ~div_complete;

// ALU实例化
alu u_alu(
    .alu_op     (es_alu_op    ),    // ALU操作码
    .alu_src1   (es_alu_src1  ),    // ALU源操作数1
    .alu_src2   (es_alu_src2  ),    // ALU源操作数2
    .alu_result (es_alu_result)     // ALU运算结果
    );

// 执行结果选择：CSR数据 或 ALU结果
assign exe_result     = es_res_from_csr ? es_csr_data : es_alu_result;

//===================================================================================
//                              数据前推机制
//===================================================================================

// 数据前推路径实现
// 目标寄存器为0时不需要前推（0号寄存器恒为0）
assign dest_zero            = (es_dest == 5'b0); 
// TODO(lab1): 前推使能条件
// 提示：有写寄存器操作 && 目标寄存器非0 && 执行阶段有效
assign forward_enable       = es_gr_we & ~dest_zero & es_valid;
// TODO(lab1): 需要停顿的数据依赖
// 提示：加载操作、除法、乘法指令会产生数据依赖，由于不能一拍得出结果，需要停顿后续有依赖的指令
assign dep_need_stall       = es_load_op | es_div_enable | es_mul_enable;
// 前推数据总线组装
assign es_to_ds_forward_bus = {dep_need_stall ,  //38:38  是否需要停顿
                               forward_enable ,  //37:37  前推使能
                               es_dest        ,  //36:32  目标寄存器编号
                               exe_result        //31:0   执行结果
                              };

// TLB指令停顿：TLB搜索或读指令执行时需要停顿后续指令
assign tlb_inst_stall = (es_tlbsrch || es_tlbrd) && es_valid;

//===================================================================================
//                              CSR指令处理
//===================================================================================

// CSR掩码操作
// CSR掩码结果 = (rj & rkd) | (~rj & csr_data)
// 这是CSRXCHG指令的掩码操作：用rj作为掩码，选择性地更新CSR的某些位
assign csr_mask_result = (es_rj_value & es_rkd_value) | (~es_rj_value & es_csr_data);
// CSR写入数据选择：掩码操作结果 或 直接的寄存器值
assign es_csr_result   = es_csr_mask ? csr_mask_result : es_rkd_value;

// 异常虚拟地址：当发生异常时记录的地址
assign error_va        = pv_addr;

//===================================================================================
//                              异常处理
//===================================================================================

// TODO(lab2)：地址不对齐异常检测
// 提示：
// - 字节访问：无对齐要求
// - 半字访问：地址最低位必须为0
// - 字访问：地址最低两位必须为00
assign excp_ale        = access_mem & ((es_mem_size[0] &  1'b0)                                  | 
                                       (es_mem_size[1] &  es_alu_result[0])                      | 
                                       (~|es_mem_size   & (es_alu_result[0] | es_alu_result[1])));
                                
// 最终异常标志：原有异常 或 地址不对齐异常
assign excp            = es_excp || excp_ale;
// 异常编号扩展：添加地址不对齐异常标志
assign excp_num        = {excp_ale, es_excp_num};

// 内存地址低2位，用于字节使能计算
assign sram_addr_low2bit = {es_alu_result[1], es_alu_result[0]};

//===================================================================================
//                              数据Cache接口
//===================================================================================

// 数据Cache请求使能条件
// 提示：当执行阶段有效、无异常、访存阶段允许接收、无刷新信号、访存阶段无刷新时使能
assign dcache_req_or_inst_en = es_valid && !excp && ms_allowin && !es_flush_sign && !ms_flush;

// 数据Cache接口信号
assign data_valid = access_mem && dcache_req_or_inst_en;           // 数据请求有效
assign data_op    = es_store_op;                                   // 数据操作类型（1-写操作）
assign data_wstrb = wr_byte_en;                                    // 写字节使能

// 数据地址选择：TLB搜索时使用CSR中的虚拟页号，否则使用计算出的地址
// tlbsrch复用了dcache的地址翻译数据通路
assign data_addr = es_tlbsrch ? {csr_vppn, 13'b0} : pv_addr;

//===================================================================================
//                              存储指令数据格式化
//===================================================================================

// 存储指令的字节使能生成
// 字节存储(STB)：根据地址低2位确定写入位置
wire [3:0] es_stb_wen = { sram_addr_low2bit==2'b11  ,  // 地址末尾为11时，写第3字节
                          sram_addr_low2bit==2'b10  ,  // 地址末尾为10时，写第2字节
                          sram_addr_low2bit==2'b01  ,  // 地址末尾为01时，写第1字节
                          sram_addr_low2bit==2'b00} ;  // 地址末尾为00时，写第0字节

// 半字存储(STH)：根据地址低2位确定写入位置
wire [3:0] es_sth_wen = { sram_addr_low2bit==2'b10  ,  // 地址末尾为10时，写高半字
                          sram_addr_low2bit==2'b10  ,
                          sram_addr_low2bit==2'b00  ,  // 地址末尾为00时，写低半字
                          sram_addr_low2bit==2'b00} ;

// 字节存储数据分布：将字节数据复制到对应的字节位置
wire [31:0] es_stb_cont = { {8{es_stb_wen[3]}} & es_rkd_value[7:0] ,   // 第3字节
                            {8{es_stb_wen[2]}} & es_rkd_value[7:0] ,   // 第2字节
                            {8{es_stb_wen[1]}} & es_rkd_value[7:0] ,   // 第1字节
                            {8{es_stb_wen[0]}} & es_rkd_value[7:0]};   // 第0字节

// 半字存储数据分布：将半字数据复制到对应的半字位置
wire [31:0] es_sth_cont = { {16{es_sth_wen[3]}} & es_rkd_value[15:0] , // 高半字
                            {16{es_sth_wen[0]}} & es_rkd_value[15:0]}; // 低半字

// 根据存储大小选择字节使能和数据大小
assign {wr_byte_en, data_size}  = ({7{es_mem_size[0]}} & {es_stb_wen, 3'b00}) |  // 字节存储
                                  ({7{es_mem_size[1]}} & {es_sth_wen, 3'b01}) |  // 半字存储
                                  ({7{!es_mem_size  }} & {4'b1111   , 3'b10}) ;  // 字存储

// 根据存储大小选择写入数据
assign data_wdata = ({32{es_mem_size[0]}} & es_stb_cont ) |  // 字节存储数据
                    ({32{es_mem_size[1]}} & es_sth_cont ) |  // 半字存储数据
                    ({32{!es_mem_size  }} & es_rkd_value) ;  // 字存储数据

// TLB搜索停顿：当执行TLB搜索指令且访存阶段正在写TLBEHI时需要停顿
// TLBSRCH依赖 CSR.ASID 和 CSR.TLBEHI 的信息去查询 TLB，暂停保证数据同步
assign tlbsrch_stall = es_tlbsrch && ms_wr_tlbehi;


//===================================================================================
//                              TLB/cacop/preld 指令处理
//===================================================================================

// TLB无效化指令参数提取
assign es_invtlb_asid = es_rj_value[9:0];   // 从rj寄存器获取ASID（地址空间标识符）
assign es_invtlb_vpn  = es_rkd_value[31:13]; // 从rkd寄存器获取VPN（虚拟页号）

// 物理/虚拟地址：使用ALU计算结果作为地址
assign pv_addr = es_alu_result;

// Cache操作指令处理
assign cacop_op         = es_dest;                                          // Cache操作码来自目标寄存器字段
assign icacop_inst      = es_cacop && (cacop_op[2:0] == 3'b0);             // 指令Cache操作：低3位为000
assign icacop_op_en     = icacop_inst && dcache_req_or_inst_en;             // 指令Cache操作使能
assign dcacop_inst      = es_cacop && (cacop_op[2:0] == 3'b1);             // 数据Cache操作：低3位为001
assign dcacop_op_en     = dcacop_inst && dcache_req_or_inst_en;             // 数据Cache操作使能
assign cacop_op_mode    = cacop_op[4:3];                                    // Cache操作模式

// 预取指令处理
assign preld_hint = es_dest;                                                 // 预取提示来自目标寄存器字段
assign preld_inst = es_preld && ((preld_hint == 5'd0) || (preld_hint == 5'd8)); // 预取指令：提示为0或8时有效
assign preld_en   = preld_inst && dcache_req_or_inst_en;                    // 预取使能

// 数据获取信号：
// 1. 普通内存访问且地址握手成功
// 2. 数据Cache操作或预取指令且地址握手成功
// 3. 指令Cache操作或TLB搜索且准备就绪
assign data_fetch = (data_valid || dcacop_inst || preld_en) && data_addr_ok || ((icacop_inst || es_tlbsrch) && es_ready_go && ms_allowin);

endmodule
