/*==============================================================================
 * LoongArch架构五级流水线处理器 - 译码阶段 (Instruction Decode Stage)
 * 
 * 主要功能：
 * 1. 指令译码：解析指令操作码，生成控制信号
 * 2. 寄存器文件访问：读取源操作数
 * 3. 立即数扩展：根据指令类型扩展立即数
 * 4. 分支预测和跳转：处理分支指令，与BTB交互
 * 5. 异常检测：非法指令、特权级异常等
 * 6. 数据前递：解决数据相关问题
 * 7. CSR指令处理：控制状态寄存器相关指令
 * 8. 内存屏障指令：DBAR、IBAR指令处理
 *==============================================================================*/

/*
 * =============================================================================
 * 模块名称：id_stage
 * 功能描述：LoongArch架构五级流水线处理器的指令译码阶段（ID Stage）
 * 设计目标：
 *   1. 对从取指阶段传来的32位指令进行译码，识别指令类型和操作码
 *   2. 生成ALU、乘除法器、内存访问等功能单元的控制信号
 *   3. 读取寄存器文件，获取源操作数，处理数据前递和冲突
 *   4. 处理分支指令的判断和目标地址计算
 *   5. 生成CSR访问、异常处理、TLB操作等特权指令的控制信号
 *   6. 管理流水线控制信号，处理数据冲突和流水线暂停
 *   7. 支持BTB分支预测的验证和更新
 * 
 * 主要功能模块：
 *   - 指令字段分解和译码器
 *   - 寄存器文件读取和数据前递处理
 *   - ALU操作码生成
 *   - 乘除法操作控制
 *   - 内存访问控制信号生成
 *   - 分支指令处理和目标地址计算
 *   - CSR和特权指令处理
 *   - 异常检测和处理
 *   - 流水线控制和暂停逻辑
 *   - BTB分支预测验证
 * 
 * 设计特点：
 *   - 支持LoongArch 32位指令集的完整译码
 *   - 实现高效的数据前递机制，减少流水线停顿
 *   - 集成分支预测验证，提高分支指令性能
 *   - 支持内存屏障指令的流水线控制
 *   - 实现完整的异常检测和特权级检查
 * =============================================================================
 */

`include "mycpu.vh"

module id_stage(
    //================= 时钟和复位 =================
    input                               clk           ,  // 时钟信号
    input                               reset         ,  // 复位信号
    
    //================= 流水线控制 =================
    input                               es_allowin    ,  // 执行阶段允许新数据进入
    output                              ds_allowin    ,  // 译码阶段允许新数据进入
    
    //================= 从取指阶段来的数据 =================
    input                               fs_to_ds_valid,  // 取指到译码数据有效
    input  [`FS_TO_DS_BUS_WD -1:0]      fs_to_ds_bus  ,  // 取指到译码数据总线
    
    //================= 数据前递总线 =================
    input  [`ES_TO_DS_FORWARD_BUS -1:0] es_to_ds_forward_bus,  // 执行阶段前递数据
    input  [`MS_TO_DS_FORWARD_BUS -1:0] ms_to_ds_forward_bus,  // 访存阶段前递数据
    
    //================= 到执行阶段 =================
    output                              ds_to_es_valid,  // 译码到执行数据有效
    output [`DS_TO_ES_BUS_WD -1:0]      ds_to_es_bus  ,  // 译码到执行数据总线
    
    //================= 分支控制总线 =================
    output [`BR_BUS_WD       -1:0]      br_bus        ,  // 分支总线（给取指阶段）
    
    //================= 异常和刷新控制 =================
    input                               excp_flush    ,  // 异常刷新
    input                               ertn_flush    ,  // 异常返回刷新
    input                               refetch_flush ,  // 重取指刷新
    input                               icacop_flush  ,  // ICache操作刷新
    
    //================= 空闲指令控制 =================
    input                               idle_flush    ,  // 空闲指令刷新
    
    //================= TLB指令阻塞 =================
    input                               es_tlb_inst_stall,  // 执行阶段TLB指令阻塞
    input                               ms_tlb_inst_stall,  // 访存阶段TLB指令阻塞
    input                               ws_tlb_inst_stall,  // 写回阶段TLB指令阻塞
    
    //================= 中断信号 =================
    input                               has_int       ,  // 中断信号
    
    //================= CSR接口 =================
    output [13:0]                       rd_csr_addr   ,  // CSR读地址
    input  [31:0]                       rd_csr_data   ,  // CSR读数据
    input  [ 1:0]                       csr_plv       ,  // 当前特权级
    
    //================= 计时器接口 =================
    input  [63:0]                       timer_64      ,  // 64位计时器值
    input  [31:0]                       csr_tid       ,  // 计时器ID
    
    //================= LL/SC原子操作 =================
    input                               ds_llbit      ,  // LLbit状态
    
    //================= 流水线有效信号 =================
    input                               es_to_ds_valid,  // 执行阶段有效
    input                               ms_to_ds_valid,  // 访存阶段有效
    input                               ws_to_ds_valid,  // 写回阶段有效
    
    //================= 写缓冲和Cache状态 =================
    input                               write_buffer_empty,  // 写缓冲为空
    input 							    dcache_empty      ,  // 数据Cache为空
    
    //================= BTB分支预测接口 =================
    output                              btb_operate_en    ,  // BTB操作使能
    output                              btb_pop_ras       ,  // BTB弹出返回地址栈
    output                              btb_push_ras      ,  // BTB压入返回地址栈
    output                              btb_add_entry     ,  // BTB添加条目
    output                              btb_delete_entry  ,  // BTB删除条目
    output                              btb_pre_error     ,  // BTB预测错误
    output                              btb_pre_right     ,  // BTB预测正确
    output                              btb_target_error  ,  // BTB目标地址错误
    output                              btb_right_orien   ,  // BTB正确方向
    output [31:0]                       btb_right_target  ,  // BTB正确目标地址
    output [31:0]                       btb_operate_pc    ,  // BTB操作PC
    output [ 4:0]                       btb_operate_index ,  // BTB操作索引
 
    //================= 调试接口 =================
    input                               infor_flag,     // 调试信息标志
    input  [ 4:0]                       reg_num,        // 调试寄存器号
    output [31:0]                       debug_rf_rdata1,// 调试寄存器数据

    //================= 寄存器文件写回接口 =================
    input  [`WS_TO_RF_BUS_WD -1:0]      ws_to_rf_bus      // 写回阶段到寄存器文件总线
    `ifdef DIFFTEST_EN
    ,
    // difftest
    output [31:0]                       rf_to_diff [31:0]  // Difftest寄存器文件输出
    `endif
);

/*==============================================================================
 * 译码阶段内部信号声明
 *==============================================================================*/

//================= 流水线控制信号 =================
reg         ds_valid   ;        // 译码阶段数据有效标志
wire        ds_ready_go;        // 译码阶段准备完成

//================= 取指阶段数据缓存 =================
reg  [`FS_TO_DS_BUS_WD -1:0] fs_to_ds_bus_r;  // 缓存的取指阶段数据

//================= 从取指阶段解析的信号 =================
wire [31:0] ds_inst;           // 译码阶段指令
wire [31:0] ds_pc  ;           // 译码阶段PC
wire [ 3:0] ds_excp_num;       // 译码阶段异常编号
wire        ds_excp;           // 译码阶段异常标志
wire        ds_icache_miss;    // 指令Cache缺失
wire        ds_btb_taken;      // BTB预测taken
wire        ds_btb_en;         // BTB命中
wire [ 4:0] ds_btb_index;      // BTB索引
wire [31:0] ds_btb_target;     // BTB预测目标地址

// 解析取指阶段数据总线
assign {ds_btb_target,  //108:77
        ds_btb_index,   //76:72
        ds_btb_taken,   //71:71
        ds_btb_en,      //70:70
        ds_icache_miss, //69:69
        ds_excp,        //68:68
        ds_excp_num,    //67:64
        ds_inst,        //63:32
        ds_pc           //31:0
       } = fs_to_ds_bus_r;

//================= 寄存器文件写回信号 =================
wire        rf_we   ;          // 寄存器写使能
wire [ 4:0] rf_waddr;          // 寄存器写地址
wire [31:0] rf_wdata;          // 寄存器写数据

// 解析写回阶段数据
assign {rf_we   ,  //37:37
        rf_waddr,  //36:32
        rf_wdata   //31:0
       } = ws_to_rf_bus;

//================= 分支预测和跳转相关 =================
wire        br_taken;                    // 分支taken
wire [31:0] br_target;                   // 分支目标地址
wire        btb_pre_error_flush;         // BTB预测错误刷新
wire [31:0] btb_pre_error_flush_target;  // BTB预测错误目标地址

//================= ALU控制信号 =================
wire [13:0] alu_op;            // ALU操作码
wire [ 3:0] mul_div_op;        // 乘除法操作码
wire        mul_div_sign;      // 乘除法有符号标志
wire        src1_is_pc;        // 源操作数1是PC
wire        src2_is_imm;       // 源操作数2是立即数
wire        src2_is_4;         // 源操作数2是4
wire        load_op;           // 加载操作
wire        res_from_csr;      // 结果来自CSR
wire        csr_mask;          // CSR掩码模式
wire        mem_b_size;        // 内存字节大小
wire        mem_h_size;        // 内存半字大小
wire        mem_sign_exted;    // 内存符号扩展
wire        dst_is_r1;         // 目标寄存器是r1
wire        dst_is_rj;         // 目标寄存器是rj
wire        gr_we;             // 通用寄存器写使能
wire        store_op;          // 存储操作
wire        csr_we;            // CSR写使能
wire        src_reg_is_rd;     // 源寄存器是rd
wire [1: 0] mem_size;          // 内存访问大小
wire [4: 0] dest;              // 目标寄存器
wire [31:0] rj_value;          // rj寄存器值
wire [31:0] rkd_value;         // rk/rd寄存器值
wire [31:0] ds_imm;            // 立即数

//================= 指令字段分解 =================
wire [ 5:0] op_31_26;          // 指令[31:26]位
wire [ 3:0] op_25_22;          // 指令[25:22]位
wire [ 1:0] op_21_20;          // 指令[21:20]位
wire [ 4:0] op_19_15;          // 指令[19:15]位
wire [ 4:0] rd;                // rd字段
wire [ 4:0] rj;                // rj字段
wire [ 4:0] rk;                // rk字段
wire [11:0] i12;               // 12位立即数
wire [13:0] i14;               // 14位立即数
wire [19:0] i20;               // 20位立即数
wire [15:0] i16;               // 16位立即数
wire [25:0] i26;               // 26位立即数
wire [13:0] csr_idx;           // CSR索引

//================= 指令译码器输出 =================
wire [63:0] op_31_26_d;        // op_31_26译码输出
wire [15:0] op_25_22_d;        // op_25_22译码输出
wire [ 3:0] op_21_20_d;        // op_21_20译码输出
wire [31:0] op_19_15_d;        // op_19_15译码输出
wire [31:0] rd_d;              // rd译码输出
wire [31:0] rj_d;              // rj译码输出
wire [31:0] rk_d;              // rk译码输出
/*==============================================================================
 * 指令类型识别信号
 * 每个信号对应一种具体的指令类型
 *==============================================================================*/

//================= 算术逻辑指令 =================
wire inst_add_w;     // 字加法
wire inst_sub_w;     // 字减法  
wire inst_slt;       // 小于比较（有符号）
wire inst_sltu;      // 小于比较（无符号）   
wire inst_nor;       // 或非
wire inst_and;       // 逻辑与
wire inst_or;        // 逻辑或
wire inst_xor;       // 逻辑异或
wire inst_lu12i_w;   // 12位立即数加载到高位
wire inst_addi_w;    // 字加法立即数
wire inst_slti;      // 小于比较立即数（有符号）
wire inst_sltui;     // 小于比较立即数（无符号）
wire inst_pcaddi;    // PC加立即数
wire inst_pcaddu12i; // PC加12位立即数到高位
wire inst_andn;      // 与非
wire inst_orn;       // 或非
wire inst_andi;      // 逻辑与立即数
wire inst_ori;       // 逻辑或立即数
wire inst_xori;      // 逻辑异或立即数

//================= 乘除法指令 =================
wire inst_mul_w;     // 字乘法
wire inst_mulh_w;    // 字乘法高位（有符号）
wire inst_mulh_wu;   // 字乘法高位（无符号）
wire inst_div_w;     // 字除法（有符号）
wire inst_mod_w;     // 字求模（有符号）
wire inst_div_wu;    // 字除法（无符号）
wire inst_mod_wu;    // 字求模（无符号）

//================= 移位指令 =================
wire inst_slli_w;    // 字逻辑左移立即数
wire inst_srli_w;    // 字逻辑右移立即数
wire inst_srai_w;    // 字算术右移立即数
wire inst_sll_w;     // 字逻辑左移
wire inst_srl_w;     // 字逻辑右移
wire inst_sra_w;     // 字算术右移

//================= 分支跳转指令 =================
wire inst_jirl;      // 间接跳转并链接
wire inst_b;         // 无条件跳转
wire inst_bl;        // 无条件跳转并链接
wire inst_beq;       // 相等时分支
wire inst_bne;       // 不等时分支
wire inst_blt;       // 小于时分支（有符号）
wire inst_bge;       // 大于等于时分支（有符号）
wire inst_bltu;      // 小于时分支（无符号）
wire inst_bgeu;      // 大于等于时分支（无符号）

//================= 原子操作指令 =================
wire inst_ll_w;      // 链接加载字
wire inst_sc_w;      // 条件存储字

//================= 内存访问指令 =================
wire inst_ld_b;      // 加载字节（有符号扩展）
wire inst_ld_bu;     // 加载字节（零扩展）
wire inst_ld_h;      // 加载半字（有符号扩展）
wire inst_ld_hu;     // 加载半字（零扩展）
wire inst_ld_w;      // 加载字
wire inst_st_b;      // 存储字节
wire inst_st_h;      // 存储半字
wire inst_st_w;      // 存储字

//================= 系统调用和异常 =================
wire inst_syscall;   // 系统调用
wire inst_break;     // 断点异常

//================= CSR指令 =================
wire inst_csrrd;     // CSR读
wire inst_csrwr;     // CSR写
wire inst_csrxchg;   // CSR交换
wire inst_ertn;      // 异常返回
wire inst_cpucfg;    // CPU配置读取

//================= 计时器指令 =================
wire inst_rdcntid_w; // 读计时器ID
wire inst_rdcntvl_w; // 读计时器值低32位
wire inst_rdcntvh_w; // 读计时器值高32位
wire inst_idle;      // 空闲指令

//================= TLB指令 =================
wire inst_tlbsrch;   // TLB搜索
wire inst_tlbrd;     // TLB读
wire inst_tlbwr;     // TLB写
wire inst_tlbfill;   // TLB填充
wire inst_invtlb;    // TLB无效化

//================= Cache和内存屏障指令 =================
wire inst_cacop;     // Cache操作
wire inst_valid_cacop; // 有效的Cache操作
wire inst_preld;     // 预加载
wire inst_dbar;      // 数据屏障
wire inst_ibar;      // 指令屏障

//================= 空操作 =================
wire inst_nop;       // 空操作

//================= 立即数类型识别 =================
wire need_ui5;       // 需要5位无符号立即数
wire need_si12;      // 需要12位有符号立即数
wire need_ui12;      // 需要12位无符号立即数
wire need_si14_pc;   // 需要14位有符号立即数（PC相对）
wire need_si16_pc;   // 需要16位有符号立即数（PC相对）
wire need_si20;      // 需要20位有符号立即数
wire need_si20_pc;   // 需要20位有符号立即数（PC相对）
wire need_si26_pc;   // 需要26位有符号立即数（PC相对）

//================= 寄存器文件接口 =================
wire [ 4:0] rf_raddr1;  // 寄存器文件读端口1地址
wire [31:0] rf_rdata1;  // 寄存器文件读端口1数据
wire [ 4:0] rf_raddr2;  // 寄存器文件读端口2地址
wire [31:0] rf_rdata2;  // 寄存器文件读端口2数据

//================= 流水线和阻塞控制 =================
wire        pipeline_no_empty; // 流水线非空
wire        dbar_stall;        // DBAR阻塞
wire        ibar_stall;        // IBAR阻塞

//================= 分支条件判断 =================
wire        rj_eq_rd;          // rj等于rd
wire        rj_lt_rd_sign;     // rj小于rd（有符号）
wire        rj_lt_rd_unsign;   // rj小于rd（无符号）

//================= 数据前递控制 =================
wire        ms_forward_enable;   // 访存阶段前递使能
wire [ 4:0] ms_forward_reg;      // 访存阶段前递寄存器
wire [31:0] ms_forward_data;     // 访存阶段前递数据
wire        ms_dep_need_stall;   // 访存阶段依赖需要阻塞
wire        es_dep_need_stall;   // 执行阶段依赖需要阻塞
wire        es_forward_enable;   // 执行阶段前递使能
wire [ 4:0] es_forward_reg;      // 执行阶段前递寄存器
wire [31:0] es_forward_data;     // 执行阶段前递数据
wire        rf1_forward_stall;   // 寄存器1前递阻塞
wire        rf2_forward_stall;   // 寄存器2前递阻塞

//================= 异常处理 =================
wire        excp;               // 异常标志
wire [ 8:0] excp_num;           // 异常编号
wire        inst_valid;         // 指令有效
wire        excp_ine;           // 非法指令异常
wire        excp_ipe;           // 特权指令异常
wire [31:0] csr_data;           // CSR数据
wire        refetch;            // 重取指
wire        flush_sign;         // 刷新信号

wire        fs_excp;            // 取指阶段异常

wire        kernel_inst;        // 内核指令

//================= 计时器相关 =================
wire [31:0] rdcnt_result;       // 计时器读结果
wire        rdcnt_en;           // 计时器读使能

//================= 分支槽取消 =================
reg         branch_slot_cancel; // 分支槽取消

//================= TLB指令阻塞 =================
wire        tlb_inst_stall;     // TLB指令阻塞

//================= 分支相关 =================
wire        br_inst;            // 分支指令

reg         br_jirl;            // JIRL分支

wire        br_need_reg_data;   // 分支需要寄存器数据
wire        br_to_btb;          // 分支到BTB

//================= 寄存器需求检测 =================
wire        inst_need_rj;       // 指令需要rj
wire        inst_need_rkd;      // 指令需要rk/rd

//================= Difftest接口 =================
wire [7:0]  inst_ld_en;         // 加载指令使能（用于difftest）
wire [7:0]  inst_st_en;         // 存储指令使能（用于difftest）
wire        inst_csr_rstat_en;  // CSR RSTAT使能（用于difftest）

/*==============================================================================
 * 输出总线组装
 *==============================================================================*/

// 分支总线：BTB预测错误刷新信息
assign br_bus       = {btb_pre_error_flush,           //32:32
                       btb_pre_error_flush_target     //31:0
                      };

// 译码到执行阶段数据总线：包含所有执行阶段需要的控制信号和数据
assign ds_to_es_bus = {inst_csr_rstat_en,  // 349:349 CSR RSTAT使能（difftest用）
                       inst_st_en       ,  // 348:341 存储指令使能（difftest用）
                       inst_ld_en       ,  // 340:333 加载指令使能（difftest用）
                       (inst_rdcntvl_w | inst_rdcntvh_w | inst_rdcntid_w), //332:332 计时器读指令（difftest用）
                       timer_64      ,  //331:268 64位计时器值（difftest用）
                       ds_inst       ,  //267:236 指令（difftest用）
                       inst_idle     ,  //235:235 空闲指令
                       btb_pre_error_flush, //234:234 BTB预测错误刷新
                       br_to_btb     ,  //233:233 分支到BTB
                       ds_icache_miss,  //232:232 指令Cache缺失
                       br_inst       ,  //231:231 分支指令
                       inst_preld    ,  //230:230 预加载指令
                       inst_valid_cacop,  //229:229 有效Cache操作
                       mem_sign_exted,  //228:228 内存符号扩展
                       inst_invtlb   ,  //227:227 TLB无效化指令
                       inst_tlbrd    ,  //226:226 TLB读指令
                       refetch       ,  //225:225 重取指
                       inst_tlbfill  ,  //224:224 TLB填充指令
                       inst_tlbwr    ,  //223:223 TLB写指令
                       inst_tlbsrch  ,  //222:222 TLB搜索指令
                       inst_sc_w     ,  //221:221 条件存储指令
                       inst_ll_w     ,  //220:220 链接加载指令
                       excp_num      ,  //219:211 异常编号
                       csr_mask      ,  //210:210 CSR掩码
                       csr_we        ,  //209:209 CSR写使能
                       csr_idx       ,  //208:195 CSR索引
                       res_from_csr  ,  //194:194 结果来自CSR
                       csr_data      ,  //193:162 CSR数据
                       inst_ertn     ,  //161:161 异常返回指令
                       excp          ,  //160:160 异常标志
                       mem_size      ,  //159:158 内存访问大小
                       mul_div_op    ,  //157:154 乘除法操作码
                       mul_div_sign  ,  //153:153 乘除法符号标志
                       alu_op        ,  //152:139 ALU操作码
                       load_op       ,  //138:138 加载操作
                       src1_is_pc    ,  //137:137 源操作数1是PC
                       src2_is_imm   ,  //136:136 源操作数2是立即数
                       src2_is_4     ,  //135:135 源操作数2是4
                       gr_we         ,  //134:134 通用寄存器写使能
                       store_op      ,  //133:133 存储操作
                       dest          ,  //132:128 目标寄存器
                       ds_imm        ,  //127:96  立即数
                       rj_value      ,  //95 :64  rj寄存器值
                       rkd_value     ,  //63 :32  rk/rd寄存器值
                       ds_pc            //31 :0   PC值
                      };

/*==============================================================================
 * 流水线控制逻辑
 *==============================================================================*/

// 刷新信号汇总
assign flush_sign = excp_flush || ertn_flush || refetch_flush || icacop_flush || idle_flush;

// 取指阶段异常标志
assign fs_excp = fs_to_ds_bus[68];

// TODO(lab1): 译码阶段准备完成条件
// 提示：无数据相关阻塞、无TLB指令阻塞、无内存屏障阻塞，或发生异常
assign ds_ready_go    = !(rf2_forward_stall || rf1_forward_stall || tlb_inst_stall || ibar_stall || dbar_stall) || excp;

// TODO(lab1): 译码阶段允许新数据进入
// 提示：当前无有效数据或准备完成且执行阶段允许
assign ds_allowin     = !ds_valid || ds_ready_go && es_allowin;

// TODO(lab1): 译码到执行阶段数据有效
// 提示：当前有效且准备完成
assign ds_to_es_valid = ds_valid && ds_ready_go;

/*==============================================================================
 * 译码阶段状态寄存器
 *==============================================================================*/
always @(posedge clk) begin
    if (reset || flush_sign) begin
        // 复位或刷新时清除有效标志
        ds_valid <= 1'b0;
    end
    else begin 
        if (ds_allowin) begin
            if ((btb_pre_error_flush && es_allowin) || branch_slot_cancel) begin
                // BTB预测错误或分支槽取消时清除有效标志
                ds_valid <= 1'b0;
            end
            else begin
                // 正常情况下更新有效标志
                ds_valid <= fs_to_ds_valid;
            end
        end
    end

    // 缓存取指阶段数据
    if (fs_to_ds_valid && ds_allowin) begin
        fs_to_ds_bus_r <= fs_to_ds_bus;
    end
end

/*==============================================================================
 * 指令字段提取
 *==============================================================================*/
assign op_31_26  = ds_inst[31:26];  // 主操作码
assign op_25_22  = ds_inst[25:22];  // 次操作码
assign op_21_20  = ds_inst[21:20];  // 次操作码
assign op_19_15  = ds_inst[19:15];  // 次操作码

assign rd   = ds_inst[ 4: 0];       // 目标寄存器
assign rj   = ds_inst[ 9: 5];       // 源寄存器1
assign rk   = ds_inst[14:10];       // 源寄存器2

assign i12  = ds_inst[21:10];       // 12位立即数
assign i14  = ds_inst[23:10];       // 14位立即数
assign i20  = ds_inst[24: 5];       // 20位立即数
assign i16  = ds_inst[25:10];       // 16位立即数
assign i26  = {ds_inst[ 9: 0], ds_inst[25:10]};  // 26位立即数

assign csr_idx = ds_inst[23:10];    // CSR索引

/*==============================================================================
 * 指令译码器实例化
 * 将指令字段译码为独热码形式，便于指令识别
 *==============================================================================*/
decoder_6_64 u_dec0(.in(op_31_26 ), .out(op_31_26_d ));  // 6位到64位译码器
decoder_4_16 u_dec1(.in(op_25_22 ), .out(op_25_22_d ));  // 4位到16位译码器
decoder_2_4  u_dec2(.in(op_21_20 ), .out(op_21_20_d ));  // 2位到4位译码器
decoder_5_32 u_dec3(.in(op_19_15 ), .out(op_19_15_d ));  // 5位到32位译码器

decoder_5_32 u_dec4(.in(rd  ), .out(rd_d  ));           // rd字段译码器
decoder_5_32 u_dec5(.in(rj  ), .out(rj_d  ));           // rj字段译码器
decoder_5_32 u_dec6(.in(rk  ), .out(rk_d  ));           // rk字段译码器

/*==============================================================================
 * 指令识别逻辑
 * 通过译码器输出的独热码进行指令类型判断
 *==============================================================================*/

//================= 算术逻辑运算指令 =================
assign inst_add_w      = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h00]; // 字加法
assign inst_sub_w      = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h02]; // 字减法
assign inst_slt        = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h04]; // 小于比较（有符号）
assign inst_sltu       = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h05]; // 小于比较（无符号）
assign inst_nor        = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h08]; // 或非
assign inst_and        = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h09]; // 逻辑与
assign inst_or         = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h0a]; // 逻辑或
assign inst_xor        = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h0b]; // 逻辑异或
assign inst_orn        = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h0c]; // 或非
assign inst_andn       = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h0d]; // 与非

//================= 移位运算指令 =================
assign inst_sll_w      = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h0e]; // 字逻辑左移
assign inst_srl_w      = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h0f]; // 字逻辑右移
assign inst_sra_w      = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h10]; // 字算术右移
assign inst_slli_w     = op_31_26_d[6'h00] & op_25_22_d[4'h1] & op_21_20_d[2'h0] & op_19_15_d[5'h01]; // 字逻辑左移立即数
assign inst_srli_w     = op_31_26_d[6'h00] & op_25_22_d[4'h1] & op_21_20_d[2'h0] & op_19_15_d[5'h09]; // 字逻辑右移立即数
assign inst_srai_w     = op_31_26_d[6'h00] & op_25_22_d[4'h1] & op_21_20_d[2'h0] & op_19_15_d[5'h11]; // 字算术右移立即数

//================= 乘除法运算指令 =================
assign inst_mul_w      = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h18]; // 字乘法
assign inst_mulh_w     = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h19]; // 字乘法高位（有符号）
assign inst_mulh_wu    = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h1a]; // 字乘法高位（无符号）
assign inst_div_w      = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h2] & op_19_15_d[5'h00]; // 字除法（有符号）
assign inst_mod_w      = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h2] & op_19_15_d[5'h01]; // 字求模（有符号）
assign inst_div_wu     = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h2] & op_19_15_d[5'h02]; // 字除法（无符号）
assign inst_mod_wu     = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h2] & op_19_15_d[5'h03]; // 字求模（无符号）

//================= 系统调用和异常指令 =================
assign inst_break      = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h2] & op_19_15_d[5'h14]; // 断点异常
assign inst_syscall    = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h2] & op_19_15_d[5'h16]; // 系统调用

//================= 立即数运算指令 =================
assign inst_slti       = op_31_26_d[6'h00] & op_25_22_d[4'h8];  // 小于比较立即数（有符号）
assign inst_sltui      = op_31_26_d[6'h00] & op_25_22_d[4'h9];  // 小于比较立即数（无符号）
assign inst_addi_w     = op_31_26_d[6'h00] & op_25_22_d[4'ha];  // 字加法立即数
assign inst_andi       = op_31_26_d[6'h00] & op_25_22_d[4'hd];  // 逻辑与立即数
assign inst_ori        = op_31_26_d[6'h00] & op_25_22_d[4'he];  // 逻辑或立即数
assign inst_xori       = op_31_26_d[6'h00] & op_25_22_d[4'hf];  // 逻辑异或立即数

//================= PC相对运算指令 =================
assign inst_lu12i_w    = op_31_26_d[6'h05] & ~ds_inst[25];     // 加载12位立即数到高位
assign inst_pcaddi     = op_31_26_d[6'h06] & ~ds_inst[25];     // PC加立即数
assign inst_pcaddu12i  = op_31_26_d[6'h07] & ~ds_inst[25];     // PC加12位立即数到高位

//================= 内存访问指令 =================
assign inst_ld_b       = op_31_26_d[6'h0a] & op_25_22_d[4'h0]; // 加载字节（有符号扩展）
assign inst_ld_h       = op_31_26_d[6'h0a] & op_25_22_d[4'h1]; // 加载半字（有符号扩展）
assign inst_ld_w       = op_31_26_d[6'h0a] & op_25_22_d[4'h2]; // 加载字
assign inst_st_b       = op_31_26_d[6'h0a] & op_25_22_d[4'h4]; // 存储字节
assign inst_st_h       = op_31_26_d[6'h0a] & op_25_22_d[4'h5]; // 存储半字
assign inst_st_w       = op_31_26_d[6'h0a] & op_25_22_d[4'h6]; // 存储字
assign inst_ld_bu      = op_31_26_d[6'h0a] & op_25_22_d[4'h8]; // 加载字节（零扩展）
assign inst_ld_hu      = op_31_26_d[6'h0a] & op_25_22_d[4'h9]; // 加载半字（零扩展）

//================= 原子操作指令 =================
assign inst_ll_w       = op_31_26_d[6'h08] & ~ds_inst[25] & ~ds_inst[24]; // 链接加载字
assign inst_sc_w       = op_31_26_d[6'h08] & ~ds_inst[25] &  ds_inst[24]; // 条件存储字

//================= 跳转分支指令 =================
assign inst_jirl       = op_31_26_d[6'h13];    // 间接跳转并链接
assign inst_b          = op_31_26_d[6'h14];    // 无条件跳转
assign inst_bl         = op_31_26_d[6'h15];    // 无条件跳转并链接
assign inst_beq        = op_31_26_d[6'h16];    // 相等时分支
assign inst_bne        = op_31_26_d[6'h17];    // 不等时分支
assign inst_blt        = op_31_26_d[6'h18];    // 小于时分支（有符号）
assign inst_bge        = op_31_26_d[6'h19];    // 大于等于时分支（有符号）
assign inst_bltu       = op_31_26_d[6'h1a];    // 小于时分支（无符号）
assign inst_bgeu       = op_31_26_d[6'h1b];    // 大于等于时分支（无符号）

//================= CSR指令 =================
assign inst_csrxchg    = op_31_26_d[6'h01] & ~ds_inst[25] & ~ds_inst[24] & (~rj_d[5'h00] & ~rj_d[5'h01]); // CSR交换（rj != 0,1）
assign inst_csrrd      = op_31_26_d[6'h01] & ~ds_inst[25] & ~ds_inst[24] & rj_d[5'h00]; // CSR读（rj == 0）
assign inst_csrwr      = op_31_26_d[6'h01] & ~ds_inst[25] & ~ds_inst[24] & rj_d[5'h01]; // CSR写（rj == 1）

//================= 计时器指令 =================
assign inst_rdcntid_w  = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h0] & op_19_15_d[5'h00] & rk_d[5'h18] & rd_d[5'h00]; // 读计时器ID
assign inst_rdcntvl_w  = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h0] & op_19_15_d[5'h00] & rk_d[5'h18] & rj_d[5'h00] & !rd_d[5'h00]; // 读计时器值低32位
assign inst_rdcntvh_w  = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h0] & op_19_15_d[5'h00] & rk_d[5'h19] & rj_d[5'h00]; // 读计时器值高32位

//================= TLB相关指令 =================
assign inst_tlbsrch    = op_31_26_d[6'h01] & op_25_22_d[4'h9] & op_21_20_d[2'h0] & op_19_15_d[5'h10] & rk_d[5'h0a] & rj_d[5'h00] & rd_d[5'h00]; // TLB搜索
assign inst_tlbrd      = op_31_26_d[6'h01] & op_25_22_d[4'h9] & op_21_20_d[2'h0] & op_19_15_d[5'h10] & rk_d[5'h0b] & rj_d[5'h00] & rd_d[5'h00]; // TLB读
assign inst_tlbwr      = op_31_26_d[6'h01] & op_25_22_d[4'h9] & op_21_20_d[2'h0] & op_19_15_d[5'h10] & rk_d[5'h0c] & rj_d[5'h00] & rd_d[5'h00]; // TLB写
assign inst_tlbfill    = op_31_26_d[6'h01] & op_25_22_d[4'h9] & op_21_20_d[2'h0] & op_19_15_d[5'h10] & rk_d[5'h0d] & rj_d[5'h00] & rd_d[5'h00]; // TLB填充
assign inst_invtlb     = op_31_26_d[6'h01] & op_25_22_d[4'h9] & op_21_20_d[2'h0] & op_19_15_d[5'h13]; // TLB无效化

//================= 特殊指令 =================
assign inst_ertn       = op_31_26_d[6'h01] & op_25_22_d[4'h9] & op_21_20_d[2'h0] & op_19_15_d[5'h10] & rk_d[5'h0e] & rj_d[5'h00] & rd_d[5'h00]; // 异常返回
assign inst_idle       = op_31_26_d[6'h01] & op_25_22_d[4'h9] & op_21_20_d[2'h0] & op_19_15_d[5'h11]; // 空闲指令
assign inst_cpucfg     = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h0] & op_19_15_d[5'h00] & rk_d[5'h1b]; // CPU配置读取

//================= Cache和内存屏障指令 =================
assign inst_cacop      = op_31_26_d[6'h01] & op_25_22_d[4'h8]; // Cache操作
assign inst_preld      = op_31_26_d[6'h0a] & op_25_22_d[4'hb]; // 预加载
assign inst_dbar       = op_31_26_d[6'h0e] & op_25_22_d[4'h1] & op_21_20_d[2'h3] & op_19_15_d[5'h04]; // 数据屏障
assign inst_ibar       = op_31_26_d[6'h0e] & op_25_22_d[4'h1] & op_21_20_d[2'h3] & op_19_15_d[5'h05]; // 指令屏障

//================= Cache操作有效性判断 =================
// 有效的Cache操作：操作码为0/1且目标为0/1/2级Cache
assign inst_valid_cacop = inst_cacop&&(dest[2:0]==3'b0||dest[2:0]==3'b1)&&(dest[4:3]==2'd0||dest[4:3]==2'd1||dest[4:3]==2'd2);
// 无效的Cache操作当作NOP处理
assign inst_nop = inst_cacop&&((dest[2:0]!=3'b0&&dest[2:0]!=3'b1)||(dest[4:3]==2'd3));

/*==============================================================================
 * TODO(lab1): ALU操作码生成
 * 提示：根据指令类型生成ALU控制信号
 * ALU译码规则：
 *   alu_op[0]: 加法
 *   alu_op[1]: 减法
 *   alu_op[2]: 有符号比较
 *   alu_op[3]: 无符号比较
 *   alu_op[4]: 逻辑与
 *   alu_op[5]: 或非
 *   alu_op[6]: 逻辑或
 *   alu_op[7]: 逻辑异或
 *   alu_op[8]: 逻辑左移
 *   alu_op[9]: 逻辑右移
 *   alu_op[10]: 算术右移
 *   alu_op[11]: 12位立即数加载
 *   alu_op[12]: 与非
 *   alu_op[13]: 或非
 *==============================================================================*/
assign alu_op[ 0] = inst_add_w      |    // 加法运算
                    inst_addi_w     |    // 立即数加法
                    inst_ld_b       |    // 地址计算（加载指令）
                    inst_ld_h       |
                    inst_ld_w       |
                    inst_st_b       |    // 地址计算（存储指令）
                    inst_st_h       | 
                    inst_st_w       |
                    inst_ld_bu      |
                    inst_ld_hu      | 
                    inst_ll_w       |    // 原子操作地址计算
                    inst_sc_w       |
                    inst_jirl       |    // 跳转地址计算
                    inst_bl         |
                    inst_pcaddi     |    // PC相对地址计算
                    inst_pcaddu12i  |
                    inst_valid_cacop|    // Cache操作地址计算
                    inst_preld      ;    // 预加载地址计算

assign alu_op[ 1] = inst_sub_w;          // 减法运算
assign alu_op[ 2] = inst_slt   | inst_slti;    // 有符号比较
assign alu_op[ 3] = inst_sltu  | inst_sltui;   // 无符号比较
assign alu_op[ 4] = inst_and   | inst_andi;    // 逻辑与运算
assign alu_op[ 5] = inst_nor;                  // 或非运算
assign alu_op[ 6] = inst_or    | inst_ori;     // 逻辑或运算
assign alu_op[ 7] = inst_xor   | inst_xori;    // 逻辑异或运算
assign alu_op[ 8] = inst_sll_w | inst_slli_w;  // 逻辑左移
assign alu_op[ 9] = inst_srl_w | inst_srli_w;  // 逻辑右移
assign alu_op[10] = inst_sra_w | inst_srai_w;  // 算术右移
assign alu_op[11] = inst_lu12i_w;              // 12位立即数加载
assign alu_op[12] = inst_andn;                 // 与非运算
assign alu_op[13] = inst_orn;                  // 或非运算

/*==============================================================================
 * 乘除法操作码生成
 *==============================================================================*/
assign mul_div_op[ 0] = inst_mul_w;                    // 乘法
assign mul_div_op[ 1] = inst_mulh_w | inst_mulh_wu;    // 乘法高位
assign mul_div_op[ 2] = inst_div_w  | inst_div_wu;     // 除法
assign mul_div_op[ 3] = inst_mod_w  | inst_mod_wu;     // 求模

// 乘除法符号标志：有符号运算为1，无符号运算为0
assign mul_div_sign  =  inst_mul_w | inst_mulh_w | inst_div_w | inst_mod_w;

/*==============================================================================
 * 立即数类型识别
 * 根据指令类型确定需要哪种立即数格式
 *==============================================================================*/
assign need_ui5      =  inst_slli_w | inst_srli_w | inst_srai_w;  // 5位无符号立即数（移位量）

assign need_si12     =  inst_addi_w     |    // 12位有符号立即数
                        inst_ld_b       |    // 内存访问偏移
                        inst_ld_h       |
                        inst_ld_w       |
                        inst_st_b       |
                        inst_st_h       | 
                        inst_st_w       |
                        inst_ld_bu      |
                        inst_ld_hu      | 
                        inst_slti       |    // 立即数比较
                        inst_sltui      |
                        inst_valid_cacop|    // Cache操作偏移
                        inst_preld      ;    // 预加载偏移

assign need_ui12     =  inst_andi | inst_ori | inst_xori;  // 12位无符号立即数（逻辑运算）

assign need_si14_pc  =  inst_ll_w | inst_sc_w;  // 14位有符号立即数（PC相对）

assign need_si16_pc  =  inst_jirl |    // 16位有符号立即数（PC相对）
                        inst_beq  |    // 分支指令偏移
                        inst_bne  | 
                        inst_blt  | 
                        inst_bge  | 
                        inst_bltu | 
                        inst_bgeu;

assign need_si20     =  inst_lu12i_w | inst_pcaddu12i;  // 20位有符号立即数
assign need_si20_pc  =  inst_pcaddi;                   // 20位有符号立即数（PC相对）
assign need_si26_pc  =  inst_b | inst_bl;              // 26位有符号立即数（PC相对）

/*==============================================================================
 * 立即数扩展逻辑
 * 根据立即数类型进行符号扩展或零扩展
 *==============================================================================*/
assign ds_imm = ({32{need_ui5    }} & {27'b0, rk}               ) |  // 5位无符号：移位量
                ({32{need_si12   }} & {{20{i12[11]}}, i12}      ) |  // 12位有符号扩展
                ({32{need_ui12   }} & {20'b0, i12}              ) |  // 12位零扩展
                ({32{need_si14_pc}} & {{16{i14[13]}}, i14, 2'b0}) |  // 14位有符号扩展，左移2位
                ({32{need_si16_pc}} & {{14{i16[15]}}, i16, 2'b0}) |  // 16位有符号扩展，左移2位
                ({32{need_si20   }} & {i20, 12'b0}              ) |  // 20位立即数到高位
                ({32{need_si20_pc}} & {{10{i20[19]}}, i20, 2'b0}) |  // 20位有符号扩展，左移2位
                ({32{need_si26_pc}} & {{ 4{i26[25]}}, i26, 2'b0}) ;  // 26位有符号扩展，左移2位

/*==============================================================================
 * 源操作数和目标寄存器选择控制
 *==============================================================================*/
// 源寄存器是rd的指令（用于分支比较和存储数据）
assign src_reg_is_rd = inst_beq    |    // 分支指令需要比较rd
                       inst_bne    | 
                       inst_blt    | 
                       inst_bltu   | 
                       inst_bge    | 
                       inst_bgeu   |
                       inst_st_b   |    // 存储指令rd为存储数据
                       inst_st_h   |
                       inst_st_w   |
                       inst_sc_w   |    // 条件存储
                       inst_csrwr  |    // CSR写指令
                       inst_csrxchg;    // CSR交换指令

// 源操作数1是PC的指令
assign src1_is_pc    = inst_jirl | inst_bl | inst_pcaddi | inst_pcaddu12i;

// 源操作数2是立即数的指令
assign src2_is_imm   = inst_slli_w     |    // 移位立即数指令
                       inst_srli_w     |
                       inst_srai_w     |
                       inst_addi_w     |    // 算术立即数指令
                       inst_slti       |
                       inst_sltui      |
                       inst_andi       |    // 逻辑立即数指令
                       inst_ori        |
                       inst_xori       |
                       inst_pcaddi     |    // PC相对指令
                       inst_pcaddu12i  |
                       inst_ld_b       |    // 内存访问指令
                       inst_ld_h       |
                       inst_ld_w       |
                       inst_ld_bu      |
                       inst_ld_hu      |
                       inst_st_b       |
                       inst_st_h       |
                       inst_st_w       |
                       inst_ll_w       |    // 原子操作指令
                       inst_sc_w       |
                       inst_lu12i_w    |    // 立即数加载指令
                       inst_valid_cacop|    // Cache操作
                       inst_preld      ;    // 预加载

// 源操作数2是4的指令（用于返回地址计算）
assign src2_is_4     = inst_jirl | inst_bl;

/*==============================================================================
 * 内存访问和寄存器写入控制
 *==============================================================================*/
// 加载操作标志
assign load_op       = inst_ld_b | inst_ld_h | inst_ld_w | inst_ld_bu | inst_ld_hu | inst_ll_w;

// 内存访问大小标志
assign mem_b_size    = inst_ld_b | inst_ld_bu | inst_st_b;    // 字节访问
assign mem_h_size    = inst_ld_h | inst_ld_hu | inst_st_h;    // 半字访问
assign mem_sign_exted= inst_ld_b | inst_ld_h;                 // 符号扩展

// 目标寄存器选择
assign dst_is_r1     = inst_bl;    // BL指令目标寄存器是r1

// 通用寄存器写使能（排除不写寄存器的指令）
assign gr_we         = ~inst_st_b       &     // 存储指令
                       ~inst_st_h       & 
                       ~inst_st_w       & 
                       ~inst_beq        &     // 分支指令
                       ~inst_bne        & 
                       ~inst_blt        & 
                       ~inst_bge        &
                       ~inst_bltu       &
                       ~inst_bgeu       &
                       ~inst_b          &     // 跳转指令
                       ~inst_syscall    &     // 系统调用
                       ~inst_tlbsrch    &     // TLB指令
                       ~inst_tlbrd      &
                       ~inst_tlbwr      &
                       ~inst_tlbfill    &
                       ~inst_invtlb     &
                       ~inst_valid_cacop&     // Cache操作
                       ~inst_preld      &     // 预加载
                       ~inst_dbar       &     // 内存屏障
                       ~inst_ibar       &
					   ~inst_nop        ;     // 空操作

// 存储操作标志（SC指令需要检查LLbit）
assign store_op      = inst_st_b | inst_st_h | inst_st_w | (inst_sc_w & ds_llbit);

/*==============================================================================
 * 目标寄存器选择和CSR相关逻辑
 *==============================================================================*/
// 目标寄存器选择：BL指令写r1，RDCNTID写rj，其他写rd
assign dest          = (dst_is_r1) ? 5'd1 :
                       (dst_is_rj) ? rj   : rd;

assign dst_is_rj     = inst_rdcntid_w;  // RDCNTID指令目标寄存器是rj

// 计时器读取结果选择
assign {rdcnt_en, rdcnt_result} = ({33{inst_rdcntvl_w}} & {1'b1, timer_64[31: 0]}) |  // 计时器低32位
                                  ({33{inst_rdcntvh_w}} & {1'b1, timer_64[63:32]}) |  // 计时器高32位
                                  ({33{inst_rdcntid_w}} & {1'b1, csr_tid});           // 计时器ID

// CSR数据选择：计时器读取、SC指令状态或CSR读取
assign csr_data      = rdcnt_en  ? rdcnt_result      :     // 计时器读取结果
                       inst_sc_w ? {31'b0, ds_llbit} :     // SC指令返回LLbit状态
                       rd_csr_data;                         // 普通CSR读取

// CSR相关控制信号                                                                        
assign res_from_csr  = inst_csrrd | inst_csrwr | inst_csrxchg | inst_rdcntid_w | inst_rdcntvh_w | inst_rdcntvl_w | inst_sc_w | inst_cpucfg;
assign csr_we        = inst_csrwr | inst_csrxchg;  // CSR写使能
assign csr_mask      = inst_csrxchg;               // CSR掩码模式（CSRXCHG指令）

// 内存访问大小编码
assign mem_size  = {mem_h_size, mem_b_size};  // {半字, 字节}

/*==============================================================================
 * 寄存器需求检测
 * 确定指令是否需要读取特定的源寄存器
 *==============================================================================*/
assign inst_need_rj = inst_add_w      |    // 需要rj寄存器的指令
                      inst_sub_w      |
                      inst_addi_w     |
                      inst_slt        |
                      inst_sltu       |
                      inst_slti       |
                      inst_sltui      |
                      inst_and        |
                      inst_or         |
                      inst_nor        |
                      inst_xor        |
                      inst_andi       |
                      inst_ori        |
                      inst_xori       |
                      inst_mul_w      |
                      inst_mulh_w     |
                      inst_mulh_wu    |
                      inst_div_w      |
                      inst_div_wu     |
                      inst_mod_w      |
                      inst_mod_wu     |
                      inst_sll_w      |
                      inst_srl_w      |
                      inst_sra_w      |
                      inst_slli_w     |
                      inst_srli_w     |
                      inst_srai_w     |
                      inst_beq        |    // 分支比较指令
                      inst_bne        |
                      inst_blt        |
                      inst_bltu       |
                      inst_bge        |
                      inst_bgeu       |
                      inst_jirl       |    // 间接跳转
                      inst_ld_b       |    // 内存访问（基址）
                      inst_ld_bu      |
                      inst_ld_h       |
                      inst_ld_hu      |
                      inst_ld_w       |
                      inst_st_b       |
                      inst_st_h       |
                      inst_st_w       |
                      inst_preld      |
                      inst_ll_w       |
                      inst_sc_w       |
                      inst_csrxchg    |    // CSR交换
                      inst_valid_cacop|    // Cache操作
                      inst_invtlb     ;    // TLB无效化
                      
assign inst_need_rkd = inst_add_w   |      // 需要rk/rd寄存器的指令
                       inst_sub_w   |
                       inst_slt     |
                       inst_sltu    |
                       inst_and     |
                       inst_or      |
                       inst_nor     |
                       inst_xor     |
                       inst_mul_w   |
                       inst_mulh_w  |
                       inst_mulh_wu |
                       inst_div_w   |
                       inst_div_wu  |
                       inst_mod_w   |
                       inst_mod_wu  |
                       inst_sll_w   |
                       inst_srl_w   |
                       inst_sra_w   |
                       inst_beq     |      // 分支比较指令
                       inst_bne     |
                       inst_blt     |
                       inst_bltu    |
                       inst_bge     |
                       inst_bgeu    |
                       inst_st_b    |      // 存储数据
                       inst_st_h    |
                       inst_st_w    |
                       inst_sc_w    |
                       inst_csrwr   |      // CSR写入
                       inst_csrxchg |      // CSR交换
                       inst_invtlb  ;      // TLB无效化

/*==============================================================================
 * 寄存器文件实例化
 *==============================================================================*/
assign rf_raddr1 = infor_flag?reg_num:rj;  // 调试模式下可读取指定寄存器
assign rf_raddr2 = src_reg_is_rd ? rd : rk; // 根据指令类型选择读端口2地址

regfile u_regfile(
    .clk    (clk      ),
    .raddr1 (rf_raddr1),  // 读端口1地址
    .rdata1 (rf_rdata1),  // 读端口1数据
    .raddr2 (rf_raddr2),  // 读端口2地址
    .rdata2 (rf_rdata2),  // 读端口2数据
    .we     (rf_we    ),  // 写使能
    .waddr  (rf_waddr ),  // 写地址
    .wdata  (rf_wdata )   // 写数据
    `ifdef DIFFTEST_EN
    ,
    .rf_o   (rf_to_diff)  // Difftest寄存器输出
    `endif
    );

/*==============================================================================
 * 数据前递总线解析
 *==============================================================================*/
assign {es_dep_need_stall,  // 执行阶段依赖需要阻塞
        es_forward_enable,  // 执行阶段前递使能
        es_forward_reg   ,  // 执行阶段前递寄存器号
        es_forward_data     // 执行阶段前递数据
       } = es_to_ds_forward_bus;

assign {ms_dep_need_stall,  // 访存阶段依赖需要阻塞
        ms_forward_enable,  // 访存阶段前递使能
        ms_forward_reg   ,  // 访存阶段前递寄存器号
        ms_forward_data     // 访存阶段前递数据
       } = ms_to_ds_forward_bus;

/*==============================================================================
 * 数据前递和相关检测逻辑
 *==============================================================================*/
// TODO(lab1): 数据前递逻辑
// 提示：根据指令类型（是否需要寄存器）和寄存器地址判断是否需要前递数据
//      这里考虑exe和mem两个阶段的前递，wb阶段可通过regfile内部转发实现
assign {rf1_forward_stall, rj_value} = 
        ((rf_raddr1 == es_forward_reg) && es_forward_enable && inst_need_rj)    ? 
            {es_dep_need_stall, es_forward_data}                                : // 从执行阶段前递
        ((rf_raddr1 == ms_forward_reg) && ms_forward_enable && inst_need_rj)    ? 
            {ms_dep_need_stall, ms_forward_data}                                : // 从访存阶段前递
            {1'b0, rf_rdata1}                                                   ; // 使用寄存器文件数据

assign {rf2_forward_stall, rkd_value} = 
        ((rf_raddr2 == es_forward_reg) && es_forward_enable && inst_need_rkd)   ? 
            {es_dep_need_stall, es_forward_data}                                : // 从执行阶段前递
        ((rf_raddr2 == ms_forward_reg) && ms_forward_enable && inst_need_rkd)   ? 
            {ms_dep_need_stall, ms_forward_data}                                : // 从访存阶段前递
            {1'b0, rf_rdata2}                                                   ; // 使用寄存器文件数据

/*==============================================================================
 * 分支条件判断逻辑
 *==============================================================================*/
assign rj_eq_rd        = (rj_value == rkd_value);  // 相等比较
assign rj_lt_rd_unsign = (rj_value < rkd_value);   // 无符号小于比较

// 有符号小于比较：考虑符号位
assign rj_lt_rd_sign   = (rj_value[31] && ~rkd_value[31]) ? 1'b1 :    // rj负，rd正
                         (~rj_value[31] && rkd_value[31]) ? 1'b0 :    // rj正，rd负
                         rj_lt_rd_unsign;                             // 同号时按无符号比较
                                                            
// 分支taken判断
assign br_taken  = (   inst_beq  &&  rj_eq_rd         // 相等分支
                    || inst_bne  && !rj_eq_rd         // 不等分支
                    || inst_blt  &&  rj_lt_rd_sign    // 有符号小于分支
                    || inst_bge  && !rj_lt_rd_sign    // 有符号大于等于分支
                    || inst_bltu &&  rj_lt_rd_unsign  // 无符号小于分支
                    || inst_bgeu && !rj_lt_rd_unsign  // 无符号大于等于分支
                    || inst_jirl                      // 间接跳转
                    || inst_bl                        // 无条件跳转链接
                    || inst_b                         // 无条件跳转
                    ) && ds_valid && !ds_excp;        // 且当前有效且无异常

/*==============================================================================
 * 分支和BTB相关信号
 *==============================================================================*/
assign br_inst = br_need_reg_data || inst_bl || inst_b;  // 分支指令标志

assign br_to_btb = inst_beq   ||    // 需要BTB预测的分支指令
                   inst_bne   ||
                   inst_blt   ||
                   inst_bge   ||
                   inst_bltu  ||
                   inst_bgeu  ||
                   inst_bl    ||
                   inst_b     || 
                   inst_jirl;

assign br_need_reg_data = inst_beq   ||  // 需要寄存器数据进行判断的分支
                          inst_bne   ||
                          inst_blt   ||
                          inst_bge   ||
                          inst_bltu  ||
                          inst_bgeu  ||
                          inst_jirl;

// 分支目标地址计算
assign br_target = ({32{inst_beq || inst_bne || inst_bl || inst_b || 
                    inst_blt || inst_bge || inst_bltu || inst_bgeu}} & (ds_pc + ds_imm   ))            |  // PC相对分支
                   ({32{inst_jirl}}                                  & (rj_value + ds_imm)) ;  // 寄存器相对跳转

/*==============================================================================
 * 异常处理逻辑
 *==============================================================================*/
assign excp     = excp_ipe | inst_syscall | inst_break | ds_excp | excp_ine | has_int;  // 异常汇总
assign excp_num = {excp_ipe, excp_ine, inst_break, inst_syscall, ds_excp_num, has_int}; // 异常编号

// CSR地址选择：CPUCFG指令使用特殊地址计算
assign rd_csr_addr = inst_cpucfg ? (rj_value[13:0]+14'h00b0) : csr_idx;

// 重取指信号：会改变地址翻译的指令执行后需要重取指
assign refetch = (inst_tlbwr || inst_tlbfill || inst_tlbrd || inst_invtlb || inst_ibar) && ds_valid;

// TLB指令阻塞：前面阶段有TLB指令时需要阻塞，抽空流水线
// TLBSRCH和TLBRD指令会修改CSR状态，暂停以保证后续指令执行时看到的CSR数据同步
// 其实refetch也可以解决这个问题
assign tlb_inst_stall = es_tlb_inst_stall || ms_tlb_inst_stall || ws_tlb_inst_stall;

/*==============================================================================
 * 指令有效性判断
 *==============================================================================*/
assign inst_valid = inst_add_w      |    // 所有有效指令的汇总
                    inst_sub_w      |
                    inst_slt        |
                    inst_sltu       |
                    inst_nor        |
                    inst_and        |
                    inst_or         |
                    inst_xor        |
                    inst_sll_w      |
                    inst_srl_w      |
                    inst_sra_w      |
                    inst_mul_w      |
                    inst_mulh_w     |
                    inst_mulh_wu    |
                    inst_div_w      |
                    inst_mod_w      |
                    inst_div_wu     |
                    inst_mod_wu     |
                    inst_break      |
                    inst_syscall    |
                    inst_slli_w     |
                    inst_srli_w     |
                    inst_srai_w     |
                    inst_idle       |
                    inst_slti       |
                    inst_sltui      |
                    inst_addi_w     |
                    inst_andi       |
                    inst_ori        |
                    inst_xori       |
                    inst_ld_b       |
                    inst_ld_h       |
                    inst_ld_w       |
                    inst_st_b       |
                    inst_st_h       |
                    inst_st_w       |
                    inst_ld_bu      |
                    inst_ld_hu      |
                    inst_ll_w       |
                    inst_sc_w       |
                    inst_jirl       |
                    inst_b          |
                    inst_bl         |
                    inst_beq        |
                    inst_bne        |
                    inst_blt        |
                    inst_bge        |
                    inst_bltu       |
                    inst_bgeu       |
                    inst_lu12i_w    |
                    inst_pcaddu12i  |
                    inst_csrrd      |
                    inst_csrwr      |
                    inst_csrxchg    |
                    inst_rdcntid_w  |
                    inst_rdcntvh_w  |
                    inst_rdcntvl_w  |
                    inst_ertn       |
                    inst_valid_cacop|
                    inst_preld      |
                    inst_dbar       |
                    inst_ibar       |
                    inst_tlbsrch    |
                    inst_tlbrd      |
                    inst_tlbwr      |
                    inst_tlbfill    |
					inst_nop        |
                    inst_cpucfg     |
                    (inst_invtlb && (rd == 5'd0 ||     // INVTLB有效操作码
                                     rd == 5'd1 || 
                                     rd == 5'd2 || 
                                     rd == 5'd3 || 
                                     rd == 5'd4 ||
                                     rd == 5'd5 || 
                                     rd == 5'd6 ));
// 非法指令异常
assign excp_ine = ~inst_valid;

// 内核指令：需要特权级权限的指令
assign kernel_inst = inst_csrrd      |
                     inst_csrwr      |
                     inst_csrxchg    |
                     inst_valid_cacop & (rd[4:3] != 2'b10)|  // 非用户级Cache操作
                     inst_tlbsrch    |
                     inst_tlbrd      |
                     inst_tlbwr      |
                     inst_tlbfill    |
                     inst_invtlb     |
                     inst_ertn       |
                     inst_idle       ;
// TODO(lab2): 指令特权异常
// 提示：用户态执行内核指令
assign excp_ipe = kernel_inst && (csr_plv == 2'b11);

/*==============================================================================
 * 分支槽取消逻辑
 * 当BTB预测错误时，需要取消延迟槽指令
 *==============================================================================*/
always @(posedge clk) begin
    if (reset || flush_sign) begin
        // 复位或刷新时清除分支槽取消标志
        branch_slot_cancel <= 1'b0;
    end
    else if (btb_pre_error_flush && es_allowin && !fs_to_ds_valid) begin
        // BTB预测错误且后级允许且前级无有效数据时设置取消标志
        branch_slot_cancel <= 1'b1;
    end
    else if (branch_slot_cancel && fs_to_ds_valid) begin
        // 有有效指令到达时清除取消标志
        branch_slot_cancel <= 1'b0;
    end
end

/*==============================================================================
 * BTB操作接口
 *==============================================================================*/
assign btb_operate_en    = ds_valid && ds_ready_go && es_allowin && !ds_excp;  // BTB操作使能
assign btb_operate_pc    = ds_pc;                    // 操作PC
assign btb_pop_ras       = inst_jirl;                // 弹出返回地址栈（函数返回）
assign btb_push_ras      = inst_bl;                  // 压入返回地址栈（函数调用）
assign btb_add_entry     = br_to_btb && !ds_btb_en && br_taken;              // 添加BTB条目
assign btb_delete_entry  = !br_to_btb && ds_btb_en;                          // 删除BTB条目
assign btb_pre_error     = br_to_btb && ds_btb_en && (ds_btb_taken ^ br_taken);        // BTB预测方向错误
assign btb_target_error  = br_to_btb && ds_btb_en && (ds_btb_taken && br_taken) && (ds_btb_target != br_target); // BTB目标地址错误
assign btb_pre_right     = br_to_btb && ds_btb_en && !(ds_btb_taken ^ br_taken);       // BTB预测正确
assign btb_right_orien   = br_taken;                 // 正确的分支方向
assign btb_right_target  = br_target;                // 正确的目标地址
assign btb_operate_index = ds_btb_index;             // BTB操作索引

// BTB预测错误刷新信号
assign btb_pre_error_flush = (btb_add_entry || btb_delete_entry || btb_pre_error || btb_target_error) && ds_valid && ds_ready_go && !ds_excp;
// BTB预测错误刷新目标：taken时跳转到目标地址，否则顺序执行
assign btb_pre_error_flush_target = br_taken ? br_target : ds_pc + 32'h4;

/*==============================================================================
 * 内存屏障指令处理
 *==============================================================================*/
// 流水线非空判断：任何阶段有效或写缓冲/DCache非空
assign pipeline_no_empty = es_to_ds_valid || ms_to_ds_valid || ws_to_ds_valid || !write_buffer_empty || !dcache_empty;
// DBAR阻塞：数据屏障指令需要等待流水线为空
assign dbar_stall = inst_dbar && pipeline_no_empty;
// IBAR阻塞：指令屏障指令需要等待流水线为空
assign ibar_stall = inst_ibar && pipeline_no_empty;

/*==============================================================================
 * Difftest接口信号
 * 用于与黄金模型进行对比验证
 *==============================================================================*/
// 加载指令使能编码：ll ldw ldhu ldh ldbu ldb
assign inst_ld_en = {2'b0, inst_ll_w, inst_ld_w, inst_ld_hu, inst_ld_h, inst_ld_bu, inst_ld_b};
// 存储指令使能编码：sc(需要llbit=1) stw sth stb
assign inst_st_en = {4'b0, ds_llbit && inst_sc_w, inst_st_w, inst_st_h, inst_st_b};
// CSR RSTAT读取使能：访问RSTAT寄存器时置位
assign inst_csr_rstat_en = (inst_csrrd || inst_csrwr || inst_csrxchg) && (csr_idx == 14'd5);

/*==============================================================================
 * 调试接口
 *==============================================================================*/
// 调试寄存器数据输出
assign debug_rf_rdata1 = rf_raddr1;

endmodule
