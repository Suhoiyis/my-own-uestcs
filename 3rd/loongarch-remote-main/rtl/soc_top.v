`include "config.h"

module soc_top #(parameter SIMULATION = 1'b0)
(
    // System clocks and reset
    input           clk,            // 50 MHz input clock
    input           reset,          // BTN6 manual reset (debounced, active high)

    // Video output signals
    output [2:0]    video_red,      // 3-bit red
    output [2:0]    video_green,    // 3-bit green
    output [1:0]    video_blue,     // 2-bit blue
    output          video_hsync,    // horizontal sync
    output          video_vsync,    // vertical sync
    output          video_clk,      // pixel clock
    output          video_de,       // data enable

    // Buttons and displays
    input           clock_btn,      // BTN5 manual clock button (debounced)
    input  [3:0]    touch_btn,      // BTN1~BTN4 touch buttons
    input  [31:0]   dip_sw,         // 32-bit DIP switches
    output [15:0]   leds,           // 16 LEDs
    output [7:0]    dpy0,           // seven-segment low digit
    output [7:0]    dpy1,           // seven-segment high digit

    // BaseRAM interface
    inout  [31:0]   base_ram_data,
    output [19:0]   base_ram_addr,
    output [ 3:0]   base_ram_be_n,
    output          base_ram_ce_n,
    output          base_ram_oe_n,
    output          base_ram_we_n,

    // ExtRAM interface
    inout  [31:0]   ext_ram_data,
    output [19:0]   ext_ram_addr,
    output [ 3:0]   ext_ram_be_n,
    output          ext_ram_ce_n,
    output          ext_ram_oe_n,
    output          ext_ram_we_n,

    // Flash memory interface
    output [22:0]   flash_a,
    inout  [15:0]   flash_d,
    output          flash_rp_n,
    output          flash_vpen,
    output          flash_ce_n,
    output          flash_oe_n,
    output          flash_we_n,
    output          flash_byte_n,

    // UART pins
    inout           UART_RX,
    inout           UART_TX
);

  // Clock/reset domains
  wire cpu_clk, cpu_resetn;
  wire sys_clk, sys_resetn;

  generate
    if (SIMULATION) begin : sim_clk
      // Simulation clock generator
      reg clk_sim = 1'b0;
      always #15 clk_sim = ~clk_sim;
      assign cpu_clk = clk_sim;
      assign sys_clk = clk;
      rst_sync u_rst_sys (.clk(sys_clk), .rst_n_in(~reset),  .rst_n_out(sys_resetn));
      rst_sync u_rst_cpu (.clk(cpu_clk), .rst_n_in(sys_resetn), .rst_n_out(cpu_resetn));
    end else begin : pll_clk
      // FPGA PLL clock generator
      clk_pll u_clk_pll (
        .cpu_clk  (cpu_clk),
        .sys_clk  (sys_clk),
        .resetn   (~reset),
        .locked   (pll_locked),
        .clk_in1  (clk)
      );
      rst_sync u_rst_sys (.clk(sys_clk), .rst_n_in(pll_locked), .rst_n_out(sys_resetn));
      rst_sync u_rst_cpu (.clk(cpu_clk), .rst_n_in(sys_resetn),  .rst_n_out(cpu_resetn));
    end
  endgenerate

  // ------------------------------------------------
  // Instantiate the core_top (CPU) with AXI interface
  // ------------------------------------------------
  // AXI read address channel
  wire [3:0]   cpu_arid;
  wire [31:0]  cpu_araddr;
  wire [7:0]   cpu_arlen;
  wire [2:0]   cpu_arsize;
  wire [1:0]   cpu_arburst;
  wire [1:0]   cpu_arlock;
  wire [3:0]   cpu_arcache;
  wire [2:0]   cpu_arprot;
  wire         cpu_arvalid;
  wire         cpu_arready;
  // AXI read data channel
  wire [3:0]   cpu_rid;
  wire [31:0]  cpu_rdata;
  wire [1:0]   cpu_rresp;
  wire         cpu_rlast;
  wire         cpu_rvalid;
  wire         cpu_rready;
  // AXI write address channel
  wire [3:0]   cpu_awid;
  wire [31:0]  cpu_awaddr;
  wire [7:0]   cpu_awlen;
  wire [2:0]   cpu_awsize;
  wire [1:0]   cpu_awburst;
  wire [1:0]   cpu_awlock;
  wire [3:0]   cpu_awcache;
  wire [2:0]   cpu_awprot;
  wire         cpu_awvalid;
  wire         cpu_awready;
  // AXI write data channel
  wire [3:0]   cpu_wid;
  wire [31:0]  cpu_wdata;
  wire [3:0]   cpu_wstrb;
  wire         cpu_wlast;
  wire         cpu_wvalid;
  wire         cpu_wready;
  // AXI write response channel
  wire [3:0]   cpu_bid;
  wire [1:0]   cpu_bresp;
  wire         cpu_bvalid;
  wire         cpu_bready;

  // Debug interface
  wire         ws_valid;
  wire [31:0]  rf_rdata;
  wire [31:0]  debug0_wb_pc;
  wire [3:0]   debug0_wb_rf_wen;
  wire [4:0]   debug0_wb_rf_wnum;
  wire [31:0]  debug0_wb_rf_wdata;
  wire [31:0]  debug0_wb_inst;

core_top u_cpu(
    .intrpt    ({7'h0, confreg_int}),   //high active

    .aclk      (cpu_clk       ),
    .aresetn   (cpu_resetn    ),   //low active

    .arid      (cpu_arid      ),
    .araddr    (cpu_araddr    ),
    .arlen     (cpu_arlen     ),
    .arsize    (cpu_arsize    ),
    .arburst   (cpu_arburst   ),
    .arlock    (cpu_arlock    ),
    .arcache   (cpu_arcache   ),
    .arprot    (cpu_arprot    ),
    .arvalid   (cpu_arvalid   ),
    .arready   (cpu_arready   ),
                
    .rid       (cpu_rid       ),
    .rdata     (cpu_rdata     ),
    .rresp     (cpu_rresp     ),
    .rlast     (cpu_rlast     ),
    .rvalid    (cpu_rvalid    ),
    .rready    (cpu_rready    ),
               
    .awid      (cpu_awid      ),
    .awaddr    (cpu_awaddr    ),
    .awlen     (cpu_awlen     ),
    .awsize    (cpu_awsize    ),
    .awburst   (cpu_awburst   ),
    .awlock    (cpu_awlock    ),
    .awcache   (cpu_awcache   ),
    .awprot    (cpu_awprot    ),
    .awvalid   (cpu_awvalid   ),
    .awready   (cpu_awready   ),
    
    .wid       (cpu_wid       ),
    .wdata     (cpu_wdata     ),
    .wstrb     (cpu_wstrb     ),
    .wlast     (cpu_wlast     ),
    .wvalid    (cpu_wvalid    ),
    .wready    (cpu_wready    ),
    
    .bid       (cpu_bid       ),
    .bresp     (cpu_bresp     ),
    .bvalid    (cpu_bvalid    ),
    .bready    (cpu_bready    ),

    //debug interface
    .break_point        (1'b0               ),
    .infor_flag         (1'b0               ),
    .reg_num            (5'b0               ),
    .ws_valid           (                   ),
    .rf_rdata           (                   ),

    .debug0_wb_pc       (debug_wb_pc        ),
    .debug0_wb_inst     (debug_wb_inst      ),
    .debug0_wb_rf_wen   (debug_wb_rf_wen    ),
    .debug0_wb_rf_wnum  (debug_wb_rf_wnum   ),
    .debug0_wb_rf_wdata (debug_wb_rf_wdata  )
);

  // ------------------ AXI Clock Domain Crossing ------------------
  // Input side from CPU AXI, output side to AXI crossbar
  wire        cdc_awvalid, cdc_awready;
  wire [31:0] cdc_awaddr;
  wire [3:0]  cdc_awid;
  wire [7:0]  cdc_awlen;
  wire [2:0]  cdc_awsize;
  wire [1:0]  cdc_awburst;
  wire [0:0]  cdc_awlock;
  wire [3:0]  cdc_awcache;
  wire [2:0]  cdc_awprot;

  wire        cdc_wvalid, cdc_wready;
  wire [31:0] cdc_wdata;
  wire [3:0]  cdc_wstrb;
  wire        cdc_wlast;

  wire        cdc_bvalid, cdc_bready;
  wire [3:0]  cdc_bid;
  wire [1:0]  cdc_bresp;

  wire        cdc_arvalid, cdc_arready;
  wire [31:0] cdc_araddr;
  wire [3:0]  cdc_arid;
  wire [7:0]  cdc_arlen;
  wire [2:0]  cdc_arsize;
  wire [1:0]  cdc_arburst;
  wire [0:0]  cdc_arlock;
  wire [3:0]  cdc_arcache;
  wire [2:0]  cdc_arprot;

  wire        cdc_rvalid, cdc_rready;
  wire [31:0] cdc_rdata;
  wire [3:0]  cdc_rid;
  wire [1:0]  cdc_rresp;
  wire        cdc_rlast;

  Axi_CDC u_axi_cdc (
    .axiInClk       (cpu_clk),
    .axiInRst       (cpu_resetn),
    .axiOutClk      (sys_clk),
    .axiOutRst      (sys_resetn),

    // Input AXI from CPU
    .axiIn_awvalid  (cpu_awvalid),
    .axiIn_awready  (cpu_awready),
    .axiIn_awaddr   (cpu_awaddr),
    .axiIn_awid     (cpu_awid),
    .axiIn_awlen    (cpu_awlen),
    .axiIn_awsize   (cpu_awsize),
    .axiIn_awburst  (cpu_awburst),
    .axiIn_awlock   (cpu_awlock[0]),
    .axiIn_awcache  (cpu_awcache),
    .axiIn_awprot   (cpu_awprot),

    .axiIn_wvalid   (cpu_wvalid),
    .axiIn_wready   (cpu_wready),
    .axiIn_wdata    (cpu_wdata),
    .axiIn_wstrb    (cpu_wstrb),
    .axiIn_wlast    (cpu_wlast),

    .axiIn_bvalid   (cpu_bvalid),
    .axiIn_bready   (cpu_bready),
    .axiIn_bid      (cpu_bid),
    .axiIn_bresp    (cpu_bresp),

    .axiIn_arvalid  (cpu_arvalid),
    .axiIn_arready  (cpu_arready),
    .axiIn_araddr   (cpu_araddr),
    .axiIn_arid     (cpu_arid),
    .axiIn_arlen    (cpu_arlen),
    .axiIn_arsize   (cpu_arsize),
    .axiIn_arburst  (cpu_arburst),
    .axiIn_arlock   (cpu_arlock[0]),
    .axiIn_arcache  (cpu_arcache),
    .axiIn_arprot   (cpu_arprot),

    .axiIn_rvalid   (cpu_rvalid),
    .axiIn_rready   (cpu_rready),
    .axiIn_rdata    (cpu_rdata),
    .axiIn_rid      (cpu_rid),
    .axiIn_rresp    (cpu_rresp),
    .axiIn_rlast    (cpu_rlast),

    // Output AXI to crossbar
    .axiOut_awvalid (cdc_awvalid),
    .axiOut_awready (cdc_awready),
    .axiOut_awaddr  (cdc_awaddr),
    .axiOut_awid    (cdc_awid),
    .axiOut_awlen   (cdc_awlen),
    .axiOut_awsize  (cdc_awsize),
    .axiOut_awburst (cdc_awburst),
    .axiOut_awlock  (cdc_awlock),
    .axiOut_awcache (cdc_awcache),
    .axiOut_awprot  (cdc_awprot),

    .axiOut_wvalid  (cdc_wvalid),
    .axiOut_wready  (cdc_wready),
    .axiOut_wdata   (cdc_wdata),
    .axiOut_wstrb   (cdc_wstrb),
    .axiOut_wlast   (cdc_wlast),

    .axiOut_bvalid  (cdc_bvalid),
    .axiOut_bready  (cdc_bready),
    .axiOut_bid     (cdc_bid),
    .axiOut_bresp   (cdc_bresp),

    .axiOut_arvalid (cdc_arvalid),
    .axiOut_arready (cdc_arready),
    .axiOut_araddr  (cdc_araddr),
    .axiOut_arid    (cdc_arid),
    .axiOut_arlen   (cdc_arlen),
    .axiOut_arsize  (cdc_arsize),
    .axiOut_arburst (cdc_arburst),
    .axiOut_arlock  (cdc_arlock),
    .axiOut_arcache (cdc_arcache),
    .axiOut_arprot  (cdc_arprot),

    .axiOut_rvalid  (cdc_rvalid),
    .axiOut_rready  (cdc_rready),
    .axiOut_rdata   (cdc_rdata),
    .axiOut_rid     (cdc_rid),
    .axiOut_rresp   (cdc_rresp),
    .axiOut_rlast   (cdc_rlast)
  );

  // ------------------ AXI Crossbar 1x4 ------------------
  // Port 0 - SRAM Bridge
  // Port 1 - APB/UART Bridge
  // Port 2 - Dummy Slave
  // Port 3 - Config Register

  // Signals for crossbar Port 0
  wire        xbar0_awvalid, xbar0_awready;
  wire [31:0] xbar0_awaddr;  wire [4:0] xbar0_awid;  wire [7:0]  xbar0_awlen;
  wire [2:0]  xbar0_awsize;  wire [1:0]  xbar0_awburst; wire [0:0]  xbar0_awlock;
  wire [3:0]  xbar0_awcache; wire [2:0]  xbar0_awprot;
  wire        xbar0_wvalid, xbar0_wready;
  wire [31:0] xbar0_wdata;   wire [3:0]  xbar0_wstrb; wire        xbar0_wlast;
  wire        xbar0_bvalid, xbar0_bready;
  wire [4:0]  xbar0_bid;     wire [1:0]  xbar0_bresp;
  wire        xbar0_arvalid, xbar0_arready;
  wire [31:0] xbar0_araddr;  wire [4:0]  xbar0_arid;  wire [7:0]  xbar0_arlen;
  wire [2:0]  xbar0_arsize;  wire [1:0]  xbar0_arburst; wire [0:0]  xbar0_arlock;
  wire [3:0]  xbar0_arcache; wire [2:0]  xbar0_arprot;
  wire        xbar0_rvalid, xbar0_rready;
  wire [31:0] xbar0_rdata;   wire [4:0]  xbar0_rid;   wire [1:0]  xbar0_rresp;
  wire        xbar0_rlast;

  // Signals for crossbar Port 1
  wire        xbar1_awvalid, xbar1_awready;
  wire [31:0] xbar1_awaddr;  wire [4:0]  xbar1_awid;  wire [7:0]  xbar1_awlen;
  wire [2:0]  xbar1_awsize;  wire [1:0]  xbar1_awburst; wire [0:0]  xbar1_awlock;
  wire [3:0]  xbar1_awcache; wire [2:0]  xbar1_awprot;
  wire        xbar1_wvalid, xbar1_wready;
  wire [31:0] xbar1_wdata;   wire [3:0]  xbar1_wstrb; wire        xbar1_wlast;
  wire        xbar1_bvalid, xbar1_bready;
  wire [4:0]  xbar1_bid;     wire [1:0]  xbar1_bresp;
  wire        xbar1_arvalid, xbar1_arready;
  wire [31:0] xbar1_araddr;  wire [4:0]  xbar1_arid;  wire [7:0]  xbar1_arlen;
  wire [2:0]  xbar1_arsize;  wire [1:0]  xbar1_arburst; wire [0:0]  xbar1_arlock;
  wire [3:0]  xbar1_arcache; wire [2:0]  xbar1_arprot;
  wire        xbar1_rvalid, xbar1_rready;
  wire [31:0] xbar1_rdata;   wire [4:0]  xbar1_rid;   wire [1:0]  xbar1_rresp;
  wire        xbar1_rlast;

  // Signals for crossbar Port 2 (to be tied off)
  wire        xbar2_awvalid, xbar2_awready;
  wire [31:0] xbar2_awaddr;  wire [4:0]  xbar2_awid;  wire [7:0]  xbar2_awlen;
  wire [2:0]  xbar2_awsize;  wire [1:0]  xbar2_awburst; wire [0:0]  xbar2_awlock;
  wire [3:0]  xbar2_awcache; wire [2:0]  xbar2_awprot;
  wire        xbar2_wvalid, xbar2_wready;
  wire [31:0] xbar2_wdata;   wire [3:0]  xbar2_wstrb; wire        xbar2_wlast;
  wire        xbar2_bvalid, xbar2_bready;
  wire [4:0]  xbar2_bid;     wire [1:0]  xbar2_bresp;
  wire        xbar2_arvalid, xbar2_arready;
  wire [31:0] xbar2_araddr;  wire [4:0]  xbar2_arid;  wire [7:0]  xbar2_arlen;
  wire [2:0]  xbar2_arsize;  wire [1:0]  xbar2_arburst; wire [0:0]  xbar2_arlock;
  wire [3:0]  xbar2_arcache; wire [2:0]  xbar2_arprot;
  wire        xbar2_rvalid, xbar2_rready;
  wire [31:0] xbar2_rdata;   wire [4:0]  xbar2_rid;   wire [1:0]  xbar2_rresp;
  wire        xbar2_rlast;

  // Signals for crossbar Port 3
  wire        xbar3_awvalid, xbar3_awready;
  wire [31:0] xbar3_awaddr;  wire [4:0]  xbar3_awid;  wire [7:0]  xbar3_awlen;
  wire [2:0]  xbar3_awsize;  wire [1:0]  xbar3_awburst; wire [0:0]  xbar3_awlock;
  wire [3:0]  xbar3_awcache; wire [2:0]  xbar3_awprot;
  wire        xbar3_wvalid, xbar3_wready;
  wire [31:0] xbar3_wdata;   wire [3:0]  xbar3_wstrb; wire        xbar3_wlast;
  wire        xbar3_bvalid, xbar3_bready;
  wire [4:0]  xbar3_bid;     wire [1:0]  xbar3_bresp;
  wire        xbar3_arvalid, xbar3_arready;
  wire [31:0] xbar3_araddr;  wire [4:0]  xbar3_arid;  wire [7:0]  xbar3_arlen;
  wire [2:0]  xbar3_arsize;  wire [1:0]  xbar3_arburst; wire [0:0]  xbar3_arlock;
  wire [3:0]  xbar3_arcache; wire [2:0]  xbar3_arprot;
  wire        xbar3_rvalid, xbar3_rready;
  wire [31:0] xbar3_rdata;   wire [4:0]  xbar3_rid;   wire [1:0]  xbar3_rresp;
  wire        xbar3_rlast;

  AxiCrossbar_1x4 u_axi_xbar (
    // AXI input from CDC
    .axiIn_awvalid  (cdc_awvalid), .axiIn_awready  (cdc_awready),
    .axiIn_awaddr   (cdc_awaddr),  .axiIn_awid     (cdc_awid),
    .axiIn_awlen    (cdc_awlen),   .axiIn_awsize   (cdc_awsize),
    .axiIn_awburst  (cdc_awburst), .axiIn_awlock   (cdc_awlock),
    .axiIn_awcache  (cdc_awcache), .axiIn_awprot   (cdc_awprot),

    .axiIn_wvalid   (cdc_wvalid),  .axiIn_wready   (cdc_wready),
    .axiIn_wdata    (cdc_wdata),   .axiIn_wstrb    (cdc_wstrb),
    .axiIn_wlast    (cdc_wlast),

    .axiIn_bvalid   (cdc_bvalid),  .axiIn_bready   (cdc_bready),
    .axiIn_bid      (cdc_bid),     .axiIn_bresp    (cdc_bresp),

    .axiIn_arvalid  (cdc_arvalid), .axiIn_arready  (cdc_arready),
    .axiIn_araddr   (cdc_araddr),  .axiIn_arid     (cdc_arid),
    .axiIn_arlen    (cdc_arlen),   .axiIn_arsize   (cdc_arsize),
    .axiIn_arburst  (cdc_arburst), .axiIn_arlock   (cdc_arlock),
    .axiIn_arcache  (cdc_arcache), .axiIn_arprot   (cdc_arprot),

    .axiIn_rvalid   (cdc_rvalid),  .axiIn_rready   (cdc_rready),
    .axiIn_rdata    (cdc_rdata),   .axiIn_rid      (cdc_rid),
    .axiIn_rresp    (cdc_rresp),   .axiIn_rlast    (cdc_rlast),

    // AXI Out 0 - SRAM Bridge
    .axiOut_0_awvalid(xbar0_awvalid), .axiOut_0_awready(xbar0_awready),
    .axiOut_0_awaddr (xbar0_awaddr),  .axiOut_0_awid   (xbar0_awid),
    .axiOut_0_awlen  (xbar0_awlen),   .axiOut_0_awsize (xbar0_awsize),
    .axiOut_0_awburst(xbar0_awburst), .axiOut_0_awlock (xbar0_awlock),
    .axiOut_0_awcache(xbar0_awcache), .axiOut_0_awprot (xbar0_awprot),

    .axiOut_0_wvalid (xbar0_wvalid),  .axiOut_0_wready (xbar0_wready),
    .axiOut_0_wdata  (xbar0_wdata),   .axiOut_0_wstrb  (xbar0_wstrb),
    .axiOut_0_wlast  (xbar0_wlast),

    .axiOut_0_bvalid (xbar0_bvalid),  .axiOut_0_bready (xbar0_bready),
    .axiOut_0_bid    (xbar0_bid),     .axiOut_0_bresp  (xbar0_bresp),

    .axiOut_0_arvalid(xbar0_arvalid), .axiOut_0_arready(xbar0_arready),
    .axiOut_0_araddr (xbar0_araddr),  .axiOut_0_arid   (xbar0_arid),
    .axiOut_0_arlen  (xbar0_arlen),   .axiOut_0_arsize (xbar0_arsize),
    .axiOut_0_arburst(xbar0_arburst), .axiOut_0_arlock (xbar0_arlock),
    .axiOut_0_arcache(xbar0_arcache), .axiOut_0_arprot (xbar0_arprot),

    .axiOut_0_rvalid (xbar0_rvalid),  .axiOut_0_rready (xbar0_rready),
    .axiOut_0_rdata  (xbar0_rdata),   .axiOut_0_rid    (xbar0_rid),
    .axiOut_0_rresp  (xbar0_rresp),   .axiOut_0_rlast  (xbar0_rlast),

    // AXI Out 1 - APB/UART Bridge
    .axiOut_1_awvalid(xbar1_awvalid), .axiOut_1_awready(xbar1_awready),
    .axiOut_1_awaddr (xbar1_awaddr),  .axiOut_1_awid   (xbar1_awid),
    .axiOut_1_awlen  (xbar1_awlen),   .axiOut_1_awsize (xbar1_awsize),
    .axiOut_1_awburst(xbar1_awburst), .axiOut_1_awlock (xbar1_awlock),
    .axiOut_1_awcache(xbar1_awcache), .axiOut_1_awprot (xbar1_awprot),

    .axiOut_1_wvalid (xbar1_wvalid),  .axiOut_1_wready (xbar1_wready),
    .axiOut_1_wdata  (xbar1_wdata),   .axiOut_1_wstrb  (xbar1_wstrb),
    .axiOut_1_wlast  (xbar1_wlast),

    .axiOut_1_bvalid (xbar1_bvalid),  .axiOut_1_bready (xbar1_bready),
    .axiOut_1_bid    (xbar1_bid),     .axiOut_1_bresp  (xbar1_bresp),

    .axiOut_1_arvalid(xbar1_arvalid), .axiOut_1_arready(xbar1_arready),
    .axiOut_1_araddr (xbar1_araddr),  .axiOut_1_arid   (xbar1_arid),
    .axiOut_1_arlen  (xbar1_arlen),   .axiOut_1_arsize (xbar1_arsize),
    .axiOut_1_arburst(xbar1_arburst), .axiOut_1_arlock (xbar1_arlock),
    .axiOut_1_arcache(xbar1_arcache), .axiOut_1_arprot (xbar1_arprot),

    .axiOut_1_rvalid (xbar1_rvalid),  .axiOut_1_rready (xbar1_rready),
    .axiOut_1_rdata  (xbar1_rdata),   .axiOut_1_rid    (xbar1_rid),
    .axiOut_1_rresp  (xbar1_rresp),   .axiOut_1_rlast  (xbar1_rlast),

    // AXI Out 2 - Dummy Slave
    .axiOut_2_awvalid(xbar2_awvalid), .axiOut_2_awready(xbar2_awready),
    .axiOut_2_awaddr (xbar2_awaddr),  .axiOut_2_awid   (xbar2_awid),
    .axiOut_2_awlen  (xbar2_awlen),   .axiOut_2_awsize (xbar2_awsize),
    .axiOut_2_awburst(xbar2_awburst), .axiOut_2_awlock (xbar2_awlock),
    .axiOut_2_awcache(xbar2_awcache), .axiOut_2_awprot (xbar2_awprot),

    .axiOut_2_wvalid (xbar2_wvalid),  .axiOut_2_wready (xbar2_wready),
    .axiOut_2_wdata  (xbar2_wdata),   .axiOut_2_wstrb  (xbar2_wstrb),
    .axiOut_2_wlast  (xbar2_wlast),

    .axiOut_2_bvalid (xbar2_bvalid),  .axiOut_2_bready (xbar2_bready),
    .axiOut_2_bid    (xbar2_bid),     .axiOut_2_bresp  (xbar2_bresp),

    .axiOut_2_arvalid(xbar2_arvalid), .axiOut_2_arready(xbar2_arready),
    .axiOut_2_araddr (xbar2_araddr),  .axiOut_2_arid   (xbar2_arid),
    .axiOut_2_arlen  (xbar2_arlen),   .axiOut_2_arsize (xbar2_arsize),
    .axiOut_2_arburst(xbar2_arburst), .axiOut_2_arlock (xbar2_arlock),
    .axiOut_2_arcache(xbar2_arcache), .axiOut_2_arprot (xbar2_arprot),

    .axiOut_2_rvalid (xbar2_rvalid),  .axiOut_2_rready (xbar2_rready),
    .axiOut_2_rdata  (xbar2_rdata),   .axiOut_2_rid    (xbar2_rid),
    .axiOut_2_rresp  (xbar2_rresp),   .axiOut_2_rlast  (xbar2_rlast),

    // AXI Out 3 - Configuration Register
    .axiOut_3_awvalid(xbar3_awvalid), .axiOut_3_awready(xbar3_awready),
    .axiOut_3_awaddr (xbar3_awaddr),  .axiOut_3_awid   (xbar3_awid),
    .axiOut_3_awlen  (xbar3_awlen),   .axiOut_3_awsize (xbar3_awsize),
    .axiOut_3_awburst(xbar3_awburst), .axiOut_3_awlock (xbar3_awlock),
    .axiOut_3_awcache(xbar3_awcache), .axiOut_3_awprot (xbar3_awprot),

    .axiOut_3_wvalid (xbar3_wvalid),  .axiOut_3_wready (xbar3_wready),
    .axiOut_3_wdata  (xbar3_wdata),   .axiOut_3_wstrb  (xbar3_wstrb),
    .axiOut_3_wlast  (xbar3_wlast),

    .axiOut_3_bvalid (xbar3_bvalid),  .axiOut_3_bready (xbar3_bready),
    .axiOut_3_bid    (xbar3_bid),     .axiOut_3_bresp  (xbar3_bresp),

    .axiOut_3_arvalid(xbar3_arvalid), .axiOut_3_arready(xbar3_arready),
    .axiOut_3_araddr (xbar3_araddr),  .axiOut_3_arid   (xbar3_arid),
    .axiOut_3_arlen  (xbar3_arlen),   .axiOut_3_arsize (xbar3_arsize),
    .axiOut_3_arburst(xbar3_arburst), .axiOut_3_arlock (xbar3_arlock),
    .axiOut_3_arcache(xbar3_arcache), .axiOut_3_arprot (xbar3_arprot),

    .axiOut_3_rvalid (xbar3_rvalid),  .axiOut_3_rready (xbar3_rready),
    .axiOut_3_rdata  (xbar3_rdata),   .axiOut_3_rid    (xbar3_rid),
    .axiOut_3_rresp  (xbar3_rresp),   .axiOut_3_rlast  (xbar3_rlast),

    .clk            (sys_clk),
    .resetn         (sys_resetn)
  );

  // ------------------------------------------------
  // Dummy Slave for unused crossbar Port 2
  // ------------------------------------------------
  assign xbar2_arready = 1'b1;
  assign xbar2_rid     = 5'b0;
  assign xbar2_rdata   = 32'b0;
  assign xbar2_rresp   = 2'b0;
  assign xbar2_rlast   = 1'b0;
  assign xbar2_rvalid  = 1'b0;
  assign xbar2_awready = 1'b1;
  assign xbar2_wready  = 1'b1;
  assign xbar2_bid     = 5'b0;
  assign xbar2_bresp   = 2'b0;
  assign xbar2_bvalid  = 1'b0;

  // ------------------------------------------------
  // AXI to SRAM Bridge
  // ------------------------------------------------
  axi_wrap_ram_sp_ext u_sram_bridge (
    .aclk          (sys_clk),
    .aresetn       (sys_resetn),

    // AXI slave interface from crossbar Port 0
    .axi_arid      (xbar0_arid),
    .axi_araddr    (xbar0_araddr),
    .axi_arlen     (xbar0_arlen),
    .axi_arsize    (xbar0_arsize),
    .axi_arburst   (xbar0_arburst),
    .axi_arlock    (xbar0_arlock),
    .axi_arcache   (xbar0_arcache),
    .axi_arprot    (xbar0_arprot),
    .axi_arvalid   (xbar0_arvalid),
    .axi_arready   (xbar0_arready),

    .axi_rid       (xbar0_rid),
    .axi_rdata     (xbar0_rdata),
    .axi_rresp     (xbar0_rresp),
    .axi_rlast     (xbar0_rlast),
    .axi_rvalid    (xbar0_rvalid),
    .axi_rready    (xbar0_rready),

    .axi_awid      (xbar0_awid),
    .axi_awaddr    (xbar0_awaddr),
    .axi_awlen     (xbar0_awlen),
    .axi_awsize    (xbar0_awsize),
    .axi_awburst   (xbar0_awburst),
    .axi_awlock    (xbar0_awlock),
    .axi_awcache   (xbar0_awcache),
    .axi_awprot    (xbar0_awprot),
    .axi_awvalid   (xbar0_awvalid),
    .axi_awready   (xbar0_awready),

    .axi_wdata     (xbar0_wdata),
    .axi_wstrb     (xbar0_wstrb),
    .axi_wlast     (xbar0_wlast),
    .axi_wvalid    (xbar0_wvalid),
    .axi_wready    (xbar0_wready),

    .axi_bid       (xbar0_bid),
    .axi_bresp     (xbar0_bresp),
    .axi_bvalid    (xbar0_bvalid),
    .axi_bready    (xbar0_bready),

    // On-board SRAM pins
    .base_ram_data (base_ram_data),
    .base_ram_addr (base_ram_addr),
    .base_ram_be_n (base_ram_be_n),
    .base_ram_ce_n (base_ram_ce_n),
    .base_ram_oe_n (base_ram_oe_n),
    .base_ram_we_n (base_ram_we_n),

    // External SRAM pins
    .ext_ram_data  (ext_ram_data),
    .ext_ram_addr  (ext_ram_addr),
    .ext_ram_be_n  (ext_ram_be_n),
    .ext_ram_ce_n  (ext_ram_ce_n),
    .ext_ram_oe_n  (ext_ram_oe_n),
    .ext_ram_we_n  (ext_ram_we_n)
  );

  // ------------------------------------------------
  // AXI to APB / UART Bridge
  // ------------------------------------------------
  // UART signal declarations
wire UART_CTS, UART_RTS;
wire UART_DTR, UART_DSR;
wire UART_RI,  UART_DCD;

assign UART_CTS = 1'b0;
assign UART_DSR = 1'b0;
assign UART_DCD = 1'b0;
assign UART_RI  = 1'b0;

wire uart0_int;
wire uart0_txd_o, uart0_txd_i, uart0_txd_oe;
wire uart0_rxd_o, uart0_rxd_i, uart0_rxd_oe;
wire uart0_rts_o;
wire uart0_cts_i;
wire uart0_dsr_i;
wire uart0_dcd_i;
wire uart0_dtr_o;
wire uart0_ri_i;

// Tie top-level UART pins to internal signals
assign UART_RX = uart0_rxd_oe ? 1'bz : uart0_rxd_o;
assign UART_TX = uart0_txd_oe ? 1'bz : uart0_txd_o;
assign UART_RTS = uart0_rts_o;
assign UART_DTR = uart0_dtr_o;

// Loop back top-level pins into controller inputs
assign uart0_txd_i = UART_TX;
assign uart0_rxd_i = UART_RX;
assign uart0_cts_i = UART_CTS;
assign uart0_dcd_i = UART_DCD;
assign uart0_dsr_i = UART_DSR;
assign uart0_ri_i  = UART_RI;

// Instantiate the AXI-to-UART controller
axi_uart_controller u_axi_uart_controller (
    .clk               (sys_clk),
    .rst_n             (sys_resetn),

    // AXI4-Lite slave interface
    .axi_s_awid        (xbar1_awid),
    .axi_s_awaddr      (xbar1_awaddr),
    .axi_s_awlen       (xbar1_awlen),
    .axi_s_awsize      (xbar1_awsize),
    .axi_s_awburst     (xbar1_awburst),
    .axi_s_awlock      (xbar1_awlock),
    .axi_s_awcache     (xbar1_awcache),
    .axi_s_awprot      (xbar1_awprot),
    .axi_s_awvalid     (xbar1_awvalid),
    .axi_s_awready     (xbar1_awready),

    .axi_s_wid         (xbar1_awid),
    .axi_s_wdata       (xbar1_wdata),
    .axi_s_wstrb       (xbar1_wstrb),
    .axi_s_wlast       (xbar1_wlast),
    .axi_s_wvalid      (xbar1_wvalid),
    .axi_s_wready      (xbar1_wready),

    .axi_s_bid         (xbar1_bid),
    .axi_s_bresp       (xbar1_bresp),
    .axi_s_bvalid      (xbar1_bvalid),
    .axi_s_bready      (xbar1_bready),

    .axi_s_arid        (xbar1_arid),
    .axi_s_araddr      (xbar1_araddr),
    .axi_s_arlen       (xbar1_arlen),
    .axi_s_arsize      (xbar1_arsize),
    .axi_s_arburst     (xbar1_arburst),
    .axi_s_arlock      (xbar1_arlock),
    .axi_s_arcache     (xbar1_arcache),
    .axi_s_arprot      (xbar1_arprot),
    .axi_s_arvalid     (xbar1_arvalid),
    .axi_s_arready     (xbar1_arready),

    .axi_s_rid         (xbar1_rid),
    .axi_s_rdata       (xbar1_rdata),
    .axi_s_rresp       (xbar1_rresp),
    .axi_s_rlast       (xbar1_rlast),
    .axi_s_rvalid      (xbar1_rvalid),
    .axi_s_rready      (xbar1_rready),

    // DMA APB interface (unused ties)
    .apb_rw_dma        (1'b0),
    .apb_psel_dma      (1'b0),
    .apb_enab_dma      (1'b0),
    .apb_addr_dma      (20'b0),
    .apb_valid_dma     (1'b0),
    .apb_wdata_dma     (32'b0),
    .apb_rdata_dma     (),
    .apb_ready_dma     (),
    .dma_grant         (),

    .dma_req_o         (),
    .dma_ack_i         (1'b0),

    // UART0 signals
    .uart0_txd_i       (uart0_txd_i),
    .uart0_txd_o       (uart0_txd_o),
    .uart0_txd_oe      (uart0_txd_oe),
    .uart0_rxd_i       (uart0_rxd_i),
    .uart0_rxd_o       (uart0_rxd_o),
    .uart0_rxd_oe      (uart0_rxd_oe),
    .uart0_rts_o       (uart0_rts_o),
    .uart0_dtr_o       (uart0_dtr_o),
    .uart0_cts_i       (uart0_cts_i),
    .uart0_dsr_i       (uart0_dsr_i),
    .uart0_dcd_i       (uart0_dcd_i),
    .uart0_ri_i        (uart0_ri_i),
    .uart0_int         (uart0_int)
);


  // ------------------------------------------------
  // Configuration Register Module
  // ------------------------------------------------
  wire confreg_int;

  confreg #(.SIMULATION(SIMULATION)) u_confreg (
    .aclk          (sys_clk),
    .aresetn       (sys_resetn),
    .cpu_clk       (cpu_clk),
    .cpu_resetn    (cpu_resetn),

    // AXI-Slave from crossbar Port 3
        // Write address channel
    .s_awid        (xbar3_awid),
    .s_awaddr      (xbar3_awaddr),
    .s_awlen       (xbar3_awlen),
    .s_awsize      (xbar3_awsize),
    .s_awburst     (xbar3_awburst),
    .s_awlock      (xbar3_awlock[0]),
    .s_awcache     (xbar3_awcache),
    .s_awprot      (xbar3_awprot),
    .s_awvalid     (xbar3_awvalid),
    .s_awready     (xbar3_awready),

    // Write data channel
    .s_wid         (xbar3_awid),    // ID same as AWID
    .s_wdata       (xbar3_wdata),
    .s_wstrb       (xbar3_wstrb),
    .s_wlast       (xbar3_wlast),
    .s_wvalid      (xbar3_wvalid),
    .s_wready      (xbar3_wready),

    // Write response channel
    .s_bid         (xbar3_bid),
    .s_bresp       (xbar3_bresp),
    .s_bvalid      (xbar3_bvalid),
    .s_bready      (xbar3_bready),

    // Read address channel
    .s_arid        (xbar3_arid),
    .s_araddr      (xbar3_araddr),
    .s_arlen       (xbar3_arlen),
    .s_arsize      (xbar3_arsize),
    .s_arburst     (xbar3_arburst),
    .s_arlock      (xbar3_arlock[0]),
    .s_arcache     (xbar3_arcache),
    .s_arprot      (xbar3_arprot),
    .s_arvalid     (xbar3_arvalid),
    .s_arready     (xbar3_arready),

    // Read data channel
    .s_rid         (xbar3_rid),
    .s_rdata       (xbar3_rdata),
    .s_rresp       (xbar3_rresp),
    .s_rlast       (xbar3_rlast),
    .s_rvalid      (xbar3_rvalid),
    .s_rready      (xbar3_rready),

    // Peripherals
    .led           (leds),          // 16-bit LED drive
    .dpy0          (dpy0),          // seven-segment low digit
    .dpy1          (dpy1),          // seven-segment high digit
    .switch        (dip_sw),        // DIP switch inputs
    .touch_btn     (touch_btn),     // BTN1~BTN4 inputs

    .confreg_int   (confreg_int)
  );

endmodule
