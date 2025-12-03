
module alu
(
    // 主运算接口
    input  [15:0]    a,        // 操作数1（寄存器值）
    input  [15:0]    b,        // 操作数2/立即数（已符号扩展）
    input  [3:0]     opcode,   // 操作码（4位）
    output reg [15:0] result,  // 运算结果
    output            zero,     // 零标志位
    // 扩展标志接口
    output            carry,    // 进位标志（加法运算专用）
    output            sign      // 符号标志（结果最高位）
);

// 操作码宏定义
`define JAL  4'b0000  // 跳转指令（由控制单元处理）
`define JALR 4'b0001  
`define BEQ  4'b0010  
`define BLE  4'b0011  
`define LB   4'b0100  
`define LW   4'b0101  
`define SB   4'b0110  
`define SW   4'b0111  
`define ADD  4'b1000  
`define SUB  4'b1001  
`define AND  4'b1010  
`define OR   4'b1011  
`define ADDI 4'b1100  
`define SUBI 4'b1101  
`define ANDI 4'b1110  
`define ORI  4'b1111  

// 核心运算逻辑
always @(*) begin
    case(opcode)
        // 地址计算类
        `LB, `LW: result = a + b;       // 加载地址计算
        `SB, `SW: result = b + a;       // 存储地址计算
        
        // 算术逻辑运算
        `ADD, `ADDI: result = a + b;    // 加法
        `SUB, `SUBI: result = a - b;    // 减法
        `AND, `ANDI: result = a & b;    // 按位与
        `OR, `ORI:   result = a | b;    // 按位或
        
        // 条件判断
        `BEQ: result = a ^ b;           // 异或生成zero标志
        `BLE: result = ($signed(a) <= $signed(b)) ? 16'h1 : 16'h0;
        
        // 未实现指令
        default: result = 16'h0000;
    endcase
end

// 标志位生成
assign zero  = (result == 16'h0000);    // 全零判断
assign carry = (opcode == `ADD || opcode == `ADDI) ? result[15] : 1'b0;
assign sign  = result[15];              // 符号位直连

endmodule
