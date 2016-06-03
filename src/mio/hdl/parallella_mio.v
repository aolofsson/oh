//#############################################################################
//# Purpose: Parallella MIO top                                               #
//#############################################################################
//# Author:   Ola Jeppsson                                                    #
//# SPDX-License-Identifier:     MIT                                          #
//#############################################################################

module parallella_mio(/*AUTOARG*/
   // Outputs
   s_axi_wready, s_axi_rvalid, s_axi_rresp, s_axi_rlast, s_axi_rid,
   s_axi_rdata, s_axi_bvalid, s_axi_bresp, s_axi_bid, s_axi_awready,
   s_axi_arready, m_axi_wvalid, m_axi_wstrb, m_axi_wlast, m_axi_wid,
   m_axi_wdata, m_axi_rready, m_axi_bready, m_axi_awvalid,
   m_axi_awsize, m_axi_awqos, m_axi_awprot, m_axi_awlock, m_axi_awlen,
   m_axi_awid, m_axi_awcache, m_axi_awburst, m_axi_awaddr,
   m_axi_arvalid, m_axi_arsize, m_axi_arqos, m_axi_arprot,
   m_axi_arlock, m_axi_arlen, m_axi_arid, m_axi_arcache,
   m_axi_arburst, m_axi_araddr, constant_zero, constant_one,
   // Inouts
   gpio_n, gpio_p,
   // Inputs
   s_axi_wvalid, s_axi_wstrb, s_axi_wlast, s_axi_wid, s_axi_wdata,
   s_axi_rready, s_axi_bready, s_axi_awvalid, s_axi_awsize,
   s_axi_awqos, s_axi_awprot, s_axi_awlock, s_axi_awlen, s_axi_awid,
   s_axi_awcache, s_axi_awburst, s_axi_awaddr, s_axi_arvalid,
   s_axi_arsize, s_axi_arqos, s_axi_arprot, s_axi_arlock, s_axi_arlen,
   s_axi_arid, s_axi_aresetn, s_axi_arcache, s_axi_arburst,
   s_axi_araddr, m_axi_wready, m_axi_rvalid, m_axi_rresp, m_axi_rlast,
   m_axi_rid, m_axi_rdata, m_axi_bvalid, m_axi_bresp, m_axi_bid,
   m_axi_awready, m_axi_arready, m_axi_aresetn, sys_nreset, sys_clk
   );

   //########################################################
   // INTERFACE
   //########################################################
   parameter AW		= 32;			// address width
   parameter DW		= 32;
   parameter PW		= 2*AW+40;		// packet width
   parameter ID		= 12'h7fd;		// addr[31:20] id
   parameter REMAPID	= 12'h3e0;		// addr[31:20] id
   parameter S_IDW	= 12;			// ID width for S_AXI
   parameter M_IDW	= 6;			// ID width for M_AXI
   parameter NGPIO	= 24;			// number of gpio pins
   parameter NMIO	= 8;			// MIO IO packet width
   parameter TARGET     = "XILINX";		// XILINX,ALTERA,GENERIC,ASIC

   // constants
   output		constant_zero;		// Always 0
   output		constant_one;		// Always 1

   //clk, reset
   input		sys_nreset;		// active low async reset
   input		sys_clk;		// system clock for AXI

   // gpio pins
   inout [NGPIO-1:0]	gpio_n;			// physical mio pins
   inout [NGPIO-1:0]	gpio_p;			// physical mio pins
   wire  [NGPIO-1:0]	gpio_in;		// out gpio pins
   wire  [NGPIO-1:0]	gpio_out;		// in gpio pins
   wire  [NGPIO-1:0]	gpio_dir;		// gpio pin direction

   // mio io signals
   wire			mio_tx_wait;
   wire			mio_tx_access;
   wire			mio_tx_clk;
   wire [NMIO-1:0]	mio_tx_packet;
   wire			mio_rx_access;
   wire			mio_rx_clk;
   wire [NMIO-1:0]	mio_rx_packet;
   wire			mio_rx_wait;

   //##############################################################
   //AUTOS
   //##############################################################

   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		m_axi_aresetn;		// To axi_mio of axi_mio.v
   input		m_axi_arready;		// To axi_mio of axi_mio.v
   input		m_axi_awready;		// To axi_mio of axi_mio.v
   input [M_IDW-1:0]	m_axi_bid;		// To axi_mio of axi_mio.v
   input [1:0]		m_axi_bresp;		// To axi_mio of axi_mio.v
   input		m_axi_bvalid;		// To axi_mio of axi_mio.v
   input [63:0]		m_axi_rdata;		// To axi_mio of axi_mio.v
   input [M_IDW-1:0]	m_axi_rid;		// To axi_mio of axi_mio.v
   input		m_axi_rlast;		// To axi_mio of axi_mio.v
   input [1:0]		m_axi_rresp;		// To axi_mio of axi_mio.v
   input		m_axi_rvalid;		// To axi_mio of axi_mio.v
   input		m_axi_wready;		// To axi_mio of axi_mio.v
   input [31:0]		s_axi_araddr;		// To axi_mio of axi_mio.v
   input [1:0]		s_axi_arburst;		// To axi_mio of axi_mio.v
   input [3:0]		s_axi_arcache;		// To axi_mio of axi_mio.v
   input		s_axi_aresetn;		// To axi_mio of axi_mio.v
   input [S_IDW-1:0]	s_axi_arid;		// To axi_mio of axi_mio.v
   input [7:0]		s_axi_arlen;		// To axi_mio of axi_mio.v
   input		s_axi_arlock;		// To axi_mio of axi_mio.v
   input [2:0]		s_axi_arprot;		// To axi_mio of axi_mio.v
   input [3:0]		s_axi_arqos;		// To axi_mio of axi_mio.v
   input [2:0]		s_axi_arsize;		// To axi_mio of axi_mio.v
   input		s_axi_arvalid;		// To axi_mio of axi_mio.v
   input [31:0]		s_axi_awaddr;		// To axi_mio of axi_mio.v
   input [1:0]		s_axi_awburst;		// To axi_mio of axi_mio.v
   input [3:0]		s_axi_awcache;		// To axi_mio of axi_mio.v
   input [S_IDW-1:0]	s_axi_awid;		// To axi_mio of axi_mio.v
   input [7:0]		s_axi_awlen;		// To axi_mio of axi_mio.v
   input		s_axi_awlock;		// To axi_mio of axi_mio.v
   input [2:0]		s_axi_awprot;		// To axi_mio of axi_mio.v
   input [3:0]		s_axi_awqos;		// To axi_mio of axi_mio.v
   input [2:0]		s_axi_awsize;		// To axi_mio of axi_mio.v
   input		s_axi_awvalid;		// To axi_mio of axi_mio.v
   input		s_axi_bready;		// To axi_mio of axi_mio.v
   input		s_axi_rready;		// To axi_mio of axi_mio.v
   input [31:0]		s_axi_wdata;		// To axi_mio of axi_mio.v
   input [S_IDW-1:0]	s_axi_wid;		// To axi_mio of axi_mio.v
   input		s_axi_wlast;		// To axi_mio of axi_mio.v
   input [3:0]		s_axi_wstrb;		// To axi_mio of axi_mio.v
   input		s_axi_wvalid;		// To axi_mio of axi_mio.v
   // End of automatics

   /*AUTOINPUT("^[ms]_axi_")*/

   /*AUTOOUTPUT("^[ms]_axi_")*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [31:0]	m_axi_araddr;		// From axi_mio of axi_mio.v
   output [1:0]		m_axi_arburst;		// From axi_mio of axi_mio.v
   output [3:0]		m_axi_arcache;		// From axi_mio of axi_mio.v
   output [M_IDW-1:0]	m_axi_arid;		// From axi_mio of axi_mio.v
   output [7:0]		m_axi_arlen;		// From axi_mio of axi_mio.v
   output		m_axi_arlock;		// From axi_mio of axi_mio.v
   output [2:0]		m_axi_arprot;		// From axi_mio of axi_mio.v
   output [3:0]		m_axi_arqos;		// From axi_mio of axi_mio.v
   output [2:0]		m_axi_arsize;		// From axi_mio of axi_mio.v
   output		m_axi_arvalid;		// From axi_mio of axi_mio.v
   output [31:0]	m_axi_awaddr;		// From axi_mio of axi_mio.v
   output [1:0]		m_axi_awburst;		// From axi_mio of axi_mio.v
   output [3:0]		m_axi_awcache;		// From axi_mio of axi_mio.v
   output [M_IDW-1:0]	m_axi_awid;		// From axi_mio of axi_mio.v
   output [7:0]		m_axi_awlen;		// From axi_mio of axi_mio.v
   output		m_axi_awlock;		// From axi_mio of axi_mio.v
   output [2:0]		m_axi_awprot;		// From axi_mio of axi_mio.v
   output [3:0]		m_axi_awqos;		// From axi_mio of axi_mio.v
   output [2:0]		m_axi_awsize;		// From axi_mio of axi_mio.v
   output		m_axi_awvalid;		// From axi_mio of axi_mio.v
   output		m_axi_bready;		// From axi_mio of axi_mio.v
   output		m_axi_rready;		// From axi_mio of axi_mio.v
   output [63:0]	m_axi_wdata;		// From axi_mio of axi_mio.v
   output [M_IDW-1:0]	m_axi_wid;		// From axi_mio of axi_mio.v
   output		m_axi_wlast;		// From axi_mio of axi_mio.v
   output [7:0]		m_axi_wstrb;		// From axi_mio of axi_mio.v
   output		m_axi_wvalid;		// From axi_mio of axi_mio.v
   output		s_axi_arready;		// From axi_mio of axi_mio.v
   output		s_axi_awready;		// From axi_mio of axi_mio.v
   output [S_IDW-1:0]	s_axi_bid;		// From axi_mio of axi_mio.v
   output [1:0]		s_axi_bresp;		// From axi_mio of axi_mio.v
   output		s_axi_bvalid;		// From axi_mio of axi_mio.v
   output [31:0]	s_axi_rdata;		// From axi_mio of axi_mio.v
   output [S_IDW-1:0]	s_axi_rid;		// From axi_mio of axi_mio.v
   output		s_axi_rlast;		// From axi_mio of axi_mio.v
   output [1:0]		s_axi_rresp;		// From axi_mio of axi_mio.v
   output		s_axi_rvalid;		// From axi_mio of axi_mio.v
   output		s_axi_wready;		// From axi_mio of axi_mio.v
   // End of automatics

   /*AUTOWIRE*/

   //##############################################################
   //GPIO
   //##############################################################

   // assign mio_s_ss		= gpio_in[10];
   // assign mio_s_miso		= gpio_out[9];
   // assign mio_s_mosi		= gpio_in[8];
   // assign mio_rx_clk		= gpio_in[7]; /* Must map to a MRCC/SRCC pin */
   // assign mio_m_ss		= gpio_out[6];
   // assign mio_m_miso		= gpio_in[5];
   // assign mio_m_mosi		= gpio_out[4];
   // assign mio_m_sclk		= gpio_out[3];

   /* NOTE: 0 = in, 1 = out */
   assign gpio_dir[NGPIO-1:0] = {{(NGPIO-11){1'b0}}, 8'b01001011, 3'b000};

   assign constant_zero = 1'b0;
   assign constant_one = 1'b1;

   pgpio #(.NGPIO(NGPIO),.NPS(NGPIO),.SLEW("FAST"))
   pgpio (.ps_gpio_i			(gpio_in[NGPIO-1:0]),
	  .ps_gpio_o			(gpio_out[NGPIO-1:0]),
	  .ps_gpio_t			(~gpio_dir[NGPIO-1:0]),
	  /*AUTOINST*/
	  // Inouts
	  .gpio_p			(gpio_p[NGPIO-1:0]),
	  .gpio_n			(gpio_n[NGPIO-1:0]));


   //##############################################################
   //AXI
   //##############################################################
   axi_mio #(.S_IDW(S_IDW),
	     .M_IDW(M_IDW),
	     .AW(AW),
	     .ID(ID),
	     .REMAPID(REMAPID),
	     .TARGET(TARGET),
	     .NMIO(NMIO))
   axi_mio (
	    /* HACK: connect to GPIO pins later */
	    .mio_rx_access		(mio_tx_access),
	    .mio_rx_clk			(mio_tx_clk),
	    .mio_rx_packet		(mio_tx_packet[NMIO-1:0]),
	    .mio_tx_wait		(mio_rx_wait),
	    /*AUTOINST*/
	    // Outputs
	    .m_axi_araddr		(m_axi_araddr[31:0]),
	    .m_axi_arburst		(m_axi_arburst[1:0]),
	    .m_axi_arcache		(m_axi_arcache[3:0]),
	    .m_axi_arid			(m_axi_arid[M_IDW-1:0]),
	    .m_axi_arlen		(m_axi_arlen[7:0]),
	    .m_axi_arlock		(m_axi_arlock),
	    .m_axi_arprot		(m_axi_arprot[2:0]),
	    .m_axi_arqos		(m_axi_arqos[3:0]),
	    .m_axi_arsize		(m_axi_arsize[2:0]),
	    .m_axi_arvalid		(m_axi_arvalid),
	    .m_axi_awaddr		(m_axi_awaddr[31:0]),
	    .m_axi_awburst		(m_axi_awburst[1:0]),
	    .m_axi_awcache		(m_axi_awcache[3:0]),
	    .m_axi_awid			(m_axi_awid[M_IDW-1:0]),
	    .m_axi_awlen		(m_axi_awlen[7:0]),
	    .m_axi_awlock		(m_axi_awlock),
	    .m_axi_awprot		(m_axi_awprot[2:0]),
	    .m_axi_awqos		(m_axi_awqos[3:0]),
	    .m_axi_awsize		(m_axi_awsize[2:0]),
	    .m_axi_awvalid		(m_axi_awvalid),
	    .m_axi_bready		(m_axi_bready),
	    .m_axi_rready		(m_axi_rready),
	    .m_axi_wdata		(m_axi_wdata[63:0]),
	    .m_axi_wid			(m_axi_wid[M_IDW-1:0]),
	    .m_axi_wlast		(m_axi_wlast),
	    .m_axi_wstrb		(m_axi_wstrb[7:0]),
	    .m_axi_wvalid		(m_axi_wvalid),
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
	    .m_axi_aresetn		(m_axi_aresetn),
	    .m_axi_arready		(m_axi_arready),
	    .m_axi_awready		(m_axi_awready),
	    .m_axi_bid			(m_axi_bid[M_IDW-1:0]),
	    .m_axi_bresp		(m_axi_bresp[1:0]),
	    .m_axi_bvalid		(m_axi_bvalid),
	    .m_axi_rdata		(m_axi_rdata[63:0]),
	    .m_axi_rid			(m_axi_rid[M_IDW-1:0]),
	    .m_axi_rlast		(m_axi_rlast),
	    .m_axi_rresp		(m_axi_rresp[1:0]),
	    .m_axi_rvalid		(m_axi_rvalid),
	    .m_axi_wready		(m_axi_wready),
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

endmodule // parallella_mio
// Local Variables:
// verilog-library-directories:("." "../../axi/hdl" "../../common/hdl" "../../emesh/hdl" "../../parallella/hdl")
// End:
