//########################################################
// ACCELERATOR + AXI_SLAVE + AXI_MASTER
//########################################################
module axi_accelerator(/*AUTOARG*/
   // Outputs
   irq, m_axi_awid, m_axi_awaddr, m_axi_awlen, m_axi_awsize,
   m_axi_awburst, m_axi_awlock, m_axi_awcache, m_axi_awprot,
   m_axi_awqos, m_axi_awvalid, m_axi_wid, m_axi_wdata, m_axi_wstrb,
   m_axi_wlast, m_axi_wvalid, m_axi_bready, m_axi_arid, m_axi_araddr,
   m_axi_arlen, m_axi_arsize, m_axi_arburst, m_axi_arlock,
   m_axi_arcache, m_axi_arprot, m_axi_arqos, m_axi_arvalid,
   m_axi_rready, s_axi_arready, s_axi_awready, s_axi_bid, s_axi_bresp,
   s_axi_bvalid, s_axi_rid, s_axi_rdata, s_axi_rlast, s_axi_rresp,
   s_axi_rvalid, s_axi_wready,
   // Inputs
   sys_nreset, sys_clk, m_axi_aresetn, m_axi_awready, m_axi_wready,
   m_axi_bid, m_axi_bresp, m_axi_bvalid, m_axi_arready, m_axi_rid,
   m_axi_rdata, m_axi_rresp, m_axi_rlast, m_axi_rvalid, s_axi_aresetn,
   s_axi_arid, s_axi_araddr, s_axi_arburst, s_axi_arcache,
   s_axi_arlock, s_axi_arlen, s_axi_arprot, s_axi_arqos, s_axi_arsize,
   s_axi_arvalid, s_axi_awid, s_axi_awaddr, s_axi_awburst,
   s_axi_awcache, s_axi_awlock, s_axi_awlen, s_axi_awprot,
   s_axi_awqos, s_axi_awsize, s_axi_awvalid, s_axi_bready,
   s_axi_rready, s_axi_wid, s_axi_wdata, s_axi_wlast, s_axi_wstrb,
   s_axi_wvalid
   );
   
   //########################################################
   // INTERFACE
   //########################################################
   parameter AW          = 32;               // address width
   parameter PW          = 2*AW+40;          // packet width   
   parameter ID          = 12'h810;          // addr[31:20] id
   parameter S_IDW       = 12;               // ID width for S_AXI
   parameter M_IDW       = 6;                // ID width for M_AXI   
   
   //clk, reset
   input        sys_nreset;                  // active low async reset
   input 	sys_clk;                     // system clock for AXI
    
   //Interrupt
   output 	irq;                         // accelerator interrupt

   //AXI master   
   input 	      m_axi_aresetn; // global reset singal.
   output [M_IDW-1:0] m_axi_awid;    // write address ID
   output [31 : 0]    m_axi_awaddr;  // master interface write address   
   output [7 : 0]     m_axi_awlen;   // burst length.
   output [2 : 0]     m_axi_awsize;  // burst size.
   output [1 : 0]     m_axi_awburst; // burst type.
   output 	      m_axi_awlock;  // lock type   
   output [3 : 0]     m_axi_awcache; // memory type.
   output [2 : 0]     m_axi_awprot;  // protection type.
   output [3 : 0]     m_axi_awqos;   // quality of service
   output 	      m_axi_awvalid; // write address valid
   input 	      m_axi_awready; // write address ready
   output [M_IDW-1:0] m_axi_wid;     
   output [63 : 0]    m_axi_wdata;   // master interface write data.
   output [7 : 0]     m_axi_wstrb;   // byte write strobes
   output 	      m_axi_wlast;   // last transfer in a write burst.
   output 	      m_axi_wvalid;  // indicates data is ready to go
   input 	      m_axi_wready;  // slave is ready for data
   input [M_IDW-1:0]  m_axi_bid;
   input [1 : 0]      m_axi_bresp;   // status of the write transaction.
   input 	      m_axi_bvalid;  // valid write response
   output 	      m_axi_bready;  // master can accept write response.
   output [M_IDW-1:0] m_axi_arid;    // read address ID
   output [31 : 0]    m_axi_araddr;  // initial address of a read burst
   output [7 : 0]     m_axi_arlen;   // burst length
   output [2 : 0]     m_axi_arsize;  // burst size
   output [1 : 0]     m_axi_arburst; // burst type
   output 	      m_axi_arlock;  // lock type   
   output [3 : 0]     m_axi_arcache; // memory type
   output [2 : 0]     m_axi_arprot;  // protection type
   output [3 : 0]     m_axi_arqos;   // --
   output 	      m_axi_arvalid; // read address and control is valid
   input 	      m_axi_arready; // slave is ready to accept an address  
   input [M_IDW-1:0]  m_axi_rid; 
   input [63 : 0]     m_axi_rdata;   // master read data
   input [1 : 0]      m_axi_rresp;   // status of the read transfer
   input 	      m_axi_rlast;   // signals last transfer in a read burst
   input 	      m_axi_rvalid;  // signaling the required read data
   output 	      m_axi_rready;  // master can accept the readback data
      
   //AXI slave
   input 	      s_axi_aresetn;
   input [S_IDW-1:0]  s_axi_arid;    //write address ID
   input [31:0]       s_axi_araddr;
   input [1:0] 	      s_axi_arburst;
   input [3:0] 	      s_axi_arcache;
   input  	      s_axi_arlock;
   input [7:0] 	      s_axi_arlen;
   input [2:0] 	      s_axi_arprot;
   input [3:0] 	      s_axi_arqos;
   output 	      s_axi_arready;
   input [2:0] 	      s_axi_arsize;
   input 	      s_axi_arvalid;
   input [S_IDW-1:0]  s_axi_awid;    //write address ID
   input [31:0]       s_axi_awaddr;
   input [1:0] 	      s_axi_awburst;
   input [3:0] 	      s_axi_awcache;
   input      s_axi_awlock;
   input [7:0] 	      s_axi_awlen;
   input [2:0] 	      s_axi_awprot;
   input [3:0] 	      s_axi_awqos;   
   input [2:0] 	      s_axi_awsize;
   input 	      s_axi_awvalid;
   output 	      s_axi_awready;
   output [S_IDW-1:0] s_axi_bid;    //write address ID
   output [1:0]       s_axi_bresp;
   output 	      s_axi_bvalid;
   input 	      s_axi_bready;
   output [S_IDW-1:0] s_axi_rid;    //write address ID
   output [31:0]      s_axi_rdata;
   output 	      s_axi_rlast;   
   output [1:0]       s_axi_rresp;
   output 	      s_axi_rvalid;
   input 	      s_axi_rready;
   input [S_IDW-1:0]  s_axi_wid;    //write address ID
   input [31:0]       s_axi_wdata;
   input 	      s_axi_wlast;   
   input [3:0] 	      s_axi_wstrb;
   input 	      s_axi_wvalid;
   output 	      s_axi_wready;
   
   //########################################################
   // BODY
   //########################################################
   
   /*AUTOINPUT*/
   /*AUTOOUTPUT*/  
   // End of automatics

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			m_rd_access;		// From accelerator of accelerator.v
   wire [PW-1:0]	m_rd_packet;		// From accelerator of accelerator.v
   wire			m_rd_wait;		// From emaxi of emaxi.v
   wire			m_rr_access;		// From emaxi of emaxi.v
   wire [PW-1:0]	m_rr_packet;		// From emaxi of emaxi.v
   wire			m_rr_wait;		// From accelerator of accelerator.v
   wire			m_wr_access;		// From accelerator of accelerator.v
   wire [PW-1:0]	m_wr_packet;		// From accelerator of accelerator.v
   wire			m_wr_wait;		// From emaxi of emaxi.v
   wire			s_rd_access;		// From esaxi of esaxi.v
   wire [PW-1:0]	s_rd_packet;		// From esaxi of esaxi.v
   wire			s_rd_wait;		// From accelerator of accelerator.v
   wire			s_rr_access;		// From accelerator of accelerator.v
   wire [PW-1:0]	s_rr_packet;		// From accelerator of accelerator.v
   wire			s_rr_wait;		// From esaxi of esaxi.v
   wire			s_wr_access;		// From esaxi of esaxi.v
   wire [PW-1:0]	s_wr_packet;		// From esaxi of esaxi.v
   wire			s_wr_wait;		// From accelerator of accelerator.v
   // End of automatics
   accelerator accelerator (.clk		(sys_clk),
			    .nreset		(sys_nreset),
			    /*AUTOINST*/
			    // Outputs
			    .m_wr_access	(m_wr_access),
			    .m_wr_packet	(m_wr_packet[PW-1:0]),
			    .m_rd_access	(m_rd_access),
			    .m_rd_packet	(m_rd_packet[PW-1:0]),
			    .m_rr_wait		(m_rr_wait),
			    .s_wr_wait		(s_wr_wait),
			    .s_rd_wait		(s_rd_wait),
			    .s_rr_access	(s_rr_access),
			    .s_rr_packet	(s_rr_packet[PW-1:0]),
			    // Inputs
			    .m_wr_wait		(m_wr_wait),
			    .m_rd_wait		(m_rd_wait),
			    .m_rr_access	(m_rr_access),
			    .m_rr_packet	(m_rr_packet[PW-1:0]),
			    .s_wr_access	(s_wr_access),
			    .s_wr_packet	(s_wr_packet[PW-1:0]),
			    .s_rd_access	(s_rd_access),
			    .s_rd_packet	(s_rd_packet[PW-1:0]),
			    .s_rr_wait		(s_rr_wait));
   

   //########################################################
   //AXI SLAVE
   //########################################################
   /*esaxi AUTO_TEMPLATE (//Stimulus
                         .rr_\(.*\)   (s_rr_\1[]),  
                         .rd_\(.*\)   (s_rd_\1[]),
                         .wr_\(.*\)   (s_wr_\1[]),
        );
     */

   esaxi #(.S_IDW(S_IDW))
   esaxi (.s_axi_aclk		(sys_clk),
		/*AUTOINST*/
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
   //AXI MASTER INTERFACE
   //########################################################
   /*emaxi AUTO_TEMPLATE (//Stimulus
                         .rr_\(.*\)   (m_rr_\1[]),  
                         .rd_\(.*\)   (m_rd_\1[]),
                         .wr_\(.*\)   (m_wr_\1[]),
        );
    */
   emaxi #(.M_IDW(M_IDW))     
   emaxi (.m_axi_aclk		       (sys_clk),
	  /*AUTOINST*/
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
	  .wr_packet			(m_wr_packet[PW-1:0]),	 // Templated
	  .rd_access			(m_rd_access),		 // Templated
	  .rd_packet			(m_rd_packet[PW-1:0]),	 // Templated
	  .rr_wait			(m_rr_wait),		 // Templated
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

      
endmodule // elink
// Local Variables:
// verilog-library-directories:("." "../../axi/hdl")
// End:

