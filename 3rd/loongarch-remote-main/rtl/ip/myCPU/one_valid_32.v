module one_valid_32 (
    input  [31:0] in,
    output [ 4:0] out_en
);

wire [31:0] one_in;

assign one_in[0] = in[0];

genvar i;
generate 
	for (i=1; i<32; i=i+1)
	begin: sel_one
		assign one_in[i] = in[i] && ~|in[i-1:0];
	end
endgenerate

encoder_32_5 coder (.in(one_in), .out(out_en));

endmodule
