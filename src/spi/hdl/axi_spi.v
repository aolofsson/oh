//#############################################################################
//# Purpose: AXI spi module                                                   #
//#############################################################################
//# Author:   Ola Jeppsson                                                    #
//# SPDX-License-Identifier:     MIT                                          #
//#############################################################################

module axi_spi(/*AUTOARG*/
   // Outputs
   spi_s_miso, spi_m_ss, spi_m_sclk, spi_m_mosi, spi_irq,
   s_axi_wready, s_axi_rvalid, s_axi_rresp, s_axi_rlast, s_axi_rid,
   s_axi_rdata, s_axi_bvalid, s_axi_bresp, s_axi_bid, s_axi_awready,
   s_axi_arready,
   // Inputs
   spi_s_ss, spi_s_sclk, spi_s_mosi, spi_m_miso, s_axi_wvalid,
   s_axi_wstrb, s_axi_wlast, s_axi_wid, s_axi_wdata, s_axi_rready,
   s_axi_bready, s_axi_awvalid, s_axi_awsize, s_axi_awqos,
   s_axi_awprot, s_axi_awlock, s_axi_awlen, s_axi_awid, s_axi_awcache,
   s_axi_awburst, s_axi_awaddr, s_axi_arvalid, s_axi_arsize,
   s_axi_arqos, s_axi_arprot, s_axi_arlock, s_axi_arlen, s_axi_arid,
   s_axi_aresetn, s_axi_arcache, s_axi_arburst, s_axi_araddr,
   sys_nreset, sys_clk
   );

   //########################################################
   // INTERFACE
   //########################################################
   parameter AW          = 32;               // address width
   parameter PW          = 2*AW+40;          // packet width
   parameter ID          = 12'h810;          // addr[31:20] id
   parameter S_IDW       = 12;               // ID width for S_AXI

   //clk, reset
   input        sys_nreset;                  // active low async reset
   input        sys_clk;                     // system clock for AXI

   //############################
   // HOST GENERATERD
   //############################
   //Slave Write
   wire			s_wr_access;
   wire [PW-1:0]	s_wr_packet;
   wire			s_wr_wait;

   //Slave Read Request
   wire			s_rd_access;
   wire [PW-1:0]	s_rd_packet;
   wire			s_rd_wait;

   //Slave Read Response
   wire			s_rr_access;
   wire [PW-1:0]	s_rr_packet;
   wire			s_rr_wait;

   //##############################################################

   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
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
   input		spi_m_miso;		// To spi of spi.v
   input		spi_s_mosi;		// To spi of spi.v
   input		spi_s_sclk;		// To spi of spi.v
   input		spi_s_ss;		// To spi of spi.v
   // End of automatics

   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
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
   output		spi_irq;		// From spi of spi.v
   output		spi_m_mosi;		// From spi of spi.v
   output		spi_m_sclk;		// From spi of spi.v
   output		spi_m_ss;		// From spi of spi.v
   output		spi_s_miso;		// From spi of spi.v
   // End of automatics

   /*AUTOWIRE*/

   /*AUTOREG*/

   wire			spi_wait_out;
   wire			spi_access_out;
   wire [PW-1:0]	spi_packet_out;
   wire			spi_access_in;
   wire [PW-1:0]	spi_packet_in;
   wire			spi_wait_in;

   /* spi AUTO_TEMPLATE (.\([sm]_.*\) (spi_\1[]),); */
   spi #(.AW(AW))
   spi (
	//Outputs
	.hw_en				(1'b1),
	.wait_out			(spi_wait_out),
	.access_out			(spi_access_out),
	.packet_out			(spi_packet_out[PW-1:0]),
	//Inputs
	.nreset				(sys_nreset),
	.clk				(sys_clk),
	.access_in			(spi_access_in),
	.packet_in			(spi_packet_in[PW-1:0]),
	.wait_in			(spi_wait_in),
	/*AUTOINST*/
	// Outputs
	.spi_irq			(spi_irq),
	.m_sclk				(spi_m_sclk),		 // Templated
	.m_mosi				(spi_m_mosi),		 // Templated
	.m_ss				(spi_m_ss),		 // Templated
	.s_miso				(spi_s_miso),		 // Templated
	// Inputs
	.m_miso				(spi_m_miso),		 // Templated
	.s_sclk				(spi_s_sclk),		 // Templated
	.s_mosi				(spi_s_mosi),		 // Templated
	.s_ss				(spi_s_ss));		 // Templated

   //########################################################
   //AXI SLAVE
   //########################################################

   emesh_mux #(.N(2),.AW(AW))
   mux2(// Outputs
	.wait_out			({s_rd_wait, s_wr_wait}),
	.access_out			(spi_access_in),
	.packet_out			(spi_packet_in[PW-1:0]),
	// Inputs
	.access_in			({s_rd_access, s_wr_access}),
	.packet_in			({s_rd_packet[PW-1:0], s_wr_packet[PW-1:0]}),
	.wait_in			(s_rr_wait)
	);

   esaxi #(.S_IDW(S_IDW))
   esaxi (.s_axi_aclk			(sys_clk),
	  .wr_access			(s_wr_access),
	  .wr_packet			(s_wr_packet[PW-1:0]),
	  .rr_wait			(s_rr_wait),
	  .rd_wait			(s_rd_wait),
	  .rr_access			(spi_access_out),
	  .rr_packet			(spi_packet_out[PW-1:0]),
	  .wr_wait			(s_wr_wait),
	  .rd_access			(s_rd_access),
	  .rd_packet			(s_rd_packet[PW-1:0]),
	  /*AUTOINST*/
	  // Outputs
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

endmodule // axi_spi
// Local Variables:
// verilog-library-directories:("." "../../axi/hdl" "../../common/hdl" "../../emesh/hdl")
// End:
