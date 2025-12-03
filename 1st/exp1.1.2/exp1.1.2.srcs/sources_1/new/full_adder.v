`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/18 14:41:19
// Design Name: 
// Module Name: full_adder
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


module full_adder(

	input a,
	input b,
	input cin,
	output reg sum,
	output reg cout

    );
	
	always @(a or b or cin)
	begin
		sum = a ^ b ^ cin;
		cout = a & b |(cin&(a^b));
	end
	
endmodule
