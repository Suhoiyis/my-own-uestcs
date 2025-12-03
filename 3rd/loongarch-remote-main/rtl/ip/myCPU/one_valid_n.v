module one_valid_n #(
	parameter n = 16
)(
	input  [n-1:0] in,
	output [n-1:0] out,
	output         nozero
);

wire [n-1:0] one_in;

assign one_in[0] = in[0];

genvar i;
generate 
	for (i=1; i<n; i=i+1)
	begin: sel_one
		assign one_in[i] = in[i] && ~|in[i-1:0];
	end
endgenerate

assign out = one_in;
assign nozero = |out;

endmodule
