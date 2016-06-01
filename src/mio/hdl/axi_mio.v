//#############################################################################
//# Purpose: AXI MIO module                                                   #
//#############################################################################
//# Author:   Ola Jeppsson                                                    #
//# SPDX-License-Identifier:     MIT                                          #
//#############################################################################

module axi_mio(/*AUTOARG*/
   // Outputs
   mio_io_tx_packet, mio_io_tx_clk, mio_io_tx_access, mio_io_rx_wait,
   s_axi_wready, s_axi_rvalid, s_axi_rresp, s_axi_rlast, s_axi_rid,
   s_axi_rdata, s_axi_bvalid, s_axi_bresp, s_axi_bid, s_axi_awready,
   s_axi_arready, m_axi_wvalid, m_axi_wstrb, m_axi_wlast, m_axi_wid,
   m_axi_wdata, m_axi_rready, m_axi_bready, m_axi_awvalid,
   m_axi_awsize, m_axi_awqos, m_axi_awprot, m_axi_awlock, m_axi_awlen,
   m_axi_awid, m_axi_awcache, m_axi_awburst, m_axi_awaddr,
   m_axi_arvalid, m_axi_arsize, m_axi_arqos, m_axi_arprot,
   m_axi_arlock, m_axi_arlen, m_axi_arid, m_axi_arcache,
   m_axi_arburst, m_axi_araddr,
   // Inputs
   mio_io_tx_wait, mio_io_rx_packet, mio_io_rx_clk, mio_io_rx_access,
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
   parameter AW          = 32;			   // address width
   parameter PW          = 2*AW+40;		   // packet width
   parameter ID          = 12'h810;		   // addr[31:20] id
   parameter REMAPID     = 12'h3E0;		   // AXI slave addr[31:20] out
   parameter S_IDW       = 12;			   // ID width for S_AXI
   parameter M_IDW       = 6;			   // ID width for S_AXI
   parameter TARGET      = "GENERIC";		   // XILINX,ALTERA,GENERIC,ASIC
   parameter EGROUP_RR   = 4'hD;
   parameter EGROUP_CFG  = 4'h0;
   parameter RETURN_ADDR = {ID, EGROUP_RR, 16'b0}; // axi return addr
   parameter NMIO	 = 8;			   // MIO IO packet width

   //clk, reset
   input        sys_nreset;			   // active low async reset
   input        sys_clk;			   // system clock for AXI

   // AXI slave
   wire			s_rd_access;
   wire [PW-1:0]	s_rd_packet;
   wire			s_rr_wait;
   wire			s_wr_access;
   wire [PW-1:0]	s_wr_packet;

   // AXI master
   wire			m_rd_wait;
   wire			m_rr_access;
   wire [PW-1:0]	m_rr_packet;
   wire			m_wr_wait;

   //##############################################################
   //AUTOS
   //##############################################################

   /*AUTOINPUT("^[ms]_axi_")*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		m_axi_aresetn;		// To emaxi of emaxi.v
   input		m_axi_arready;		// To emaxi of emaxi.v
   input		m_axi_awready;		// To emaxi of emaxi.v
   input [M_IDW-1:0]	m_axi_bid;		// To emaxi of emaxi.v
   input [1:0]		m_axi_bresp;		// To emaxi of emaxi.v
   input		m_axi_bvalid;		// To emaxi of emaxi.v
   input [63:0]		m_axi_rdata;		// To emaxi of emaxi.v
   input [M_IDW-1:0]	m_axi_rid;		// To emaxi of emaxi.v
   input		m_axi_rlast;		// To emaxi of emaxi.v
   input [1:0]		m_axi_rresp;		// To emaxi of emaxi.v
   input		m_axi_rvalid;		// To emaxi of emaxi.v
   input		m_axi_wready;		// To emaxi of emaxi.v
   input [31:0]		s_axi_araddr;		// To esaxi of esaxi.v
   input [1:0]		s_axi_arburst;		// To esaxi of esaxi.v
   input [3:0]		s_axi_arcache;		// To esaxi of esaxi.v
   input		s_axi_aresetn;		// To esaxi of esaxi.v
   input [S_IDW-1:0]	s_axi_arid;		// To esaxi of esaxi.v
   input [7:0]		s_axi_arlen;		// To esaxi of esaxi.v
   input		s_axi_arlock;		// To esaxi of esaxi.v
   input [2:0]		s_axi_arprot;		// To esaxi of esaxi.v
   input [3:0]		s_axi_arqos;		// To esaxi of esaxi.v
   input [2:0]		s_axi_arsize;		// To esaxi of esaxi.v
   input		s_axi_arvalid;		// To esaxi of esaxi.v
   input [31:0]		s_axi_awaddr;		// To esaxi of esaxi.v
   input [1:0]		s_axi_awburst;		// To esaxi of esaxi.v
   input [3:0]		s_axi_awcache;		// To esaxi of esaxi.v
   input [S_IDW-1:0]	s_axi_awid;		// To esaxi of esaxi.v
   input [7:0]		s_axi_awlen;		// To esaxi of esaxi.v
   input		s_axi_awlock;		// To esaxi of esaxi.v
   input [2:0]		s_axi_awprot;		// To esaxi of esaxi.v
   input [3:0]		s_axi_awqos;		// To esaxi of esaxi.v
   input [2:0]		s_axi_awsize;		// To esaxi of esaxi.v
   input		s_axi_awvalid;		// To esaxi of esaxi.v
   input		s_axi_bready;		// To esaxi of esaxi.v
   input		s_axi_rready;		// To esaxi of esaxi.v
   input [31:0]		s_axi_wdata;		// To esaxi of esaxi.v
   input [S_IDW-1:0]	s_axi_wid;		// To esaxi of esaxi.v
   input		s_axi_wlast;		// To esaxi of esaxi.v
   input [3:0]		s_axi_wstrb;		// To esaxi of esaxi.v
   input		s_axi_wvalid;		// To esaxi of esaxi.v
   // End of automatics

   /*AUTOINPUT("^mio_io_[rt]x_")*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		mio_io_rx_access;	// To mio of mio.v
   input		mio_io_rx_clk;		// To mio of mio.v
   input [NMIO-1:0]	mio_io_rx_packet;	// To mio of mio.v
   input		mio_io_tx_wait;		// To mio of mio.v
   // End of automatics

   /*AUTOOUTPUT("^[ms]_axi_")*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [31:0]	m_axi_araddr;		// From emaxi of emaxi.v
   output [1:0]		m_axi_arburst;		// From emaxi of emaxi.v
   output [3:0]		m_axi_arcache;		// From emaxi of emaxi.v
   output [M_IDW-1:0]	m_axi_arid;		// From emaxi of emaxi.v
   output [7:0]		m_axi_arlen;		// From emaxi of emaxi.v
   output		m_axi_arlock;		// From emaxi of emaxi.v
   output [2:0]		m_axi_arprot;		// From emaxi of emaxi.v
   output [3:0]		m_axi_arqos;		// From emaxi of emaxi.v
   output [2:0]		m_axi_arsize;		// From emaxi of emaxi.v
   output		m_axi_arvalid;		// From emaxi of emaxi.v
   output [31:0]	m_axi_awaddr;		// From emaxi of emaxi.v
   output [1:0]		m_axi_awburst;		// From emaxi of emaxi.v
   output [3:0]		m_axi_awcache;		// From emaxi of emaxi.v
   output [M_IDW-1:0]	m_axi_awid;		// From emaxi of emaxi.v
   output [7:0]		m_axi_awlen;		// From emaxi of emaxi.v
   output		m_axi_awlock;		// From emaxi of emaxi.v
   output [2:0]		m_axi_awprot;		// From emaxi of emaxi.v
   output [3:0]		m_axi_awqos;		// From emaxi of emaxi.v
   output [2:0]		m_axi_awsize;		// From emaxi of emaxi.v
   output		m_axi_awvalid;		// From emaxi of emaxi.v
   output		m_axi_bready;		// From emaxi of emaxi.v
   output		m_axi_rready;		// From emaxi of emaxi.v
   output [63:0]	m_axi_wdata;		// From emaxi of emaxi.v
   output [M_IDW-1:0]	m_axi_wid;		// From emaxi of emaxi.v
   output		m_axi_wlast;		// From emaxi of emaxi.v
   output [7:0]		m_axi_wstrb;		// From emaxi of emaxi.v
   output		m_axi_wvalid;		// From emaxi of emaxi.v
   output		s_axi_arready;		// From esaxi of esaxi.v
   output		s_axi_awready;		// From esaxi of esaxi.v
   output [S_IDW-1:0]	s_axi_bid;		// From esaxi of esaxi.v
   output [1:0]		s_axi_bresp;		// From esaxi of esaxi.v
   output		s_axi_bvalid;		// From esaxi of esaxi.v
   output [31:0]	s_axi_rdata;		// From esaxi of esaxi.v
   output [S_IDW-1:0]	s_axi_rid;		// From esaxi of esaxi.v
   output		s_axi_rlast;		// From esaxi of esaxi.v
   output [1:0]		s_axi_rresp;		// From esaxi of esaxi.v
   output		s_axi_rvalid;		// From esaxi of esaxi.v
   output		s_axi_wready;		// From esaxi of esaxi.v
   // End of automatics

   /*AUTOOUTPUT("^mio_io_[rt]x_")*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output		mio_io_rx_wait;		// From mio of mio.v
   output		mio_io_tx_access;	// From mio of mio.v
   output		mio_io_tx_clk;		// From mio of mio.v
   output [NMIO-1:0]	mio_io_tx_packet;	// From mio of mio.v
   // End of automatics

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			mio_access_out;		// From mio of mio.v
   wire [PW-1:0]	mio_packet_out;		// From mio of mio.v
   wire			mio_reg_access_out;	// From mio of mio.v
   wire [PW-1:0]	mio_reg_packet_out;	// From mio of mio.v
   wire			mio_reg_wait_out;	// From mio of mio.v
   wire			mio_wait_out;		// From mio of mio.v
   // End of automatics

   //########################################################
   //Switchboard logic
   //########################################################

   /* AXI SLAVE wr/rd MIO TX / MIO REG match*/

   wire s_wr_mio_reg_match		= s_wr_dstaddr[31:20] == ID;
   wire s_wr_mio_reg_access		= s_wr_access &  s_wr_mio_reg_match;
   wire s_wr_mio_access			= s_wr_access & ~s_wr_mio_reg_match;

   wire			s_wr_write;
   wire [AW-1:0]	s_wr_dstaddr;
   wire [1:0]		s_wr_datamode;
   wire [4:0]		s_wr_ctrlmode;
   wire [AW-1:0]	s_wr_srcaddr;
   wire [AW-1:0]	s_wr_data;

   packet2emesh #(.AW(AW), .PW(PW))
   s_wr_p2e (// Inputs
	     .packet_in			(s_wr_packet[PW-1:0]),
	     // Output
	     .write_in			(s_wr_write),
	     .dstaddr_in		(s_wr_dstaddr[AW-1:0]),
	     .datamode_in		(s_wr_datamode[1:0]),
	     .ctrlmode_in		(s_wr_ctrlmode[4:0]),
	     .srcaddr_in		(s_wr_srcaddr[AW-1:0]),
	     .data_in			(s_wr_data[AW-1:0]));

   /* s_wr_remap */
   wire [PW-1:0]	s_wr_remapped_packet;
   emesh2packet #(.AW(AW), .PW(PW))
   s_wr_remap_e2p (// Outputs
		   .packet_out		(s_wr_remapped_packet[PW-1:0]),
		   // Inputs
		   .write_out		(s_wr_write),
		   .datamode_out	(s_wr_datamode[1:0]),
		   .ctrlmode_out	(s_wr_ctrlmode[4:0]),
		   .dstaddr_out		({REMAPID, s_wr_dstaddr[19:0]}),
		   .data_out		(s_wr_data[AW-1:0]),
		   .srcaddr_out		(s_wr_srcaddr[AW-1:0]));

   wire s_rd_mio_reg_match		= s_rd_dstaddr[31:20] == ID;
   wire s_rd_mio_reg_access		= s_rd_access &  s_rd_mio_reg_match;
   wire s_rd_mio_access			= s_rd_access & ~s_rd_mio_reg_match;

   wire			s_rd_write;
   wire [AW-1:0]	s_rd_dstaddr;
   wire [1:0]		s_rd_datamode;
   wire [4:0]		s_rd_ctrlmode;
   wire [AW-1:0]	s_rd_srcaddr;
   wire [AW-1:0]	s_rd_data;

   packet2emesh #(.AW(AW), .PW(PW))
   s_rd_p2e (// Inputs
	     .packet_in			(s_rd_packet[PW-1:0]),
	     // Output
	     .write_in			(s_rd_write),
	     .dstaddr_in		(s_rd_dstaddr[AW-1:0]),
	     .datamode_in		(s_rd_datamode[1:0]),
	     .ctrlmode_in		(s_rd_ctrlmode[4:0]),
	     .srcaddr_in		(s_rd_srcaddr[AW-1:0]),
	     .data_in			(s_rd_data[AW-1:0]));

   /* s_rd_remap */
   wire [PW-1:0]	s_rd_remapped_packet;
   emesh2packet #(.AW(AW), .PW(PW))
   s_rd_remap_e2p (// Outputs
		   .packet_out		(s_rd_remapped_packet[PW-1:0]),
		   // Inputs
		   .write_out		(s_rd_write),
		   .datamode_out	(s_rd_datamode[1:0]),
		   .ctrlmode_out	(s_rd_ctrlmode[4:0]),
		   .dstaddr_out		({REMAPID, s_rd_dstaddr[19:0]}),
		   .data_out		(s_rd_data[AW-1:0]),
		   .srcaddr_out		(s_rd_srcaddr[AW-1:0]));


   wire [AW-1:0]	mio_rx_dstaddr;
   wire			mio_rx_write;
   packet2emesh #(.AW(AW), .PW(PW))
   mio_rx_p2e (// Inputs
	       .packet_in		(mio_packet_out[PW-1:0]),
	       // Output
	       .write_in		(mio_rx_write),
	       .dstaddr_in		(mio_rx_dstaddr[AW-1:0]));

   // Match
   assign s_rr_match			= (mio_rx_dstaddr[31:20] == ID) &
					  (mio_rx_dstaddr[19:16] == EGROUP_RR);
   assign m_wr_match			= ~s_rr_match &  mio_rx_write;
   assign m_rd_match			= ~s_rr_match & ~mio_rx_write;

   // Access
   assign s_rr_access			= (mio_access_out & s_rr_match);
   assign m_wr_access			= (mio_access_out & m_wr_match);
   assign m_rd_access			= (mio_access_out & m_rd_match);

   // MIO RX Wait
   assign mio_wait_in			= (s_rr_match & (s_rr_wait | ~mio_s_rr_grant))
					| (m_wr_match & m_wr_wait)
					| (m_rd_match & m_rd_wait);

  assign mio_reg_wait_in		= ~mio_reg_s_rr_grant | s_rr_wait;

  // Arbitrate between reg and mio for axi slave read response
  oh_arbiter #(.N(2))
  s_rr_arb (.grants			({mio_reg_s_rr_grant,
					  mio_s_rr_grant}),
	    .requests			({mio_reg_access_out,
					  mio_s_rr_access}));

   wire [PW-1:0]	s_rr_packet;
   oh_mux2 #(.DW(PW))
   s_rr_mux (.out			(s_rr_packet[PW-1:0]),
	     .sel1			(mio_reg_s_rr_grant),
	     .sel0			(mio_s_rr_grant),
	     .in1			(mio_reg_packet_out[PW-1:0]),
	     .in0			(mio_packet_out[PW-1:0]));

   assign s_wr_wait = (s_wr_mio_access & s_wr_mio_wait)
		    | (s_wr_mio_reg_access & s_wr_mio_reg_wait);

   assign s_rd_wait = (s_rd_mio_access & s_rd_mio_wait)
		    | (s_rd_mio_reg_access & s_rd_mio_reg_wait);

   wire [PW-1:0]	mio_packet_in;
   // MIO TX path
   emesh_mux #(.N(3),.AW(AW))
   mio_tx_mux(// Outputs
	      .wait_out			({s_wr_mio_wait,
					  s_rd_mio_wait,
					  m_rr_wait}),
	      .access_out		(mio_access_in),
	      .packet_out		(mio_packet_in[PW-1:0]),
	      // Inputs
	      .access_in		({s_wr_mio_access,
					  s_rd_mio_access,
					  m_rr_access}),
	      .packet_in		({s_wr_remapped_packet[PW-1:0],
					  s_rd_remapped_packet[PW-1:0],
					  m_rr_packet[PW-1:0]}),
	      .wait_in			(mio_wait_out));

   // REG s_wr/s_rd access
   wire [PW-1:0]	mio_reg_packet_in;
   emesh_mux #(.N(2),.AW(AW))
   mio_reg_mux(// Outputs
	       .wait_out		({s_wr_mio_reg_wait,
					  s_rd_mio_reg_wait}),
	       .access_out		(mio_reg_access_in),
	       .packet_out		(mio_reg_packet_in[PW-1:0]),
	       // Inputs
	       .access_in		({s_wr_mio_reg_access,
					  s_rd_mio_reg_access}),
	       .packet_in		({s_wr_packet[PW-1:0],
					  s_rd_packet[PW-1:0]}),
	       .wait_in			(mio_reg_wait_out));


   //########################################################
   //MIO
   //########################################################

   /*
   mio AUTO_TEMPLATE
      (.clk (sys_clk),
       .nreset (nreset),
       .\([rt]x_.*\)			(mio_io_\1[]),
       .\(.*\)				(mio_\1[])); */
   mio #(.AW(AW), .DEF_CLK(100))
   mio (/*AUTOINST*/
	// Outputs
	.tx_clk				(mio_io_tx_clk),	 // Templated
	.tx_access			(mio_io_tx_access),	 // Templated
	.tx_packet			(mio_io_tx_packet[NMIO-1:0]), // Templated
	.rx_wait			(mio_io_rx_wait),	 // Templated
	.wait_out			(mio_wait_out),		 // Templated
	.access_out			(mio_access_out),	 // Templated
	.packet_out			(mio_packet_out[PW-1:0]), // Templated
	.reg_wait_out			(mio_reg_wait_out),	 // Templated
	.reg_access_out			(mio_reg_access_out),	 // Templated
	.reg_packet_out			(mio_reg_packet_out[PW-1:0]), // Templated
	// Inputs
	.clk				(sys_clk),		 // Templated
	.nreset				(nreset),		 // Templated
	.tx_wait			(mio_io_tx_wait),	 // Templated
	.rx_clk				(mio_io_rx_clk),	 // Templated
	.rx_access			(mio_io_rx_access),	 // Templated
	.rx_packet			(mio_io_rx_packet[NMIO-1:0]), // Templated
	.access_in			(mio_access_in),	 // Templated
	.packet_in			(mio_packet_in[PW-1:0]), // Templated
	.wait_in			(mio_wait_in),		 // Templated
	.reg_access_in			(mio_reg_access_in),	 // Templated
	.reg_packet_in			(mio_reg_packet_in[PW-1:0]), // Templated
	.reg_wait_in			(mio_reg_wait_in));	 // Templated

   //########################################################
   //AXI SLAVE
   //########################################################

   /*
   esaxi AUTO_TEMPLATE
	 (.rr_\(.*\)			(s_rr_\1[]),
	  .rr_\(.*\)			(s_rr_\1[]),
	  .rd_\(.*\)			(s_rd_\1[]),
	  .wr_\(.*\)			(s_wr_\1[]),
	  .s_axi_aclk			(sys_clk)); */

   esaxi #(.S_IDW(S_IDW), .RETURN_ADDR(RETURN_ADDR))
   esaxi (/*AUTOINST*/
	  // Outputs
	  .wr_access			(s_wr_access),		 // Templated
	  .wr_packet			(s_wr_packet[PW-1:0]),	 // Templated
	  .rd_access			(s_rd_access),		 // Templated
	  .rd_packet			(s_rd_packet[PW-1:0]),	 // Templated
	  .rr_wait			(s_rr_wait),		 // Templated
	  .s_axi_arready		(s_axi_arready),
	  .s_axi_awready		(s_axi_awready),
	  .s_axi_bid			(s_axi_bid[S_IDW-1:0]),
	  .s_axi_bresp			(s_axi_bresp[1:0]),
	  .s_axi_bvalid			(s_axi_bvalid),
	  .s_axi_rid			(s_axi_rid[S_IDW-1:0]),
	  .s_axi_rdata			(s_axi_rdata[31:0]),
	  .s_axi_rlast			(s_axi_rlast),
	  .s_axi_rresp			(s_axi_rresp[1:0]),
	  .s_axi_rvalid			(s_axi_rvalid),
	  .s_axi_wready			(s_axi_wready),
	  // Inputs
	  .wr_wait			(s_wr_wait),		 // Templated
	  .rd_wait			(s_rd_wait),		 // Templated
	  .rr_access			(s_rr_access),		 // Templated
	  .rr_packet			(s_rr_packet[PW-1:0]),	 // Templated
	  .s_axi_aclk			(sys_clk),		 // Templated
	  .s_axi_aresetn		(s_axi_aresetn),
	  .s_axi_arid			(s_axi_arid[S_IDW-1:0]),
	  .s_axi_araddr			(s_axi_araddr[31:0]),
	  .s_axi_arburst		(s_axi_arburst[1:0]),
	  .s_axi_arcache		(s_axi_arcache[3:0]),
	  .s_axi_arlock			(s_axi_arlock),
	  .s_axi_arlen			(s_axi_arlen[7:0]),
	  .s_axi_arprot			(s_axi_arprot[2:0]),
	  .s_axi_arqos			(s_axi_arqos[3:0]),
	  .s_axi_arsize			(s_axi_arsize[2:0]),
	  .s_axi_arvalid		(s_axi_arvalid),
	  .s_axi_awid			(s_axi_awid[S_IDW-1:0]),
	  .s_axi_awaddr			(s_axi_awaddr[31:0]),
	  .s_axi_awburst		(s_axi_awburst[1:0]),
	  .s_axi_awcache		(s_axi_awcache[3:0]),
	  .s_axi_awlock			(s_axi_awlock),
	  .s_axi_awlen			(s_axi_awlen[7:0]),
	  .s_axi_awprot			(s_axi_awprot[2:0]),
	  .s_axi_awqos			(s_axi_awqos[3:0]),
	  .s_axi_awsize			(s_axi_awsize[2:0]),
	  .s_axi_awvalid		(s_axi_awvalid),
	  .s_axi_bready			(s_axi_bready),
	  .s_axi_rready			(s_axi_rready),
	  .s_axi_wid			(s_axi_wid[S_IDW-1:0]),
	  .s_axi_wdata			(s_axi_wdata[31:0]),
	  .s_axi_wlast			(s_axi_wlast),
	  .s_axi_wstrb			(s_axi_wstrb[3:0]),
	  .s_axi_wvalid			(s_axi_wvalid));

   //########################################################
   //AXI SLAVE
   //########################################################

   /*
   emaxi AUTO_TEMPLATE
	 (.wr_packet			(mio_packet_out[PW-1:0]),
	  .rd_packet			(mio_packet_out[PW-1:0]),
	  .rr_\(.*\)			(m_rr_\1[]),
	  .rd_\(.*\)			(m_rd_\1[]),
	  .wr_\(.*\)			(m_wr_\1[]),
	  .m_axi_aclk			(sys_clk)); */
   emaxi #(.M_IDW(M_IDW))
   emaxi (/*AUTOINST*/
	  // Outputs
	  .wr_wait			(m_wr_wait),		 // Templated
	  .rd_wait			(m_rd_wait),		 // Templated
	  .rr_access			(m_rr_access),		 // Templated
	  .rr_packet			(m_rr_packet[PW-1:0]),	 // Templated
	  .m_axi_awid			(m_axi_awid[M_IDW-1:0]),
	  .m_axi_awaddr			(m_axi_awaddr[31:0]),
	  .m_axi_awlen			(m_axi_awlen[7:0]),
	  .m_axi_awsize			(m_axi_awsize[2:0]),
	  .m_axi_awburst		(m_axi_awburst[1:0]),
	  .m_axi_awlock			(m_axi_awlock),
	  .m_axi_awcache		(m_axi_awcache[3:0]),
	  .m_axi_awprot			(m_axi_awprot[2:0]),
	  .m_axi_awqos			(m_axi_awqos[3:0]),
	  .m_axi_awvalid		(m_axi_awvalid),
	  .m_axi_wid			(m_axi_wid[M_IDW-1:0]),
	  .m_axi_wdata			(m_axi_wdata[63:0]),
	  .m_axi_wstrb			(m_axi_wstrb[7:0]),
	  .m_axi_wlast			(m_axi_wlast),
	  .m_axi_wvalid			(m_axi_wvalid),
	  .m_axi_bready			(m_axi_bready),
	  .m_axi_arid			(m_axi_arid[M_IDW-1:0]),
	  .m_axi_araddr			(m_axi_araddr[31:0]),
	  .m_axi_arlen			(m_axi_arlen[7:0]),
	  .m_axi_arsize			(m_axi_arsize[2:0]),
	  .m_axi_arburst		(m_axi_arburst[1:0]),
	  .m_axi_arlock			(m_axi_arlock),
	  .m_axi_arcache		(m_axi_arcache[3:0]),
	  .m_axi_arprot			(m_axi_arprot[2:0]),
	  .m_axi_arqos			(m_axi_arqos[3:0]),
	  .m_axi_arvalid		(m_axi_arvalid),
	  .m_axi_rready			(m_axi_rready),
	  // Inputs
	  .wr_access			(m_wr_access),		 // Templated
	  .wr_packet			(mio_packet_out[PW-1:0]), // Templated
	  .rd_access			(m_rd_access),		 // Templated
	  .rd_packet			(mio_packet_out[PW-1:0]), // Templated
	  .rr_wait			(m_rr_wait),		 // Templated
	  .m_axi_aclk			(sys_clk),		 // Templated
	  .m_axi_aresetn		(m_axi_aresetn),
	  .m_axi_awready		(m_axi_awready),
	  .m_axi_wready			(m_axi_wready),
	  .m_axi_bid			(m_axi_bid[M_IDW-1:0]),
	  .m_axi_bresp			(m_axi_bresp[1:0]),
	  .m_axi_bvalid			(m_axi_bvalid),
	  .m_axi_arready		(m_axi_arready),
	  .m_axi_rid			(m_axi_rid[M_IDW-1:0]),
	  .m_axi_rdata			(m_axi_rdata[63:0]),
	  .m_axi_rresp			(m_axi_rresp[1:0]),
	  .m_axi_rlast			(m_axi_rlast),
	  .m_axi_rvalid			(m_axi_rvalid));

endmodule // axi_mio
// Local Variables:
// verilog-library-directories:("." "../../axi/hdl" "../../common/hdl" "../../emesh/hdl")
// End:
