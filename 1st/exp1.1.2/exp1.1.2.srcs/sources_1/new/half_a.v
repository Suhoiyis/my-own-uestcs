`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/18 14:44:51
// Design Name: 
// Module Name: half_a
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


module half_a(

	input a,
	input b,
	output sum,
	output cout
	
    );
	
	assign sum = a ^ b;
	assign cout = a & b;
	
endmodule
