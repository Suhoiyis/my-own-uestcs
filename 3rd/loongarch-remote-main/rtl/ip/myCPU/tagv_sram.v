// -*- coding: utf-8 -*-
// @Author: 
// @Date: 2025-07-02 13:55:44
// @LastEditTime: 2025-07-21 16:11:58
// @FilePath: /loongson_remote/rtl/ip/myCPU/tagv_sram.v
// @Description: Cache的Tag和Valid位SRAM存储模块

module tagv_sram
#(  // 参数不生效仅做标记
    parameter WIDTH = 21    ,
    parameter DEPTH = 256
)
( 
    input  [ 7:0]          addra   ,
    input                  clka    ,
    input  [20:0]          dina    ,
    output [20:0]          douta   ,
    input                  ena     ,
    input                  wea 
);

`ifdef SIMU
reg [20:0] mem_reg [255:0];
reg [20:0] output_buffer;

always @(posedge clka) begin
    if (ena) begin
        if (wea) begin
            mem_reg[addra] <= dina;
        end
        else begin
            output_buffer <= mem_reg[addra];
        end
    end
end

assign douta = output_buffer;
`endif

`ifdef FPGA_VIVADO2019
// xpm_memory_spram: Single Port RAM
// Xilinx Parameterized Macro, version 2019.2
xpm_memory_spram #(
    .ADDR_WIDTH_A(8),                    // DECIMAL
    .AUTO_SLEEP_TIME(0),                 // DECIMAL
    .BYTE_WRITE_WIDTH_A(21),             // DECIMAL
    .CASCADE_HEIGHT(0),                  // DECIMAL
    .ECC_MODE("no_ecc"),                 // String
    .MEMORY_INIT_FILE("none"),           // String
    .MEMORY_INIT_PARAM("0"),             // String
    .MEMORY_OPTIMIZATION("true"),        // String
    .MEMORY_PRIMITIVE("auto"),           // String
    .MEMORY_SIZE(256*21),                // DECIMAL
    .MESSAGE_CONTROL(0),                 // DECIMAL
    .READ_DATA_WIDTH_A(21),              // DECIMAL
    .READ_LATENCY_A(1),                  // DECIMAL
    .READ_RESET_VALUE_A("0"),            // String
    .RST_MODE_A("SYNC"),                 // String
    .SIM_ASSERT_CHK(0),                  // DECIMAL
    .USE_MEM_INIT(1),                    // DECIMAL
    .WAKEUP_TIME("disable_sleep"),       // String
    .WRITE_DATA_WIDTH_A(21),             // DECIMAL
    .WRITE_MODE_A("read_first")          // String
)
xpm_memory_spram_inst (
    .dbiterra(),                         // 1-bit output: Double bit error
    .douta(douta),                       // READ_DATA_WIDTH_A-bit output: Data output
    .sbiterra(),                         // 1-bit output: Single bit error
    .addra(addra),                       // ADDR_WIDTH_A-bit input: Address
    .clka(clka),                         // 1-bit input: Clock signal
    .dina(dina),                         // WRITE_DATA_WIDTH_A-bit input: Data input
    .ena(ena),                           // 1-bit input: Memory enable
    .injectdbiterra(1'b0),               // 1-bit input: Double bit error injection
    .injectsbiterra(1'b0),               // 1-bit input: Single bit error injection
    .regcea(1'b1),                       // 1-bit input: Clock enable for output register
    .rsta(1'b0),                         // 1-bit input: Reset signal
    .sleep(1'b0),                        // 1-bit input: Sleep signal
    .wea(wea)                            // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable
);
`endif

endmodule
