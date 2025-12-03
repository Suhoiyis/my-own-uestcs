/*==============================================================================
 * LoongArch架构五级流水线处理器 - 取指令阶段 (Instruction Fetch Stage)
 * 
 * 主要功能：
 * 1. PC计算和管理：顺序PC、分支预测PC、异常PC等
 * 2. 指令Cache接口：与ICache交互获取指令
 * 3. 地址翻译：支持虚实地址翻译、DMW窗口映射
 * 4. 异常处理：地址对齐异常、TLB相关异常
 * 5. 分支预测：BTB（分支目标缓冲器）集成
 * 6. 流水线控制：ready/valid握手协议
 *==============================================================================*/

/*
* LoongArch架构五级流水线处理器 - 取指令阶段 (Instruction Fetch Stage)
* 
* 模块功能：
* - 实现五级流水线的取指令阶段，负责从指令缓存中取指令
* - 处理PC地址生成、分支预测、异常检测等功能
* - 支持地址翻译（TLB）、直接映射窗口（DMW）等内存管理机制
* - 处理各种刷新信号和流水线控制
* - 与分支目标缓冲器（BTB）交互进行分支预测
*/

`include "mycpu.vh"
`include "csr.vh"

module if_stage(
    input                          clk            ,  // 时钟信号
    input                          reset          ,  // 复位信号
    
    //================= 流水线控制信号 =================
    input                          ds_allowin     ,  // 译码阶段允许新数据进入
    
    //================= 分支控制总线 =================
    input  [`BR_BUS_WD       -1:0] br_bus         ,  // 分支总线：包含分支预测错误修正信息
    
    //================= 到译码阶段接口 =================
    output                         fs_to_ds_valid ,  // 取指阶段到译码阶段数据有效
    output [`FS_TO_DS_BUS_WD -1:0] fs_to_ds_bus   ,  // 取指阶段到译码阶段数据总线
    
    //================= 异常和刷新控制 =================
    input                          excp_flush       ,  // 异常刷新信号
    input                          ertn_flush       ,  // 异常返回刷新信号
    input                          refetch_flush    ,  // 重取指刷新信号
    input                          icacop_flush     ,  // ICache操作刷新信号
    input  [31:0]                  ws_pc            ,  // 写回阶段PC（用于刷新目标）
    input  [31:0]                  csr_eentry       ,  // CSR异常入口地址
    input  [31:0]                  csr_era          ,  // CSR异常返回地址
    input                          excp_tlbrefill   ,  // TLB重填异常标志
    input  [31:0]                  csr_tlbrentry    ,  // CSR TLB重填异常入口
    input                          has_int          ,  // 中断信号
    
    //================= 空闲指令控制 =================
    input                          idle_flush       ,  // 空闲指令刷新信号
    
    //================= 指令Cache接口 =================
    output                         inst_valid        ,  // 指令请求有效
    output                         inst_op           ,  // 指令操作类型（读）
    output [ 3:0]                  inst_wstrb        ,  // 指令写字节使能（未使用）
    output [31:0]                  inst_wdata        ,  // 指令写数据（未使用）
    input                          inst_addr_ok      ,  // 指令地址接受
    input                          inst_data_ok      ,  // 指令数据返回
    input                          icache_miss       ,  // 指令Cache缺失
    input  [31:0]                  inst_rdata        ,  // 指令读数据
    output                         inst_uncache_en   ,  // 指令非缓存访问使能
    output                         tlb_excp_cancel_req,  // TLB异常取消请求
    
    //================= CSR控制信号 =================
    input                          csr_pg            ,  // 分页使能
    input                          csr_da            ,  // 直接地址翻译模式
    input  [31:0]                  csr_dmw0          ,  // 直接映射窗口0配置
    input  [31:0]                  csr_dmw1          ,  // 直接映射窗口1配置
    input  [ 1:0]                  csr_plv           ,  // 当前特权级
    input  [ 1:0]                  csr_datf          ,  // 直接地址翻译格式
    
    //================= 分支预测BTB接口 =================
    output [31:0]                  fetch_pc          ,  // 取指PC（给BTB查找）
    output                         fetch_en          ,  // 取指使能（给BTB）
    input  [31:0]                  btb_ret_pc        ,  // BTB返回的预测目标PC
    input                          btb_taken         ,  // BTB预测分支taken
    input                          btb_en            ,  // BTB命中信号
    input  [ 4:0]                  btb_index         ,  // BTB索引
    
    //================= 地址翻译接口 =================
    output [31:0]                  inst_addr         ,  // 指令地址（给地址翻译）
    output                         dmw0_en           ,  // 直接映射窗口0使能
    output                         dmw1_en           ,  // 直接映射窗口1使能
    
    //================= TLB接口 =================
    input                          inst_tlb_found    ,  // TLB查找命中
    input                          inst_tlb_v        ,  // TLB条目有效位
    input                          inst_tlb_d        ,  // TLB条目脏位
    input  [ 1:0]                  inst_tlb_mat      ,  // TLB存储访问类型
    input  [ 1:0]                  inst_tlb_plv         // TLB特权级
);

/*==============================================================================
 * 内部信号声明
 *==============================================================================*/

//================= 流水线控制信号 =================
reg          fs_valid;         // 取指阶段数据有效标志
wire         fs_ready_go;      // 取指阶段准备完成
wire         fs_allowin;       // 取指阶段允许新数据进入
wire         to_fs_valid;      // 前级到取指阶段数据有效
wire         pfs_ready_go;     // 预取指阶段准备完成

//================= PC相关信号 =================
wire [31:0]  seq_pc;           // 顺序PC（当前PC+4）
wire [31:0]  nextpc;           // 下一个PC值

//================= 异常相关信号 =================
wire         pfs_excp_adef;    // 预取指阶段地址错误异常
wire         fs_excp_tlbr;     // 取指阶段TLB重填异常
wire         fs_excp_pif;      // 取指阶段页无效异常
wire         fs_excp_ppi;      // 取指阶段页特权级异常
reg          fs_excp;          // 取指阶段异常标志
reg          fs_excp_num;      // 取指阶段异常编号
wire         excp;             // 综合异常信号
wire [3:0]   excp_num;         // 综合异常编号
wire         pfs_excp;         // 预取指阶段异常信号
wire         pfs_excp_num;     // 预取指阶段异常编号

//================= 刷新控制信号 =================
wire         flush_sign;       // 刷新信号

//================= 指令缓冲相关 =================
reg  [31:0]  inst_rd_buff;     // 指令读缓冲
reg          inst_buff_enable; // 指令缓冲使能

//================= 地址翻译模式 =================
wire         inst_addr_trans_en;  // 指令地址翻译使能
wire         da_mode;          // 直接地址翻译模式
wire         pg_mode;          // 分页模式

//================= 分支预测相关 =================
wire         btb_pre_error_flush;        // BTB预测错误刷新
wire [31:0]  btb_pre_error_flush_target; // BTB预测错误目标地址

//================= 刷新延迟控制 =================
wire         flush_inst_delay;  // 刷新指令延迟
wire         flush_inst_go_dirt; // 刷新指令立即执行

//================= BTB相关 =================
wire         fetch_btb_target;  // 取BTB预测目标

//================= 空闲锁定 =================
reg          idle_lock;         // 空闲锁定标志

//================= TLB异常锁定 =================
wire         tlb_excp_lock_pc;  // TLB异常锁定PC

//================= BTB锁定缓冲 =================
wire  [31:0] btb_ret_pc_t;      // BTB返回PC（经过锁定处理）
wire  [ 4:0] btb_index_t;       // BTB索引（经过锁定处理）
wire         btb_taken_t;       // BTB taken（经过锁定处理）
wire         btb_en_t;          // BTB使能（经过锁定处理）

//================= 异常入口和刷新PC =================
wire  [31:0] excp_entry;        // 异常入口地址
wire  [31:0] inst_flush_pc;     // 指令刷新PC

//================= 分支总线解析 =================
assign {btb_pre_error_flush,
        btb_pre_error_flush_target  } = br_bus;

//================= 输出信号 =================
wire [31:0] fs_inst;            // 取指阶段指令
reg  [31:0] fs_pc;              // 取指阶段PC

//================= BTB锁定缓冲寄存器 =================
reg [37:0] btb_lock_buffer;     // BTB锁定缓冲：{taken, index[4:0], pc[31:0]}
reg        btb_lock_en;         // BTB锁定使能

/*==============================================================================
 * 到译码阶段的数据总线
 * 包含：BTB信息、ICache缺失信息、异常信息、指令和PC
 *==============================================================================*/
assign fs_to_ds_bus = {btb_ret_pc_t,    //108:77 - BTB预测目标PC
                       btb_index_t,     //76:72  - BTB索引
                       btb_taken_t,     //71:71  - BTB预测taken
                       btb_en_t,        //70:70  - BTB命中
                       icache_miss,     //69:69  - ICache缺失
                       excp,            //68:68  - 异常标志
                       excp_num,        //67:64  - 异常编号
                       fs_inst,         //63:32  - 指令
                       fs_pc            //31:0   - PC
                      };

//================= 刷新信号汇总 =================
assign flush_sign = ertn_flush || excp_flush || refetch_flush || icacop_flush || idle_flush;

//================= 刷新延迟控制逻辑 =================
// flush需要等待icache完成现有传输事务
// flush_inst_delay: 刷新信号有效但地址未被接受，或者是空闲刷新
assign flush_inst_delay = flush_sign && !inst_addr_ok || idle_flush;
// flush_inst_go_dirt: 刷新信号有效且地址被接受，但不是空闲刷新（可立即执行）
assign flush_inst_go_dirt = flush_sign && inst_addr_ok && !idle_flush;

/*==============================================================================
 * 刷新指令请求状态机
 * 当刷新信号到达但指令地址未被接受时，缓存刷新目标地址
 * 等待合适时机重新发起指令请求
 *==============================================================================*/
reg [31:0] flush_inst_req_buffer;  // 刷新指令请求缓冲
reg        flush_inst_req_state;   // 刷新指令请求状态

// 状态定义
localparam flush_inst_req_empty = 1'b0;  // 空状态：无待处理的刷新请求
localparam flush_inst_req_full  = 1'b1;  // 满状态：有待处理的刷新请求

always @(posedge clk) begin
    if (reset) begin
        flush_inst_req_state <= flush_inst_req_empty;
    end 
    else case (flush_inst_req_state)
        flush_inst_req_empty: begin
            // 空状态：检测到延迟刷新时进入满状态
            if(flush_inst_delay) begin
                flush_inst_req_buffer <= nextpc;           // 缓存目标PC
                flush_inst_req_state  <= flush_inst_req_full;
            end
        end
        flush_inst_req_full: begin
            // 满状态：等待预取指阶段准备完成
            if(pfs_ready_go) begin
                flush_inst_req_state  <= flush_inst_req_empty;
            end
            // 如果有新的刷新信号，更新缓冲的目标PC
            else if (flush_sign) begin
                flush_inst_req_buffer <= nextpc;
            end
        end
    endcase
end

//================= BTB预测目标选择 =================
// 选择BTB预测目标：BTB当前命中且taken，或者BTB锁定缓冲有效且taken
assign fetch_btb_target = (btb_taken && btb_en) || (btb_lock_en && btb_lock_buffer[37]);

/*==============================================================================
 * 空闲锁定逻辑
 * 当空闲指令提交时，停止取指直到被中断唤醒
 * 这是为了实现处理器的低功耗模式
 *==============================================================================*/
always @(posedge clk) begin
    if (reset) begin
        idle_lock <= 1'b0;
    end
    else if (idle_flush && !has_int) begin
        // 空闲刷新且无中断时进入锁定状态
        idle_lock <= 1'b1;
    end
    else if (has_int) begin
        // 有中断时解除锁定
        idle_lock <= 1'b0;
    end
end

/*==============================================================================
 * 分支目标指令请求状态机
 * 当BTB预测错误时，ID阶段会取消一条指令
 * 需要确保无用指令（将被取消的指令）已经生成
 * 
 * 状态说明：
 * - empty: 正常状态
 * - wait_slot: 等待slot指令（延迟槽或被取消的指令）完成
 * - wait_br_target: 等待分支目标指令取指完成
 *==============================================================================*/
reg [31:0] br_target_inst_req_buffer;  // 分支目标指令请求缓冲
reg [ 2:0] br_target_inst_req_state;   // 分支目标指令请求状态

// 状态定义
localparam br_target_inst_req_empty = 3'b001;           // 空状态
localparam br_target_inst_req_wait_slot = 3'b010;       // 等待slot状态
localparam br_target_inst_req_wait_br_target = 3'b100;  // 等待分支目标状态

always @(posedge clk) begin
    if (reset) begin
        br_target_inst_req_state <= br_target_inst_req_empty;
    end
    else case (br_target_inst_req_state) 
        br_target_inst_req_empty: begin
            if (flush_sign) begin
                // 刷新信号优先，保持空状态
                br_target_inst_req_state <= br_target_inst_req_empty; 
            end
            else if(btb_pre_error_flush && !fs_valid && !inst_addr_ok) begin
                // BTB预测错误且当前无有效指令且地址未接受：等待slot
                br_target_inst_req_state  <= br_target_inst_req_wait_slot;
                br_target_inst_req_buffer <= btb_pre_error_flush_target;
            end
            else if(btb_pre_error_flush && !inst_addr_ok && fs_valid || btb_pre_error_flush && inst_addr_ok && !fs_valid) begin
                // BTB预测错误的其他情况：直接等待分支目标
                br_target_inst_req_state  <= br_target_inst_req_wait_br_target;
                br_target_inst_req_buffer <= btb_pre_error_flush_target;
            end
        end
        br_target_inst_req_wait_slot: begin
            if(flush_sign) begin
                // 刷新信号到达，返回空状态
                br_target_inst_req_state <= br_target_inst_req_empty;
            end
            else if(pfs_ready_go) begin
                // 预取指准备完成，转到等待分支目标状态
                br_target_inst_req_state <= br_target_inst_req_wait_br_target;
            end
        end
        br_target_inst_req_wait_br_target: begin
            if(pfs_ready_go || flush_sign) begin
                // 预取指完成或刷新信号到达，返回空状态
                br_target_inst_req_state <= br_target_inst_req_empty;
            end
        end
        default: begin
            br_target_inst_req_state <= br_target_inst_req_empty;
        end
    endcase
end

/*==============================================================================
 * BTB锁定逻辑
 * BTB返回信息只维持一个时钟周期
 * 当预取指阶段未准备好时，需要缓冲BTB返回信息
 *==============================================================================*/
always @(posedge clk) begin
	if (reset || flush_sign || fetch_en)
		btb_lock_en <= 1'b0;
	else if (btb_en && !pfs_ready_go) begin
		// BTB命中但预取指未准备好：锁定BTB信息
		btb_lock_en     <= 1'b1;
		btb_lock_buffer <= {btb_taken, btb_index, btb_ret_pc};
	end
end

//================= BTB信息选择逻辑 =================
// 如果BTB被锁定，使用锁定的信息；否则使用当前BTB信息
assign btb_ret_pc_t = {32{btb_lock_en}} & btb_lock_buffer[31:0] | btb_ret_pc;
assign btb_index_t  = {5{btb_lock_en}} & btb_lock_buffer[36:32] | btb_index;
assign btb_taken_t  = btb_lock_en && btb_lock_buffer[37] || btb_taken;
assign btb_en_t     = btb_lock_en || btb_en;

/*==============================================================================
 * 预取指阶段 (Pre-IF Stage) 控制逻辑
 *==============================================================================*/

// 预取指准备完成：指令请求有效或有异常，且地址被接受
assign pfs_ready_go = (inst_valid || pfs_excp) && inst_addr_ok;

// 到取指阶段有效：非复位状态且预取指准备完成
assign to_fs_valid  = ~reset && pfs_ready_go;

// 顺序PC：当前PC + 4
assign seq_pc       = fs_pc + 32'h4;

// 异常入口地址选择：TLB重填异常使用TLB重填入口，其他异常使用通用异常入口
assign excp_entry   = {32{excp_tlbrefill}}  & csr_tlbrentry |
                      {32{!excp_tlbrefill}} & csr_eentry    ;

// 指令刷新PC：根据不同刷新类型选择目标PC
assign inst_flush_pc = {32{ertn_flush}}                                  & csr_era         |  // 异常返回：返回ERA
                       {32{refetch_flush || icacop_flush || idle_flush}} & (ws_pc + 32'h4) ;  // 其他：WS阶段PC+4

//================= 下一个PC计算逻辑 =================
// PC选择优先级（从高到低）：
// 1. 刷新请求缓冲区有效
// 2. 异常刷新
// 3. 其他类型刷新
// 4. 分支目标状态机等待分支目标
// 5. BTB预测错误且当前有效
// 6. BTB预测目标
// 7. 顺序PC（默认）
assign nextpc = (flush_inst_req_state == flush_inst_req_full)                   ? flush_inst_req_buffer     :
                excp_flush                                                      ? excp_entry                :
                (ertn_flush || refetch_flush || icacop_flush || idle_flush)     ? inst_flush_pc             :
                (br_target_inst_req_state == br_target_inst_req_wait_br_target) ? br_target_inst_req_buffer :
                btb_pre_error_flush && fs_valid                                 ? btb_pre_error_flush_target:
                fetch_btb_target                                                ? btb_ret_pc_t              :
                                                                                  seq_pc                    ;
/*==============================================================================
 * TLB异常锁定PC逻辑
 * 当遇到TLB异常时，停止指令取指直到异常刷新，避免取到无用指令
 * 但当BTB状态机或刷新状态机正在工作时不应锁定
 *==============================================================================*/
assign tlb_excp_lock_pc = tlb_excp_cancel_req && 
                         br_target_inst_req_state != br_target_inst_req_wait_br_target && 
                         flush_inst_req_state != flush_inst_req_full;

/*==============================================================================
 * 指令Cache接口控制
 *==============================================================================*/
// 指令请求有效条件：
// - 允许进入且无预取指异常且无TLB异常锁定，或有刷新/BTB预测错误
// - 且非空闲刷新或空闲锁定状态（IDLE指令产生）
assign inst_valid = (fs_allowin && !pfs_excp && !tlb_excp_lock_pc || flush_sign || btb_pre_error_flush) && 
                   !(idle_flush || idle_lock);
assign inst_op     = 1'b0;      // 读操作
assign inst_wstrb  = 4'h0;      // 不需要写字节使能
assign inst_addr   = nextpc;    // 指令地址就是下一个PC
assign inst_wdata  = 32'b0;     // 不需要写数据

// 指令数据选择：如果指令缓冲使能则用缓冲数据，否则用Cache返回数据
assign fs_inst     = (inst_buff_enable) ? inst_rd_buff : inst_rdata;
/*==============================================================================
 * 指令读缓冲逻辑
 * 用于处理流水线阻塞情况下的指令缓存
 * 当指令数据返回但译码阶段不允许新数据进入时，缓存指令数据
 *==============================================================================*/
always @(posedge clk) begin
    if (reset || (fs_ready_go && ds_allowin) || flush_sign) begin
        // 复位、流水线正常前进或刷新时清除缓冲
        inst_buff_enable  <= 1'b0;
    end
    else if ((inst_data_ok) && !ds_allowin) begin
        // 指令数据返回但译码阶段不接受：缓存指令数据
        // 构建这个缓冲主要是因为icache由FSM控制，有效数据仅维持1拍
        inst_rd_buff <= inst_rdata;
        inst_buff_enable  <= 1'b1;
    end
end

/*==============================================================================
 * 异常检测逻辑
 *==============================================================================*/
// TODO(lab2): 预取指阶段异常
// 提示：地址对齐检查（指令必须4字节对齐）
assign pfs_excp_adef = (nextpc[0] || nextpc[1]); 

// TODO(lab4): TLB相关异常检测
// 提示：
// 1. TLB重填异常：TLB未命中且地址翻译使能
// 2. 页无效异常：TLB条目无效且地址翻译使能
// 3. 页特权异常：TLB条目特权级低于当前特权级且地址翻译使能
assign fs_excp_tlbr = !inst_tlb_found && inst_addr_trans_en; // TLB重填异常
assign fs_excp_pif  = !inst_tlb_v && inst_addr_trans_en; // 页无效异常
assign fs_excp_ppi  = (csr_plv > inst_tlb_plv) && inst_addr_trans_en; // 页特权异常

// TLB异常取消请求：任何TLB相关异常都需要取消当前指令取指
assign tlb_excp_cancel_req = fs_excp_tlbr || fs_excp_pif || fs_excp_ppi;

// 预取指阶段异常汇总
assign pfs_excp = pfs_excp_adef;
assign pfs_excp_num = {pfs_excp_adef};

// 所有异常汇总
assign excp = fs_excp || fs_excp_tlbr || fs_excp_pif || fs_excp_ppi ;
assign excp_num = {fs_excp_ppi, fs_excp_pif, fs_excp_tlbr, fs_excp_num};

/*==============================================================================
 * 地址翻译控制逻辑
 *==============================================================================*/
// TODO(lab4): 地址翻译使能
// 提示：分页模式下且不在DMW窗口内
assign inst_addr_trans_en = pg_mode && !dmw0_en && !dmw1_en;

// TODO(lab4): 直接映射窗口0使能
// 提示：特权级匹配且虚拟段匹配且在分页模式
assign dmw0_en = ((csr_dmw0[`PLV0] && csr_plv == 2'd0) || (csr_dmw0[`PLV3] && csr_plv == 2'd3)) && 
                 (fs_pc[31:29] == csr_dmw0[`VSEG]) && pg_mode;

// TODO(lab4): 直接映射窗口1使能
// 提示：特权级匹配且虚拟段匹配且在分页模式
assign dmw1_en = ((csr_dmw1[`PLV0] && csr_plv == 2'd0) || (csr_dmw1[`PLV3] && csr_plv == 2'd3)) && 
                 (fs_pc[31:29] == csr_dmw1[`VSEG]) && pg_mode;

/*==============================================================================
 * 缓存模式判断
 *==============================================================================*/
// 直接地址翻译模式：DA=1且PG=0
assign da_mode = csr_da && !csr_pg;
// 分页模式：PG=1且DA=0
assign pg_mode = csr_pg && !csr_da;

// TODO(lab3/4): 非缓存访问使能判断
// 提示，任一条件满足即为非缓存访问：
// 1. TODO(lab3)直接地址翻译模式且DATF=00（强序非缓存）
// 2. TODO(lab3)DMW0窗口且MAT=00（强序非缓存）
// 3. TODO(lab3)DMW1窗口且MAT=00（强序非缓存）
// 4. TODO(lab4)TLB翻译且MAT=00（强序非缓存）
assign inst_uncache_en = (da_mode && (csr_datf == 2'b0))                 ||
                         (dmw0_en && (csr_dmw0[`DMW_MAT] == 2'b0))       ||
                         (dmw1_en && (csr_dmw1[`DMW_MAT] == 2'b0))       ||
                         (inst_addr_trans_en && (inst_tlb_mat == 2'b0))  ;

/*==============================================================================
 * IF阶段流水线控制逻辑
 *==============================================================================*/
// TODO(lab1): IF阶段准备完成
// 提示：指令数据返回 或 指令缓冲有效 或 发生异常
assign fs_ready_go    = inst_data_ok || inst_buff_enable || excp;

// TODO(lab1): IF阶段允许新数据进入
// 提示：当前无有效数据或准备完成且后级允许
assign fs_allowin     = !fs_valid || fs_ready_go && ds_allowin;

// TODO(lab1): 向译码阶段传递有效信号
// 提示：当前有效且准备完成
assign fs_to_ds_valid =  fs_valid && fs_ready_go;

/*==============================================================================
 * IF阶段状态寄存器
 *==============================================================================*/
always @(posedge clk) begin
    if (reset || flush_inst_delay) begin
        // 复位或刷新延迟时清除有效标志
        fs_valid <= 1'b0;
    end
    else if (fs_allowin) begin
        // 允许新数据进入时更新有效标志
        fs_valid <= to_fs_valid;
    end

    if (reset) begin
        // 复位时初始化PC和异常信号
        fs_pc        <= 32'h1bfffffc;  // 技巧：使复位期间nextpc为0x1c000000
        fs_excp      <= 1'b0;
        fs_excp_num  <= 4'b0;
    end
    else if (to_fs_valid && (fs_allowin || flush_inst_go_dirt)) begin
        // 有新数据且允许进入或立即刷新时更新PC和异常信息
        fs_pc        <= nextpc;
        fs_excp      <= pfs_excp;
        fs_excp_num  <= pfs_excp_num;
    end
end

/*==============================================================================
 * BTB和TLB接口信号
 *==============================================================================*/
// 给BTB的取指PC
assign fetch_pc  = nextpc;
// 给BTB的取指使能：指令请求有效且地址被接受
assign fetch_en  = inst_valid && inst_addr_ok;

endmodule
