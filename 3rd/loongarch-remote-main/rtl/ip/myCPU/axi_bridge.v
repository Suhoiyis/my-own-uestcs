/**
 * AXI桥接模块 (AXI Bridge)
 * 
 * 功能说明：
 * - 将处理器Cache接口转换为标准AXI4总线接口
 * - 支持指令Cache和数据Cache的读写请求
 * - 处理AXI读写事务的握手协议
 * - 支持Cache行读取和单字读写操作
 * - 实现写缓冲机制提高性能
 * - 处理读写请求的优先级和冲突
 */
module axi_bridge(
    input   clk,    // 时钟信号
    input   reset,  // 复位信号

    // AXI4 读地址通道 (AR Channel)
    output   reg[ 3:0] arid,     // 读事务ID
    output   reg[31:0] araddr,   // 读地址
    output   reg[ 7:0] arlen,    // 突发长度 (传输次数-1)
    output   reg[ 2:0] arsize,   // 突发大小 (每次传输字节数)
    output      [ 1:0] arburst,  // 突发类型 (固定为INCR)
    output      [ 1:0] arlock,   // 锁定类型 (固定为Normal)
    output      [ 3:0] arcache,  // Cache属性 (固定为0)
    output      [ 2:0] arprot,   // 保护类型 (固定为0)
    output   reg       arvalid,  // 读地址有效
    input              arready,  // 读地址就绪

    // AXI4 读数据通道 (R Channel)
    input    [ 3:0] rid,     // 读事务ID
    input    [31:0] rdata,   // 读数据
    input    [ 1:0] rresp,   // 读响应
    input           rlast,   // 最后一次读传输
    input           rvalid,  // 读数据有效
    output   reg    rready,  // 读数据就绪

    // AXI4 写地址通道 (AW Channel)
    output      [ 3:0] awid,     // 写事务ID (固定为1)
    output   reg[31:0] awaddr,   // 写地址
    output   reg[ 7:0] awlen,    // 突发长度
    output   reg[ 2:0] awsize,   // 突发大小
    output      [ 1:0] awburst,  // 突发类型 (固定为INCR)
    output      [ 1:0] awlock,   // 锁定类型 (固定为Normal)
    output      [ 3:0] awcache,  // Cache属性 (固定为0)
    output      [ 2:0] awprot,   // 保护类型 (固定为0)
    output   reg       awvalid,  // 写地址有效
    input              awready,  // 写地址就绪

    // AXI4 写数据通道 (W Channel)
    output      [ 3:0] wid,     // 写事务ID (固定为1)
    output   reg[31:0] wdata,   // 写数据
    output   reg[ 3:0] wstrb,   // 写字节选通
    output   reg       wlast,   // 最后一次写传输
    output   reg       wvalid,  // 写数据有效
    input              wready,  // 写数据就绪

    // AXI4 写响应通道 (B Channel)
    input    [ 3:0] bid,     // 写响应ID
    input    [ 1:0] bresp,   // 写响应
    input           bvalid,  // 写响应有效
    output   reg    bready,  // 写响应就绪
    
    // 指令Cache接口
    input            inst_rd_req     ,  // 指令读请求
    input  [ 2:0]    inst_rd_type    ,  // 指令读类型 (3'b100=Cache行, 其他=单字)
    input  [31:0]    inst_rd_addr    ,  // 指令读地址
    output           inst_rd_rdy     ,  // 指令读就绪
    output           inst_ret_valid  ,  // 指令返回数据有效
    output           inst_ret_last   ,  // 指令返回最后一个数据
    output [31:0]    inst_ret_data   ,  // 指令返回数据
    input            inst_wr_req     ,  // 指令写请求 (通常不使用)
    input  [ 2:0]    inst_wr_type    ,  // 指令写类型
    input  [31:0]    inst_wr_addr    ,  // 指令写地址
    input  [ 3:0]    inst_wr_wstrb   ,  // 指令写字节选通
    input  [127:0]   inst_wr_data    ,  // 指令写数据 (128位Cache行)
    output           inst_wr_rdy     ,  // 指令写就绪

    // 数据Cache接口
    input            data_rd_req     ,  // 数据读请求
    input  [ 2:0]    data_rd_type    ,  // 数据读类型 (3'b100=Cache行, 其他=单字)
    input  [31:0]    data_rd_addr    ,  // 数据读地址
    output           data_rd_rdy     ,  // 数据读就绪
    output           data_ret_valid  ,  // 数据返回数据有效
    output           data_ret_last   ,  // 数据返回最后一个数据
    output [31:0]    data_ret_data   ,  // 数据返回数据
    input            data_wr_req     ,  // 数据写请求
    input  [ 2:0]    data_wr_type    ,  // 数据写类型 (3'b100=Cache行, 其他=单字)
    input  [31:0]    data_wr_addr    ,  // 数据写地址
    input  [ 3:0]    data_wr_wstrb   ,  // 数据写字节选通
    input  [127:0]   data_wr_data    ,  // 数据写数据 (128位Cache行)
    output           data_wr_rdy     ,  // 数据写就绪
    output           write_buffer_empty  // 写缓冲区空标志
);

/**
 * AXI固定信号赋值
 * 这些信号在当前设计中保持固定值
 */
assign  arburst = 2'b01;  // INCR突发类型 (地址递增)
assign  arlock  = 2'b00;  // Normal访问 (非锁定)
assign  arcache = 4'b0000;// 非缓存访问
assign  arprot  = 3'b000; // 数据访问，安全，非特权
assign  awid    = 4'b0001;// 写事务ID固定为1
assign  awburst = 2'b01;  // INCR突发类型
assign  awlock  = 2'b00;  // Normal访问
assign  awcache = 4'b0000;// 非缓存访问
assign  awprot  = 3'b000; // 数据访问，安全，非特权
assign  wid     = 4'b0001;// 写数据ID固定为1

// 指令写操作当前不支持，直接返回就绪
assign  inst_wr_rdy = 1'b1;

/**
 * 状态机定义
 * 用于控制读写事务的状态转换
 */
// 读请求状态机
localparam read_requst_empty = 1'b0;       // 空闲状态，可接收新请求
localparam read_requst_ready = 1'b1;       // 请求已发送，等待响应
// 读响应状态机  
localparam read_respond_empty = 1'b0;      // 空闲状态
localparam read_respond_transfer = 1'b1;   // 数据传输状态
// 写请求状态机
localparam write_request_empty = 3'b000;   // 空闲状态
localparam write_addr_ready = 3'b001;      // 地址通道就绪 (未使用)
localparam write_data_ready = 3'b010;      // 数据通道就绪 (未使用)
localparam write_all_ready = 3'b011;       // 地址和数据都就绪 (未使用)
localparam write_data_transform = 3'b100;  // 数据传输状态
localparam write_data_wait = 3'b101;       // 等待地址握手完成
localparam write_wait_b = 3'b110;          // 等待写响应

/**
 * 状态寄存器和控制信号
 */
reg       read_requst_state;   // 读请求状态机
reg       read_respond_state;  // 读响应状态机
reg [2:0] write_requst_state;  // 写请求状态机

wire      write_wait_enable;   // 写等待使能信号

/**
 * 读请求控制逻辑
 */
wire         rd_requst_state_is_empty;  // 读请求状态机空闲
wire         rd_requst_can_receive;     // 可以接收读请求

assign rd_requst_state_is_empty = read_requst_state == read_requst_empty;

/**
 * Cache行和单字访问类型转换
 * type=3'b100表示Cache行访问(128位，4次32位传输)
 * 其他值表示单字访问(32位，1次传输)
 */
wire        data_rd_cache_line;  // 数据读Cache行标志
wire        inst_rd_cache_line;  // 指令读Cache行标志
wire [ 2:0] data_real_rd_size;   // 数据读实际传输大小
wire [ 7:0] data_real_rd_len ;   // 数据读实际传输长度
wire [ 2:0] inst_real_rd_size;   // 指令读实际传输大小
wire [ 7:0] inst_real_rd_len ;   // 指令读实际传输长度
wire        data_wr_cache_line;  // 数据写Cache行标志
wire [ 2:0] data_real_wr_size;   // 数据写实际传输大小
wire [ 7:0] data_real_wr_len ;   // 数据写实际传输长度

/**
 * 写缓冲区
 * 用于缓存128位Cache行数据，分4次32位传输
 */
reg [127:0] write_buffer_data;  // 写缓冲区数据
reg [ 2:0]  write_buffer_num;   // 剩余传输次数

wire        write_buffer_last;  // 最后一次传输标志

/**
 * 写缓冲区状态和读请求优先级控制
 */
assign write_buffer_empty = (write_buffer_num == 3'b0) && !write_wait_enable;

// 读请求接收条件：读状态机空闲且没有等待的写事务(或写响应已完成)
assign rd_requst_can_receive = rd_requst_state_is_empty && !(write_wait_enable && !(bvalid && bready));

// 数据读优先级高于指令读
assign data_rd_rdy = rd_requst_can_receive;
assign inst_rd_rdy = !data_rd_req && rd_requst_can_receive;

/**
 * 访问类型解码和AXI参数转换
 */
// 数据读类型转换
assign data_rd_cache_line = data_rd_type == 3'b100;                    // Cache行读取
assign data_real_rd_size  = data_rd_cache_line ? 3'b010 : data_rd_type; // Cache行用32位传输，单字用原类型
assign data_real_rd_len   = data_rd_cache_line ? 8'b0011 : 8'b0000;     // Cache行4次传输，单字1次传输

// 指令读类型转换
assign inst_rd_cache_line = inst_rd_type == 3'b100;
assign inst_real_rd_size  = inst_rd_cache_line ? 3'b010 : inst_rd_type;
assign inst_real_rd_len   = inst_rd_cache_line ? 8'b0011 : 8'b0000;

// 数据写类型转换
assign data_wr_cache_line = data_wr_type == 3'b100;
assign data_real_wr_size  = data_wr_cache_line ? 3'b010 : data_wr_type;
assign data_real_wr_len   = data_wr_cache_line ? 8'b0011 : 8'b0000;

/**
 * 读数据返回信号路由
 * 根据读事务ID区分指令和数据返回
 * ID[0]=0: 指令读返回, ID[0]=1: 数据读返回
 */
assign inst_ret_valid = !rid[0] && rvalid;  // 指令返回数据有效
assign inst_ret_last  = !rid[0] && rlast;   // 指令返回最后数据
assign inst_ret_data  = rdata;              // 指令返回数据
assign data_ret_valid =  rid[0] && rvalid;  // 数据返回数据有效
assign data_ret_last  =  rid[0] && rlast;   // 数据返回最后数据
assign data_ret_data  = rdata;              // 数据返回数据

/**
 * 写操作控制信号
 */
assign data_wr_rdy = (write_requst_state == write_request_empty);  // 写状态机空闲时可接收写请求

assign write_buffer_last = write_buffer_num == 3'b001;  // 缓冲区剩余1次传输

/**
 * 读请求状态机
 * 处理读地址通道的握手协议和优先级控制
 */
always @(posedge clk) begin
    if (reset) begin
        read_requst_state <= read_requst_empty;
        arvalid <= 1'b0;
    end
    else case (read_requst_state)
        read_requst_empty: begin
            // 数据读请求优先级高于指令读请求
            if (data_rd_req) begin
                if (write_wait_enable) begin
                    // 如果有写事务等待，需要等写响应完成后再发送读请求
                    if (bvalid && bready) begin
                        read_requst_state <= read_requst_ready;
                        arid <= 4'b0001;              // 数据读ID=1
                        araddr <= data_rd_addr;       // 数据读地址
                        arsize <= data_real_rd_size;  // 传输大小
                        arlen  <= data_real_rd_len;   // 传输长度
                        arvalid <= 1'b1;
                    end
                end
                else begin
                    // 没有写事务冲突，直接发送读请求
                    read_requst_state <= read_requst_ready;
                    arid <= 4'b0001;
                    araddr <= data_rd_addr;
                    arsize <= data_real_rd_size;
                    arlen  <= data_real_rd_len;
                    arvalid <= 1'b1;
                end
            end
            else if (inst_rd_req) begin
                if (write_wait_enable) begin
                    // 等待写响应完成
                    if (bvalid && bready) begin
                        read_requst_state <= read_requst_ready;
                        arid <= 4'b0000;              // 指令读ID=0
                        araddr <= inst_rd_addr;       // 指令读地址
                        arsize <= inst_real_rd_size;  // 传输大小
                        arlen  <= inst_real_rd_len;   // 传输长度
                        arvalid <= 1'b1;
                    end
                end
                else begin
                    // 没有写事务冲突，直接发送读请求
                    read_requst_state <= read_requst_ready;
                    arid <= 4'b0000;
                    araddr <= inst_rd_addr;
                    arsize <= inst_real_rd_size;
                    arlen  <= inst_real_rd_len;
                    arvalid <= 1'b1;
                end
            end
        end
        read_requst_ready: begin
            // 等待读地址握手完成
            if (arready && arid[0]) begin
                // 数据读地址握手完成
                read_requst_state <= read_requst_empty;
                arvalid <= 1'b0;
            end
            else if (arready && !arid[0]) begin 
                // 指令读地址握手完成
                read_requst_state <= read_requst_empty;
                arvalid <= 1'b0;
            end
        end
    endcase
end

/**
 * 读响应状态机
 * 处理读数据通道的握手协议，保持rready为高直到传输完成
 */
always @(posedge clk) begin
    if (reset) begin
        read_respond_state <= read_respond_empty;
        rready <= 1'b1;  // 读数据通道始终准备接收
    end
    else case (read_respond_state)
        read_respond_empty: begin
            if (rvalid && rready) begin 
                // 开始接收读数据
                read_respond_state <= read_respond_transfer;
            end
        end
        read_respond_transfer: begin
            if (rlast && rvalid) begin
                // 最后一个数据传输完成
                read_respond_state <= read_respond_empty;
            end
        end
    endcase
end

/**
 * 写请求状态机
 * 处理写地址通道、写数据通道和写响应通道的握手协议
 * 支持Cache行写入的数据缓冲和分批传输
 */
always @(posedge clk) begin
    if (reset) begin
        write_requst_state <= write_request_empty;
        awvalid <= 1'b0;
        wvalid  <= 1'b0;
        wlast   <= 1'b0;
        bready  <= 1'b0;
        
        write_buffer_num   <= 3'b000;
        write_buffer_data  <= 128'b0;
    end
    else case (write_requst_state)
        write_request_empty: begin
            if (data_wr_req) begin
                // 接收到写请求，准备地址和第一个数据
                write_requst_state <= write_data_wait;
                
                // 设置写地址通道
                awaddr  <= data_wr_addr;          // 写地址
                awsize  <= data_real_wr_size;     // 传输大小
                awlen   <= data_real_wr_len;      // 传输长度
                awvalid <= 1'b1;                 // 地址有效
                
                // 准备第一个32位数据
                wdata   <= data_wr_data[31:0];    // 取低32位作为第一个传输
                wstrb   <= data_wr_wstrb;         // 字节选通信号

                // 将剩余96位数据存入缓冲区
                write_buffer_data <= {32'b0, data_wr_data[127:32]};

                if (data_wr_type == 3'b100) begin
                    // Cache行写入需要4次传输
                    write_buffer_num <= 3'b011;   // 剩余3次传输
                end
                else begin
                    // 单字写入只需1次传输
                    write_buffer_num <= 3'b000;
                    wlast <= 1'b1;               // 标记为最后传输
                end
            end
        end
        write_data_wait: begin
            if (awready) begin
                // 写地址握手完成，开始数据传输
                write_requst_state <= write_data_transform;
                awvalid <= 1'b0;   // 清除地址有效信号
        	    wvalid  <= 1'b1;   // 数据有效信号
            end
        end 
        write_data_transform: begin
            if (wready) begin
                if (wlast) begin
                    // 最后一个数据传输完成，等待写响应
                    write_requst_state <= write_wait_b;
                    wvalid <= 1'b0;    // 清除数据有效信号
                    wlast <= 1'b0;     // 清除最后传输标志
        	        bready <= 1'b1;    // 准备接收写响应
                end
                else begin
                    // 继续传输缓冲区中的数据
                    if (write_buffer_last) begin
                        wlast <= 1'b1;  // 下次是最后传输
                    end
                
                    write_requst_state <= write_data_transform;  // 保持传输状态
    
                    // 从缓冲区取下一个32位数据
                    wdata   <= write_buffer_data[31:0];
                    wvalid  <= 1'b1;
                    // 缓冲区数据右移32位
                    write_buffer_data <= {32'b0, write_buffer_data[127:32]};
                    write_buffer_num  <= write_buffer_num - 3'b001;  // 剩余传输次数减1
                end
            end
        end
	    write_wait_b: begin
            if (bvalid && bready) begin
                // 写响应握手完成，返回空闲状态
                write_requst_state <= write_request_empty;
		        bready <= 1'b0;    // 清除响应就绪信号
		    end
	    end
        default: begin
            // 默认返回空闲状态
            write_requst_state <= write_request_empty;
        end
    endcase
end

/**
 * 写等待使能信号
 * 当写状态机不在空闲状态时，表示有写事务正在进行
 * 此时读请求需要等待以避免读写冲突
 */
assign write_wait_enable = ~(write_requst_state == write_request_empty);

endmodule
