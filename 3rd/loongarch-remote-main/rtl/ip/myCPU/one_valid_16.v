module one_valid_16 (
    input  [15:0] in,
    output [ 3:0] out_en
);

wire [15:0] one_in;

assign one_in[0] = in[0];

genvar i;
generate 
	for (i=1; i<16; i=i+1)
	begin: sel_one
		assign one_in[i] = in[i] && ~|in[i-1:0];
	end
endgenerate

encoder_16_4 coder (.in(one_in), .out(out_en));

endmodule
