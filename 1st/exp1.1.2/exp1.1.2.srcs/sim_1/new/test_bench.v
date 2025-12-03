`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/18 15:08:51
// Design Name: 
// Module Name: test_bench
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


module test_bench;

    // Testbench 内部没有输入输出端口
    // Inputs to the DUT (Device Under Test) are declared as 'reg'
    reg [15:0] dip_sw;

    // Outputs from the DUT are declared as 'wire'
    wire [15:0] leds;

    // 例化你要测试的模块，我们称之为 "Device Under Test" (DUT)
    adder_top dut (
        .dip_sw(dip_sw),
        .leds(leds)
    );

    // 激励 (Stimulus) 生成块
    // 这个 initial 块描述了如何随时间变化来“拨动”开关
    initial begin
        // 1. 初始状态：所有开关都关闭
        dipsw = 16'd0;
        $display("Test Case 1: Zero Inputs");
        #10; // 等待10纳秒

        // 2. 简单加法，无溢出
        // a = 10, b = 20
        // dipsw[7:0] = 10, dipsw[15:8] = 20
        // 预期: sum = 30 (leds[7:0]), cout = 0 (leds[15])
        dipsw = {8'd20, 8'd10}; // 使用拼接符 { } 设置高8位和低8位
        $display("Test Case 2: Simple Addition (10 + 20)");
        #10;

        // 3. 产生溢出的加法
        // a = 200, b = 100
        // dipsw[7:0] = 200, dipsw[15:8] = 100
        // 预期: 200 + 100 = 300 = 1*256 + 44
        // sum = 44 (leds[7:0]), cout = 1 (leds[15])
        dipsw = {8'd100, 8'd200};
        $display("Test Case 3: Addition with Overflow (200 + 100)");
        #10;

        // 4. 边界条件测试：最大值加1
        // a = 255 (8'hFF), b = 1 (8'h01)
        // dipsw[7:0] = 255, dipsw[15:8] = 1
        // 预期: 255 + 1 = 256
        // sum = 0 (leds[7:0]), cout = 1 (leds[15])
        dipsw = {8'h01, 8'hFF};
        $display("Test Case 4: Boundary Condition (255 + 1)");
        #10;
        
        // 5. 另一个无溢出的例子
        // a = 55, b = 33
        dipsw = {8'd33, 8'd55};
        $display("Test Case 5: Another Simple Addition (55 + 33)");
        #10;

        // 结束仿真
        $display("Simulation Finished.");
        $finish;
    end

    // 监控 (Monitor) 块
    // 这个 initial 块用于在仿真过程中持续打印信号的值
    initial begin
        // $monitor 会在任何一个参数变化时，打印一次信息
        $monitor("Time=%0t ns | a(dipsw[7:0])=%3d, b(dipsw[15:8])=%3d | ==> sum(leds[7:0])=%3d, overflow(leds[15])=%b",
                 $time,    // 显示当前仿真时间
                 dipsw[7:0], // 显示拨码开关低8位的值 (a)
                 dipsw[15:8], // 显示拨码开关高8位的值 (b)
                 leds[7:0],  // 显示LED低8位的值 (sum)
                 leds[15]);   // 显示LED第15位的值 (cout/overflow)
    end

endmodule
