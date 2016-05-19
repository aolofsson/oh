//#############################################################################
//# Purpose: Parallella SPI top                                               #
//#############################################################################
//# Author:   Ola Jeppsson                                                    #
//# SPDX-License-Identifier:     MIT                                          #
//#############################################################################

module parallella_spi(/*AUTOARG*/
   // Outputs
   spi_s_miso, spi_m_ss, spi_m_sclk, spi_m_mosi, spi_irq,
   s_axi_wready, s_axi_rvalid, s_axi_rresp, s_axi_rlast, s_axi_rid,
   s_axi_rdata, s_axi_bvalid, s_axi_bresp, s_axi_bid, s_axi_awready,
   s_axi_arready,
   // Inouts
   gpio_n, gpio_p,
   // Inputs
   s_axi_wvalid, s_axi_wstrb, s_axi_wlast, s_axi_wid, s_axi_wdata,
   s_axi_rready, s_axi_bready, s_axi_awvalid, s_axi_awsize,
   s_axi_awqos, s_axi_awprot, s_axi_awlock, s_axi_awlen, s_axi_awid,
   s_axi_awcache, s_axi_awburst, s_axi_awaddr, s_axi_arvalid,
   s_axi_arsize, s_axi_arqos, s_axi_arprot, s_axi_arlock, s_axi_arlen,
   s_axi_arid, s_axi_aresetn, s_axi_arcache, s_axi_arburst,
   s_axi_araddr, constant_zero, constant_one, sys_nreset, sys_clk
   );

   //########################################################
   // INTERFACE
   //########################################################
   parameter AW		= 32;			// address width
   parameter DW		= 32;
   parameter PW		= 2*AW+40;		// packet width
   parameter ID		= 12'h7fe;		// addr[31:20] id
   parameter S_IDW	= 12;			// ID width for S_AXI
   parameter NGPIO	= 24;			// number of gpio pins

   // constants
   input		constant_zero;		// Always 0
   input		constant_one;		// Always 1

   //clk, reset
   input		sys_nreset;		// active low async reset
   input		sys_clk;		// system clock for AXI

   // gpio pins
   inout [NGPIO-1:0]	gpio_n;			// physical spi pins
   inout [NGPIO-1:0]	gpio_p;			// physical spi pins
   wire  [NGPIO-1:0]	gpio_in;		// out gpio pins
   wire  [NGPIO-1:0]	gpio_out;		// in gpio pins
   wire  [NGPIO-1:0]	gpio_dir;		// gpio pin direction

   // spi
   wire			spi_s_miso;
   wire			spi_m_ss;
   wire			spi_m_sclk;
   wire			spi_m_mosi;
   wire			spi_s_ss;
   wire			spi_s_sclk;
   wire			spi_s_mosi;
   wire			spi_m_miso;

   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input [31:0]		s_axi_araddr;		// To axi_spi of axi_spi.v
   input [1:0]		s_axi_arburst;		// To axi_spi of axi_spi.v
   input [3:0]		s_axi_arcache;		// To axi_spi of axi_spi.v
   input		s_axi_aresetn;		// To axi_spi of axi_spi.v
   input [S_IDW-1:0]	s_axi_arid;		// To axi_spi of axi_spi.v
   input [7:0]		s_axi_arlen;		// To axi_spi of axi_spi.v
   input		s_axi_arlock;		// To axi_spi of axi_spi.v
   input [2:0]		s_axi_arprot;		// To axi_spi of axi_spi.v
   input [3:0]		s_axi_arqos;		// To axi_spi of axi_spi.v
   input [2:0]		s_axi_arsize;		// To axi_spi of axi_spi.v
   input		s_axi_arvalid;		// To axi_spi of axi_spi.v
   input [31:0]		s_axi_awaddr;		// To axi_spi of axi_spi.v
   input [1:0]		s_axi_awburst;		// To axi_spi of axi_spi.v
   input [3:0]		s_axi_awcache;		// To axi_spi of axi_spi.v
   input [S_IDW-1:0]	s_axi_awid;		// To axi_spi of axi_spi.v
   input [7:0]		s_axi_awlen;		// To axi_spi of axi_spi.v
   input		s_axi_awlock;		// To axi_spi of axi_spi.v
   input [2:0]		s_axi_awprot;		// To axi_spi of axi_spi.v
   input [3:0]		s_axi_awqos;		// To axi_spi of axi_spi.v
   input [2:0]		s_axi_awsize;		// To axi_spi of axi_spi.v
   input		s_axi_awvalid;		// To axi_spi of axi_spi.v
   input		s_axi_bready;		// To axi_spi of axi_spi.v
   input		s_axi_rready;		// To axi_spi of axi_spi.v
   input [31:0]		s_axi_wdata;		// To axi_spi of axi_spi.v
   input [S_IDW-1:0]	s_axi_wid;		// To axi_spi of axi_spi.v
   input		s_axi_wlast;		// To axi_spi of axi_spi.v
   input [3:0]		s_axi_wstrb;		// To axi_spi of axi_spi.v
   input		s_axi_wvalid;		// To axi_spi of axi_spi.v
   // End of automatics

   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output		s_axi_arready;		// From axi_spi of axi_spi.v
   output		s_axi_awready;		// From axi_spi of axi_spi.v
   output [S_IDW-1:0]	s_axi_bid;		// From axi_spi of axi_spi.v
   output [1:0]		s_axi_bresp;		// From axi_spi of axi_spi.v
   output		s_axi_bvalid;		// From axi_spi of axi_spi.v
   output [31:0]	s_axi_rdata;		// From axi_spi of axi_spi.v
   output [S_IDW-1:0]	s_axi_rid;		// From axi_spi of axi_spi.v
   output		s_axi_rlast;		// From axi_spi of axi_spi.v
   output [1:0]		s_axi_rresp;		// From axi_spi of axi_spi.v
   output		s_axi_rvalid;		// From axi_spi of axi_spi.v
   output		s_axi_wready;		// From axi_spi of axi_spi.v
   output		spi_irq;		// From axi_spi of axi_spi.v
   output		spi_m_mosi;		// From axi_spi of axi_spi.v
   output		spi_m_sclk;		// From axi_spi of axi_spi.v
   output		spi_m_ss;		// From axi_spi of axi_spi.v
   output		spi_s_miso;		// From axi_spi of axi_spi.v
   // End of automatics

   /*AUTOWIRE*/

   /*AUTOREG*/

   assign spi_s_ss		= gpio_in[10];
   assign spi_s_miso		= gpio_out[9];
   assign spi_s_mosi		= gpio_in[8];
   assign spi_s_sclk		= gpio_in[7]; /* Must map to a MRCC/SRCC pin */
   assign spi_m_ss		= gpio_out[6];
   assign spi_m_miso		= gpio_in[5];
   assign spi_m_mosi		= gpio_out[4];
   assign spi_m_sclk		= gpio_out[3];

   /* NOTE: 0 = in, 1 = out */
   assign gpio_dir[NGPIO-1:0] = {{(NGPIO-8){1'b0}}, 8'b01001011};

   assign constant_zero = 1'b0;
   assign constant_one = 1'b1;

   pgpio #(.NGPIO(NGPIO),.NPS(NGPIO))
   pgpio (.ps_gpio_i			(gpio_in[NGPIO-1:0]),
	  .ps_gpio_o			(gpio_out[NGPIO-1:0]),
	  .ps_gpio_t			(~gpio_dir[NGPIO-1:0]),
	  /*AUTOINST*/
	  // Inouts
	  .gpio_p			(gpio_p[NGPIO-1:0]),
	  .gpio_n			(gpio_n[NGPIO-1:0]));


   axi_spi #(.S_IDW(S_IDW),.AW(AW),.ID(ID))
   axi_spi (// Outputs
	    .spi_irq			(spi_irq),
	    .spi_m_mosi			(spi_m_mosi),
	    .spi_m_sclk			(spi_m_sclk),
	    .spi_m_ss			(spi_m_ss),
	    .spi_s_miso			(spi_s_miso),
	    // Inputs
	    .spi_m_miso			(spi_m_miso),
	    .spi_s_mosi			(spi_s_mosi),
	    .spi_s_sclk			(spi_s_sclk),
	    .spi_s_ss			(spi_s_ss),
	    /*AUTOINST*/
	    // Outputs
	    .s_axi_arready		(s_axi_arready),
	    .s_axi_awready		(s_axi_awready),
	    .s_axi_bid			(s_axi_bid[S_IDW-1:0]),
	    .s_axi_bresp		(s_axi_bresp[1:0]),
	    .s_axi_bvalid		(s_axi_bvalid),
	    .s_axi_rdata		(s_axi_rdata[31:0]),
	    .s_axi_rid			(s_axi_rid[S_IDW-1:0]),
	    .s_axi_rlast		(s_axi_rlast),
	    .s_axi_rresp		(s_axi_rresp[1:0]),
	    .s_axi_rvalid		(s_axi_rvalid),
	    .s_axi_wready		(s_axi_wready),
	    // Inputs
	    .sys_nreset			(sys_nreset),
	    .sys_clk			(sys_clk),
	    .s_axi_araddr		(s_axi_araddr[31:0]),
	    .s_axi_arburst		(s_axi_arburst[1:0]),
	    .s_axi_arcache		(s_axi_arcache[3:0]),
	    .s_axi_aresetn		(s_axi_aresetn),
	    .s_axi_arid			(s_axi_arid[S_IDW-1:0]),
	    .s_axi_arlen		(s_axi_arlen[7:0]),
	    .s_axi_arlock		(s_axi_arlock),
	    .s_axi_arprot		(s_axi_arprot[2:0]),
	    .s_axi_arqos		(s_axi_arqos[3:0]),
	    .s_axi_arsize		(s_axi_arsize[2:0]),
	    .s_axi_arvalid		(s_axi_arvalid),
	    .s_axi_awaddr		(s_axi_awaddr[31:0]),
	    .s_axi_awburst		(s_axi_awburst[1:0]),
	    .s_axi_awcache		(s_axi_awcache[3:0]),
	    .s_axi_awid			(s_axi_awid[S_IDW-1:0]),
	    .s_axi_awlen		(s_axi_awlen[7:0]),
	    .s_axi_awlock		(s_axi_awlock),
	    .s_axi_awprot		(s_axi_awprot[2:0]),
	    .s_axi_awqos		(s_axi_awqos[3:0]),
	    .s_axi_awsize		(s_axi_awsize[2:0]),
	    .s_axi_awvalid		(s_axi_awvalid),
	    .s_axi_bready		(s_axi_bready),
	    .s_axi_rready		(s_axi_rready),
	    .s_axi_wdata		(s_axi_wdata[31:0]),
	    .s_axi_wid			(s_axi_wid[S_IDW-1:0]),
	    .s_axi_wlast		(s_axi_wlast),
	    .s_axi_wstrb		(s_axi_wstrb[3:0]),
	    .s_axi_wvalid		(s_axi_wvalid));

endmodule // parallella_spi
// Local Variables:
// verilog-library-directories:("." "../../axi/hdl" "../../common/hdl" "../../emesh/hdl" "../../parallella/hdl")
// End:
