//#############################################################################
//# Purpose: Device under test wrapper for toy accelerator example            #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see below)                                                 # 
//#############################################################################

module dut(/*AUTOARG*/
   // Outputs
   dut_active, clkout, wait_out, access_out, packet_out,
   // Inputs
   clk1, clk2, nreset, vdd, vss, access_in, packet_in, wait_in
   );

   //##########################################################################
   //# INTERFACE 
   //##########################################################################

   parameter AW    = 32;
   parameter ID    = 12'h810;   
   parameter S_IDW = 12; 
   parameter M_IDW = 6; 
   parameter PW    = 2*AW + 40;     
   parameter N     = 1;

   //clock,reset
   input            clk1;
   input            clk2;
   input            nreset;
   input [N*N-1:0]  vdd;
   input 	    vss;
   output 	    dut_active;
   output 	    clkout;
   
   //Stimulus Driven Transaction
   input [N-1:0]     access_in;
   input [N*PW-1:0]  packet_in;
   output [N-1:0]    wait_out;

   //DUT driven transaction
   output [N-1:0]    access_out;
   output [N*PW-1:0] packet_out;
   input [N-1:0]     wait_in;

   //##########################################################################
   //#BODY 
   //##########################################################################

   wire 	     mem_rd_wait;
   wire 	     mem_wr_wait;
   wire 	     mem_access;
   wire [PW-1:0]     mem_packet;

   /*AUTOINPUT*/
  
   // End of automatics
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			irq;			// From axi_accelerator of axi_accelerator.v
   wire [31:0]		m_axi_araddr;		// From axi_accelerator of axi_accelerator.v
   wire [1:0]		m_axi_arburst;		// From axi_accelerator of axi_accelerator.v
   wire [3:0]		m_axi_arcache;		// From axi_accelerator of axi_accelerator.v
   wire [M_IDW-1:0]	m_axi_arid;		// From axi_accelerator of axi_accelerator.v
   wire [7:0]		m_axi_arlen;		// From axi_accelerator of axi_accelerator.v
   wire			m_axi_arlock;		// From axi_accelerator of axi_accelerator.v
   wire [2:0]		m_axi_arprot;		// From axi_accelerator of axi_accelerator.v
   wire [3:0]		m_axi_arqos;		// From axi_accelerator of axi_accelerator.v
   wire			m_axi_arready;		// From m_stub of axislave_stub.v
   wire [2:0]		m_axi_arsize;		// From axi_accelerator of axi_accelerator.v
   wire			m_axi_arvalid;		// From axi_accelerator of axi_accelerator.v
   wire [31:0]		m_axi_awaddr;		// From axi_accelerator of axi_accelerator.v
   wire [1:0]		m_axi_awburst;		// From axi_accelerator of axi_accelerator.v
   wire [3:0]		m_axi_awcache;		// From axi_accelerator of axi_accelerator.v
   wire [M_IDW-1:0]	m_axi_awid;		// From axi_accelerator of axi_accelerator.v
   wire [7:0]		m_axi_awlen;		// From axi_accelerator of axi_accelerator.v
   wire			m_axi_awlock;		// From axi_accelerator of axi_accelerator.v
   wire [2:0]		m_axi_awprot;		// From axi_accelerator of axi_accelerator.v
   wire [3:0]		m_axi_awqos;		// From axi_accelerator of axi_accelerator.v
   wire			m_axi_awready;		// From m_stub of axislave_stub.v
   wire [2:0]		m_axi_awsize;		// From axi_accelerator of axi_accelerator.v
   wire			m_axi_awvalid;		// From axi_accelerator of axi_accelerator.v
   wire [S_IDW-1:0]	m_axi_bid;		// From m_stub of axislave_stub.v
   wire			m_axi_bready;		// From axi_accelerator of axi_accelerator.v
   wire [1:0]		m_axi_bresp;		// From m_stub of axislave_stub.v
   wire			m_axi_bvalid;		// From m_stub of axislave_stub.v
   wire [31:0]		m_axi_rdata;		// From m_stub of axislave_stub.v
   wire [S_IDW-1:0]	m_axi_rid;		// From m_stub of axislave_stub.v
   wire			m_axi_rlast;		// From m_stub of axislave_stub.v
   wire			m_axi_rready;		// From axi_accelerator of axi_accelerator.v
   wire [1:0]		m_axi_rresp;		// From m_stub of axislave_stub.v
   wire			m_axi_rvalid;		// From m_stub of axislave_stub.v
   wire [63:0]		m_axi_wdata;		// From axi_accelerator of axi_accelerator.v
   wire [M_IDW-1:0]	m_axi_wid;		// From axi_accelerator of axi_accelerator.v
   wire			m_axi_wlast;		// From axi_accelerator of axi_accelerator.v
   wire			m_axi_wready;		// From m_stub of axislave_stub.v
   wire [7:0]		m_axi_wstrb;		// From axi_accelerator of axi_accelerator.v
   wire			m_axi_wvalid;		// From axi_accelerator of axi_accelerator.v
   wire [31:0]		s_axi_araddr;		// From emaxi of emaxi.v
   wire [1:0]		s_axi_arburst;		// From emaxi of emaxi.v
   wire [3:0]		s_axi_arcache;		// From emaxi of emaxi.v
   wire [M_IDW-1:0]	s_axi_arid;		// From emaxi of emaxi.v
   wire [7:0]		s_axi_arlen;		// From emaxi of emaxi.v
   wire			s_axi_arlock;		// From emaxi of emaxi.v
   wire [2:0]		s_axi_arprot;		// From emaxi of emaxi.v
   wire [3:0]		s_axi_arqos;		// From emaxi of emaxi.v
   wire			s_axi_arready;		// From axi_accelerator of axi_accelerator.v
   wire [2:0]		s_axi_arsize;		// From emaxi of emaxi.v
   wire			s_axi_arvalid;		// From emaxi of emaxi.v
   wire [31:0]		s_axi_awaddr;		// From emaxi of emaxi.v
   wire [1:0]		s_axi_awburst;		// From emaxi of emaxi.v
   wire [3:0]		s_axi_awcache;		// From emaxi of emaxi.v
   wire [M_IDW-1:0]	s_axi_awid;		// From emaxi of emaxi.v
   wire [7:0]		s_axi_awlen;		// From emaxi of emaxi.v
   wire			s_axi_awlock;		// From emaxi of emaxi.v
   wire [2:0]		s_axi_awprot;		// From emaxi of emaxi.v
   wire [3:0]		s_axi_awqos;		// From emaxi of emaxi.v
   wire			s_axi_awready;		// From axi_accelerator of axi_accelerator.v
   wire [2:0]		s_axi_awsize;		// From emaxi of emaxi.v
   wire			s_axi_awvalid;		// From emaxi of emaxi.v
   wire [S_IDW-1:0]	s_axi_bid;		// From axi_accelerator of axi_accelerator.v
   wire			s_axi_bready;		// From emaxi of emaxi.v
   wire [1:0]		s_axi_bresp;		// From axi_accelerator of axi_accelerator.v
   wire			s_axi_bvalid;		// From axi_accelerator of axi_accelerator.v
   wire [31:0]		s_axi_rdata;		// From axi_accelerator of axi_accelerator.v
   wire [S_IDW-1:0]	s_axi_rid;		// From axi_accelerator of axi_accelerator.v
   wire			s_axi_rlast;		// From axi_accelerator of axi_accelerator.v
   wire			s_axi_rready;		// From emaxi of emaxi.v
   wire [1:0]		s_axi_rresp;		// From axi_accelerator of axi_accelerator.v
   wire			s_axi_rvalid;		// From axi_accelerator of axi_accelerator.v
   wire [63:0]		s_axi_wdata;		// From emaxi of emaxi.v
   wire [M_IDW-1:0]	s_axi_wid;		// From emaxi of emaxi.v
   wire			s_axi_wlast;		// From emaxi of emaxi.v
   wire			s_axi_wready;		// From axi_accelerator of axi_accelerator.v
   wire [7:0]		s_axi_wstrb;		// From emaxi of emaxi.v
   wire			s_axi_wvalid;		// From emaxi of emaxi.v
   // End of automatics
      
   assign clkout     = clk1;   
   assign dut_active = 1'b1;

   //######################################################################
   //ACCELERATOR
   //######################################################################
   
   axi_accelerator 
   axi_accelerator (.sys_nreset		(nreset),
		    .sys_clk		(clk1),
		    .m_axi_aresetn	(nreset),
		    .s_axi_aresetn	(nreset),
		    .s_axi_wstrb	(s_axi_wstrb[7:4] | s_axi_wstrb[3:0]),
		    /*AUTOINST*/
		    // Outputs
		    .irq		(irq),
		    .m_axi_awid		(m_axi_awid[M_IDW-1:0]),
		    .m_axi_awaddr	(m_axi_awaddr[31:0]),
		    .m_axi_awlen	(m_axi_awlen[7:0]),
		    .m_axi_awsize	(m_axi_awsize[2:0]),
		    .m_axi_awburst	(m_axi_awburst[1:0]),
		    .m_axi_awlock	(m_axi_awlock),
		    .m_axi_awcache	(m_axi_awcache[3:0]),
		    .m_axi_awprot	(m_axi_awprot[2:0]),
		    .m_axi_awqos	(m_axi_awqos[3:0]),
		    .m_axi_awvalid	(m_axi_awvalid),
		    .m_axi_wid		(m_axi_wid[M_IDW-1:0]),
		    .m_axi_wdata	(m_axi_wdata[63:0]),
		    .m_axi_wstrb	(m_axi_wstrb[7:0]),
		    .m_axi_wlast	(m_axi_wlast),
		    .m_axi_wvalid	(m_axi_wvalid),
		    .m_axi_bready	(m_axi_bready),
		    .m_axi_arid		(m_axi_arid[M_IDW-1:0]),
		    .m_axi_araddr	(m_axi_araddr[31:0]),
		    .m_axi_arlen	(m_axi_arlen[7:0]),
		    .m_axi_arsize	(m_axi_arsize[2:0]),
		    .m_axi_arburst	(m_axi_arburst[1:0]),
		    .m_axi_arlock	(m_axi_arlock),
		    .m_axi_arcache	(m_axi_arcache[3:0]),
		    .m_axi_arprot	(m_axi_arprot[2:0]),
		    .m_axi_arqos	(m_axi_arqos[3:0]),
		    .m_axi_arvalid	(m_axi_arvalid),
		    .m_axi_rready	(m_axi_rready),
		    .s_axi_arready	(s_axi_arready),
		    .s_axi_awready	(s_axi_awready),
		    .s_axi_bid		(s_axi_bid[S_IDW-1:0]),
		    .s_axi_bresp	(s_axi_bresp[1:0]),
		    .s_axi_bvalid	(s_axi_bvalid),
		    .s_axi_rid		(s_axi_rid[S_IDW-1:0]),
		    .s_axi_rdata	(s_axi_rdata[31:0]),
		    .s_axi_rlast	(s_axi_rlast),
		    .s_axi_rresp	(s_axi_rresp[1:0]),
		    .s_axi_rvalid	(s_axi_rvalid),
		    .s_axi_wready	(s_axi_wready),
		    // Inputs
		    .m_axi_awready	(m_axi_awready),
		    .m_axi_wready	(m_axi_wready),
		    .m_axi_bid		(m_axi_bid[M_IDW-1:0]),
		    .m_axi_bresp	(m_axi_bresp[1:0]),
		    .m_axi_bvalid	(m_axi_bvalid),
		    .m_axi_arready	(m_axi_arready),
		    .m_axi_rid		(m_axi_rid[M_IDW-1:0]),
		    .m_axi_rdata	(m_axi_rdata[63:0]),
		    .m_axi_rresp	(m_axi_rresp[1:0]),
		    .m_axi_rlast	(m_axi_rlast),
		    .m_axi_rvalid	(m_axi_rvalid),
		    .s_axi_arid		(s_axi_arid[S_IDW-1:0]),
		    .s_axi_araddr	(s_axi_araddr[31:0]),
		    .s_axi_arburst	(s_axi_arburst[1:0]),
		    .s_axi_arcache	(s_axi_arcache[3:0]),
		    .s_axi_arlock	(s_axi_arlock),
		    .s_axi_arlen	(s_axi_arlen[7:0]),
		    .s_axi_arprot	(s_axi_arprot[2:0]),
		    .s_axi_arqos	(s_axi_arqos[3:0]),
		    .s_axi_arsize	(s_axi_arsize[2:0]),
		    .s_axi_arvalid	(s_axi_arvalid),
		    .s_axi_awid		(s_axi_awid[S_IDW-1:0]),
		    .s_axi_awaddr	(s_axi_awaddr[31:0]),
		    .s_axi_awburst	(s_axi_awburst[1:0]),
		    .s_axi_awcache	(s_axi_awcache[3:0]),
		    .s_axi_awlock	(s_axi_awlock),
		    .s_axi_awlen	(s_axi_awlen[7:0]),
		    .s_axi_awprot	(s_axi_awprot[2:0]),
		    .s_axi_awqos	(s_axi_awqos[3:0]),
		    .s_axi_awsize	(s_axi_awsize[2:0]),
		    .s_axi_awvalid	(s_axi_awvalid),
		    .s_axi_bready	(s_axi_bready),
		    .s_axi_rready	(s_axi_rready),
		    .s_axi_wid		(s_axi_wid[S_IDW-1:0]),
		    .s_axi_wdata	(s_axi_wdata[31:0]),
		    .s_axi_wlast	(s_axi_wlast),
		    .s_axi_wvalid	(s_axi_wvalid));

   //######################################################################
   //AXI MASTER
   //######################################################################

   //Split stimulus to read/write
   assign wait_out = wr_wait | rd_wait;
   assign write_in = access_in & packet_in[0];
   assign read_in  = access_in & ~packet_in[0];

   /*emaxi AUTO_TEMPLATE (.m_\(.*\) (s_\1[]),
        );
     */
   
   emaxi #(.M_IDW(M_IDW))
   emaxi (.m_axi_aclk		(clk1),
	  .m_axi_aresetn	(nreset),
	  .m_axi_rdata		({s_axi_rdata[31:0],s_axi_rdata[31:0]}),
	  .rr_wait		(wait_in),	  
	  .rr_access		(access_out),
	  .rr_packet		(packet_out[PW-1:0]),
	  .wr_wait		(wr_wait),
	  .wr_access		(write_in),
	  .wr_packet		(packet_in[PW-1:0]),
	  .rd_wait		(rd_wait),
	  .rd_access		(read_in),
	  .rd_packet		(packet_in[PW-1:0]),	  
	  /*AUTOINST*/
	  // Outputs
	  .m_axi_awid			(s_axi_awid[M_IDW-1:0]), // Templated
	  .m_axi_awaddr			(s_axi_awaddr[31:0]),	 // Templated
	  .m_axi_awlen			(s_axi_awlen[7:0]),	 // Templated
	  .m_axi_awsize			(s_axi_awsize[2:0]),	 // Templated
	  .m_axi_awburst		(s_axi_awburst[1:0]),	 // Templated
	  .m_axi_awlock			(s_axi_awlock),		 // Templated
	  .m_axi_awcache		(s_axi_awcache[3:0]),	 // Templated
	  .m_axi_awprot			(s_axi_awprot[2:0]),	 // Templated
	  .m_axi_awqos			(s_axi_awqos[3:0]),	 // Templated
	  .m_axi_awvalid		(s_axi_awvalid),	 // Templated
	  .m_axi_wid			(s_axi_wid[M_IDW-1:0]),	 // Templated
	  .m_axi_wdata			(s_axi_wdata[63:0]),	 // Templated
	  .m_axi_wstrb			(s_axi_wstrb[7:0]),	 // Templated
	  .m_axi_wlast			(s_axi_wlast),		 // Templated
	  .m_axi_wvalid			(s_axi_wvalid),		 // Templated
	  .m_axi_bready			(s_axi_bready),		 // Templated
	  .m_axi_arid			(s_axi_arid[M_IDW-1:0]), // Templated
	  .m_axi_araddr			(s_axi_araddr[31:0]),	 // Templated
	  .m_axi_arlen			(s_axi_arlen[7:0]),	 // Templated
	  .m_axi_arsize			(s_axi_arsize[2:0]),	 // Templated
	  .m_axi_arburst		(s_axi_arburst[1:0]),	 // Templated
	  .m_axi_arlock			(s_axi_arlock),		 // Templated
	  .m_axi_arcache		(s_axi_arcache[3:0]),	 // Templated
	  .m_axi_arprot			(s_axi_arprot[2:0]),	 // Templated
	  .m_axi_arqos			(s_axi_arqos[3:0]),	 // Templated
	  .m_axi_arvalid		(s_axi_arvalid),	 // Templated
	  .m_axi_rready			(s_axi_rready),		 // Templated
	  // Inputs
	  .m_axi_awready		(s_axi_awready),	 // Templated
	  .m_axi_wready			(s_axi_wready),		 // Templated
	  .m_axi_bid			(s_axi_bid[M_IDW-1:0]),	 // Templated
	  .m_axi_bresp			(s_axi_bresp[1:0]),	 // Templated
	  .m_axi_bvalid			(s_axi_bvalid),		 // Templated
	  .m_axi_arready		(s_axi_arready),	 // Templated
	  .m_axi_rid			(s_axi_rid[M_IDW-1:0]),	 // Templated
	  .m_axi_rresp			(s_axi_rresp[1:0]),	 // Templated
	  .m_axi_rlast			(s_axi_rlast),		 // Templated
	  .m_axi_rvalid			(s_axi_rvalid));		 // Templated
   
  

 
   

   //Tie off master output for now
   /*axislave_stub AUTO_TEMPLATE (.s_\(.*\) (m_\1[]),
        );
    */

   axislave_stub m_stub (.s_axi_aclk		(clk1),
			 .s_axi_aresetn		(nreset),
			 /*AUTOINST*/
			 // Outputs
			 .s_axi_arready		(m_axi_arready), // Templated
			 .s_axi_awready		(m_axi_awready), // Templated
			 .s_axi_bid		(m_axi_bid[S_IDW-1:0]), // Templated
			 .s_axi_bresp		(m_axi_bresp[1:0]), // Templated
			 .s_axi_bvalid		(m_axi_bvalid),	 // Templated
			 .s_axi_rid		(m_axi_rid[S_IDW-1:0]), // Templated
			 .s_axi_rdata		(m_axi_rdata[31:0]), // Templated
			 .s_axi_rlast		(m_axi_rlast),	 // Templated
			 .s_axi_rresp		(m_axi_rresp[1:0]), // Templated
			 .s_axi_rvalid		(m_axi_rvalid),	 // Templated
			 .s_axi_wready		(m_axi_wready),	 // Templated
			 // Inputs
			 .s_axi_arid		(m_axi_arid[S_IDW-1:0]), // Templated
			 .s_axi_araddr		(m_axi_araddr[31:0]), // Templated
			 .s_axi_arburst		(m_axi_arburst[1:0]), // Templated
			 .s_axi_arcache		(m_axi_arcache[3:0]), // Templated
			 .s_axi_arlock		(m_axi_arlock),	 // Templated
			 .s_axi_arlen		(m_axi_arlen[7:0]), // Templated
			 .s_axi_arprot		(m_axi_arprot[2:0]), // Templated
			 .s_axi_arqos		(m_axi_arqos[3:0]), // Templated
			 .s_axi_arsize		(m_axi_arsize[2:0]), // Templated
			 .s_axi_arvalid		(m_axi_arvalid), // Templated
			 .s_axi_awid		(m_axi_awid[S_IDW-1:0]), // Templated
			 .s_axi_awaddr		(m_axi_awaddr[31:0]), // Templated
			 .s_axi_awburst		(m_axi_awburst[1:0]), // Templated
			 .s_axi_awcache		(m_axi_awcache[3:0]), // Templated
			 .s_axi_awlock		(m_axi_awlock),	 // Templated
			 .s_axi_awlen		(m_axi_awlen[7:0]), // Templated
			 .s_axi_awprot		(m_axi_awprot[2:0]), // Templated
			 .s_axi_awqos		(m_axi_awqos[3:0]), // Templated
			 .s_axi_awsize		(m_axi_awsize[2:0]), // Templated
			 .s_axi_awvalid		(m_axi_awvalid), // Templated
			 .s_axi_bready		(m_axi_bready),	 // Templated
			 .s_axi_rready		(m_axi_rready),	 // Templated
			 .s_axi_wid		(m_axi_wid[S_IDW-1:0]), // Templated
			 .s_axi_wdata		(m_axi_wdata[31:0]), // Templated
			 .s_axi_wlast		(m_axi_wlast),	 // Templated
			 .s_axi_wstrb		(m_axi_wstrb[3:0]), // Templated
			 .s_axi_wvalid		(m_axi_wvalid));	 // Templated

endmodule
// Local Variables:
// verilog-library-directories:("." "../hdl" "../../emesh/dv" "../../axi/dv" "../../emesh/hdl" "../../memory/hdl" "../../axi/hdl")
// End:

//////////////////////////////////////////////////////////////////////////////
// The MIT License (MIT)                                                    //
//                                                                          //
// Copyright (c) 2015-2016, Adapteva, Inc.                                  //
//                                                                          //
// Permission is hereby granted, free of charge, to any person obtaining a  //
// copy of this software and associated documentation files (the "Software")//
// to deal in the Software without restriction, including without limitation// 
// the rights to use, copy, modify, merge, publish, distribute, sublicense, //
// and/or sell copies of the Software, and to permit persons to whom the    //
// Software is furnished to do so, subject to the following conditions:     //
//                                                                          //
// The above copyright notice and this permission notice shall be included  // 
// in all copies or substantial portions of the Software.                   //
//                                                                          //
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS  //
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF               //
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.   //
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY     //
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT//
// OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR //
// THE USE OR OTHER DEALINGS IN THE SOFTWARE.                               //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
