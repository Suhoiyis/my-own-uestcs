`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/18 14:25:14
// Design Name: 
// Module Name: Addder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Addder(
    input  [7:0] a,
    input  [7:0] b,
    input        cin,
    output [7:0] sum,
    output       cout
);

    // 内部连线，用于连接各个全加器之间的进位
    wire [8:0] c; // c[0]是初始进位，c[1]到c[7]是中间进位, c[8]是最终进位

    // 第1位 (最低位)
    // fa0 的进位输入是整个电路的 cin
    half_a fa0 (
        .a(a[0]),
        .b(b[0]),
        .sum(sum[0]),
        .cout(c[1])  // 输出进位连接到下一个全加器
    );

    // 第2位到第8位 (最高位)
    // 使用 generate for 循环来实例化剩下的7个全加器，使代码更简洁
    genvar i;
    generate
        for (i = 1; i < 8; i = i + 1) 
		begin : fa_loop
            full_adder fa_inst (
                .a(a[i]),
                .b(b[i]),
                .cin(c[i]),     // 进位输入来自前一个全加器
                .sum(sum[i]),
                .cout(c[i+1])   // 进位输出到下一个全加器
            );
        end
    endgenerate

    // 最后一个全加器的进位输出是整个8位加法器的最终 cout
    assign cout = c[8];

endmodule
