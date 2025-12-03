module lfsr
( 
    input           clk         ,
    input           reset       ,

    output [1:0]    random_val  
);

reg [7:0] r_lfsr;

always @(posedge clk) begin
    if (reset) begin
        r_lfsr <= 8'b1;
    end
    else begin
        r_lfsr[0] <= r_lfsr[7];
        r_lfsr[1] <= r_lfsr[0];
        r_lfsr[2] <= r_lfsr[1];
        r_lfsr[3] <= r_lfsr[2];
        r_lfsr[4] <= r_lfsr[3] ^ r_lfsr[7];
        r_lfsr[5] <= r_lfsr[4] ^ r_lfsr[7];
        r_lfsr[6] <= r_lfsr[5] ^ r_lfsr[7];
        r_lfsr[7] <= r_lfsr[6];
    end
end

assign random_val = r_lfsr[7:6];

endmodule