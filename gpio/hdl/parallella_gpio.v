//#############################################################################
//# Purpose: Parallella GPIO top                                              #
//#############################################################################
//# Author:   Ola Jeppsson                                                    #
//# SPDX-License-Identifier:     MIT                                          #
//#############################################################################

module parallella_gpio(/*AUTOARG*/
   // Outputs
   s_axi_wready, s_axi_rvalid, s_axi_rresp, s_axi_rlast, s_axi_rid,
   s_axi_rdata, s_axi_bvalid, s_axi_bresp, s_axi_bid, s_axi_awready,
   s_axi_arready, gpio_irq,
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
   parameter ID		= 12'h7ff;		// addr[31:20] id
   parameter S_IDW	= 12;			// ID width for S_AXI
   parameter NGPIO	= 24;			// number of gpio pins

   // constants
   input		constant_zero;		// Always 0
   input		constant_one;		// Always 1

   //clk, reset
   input		sys_nreset;		// active low async reset
   input		sys_clk;		// system clock for AXI

   inout [NGPIO-1:0]	gpio_n;			// physical gpio pins
   inout [NGPIO-1:0]	gpio_p;			// physical gpio pins

   wire  [NGPIO-1:0]	gpio_in;		// oh gpio in
   wire  [NGPIO-1:0]	gpio_out;		// oh gpio out
   wire  [NGPIO-1:0]	gpio_dir;		// oh gpio direction
   wire  [NGPIO-1:0]	pgpio_in;		// parallella gpio in
   wire  [NGPIO-1:0]	pgpio_out;		// parallella gpio out

   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input [31:0]		s_axi_araddr;		// To axi_gpio of axi_gpio.v
   input [1:0]		s_axi_arburst;		// To axi_gpio of axi_gpio.v
   input [3:0]		s_axi_arcache;		// To axi_gpio of axi_gpio.v
   input		s_axi_aresetn;		// To axi_gpio of axi_gpio.v
   input [S_IDW-1:0]	s_axi_arid;		// To axi_gpio of axi_gpio.v
   input [7:0]		s_axi_arlen;		// To axi_gpio of axi_gpio.v
   input		s_axi_arlock;		// To axi_gpio of axi_gpio.v
   input [2:0]		s_axi_arprot;		// To axi_gpio of axi_gpio.v
   input [3:0]		s_axi_arqos;		// To axi_gpio of axi_gpio.v
   input [2:0]		s_axi_arsize;		// To axi_gpio of axi_gpio.v
   input		s_axi_arvalid;		// To axi_gpio of axi_gpio.v
   input [31:0]		s_axi_awaddr;		// To axi_gpio of axi_gpio.v
   input [1:0]		s_axi_awburst;		// To axi_gpio of axi_gpio.v
   input [3:0]		s_axi_awcache;		// To axi_gpio of axi_gpio.v
   input [S_IDW-1:0]	s_axi_awid;		// To axi_gpio of axi_gpio.v
   input [7:0]		s_axi_awlen;		// To axi_gpio of axi_gpio.v
   input		s_axi_awlock;		// To axi_gpio of axi_gpio.v
   input [2:0]		s_axi_awprot;		// To axi_gpio of axi_gpio.v
   input [3:0]		s_axi_awqos;		// To axi_gpio of axi_gpio.v
   input [2:0]		s_axi_awsize;		// To axi_gpio of axi_gpio.v
   input		s_axi_awvalid;		// To axi_gpio of axi_gpio.v
   input		s_axi_bready;		// To axi_gpio of axi_gpio.v
   input		s_axi_rready;		// To axi_gpio of axi_gpio.v
   input [31:0]		s_axi_wdata;		// To axi_gpio of axi_gpio.v
   input [S_IDW-1:0]	s_axi_wid;		// To axi_gpio of axi_gpio.v
   input		s_axi_wlast;		// To axi_gpio of axi_gpio.v
   input [3:0]		s_axi_wstrb;		// To axi_gpio of axi_gpio.v
   input		s_axi_wvalid;		// To axi_gpio of axi_gpio.v
   // End of automatics

   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output		gpio_irq;		// From axi_gpio of axi_gpio.v
   output		s_axi_arready;		// From axi_gpio of axi_gpio.v
   output		s_axi_awready;		// From axi_gpio of axi_gpio.v
   output [S_IDW-1:0]	s_axi_bid;		// From axi_gpio of axi_gpio.v
   output [1:0]		s_axi_bresp;		// From axi_gpio of axi_gpio.v
   output		s_axi_bvalid;		// From axi_gpio of axi_gpio.v
   output [31:0]	s_axi_rdata;		// From axi_gpio of axi_gpio.v
   output [S_IDW-1:0]	s_axi_rid;		// From axi_gpio of axi_gpio.v
   output		s_axi_rlast;		// From axi_gpio of axi_gpio.v
   output [1:0]		s_axi_rresp;		// From axi_gpio of axi_gpio.v
   output		s_axi_rvalid;		// From axi_gpio of axi_gpio.v
   output		s_axi_wready;		// From axi_gpio of axi_gpio.v
   // End of automatics

   /*AUTOWIRE*/

   /*AUTOREG*/

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


   axi_gpio #(.S_IDW(S_IDW),.AW(AW),.N(NGPIO),.ID(ID))
   axi_gpio (
	     .gpio_out			(gpio_out[NGPIO-1:0]),
	     .gpio_dir			(gpio_dir[NGPIO-1:0]),
	     .gpio_in			(gpio_in[NGPIO-1:0]),
	     /*AUTOINST*/
	     // Outputs
	     .gpio_irq			(gpio_irq),
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
	     .sys_nreset		(sys_nreset),
	     .sys_clk			(sys_clk),
	     .s_axi_araddr		(s_axi_araddr[31:0]),
	     .s_axi_arburst		(s_axi_arburst[1:0]),
	     .s_axi_arcache		(s_axi_arcache[3:0]),
	     .s_axi_aresetn		(s_axi_aresetn),
	     .s_axi_arid		(s_axi_arid[S_IDW-1:0]),
	     .s_axi_arlen		(s_axi_arlen[7:0]),
	     .s_axi_arlock		(s_axi_arlock),
	     .s_axi_arprot		(s_axi_arprot[2:0]),
	     .s_axi_arqos		(s_axi_arqos[3:0]),
	     .s_axi_arsize		(s_axi_arsize[2:0]),
	     .s_axi_arvalid		(s_axi_arvalid),
	     .s_axi_awaddr		(s_axi_awaddr[31:0]),
	     .s_axi_awburst		(s_axi_awburst[1:0]),
	     .s_axi_awcache		(s_axi_awcache[3:0]),
	     .s_axi_awid		(s_axi_awid[S_IDW-1:0]),
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

endmodule // parallella_gpio
// Local Variables:
// verilog-library-directories:("." "../../axi/hdl" "../../common/hdl" "../../emesh/hdl" "../../parallella/hdl")
// End:
