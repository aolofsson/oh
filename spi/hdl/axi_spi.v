//########################################################
// SPI + AXI_SLAVE + AXI_MASTER
//########################################################
`include "spi_regmap.v"
module axi_spi(/*AUTOARG*/
   // Outputs
   txwr_packet, txwr_access, txrr_packet, txrr_access, txrd_packet,
   txrd_access, s_ss, s_mosi, s_mclk, rxwr_wait, rxrr_wait, rxrd_wait,
   m_miso, ss_sel, m_axi_awid, m_axi_awaddr, m_axi_awlen,
   m_axi_awsize, m_axi_awburst, m_axi_awlock, m_axi_awcache,
   m_axi_awprot, m_axi_awqos, m_axi_awvalid, m_axi_wid, m_axi_wdata,
   m_axi_wstrb, m_axi_wlast, m_axi_wvalid, m_axi_bready, m_axi_arid,
   m_axi_araddr, m_axi_arlen, m_axi_arsize, m_axi_arburst,
   m_axi_arlock, m_axi_arcache, m_axi_arprot, m_axi_arqos,
   m_axi_arvalid, m_axi_rready, s_axi_arready, s_axi_awready,
   s_axi_bid, s_axi_bresp, s_axi_bvalid, s_axi_rid, s_axi_rdata,
   s_axi_rlast, s_axi_rresp, s_axi_rvalid, s_axi_wready,
   // Inouts
   miso, mosi, ss, sclk,
   // Inputs
   txwr_wait, txrr_wait, txrd_wait, s_miso, rxwr_packet, rxwr_access,
   rxrr_packet, rxrr_access, rxrd_packet, rxrd_access, m_ss,
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
   parameter N           = 1
   //clk, reset
   input          sys_nreset;        // active low async reset
   input 	  sys_clk;           // system clock for AXI

   //spi interface
   inout 	  miso;              // master input / slave output  
   inout 	  mosi;              // master output / slave input
   inout 	  ss;                // slave select (primary)
   inout 	  sclk;              // serial clock
   output [N-1:0] ss_sel;            // master driven slave selects
      	
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
   // Beginning of automatic inputs (from unused autoinst inputs)
   input [N-1:0]	m_ss;			// To spi of spi.v, ...
   input		rxrd_access;		// To emaxi of emaxi.v
   input [PW-1:0]	rxrd_packet;		// To emaxi of emaxi.v
   input		rxrr_access;		// To esaxi of esaxi.v
   input [PW-1:0]	rxrr_packet;		// To esaxi of esaxi.v
   input		rxwr_access;		// To emaxi of emaxi.v
   input [PW-1:0]	rxwr_packet;		// To emaxi of emaxi.v
   input		s_miso;			// To spi of spi.v, ...
   input		txrd_wait;		// To esaxi of esaxi.v
   input		txrr_wait;		// To emaxi of emaxi.v
   input		txwr_wait;		// To esaxi of esaxi.v
   // End of automatics
   /*AUTOOUTPUT*/  
   // Beginning of automatic outputs (from unused autoinst outputs)
   output		m_miso;			// From spi of spi.v, ...
   output		rxrd_wait;		// From emaxi of emaxi.v
   output		rxrr_wait;		// From esaxi of esaxi.v
   output		rxwr_wait;		// From emaxi of emaxi.v
   output		s_mclk;			// From spi of spi.v, ...
   output		s_mosi;			// From spi of spi.v, ...
   output		s_ss;			// From spi of spi.v, ...
   output		txrd_access;		// From esaxi of esaxi.v
   output [PW-1:0]	txrd_packet;		// From esaxi of esaxi.v
   output		txrr_access;		// From emaxi of emaxi.v
   output [PW-1:0]	txrr_packet;		// From emaxi of emaxi.v
   output		txwr_access;		// From esaxi of esaxi.v
   output [PW-1:0]	txwr_packet;		// From esaxi of esaxi.v
   // End of automatics
   // End of automatics

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			m_mclk;			// From spi of spi.v
   wire			m_mosi;			// From spi of spi.v
   // End of automatics

     
   //########################################################
   //SPI
   //########################################################

   //SPI Logic
   spi spi(/*AUTOINST*/
	   // Outputs
	   .m_mclk			(m_mclk),
	   .m_mosi			(m_mosi),
	   .m_miso			(m_miso),
	   .s_mclk			(s_mclk),
	   .s_mosi			(s_mosi),
	   .s_ss			(s_ss),
	   // Inputs
	   .m_ss			(m_ss[N-1:0]),
	   .s_miso			(s_miso));

   //IO cells
   spi_io spi_io (/*AUTOINST*/
		  // Outputs
		  .ss_sel		(ss_sel[N-2:0]),
		  .m_miso		(m_miso),
		  .s_mclk		(s_mclk),
		  .s_mosi		(s_mosi),
		  .s_ss			(s_ss),
		  // Inouts
		  .sclk			(sclk),
		  .mosi			(mosi),
		  .miso			(miso),
		  .ss			(ss),
		  // Inputs
		  .m_mclk		(m_mclk),
		  .m_mosi		(m_mosi),
		  .m_ss			(m_ss[N-1:0]),
		  .s_miso		(s_miso));
   
   
   //########################################################
   //AXI SLAVE
   //########################################################
   /*esaxi AUTO_TEMPLATE (//Stimulus
                         .rr_\(.*\)   (rxrr_\1[]),  
                         .rd_\(.*\)   (txrd_\1[]),
                         .wr_\(.*\)   (txwr_\1[]),
        );
     */

   esaxi #(.S_IDW(S_IDW),
	   .RETURN_ADDR(RETURN_ADDR))
   esaxi (.s_axi_aclk		(sys_clk),
		/*AUTOINST*/
	  // Outputs
	  .wr_access			(txwr_access),		 // Templated
	  .wr_packet			(txwr_packet[PW-1:0]),	 // Templated
	  .rd_access			(txrd_access),		 // Templated
	  .rd_packet			(txrd_packet[PW-1:0]),	 // Templated
	  .rr_wait			(rxrr_wait),		 // Templated
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
	  .wr_wait			(txwr_wait),		 // Templated
	  .rd_wait			(txrd_wait),		 // Templated
	  .rr_access			(rxrr_access),		 // Templated
	  .rr_packet			(rxrr_packet[PW-1:0]),	 // Templated
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
                         .rr_\(.*\)   (txrr_\1[]),  
                         .rd_\(.*\)   (rxrd_\1[]),
                         .wr_\(.*\)   (rxwr_\1[]),
        );
    */
   emaxi #(.M_IDW(M_IDW))     
   emaxi (.m_axi_aclk		       (sys_clk),
	  /*AUTOINST*/
	  // Outputs
	  .wr_wait			(rxwr_wait),		 // Templated
	  .rd_wait			(rxrd_wait),		 // Templated
	  .rr_access			(txrr_access),		 // Templated
	  .rr_packet			(txrr_packet[PW-1:0]),	 // Templated
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
	  .wr_access			(rxwr_access),		 // Templated
	  .wr_packet			(rxwr_packet[PW-1:0]),	 // Templated
	  .rd_access			(rxrd_access),		 // Templated
	  .rd_packet			(rxrd_packet[PW-1:0]),	 // Templated
	  .rr_wait			(txrr_wait),		 // Templated
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

