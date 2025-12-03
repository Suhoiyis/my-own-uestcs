`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/18 15:16:16
// Design Name: 
// Module Name: adder_top
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


// 顶层模块，用于将8位加法器连接到开发板的拨码开关和LED
module adder_top (
    input  [31:0] dip_sw,  // 16位输入，来自16个拨码开关
    output [15:0] leds     // 16位输出，连接到16个LED灯
);

    // 定义内部线网，用于连接加法器模块
    wire [7:0] sum_result;   // 用于存放加法器的和
    wire       cout_result;  // 用于存放加法器的进位输出 (溢出)

    Addder uut (
        .a    (dip_sw[7:0]),    // 加数 a 连接到拨码开关 0-7
        .b    (dip_sw[15:8]),   // 加数 b 连接到拨码开关 8-15
        .cin  (1'b0),          // 进位输入接地 (设为0)，如果需要也可以连接到另一个开关
        .sum  (sum_result),    // 加法器的和输出
        .cout (cout_result)    // 加法器的进位输出
    );

    // 将加法器的结果分配给LED灯
    // assign leds[输出引脚] = [来自模块的信号];

    // 和的结果显示在 LED 0-7 上
    assign leds[7:0] = sum_result;

    // 溢出 (cout) 的结果显示在 LED 15 上
    assign leds[15] = cout_result;

    // 将未使用的LED灯熄灭 (赋值为0)
    assign leds[14:8] = 7'b0000000;

endmodule
