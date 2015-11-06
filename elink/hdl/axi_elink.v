module axi_elink(/*AUTOARG*/
   // Outputs
   timeout, elink_active, rxo_wr_wait_p, rxo_wr_wait_n, rxo_rd_wait_p,
   rxo_rd_wait_n, txo_lclk_p, txo_lclk_n, txo_frame_p, txo_frame_n,
   txo_data_p, txo_data_n, chipid, chip_resetb, cclk_p, cclk_n,
   mailbox_not_empty, mailbox_full, m_axi_awid, m_axi_awaddr,
   m_axi_awlen, m_axi_awsize, m_axi_awburst, m_axi_awlock,
   m_axi_awcache, m_axi_awprot, m_axi_awqos, m_axi_awvalid, m_axi_wid,
   m_axi_wdata, m_axi_wstrb, m_axi_wlast, m_axi_wvalid, m_axi_bready,
   m_axi_arid, m_axi_araddr, m_axi_arlen, m_axi_arsize, m_axi_arburst,
   m_axi_arlock, m_axi_arcache, m_axi_arprot, m_axi_arqos,
   m_axi_arvalid, m_axi_rready, s_axi_arready, s_axi_awready,
   s_axi_bid, s_axi_bresp, s_axi_bvalid, s_axi_rid, s_axi_rdata,
   s_axi_rlast, s_axi_rresp, s_axi_rvalid, s_axi_wready,
   // Inputs
   reset, sys_clk, rxi_lclk_p, rxi_lclk_n, rxi_frame_p, rxi_frame_n,
   rxi_data_p, rxi_data_n, txi_wr_wait_p, txi_wr_wait_n,
   txi_rd_wait_p, txi_rd_wait_n, m_axi_aresetn, m_axi_awready,
   m_axi_wready, m_axi_bid, m_axi_bresp, m_axi_bvalid, m_axi_arready,
   m_axi_rid, m_axi_rdata, m_axi_rresp, m_axi_rlast, m_axi_rvalid,
   s_axi_aresetn, s_axi_arid, s_axi_araddr, s_axi_arburst,
   s_axi_arcache, s_axi_arlock, s_axi_arlen, s_axi_arprot,
   s_axi_arqos, s_axi_arsize, s_axi_arvalid, s_axi_awid, s_axi_awaddr,
   s_axi_awburst, s_axi_awcache, s_axi_awlock, s_axi_awlen,
   s_axi_awprot, s_axi_awqos, s_axi_awsize, s_axi_awvalid,
   s_axi_bready, s_axi_rready, s_axi_wid, s_axi_wdata, s_axi_wlast,
   s_axi_wstrb, s_axi_wvalid
   );
   
   parameter AW          = 32;
   parameter DW          = 32; 
   parameter PW          = 104;      //packet width   
   parameter ID          = 12'h810;
   parameter S_IDW       = 12;       //ID width for S_AXI
   parameter M_IDW       = 6;        //ID width for M_AXI
   parameter IOSTD_ELINK = "LVDS_25";
   parameter ETYPE       = 1;
   
   /****************************/
   /*CLK AND RESET             */
   /****************************/
   input        reset;            // active high async reset
   input 	sys_clk;          // system clock for AXI
   output 	elink_active;     // link is active and ready
   
   /********************************/
   /*ELINK I/O PINS                */
   /********************************/          
   //Receiver
   input        rxi_lclk_p,   rxi_lclk_n;    //link rx clock input
   input        rxi_frame_p,  rxi_frame_n;   //link rx frame signal
   input [7:0] 	rxi_data_p,   rxi_data_n;    //link rx data
   output       rxo_wr_wait_p,rxo_wr_wait_n; //link rx write pushback output
   output       rxo_rd_wait_p,rxo_rd_wait_n; //link rx read pushback output
   
   //Transmitter
   output       txo_lclk_p,   txo_lclk_n;    //link tx clock output
   output       txo_frame_p,  txo_frame_n;   //link tx frame signal
   output [7:0] txo_data_p,   txo_data_n;    //link tx data
   input 	txi_wr_wait_p,txi_wr_wait_n; //link tx write pushback input
   input 	txi_rd_wait_p,txi_rd_wait_n; //link tx read pushback input

   /********************************/
   /*EPIPHANY INTERFACE (I/O PINS) */
   /********************************/          
   output [11:0] chipid;	            //chip id strap pins for Epiphany
   output 	 chip_resetb;               //chip reset for Epiphany (active low)
   output 	 cclk_p,cclk_n;             //high speed clock (up to 1GHz) to Epiphany
   
   /*****************************/
   /*MAILBOX (interrupts)       */
   /*****************************/
   output        mailbox_not_empty;   
   output        mailbox_full;

   //########################
   //AXI MASTER INTERFACE
   //########################
   input  	      m_axi_aresetn; // global reset singal.

   //Write address channel
   output [M_IDW-1:0] m_axi_awid;    // write address ID
   output [31 : 0]    m_axi_awaddr;  // master interface write address   
   output [7 : 0]     m_axi_awlen;   // burst length.
   output [2 : 0]     m_axi_awsize;  // burst size.
   output [1 : 0]     m_axi_awburst; // burst type.
   output [1 : 0]     m_axi_awlock;  // lock type   
   output [3 : 0]     m_axi_awcache; // memory type.
   output [2 : 0]     m_axi_awprot;  // protection type.
   output [3 : 0]     m_axi_awqos;   // quality of service
   output 	      m_axi_awvalid; // write address valid
   input 	      m_axi_awready; // write address ready
   
   //Write data channel
   output [M_IDW-1:0] m_axi_wid;     
   output [63 : 0]    m_axi_wdata;   // master interface write data.
   output [7 : 0]     m_axi_wstrb;   // byte write strobes
   output 	      m_axi_wlast;   // last transfer in a write burst.
   output 	      m_axi_wvalid;  // indicates data is ready to go
   input 	      m_axi_wready;  // slave is ready for data

   //Write response channel
   input [M_IDW-1:0]  m_axi_bid;
   input [1 : 0]      m_axi_bresp;   // status of the write transaction.
   input 	      m_axi_bvalid;  // valid write response
   output 	      m_axi_bready;  // master can accept write response.
   
   //Read address channel
   output [M_IDW-1:0] m_axi_arid;    // read address ID
   output [31 : 0]    m_axi_araddr;  // initial address of a read burst
   output [7 : 0]     m_axi_arlen;   // burst length
   output [2 : 0]     m_axi_arsize;  // burst size
   output [1 : 0]     m_axi_arburst; // burst type
   output [1 : 0]     m_axi_arlock;  // lock type   
   output [3 : 0]     m_axi_arcache; // memory type
   output [2 : 0]     m_axi_arprot;  // protection type
   output [3 : 0]     m_axi_arqos;   // --
   output 	      m_axi_arvalid; // read address and control is valid
   input 	      m_axi_arready; // slave is ready to accept an address
   
   //Read data channel   
   input [M_IDW-1:0]  m_axi_rid; 
   input [63 : 0]     m_axi_rdata;   // master read data
   input [1 : 0]      m_axi_rresp;   // status of the read transfer
   input 	      m_axi_rlast;   // signals last transfer in a read burst
   input 	      m_axi_rvalid;  // signaling the required read data
   output 	      m_axi_rready;  // master can accept the readback data
   
   /*****************************/
   /*AXI slave interface        */
   /*****************************/  
   //Clock and reset
   input 	      s_axi_aresetn;
   
   //Read address channel
   input [S_IDW-1:0]  s_axi_arid;    //write address ID
   input [31:0]       s_axi_araddr;
   input [1:0] 	      s_axi_arburst;
   input [3:0] 	      s_axi_arcache;
   input [1:0] 	      s_axi_arlock;
   input [7:0] 	      s_axi_arlen;
   input [2:0] 	      s_axi_arprot;
   input [3:0] 	      s_axi_arqos;
   output 	      s_axi_arready;
   input [2:0] 	      s_axi_arsize;
   input 	      s_axi_arvalid;
   
   //Write address channel
   input [S_IDW-1:0]  s_axi_awid;    //write address ID
   input [31:0]       s_axi_awaddr;
   input [1:0] 	      s_axi_awburst;
   input [3:0] 	      s_axi_awcache;
   input [1:0] 	      s_axi_awlock;
   input [7:0] 	      s_axi_awlen;
   input [2:0] 	      s_axi_awprot;
   input [3:0] 	      s_axi_awqos;   
   input [2:0] 	      s_axi_awsize;
   input 	      s_axi_awvalid;
   output 	      s_axi_awready;
   
   //Buffered write response channel
   output [S_IDW-1:0] s_axi_bid;    //write address ID
   output [1:0]       s_axi_bresp;
   output 	      s_axi_bvalid;
   input 	      s_axi_bready;
   
   //Read channel
   output [S_IDW-1:0] s_axi_rid;    //write address ID
   output [31:0]      s_axi_rdata;
   output 	      s_axi_rlast;   
   output [1:0]       s_axi_rresp;
   output 	      s_axi_rvalid;
   input 	      s_axi_rready;

   //Write channel
   input [S_IDW-1:0]  s_axi_wid;    //write address ID
   input [31:0]       s_axi_wdata;
   input 	      s_axi_wlast;   
   input [3:0] 	      s_axi_wstrb;
   input 	      s_axi_wvalid;
   output 	      s_axi_wready;
   
   /*#############################################*/
   /*  END OF BLOCK INTERFACE                     */
   /*#############################################*/
   
   /*AUTOINPUT*/
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output		timeout;		// From elink of elink.v
   // End of automatics
  
   // End of automatics

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			rxrd_access;		// From elink of elink.v
   wire [PW-1:0]	rxrd_packet;		// From elink of elink.v
   wire			rxrd_wait;		// From emaxi of emaxi.v
   wire			rxrr_access;		// From elink of elink.v
   wire [PW-1:0]	rxrr_packet;		// From elink of elink.v
   wire			rxrr_wait;		// From esaxi of esaxi.v
   wire			rxwr_access;		// From elink of elink.v
   wire [PW-1:0]	rxwr_packet;		// From elink of elink.v
   wire			rxwr_wait;		// From emaxi of emaxi.v
   wire			txrd_access;		// From esaxi of esaxi.v
   wire [PW-1:0]	txrd_packet;		// From esaxi of esaxi.v
   wire			txrd_wait;		// From elink of elink.v
   wire			txrr_access;		// From emaxi of emaxi.v
   wire [PW-1:0]	txrr_packet;		// From emaxi of emaxi.v
   wire			txrr_wait;		// From elink of elink.v
   wire			txwr_access;		// From esaxi of esaxi.v
   wire [PW-1:0]	txwr_packet;		// From esaxi of esaxi.v
   wire			txwr_wait;		// From elink of elink.v
   // End of automatics

     
   //########################################################
   //ELINK
   //########################################################
    
   defparam elink.IOSTD_ELINK = IOSTD_ELINK;
   defparam elink.ETYPE       = ETYPE;

   elink elink(.sys_reset		(reset),       //por reset needed for elink_en
	       /*AUTOINST*/
	       // Outputs
	       .elink_active		(elink_active),
	       .rxo_wr_wait_p		(rxo_wr_wait_p),
	       .rxo_wr_wait_n		(rxo_wr_wait_n),
	       .rxo_rd_wait_p		(rxo_rd_wait_p),
	       .rxo_rd_wait_n		(rxo_rd_wait_n),
	       .txo_lclk_p		(txo_lclk_p),
	       .txo_lclk_n		(txo_lclk_n),
	       .txo_frame_p		(txo_frame_p),
	       .txo_frame_n		(txo_frame_n),
	       .txo_data_p		(txo_data_p[7:0]),
	       .txo_data_n		(txo_data_n[7:0]),
	       .chipid			(chipid[11:0]),
	       .cclk_p			(cclk_p),
	       .cclk_n			(cclk_n),
	       .chip_resetb		(chip_resetb),
	       .mailbox_not_empty	(mailbox_not_empty),
	       .mailbox_full		(mailbox_full),
	       .timeout			(timeout),
	       .rxwr_access		(rxwr_access),
	       .rxwr_packet		(rxwr_packet[PW-1:0]),
	       .rxrd_access		(rxrd_access),
	       .rxrd_packet		(rxrd_packet[PW-1:0]),
	       .rxrr_access		(rxrr_access),
	       .rxrr_packet		(rxrr_packet[PW-1:0]),
	       .txwr_wait		(txwr_wait),
	       .txrd_wait		(txrd_wait),
	       .txrr_wait		(txrr_wait),
	       // Inputs
	       .sys_clk			(sys_clk),
	       .rxi_lclk_p		(rxi_lclk_p),
	       .rxi_lclk_n		(rxi_lclk_n),
	       .rxi_frame_p		(rxi_frame_p),
	       .rxi_frame_n		(rxi_frame_n),
	       .rxi_data_p		(rxi_data_p[7:0]),
	       .rxi_data_n		(rxi_data_n[7:0]),
	       .txi_wr_wait_p		(txi_wr_wait_p),
	       .txi_wr_wait_n		(txi_wr_wait_n),
	       .txi_rd_wait_p		(txi_rd_wait_p),
	       .txi_rd_wait_n		(txi_rd_wait_n),
	       .rxwr_wait		(rxwr_wait),
	       .rxrd_wait		(rxrd_wait),
	       .rxrr_wait		(rxrr_wait),
	       .txwr_access		(txwr_access),
	       .txwr_packet		(txwr_packet[PW-1:0]),
	       .txrd_access		(txrd_access),
	       .txrd_packet		(txrd_packet[PW-1:0]),
	       .txrr_access		(txrr_access),
	       .txrr_packet		(txrr_packet[PW-1:0]));

    
   //########################################################
   //AXI SLAVE
   //########################################################
   
   defparam esaxi.S_IDW=S_IDW;
   esaxi esaxi (.s_axi_aclk		(sys_clk),
		/*AUTOINST*/
		// Outputs
		.txwr_access		(txwr_access),
		.txwr_packet		(txwr_packet[PW-1:0]),
		.txrd_access		(txrd_access),
		.txrd_packet		(txrd_packet[PW-1:0]),
		.rxrr_wait		(rxrr_wait),
		.s_axi_arready		(s_axi_arready),
		.s_axi_awready		(s_axi_awready),
		.s_axi_bid		(s_axi_bid[S_IDW-1:0]),
		.s_axi_bresp		(s_axi_bresp[1:0]),
		.s_axi_bvalid		(s_axi_bvalid),
		.s_axi_rid		(s_axi_rid[S_IDW-1:0]),
		.s_axi_rdata		(s_axi_rdata[31:0]),
		.s_axi_rlast		(s_axi_rlast),
		.s_axi_rresp		(s_axi_rresp[1:0]),
		.s_axi_rvalid		(s_axi_rvalid),
		.s_axi_wready		(s_axi_wready),
		// Inputs
		.txwr_wait		(txwr_wait),
		.txrd_wait		(txrd_wait),
		.rxrr_access		(rxrr_access),
		.rxrr_packet		(rxrr_packet[PW-1:0]),
		.s_axi_aresetn		(s_axi_aresetn),
		.s_axi_arid		(s_axi_arid[S_IDW-1:0]),
		.s_axi_araddr		(s_axi_araddr[31:0]),
		.s_axi_arburst		(s_axi_arburst[1:0]),
		.s_axi_arcache		(s_axi_arcache[3:0]),
		.s_axi_arlock		(s_axi_arlock[1:0]),
		.s_axi_arlen		(s_axi_arlen[7:0]),
		.s_axi_arprot		(s_axi_arprot[2:0]),
		.s_axi_arqos		(s_axi_arqos[3:0]),
		.s_axi_arsize		(s_axi_arsize[2:0]),
		.s_axi_arvalid		(s_axi_arvalid),
		.s_axi_awid		(s_axi_awid[S_IDW-1:0]),
		.s_axi_awaddr		(s_axi_awaddr[31:0]),
		.s_axi_awburst		(s_axi_awburst[1:0]),
		.s_axi_awcache		(s_axi_awcache[3:0]),
		.s_axi_awlock		(s_axi_awlock[1:0]),
		.s_axi_awlen		(s_axi_awlen[7:0]),
		.s_axi_awprot		(s_axi_awprot[2:0]),
		.s_axi_awqos		(s_axi_awqos[3:0]),
		.s_axi_awsize		(s_axi_awsize[2:0]),
		.s_axi_awvalid		(s_axi_awvalid),
		.s_axi_bready		(s_axi_bready),
		.s_axi_rready		(s_axi_rready),
		.s_axi_wid		(s_axi_wid[S_IDW-1:0]),
		.s_axi_wdata		(s_axi_wdata[31:0]),
		.s_axi_wlast		(s_axi_wlast),
		.s_axi_wstrb		(s_axi_wstrb[3:0]),
		.s_axi_wvalid		(s_axi_wvalid));

   //########################################################
   //AXI MASTER INTERFACE
   //########################################################

   defparam emaxi.M_IDW=M_IDW;
   emaxi emaxi (.m_axi_aclk		(sys_clk),
		/*AUTOINST*/
		// Outputs
		.rxwr_wait		(rxwr_wait),
		.rxrd_wait		(rxrd_wait),
		.txrr_access		(txrr_access),
		.txrr_packet		(txrr_packet[PW-1:0]),
		.m_axi_awid		(m_axi_awid[M_IDW-1:0]),
		.m_axi_awaddr		(m_axi_awaddr[31:0]),
		.m_axi_awlen		(m_axi_awlen[7:0]),
		.m_axi_awsize		(m_axi_awsize[2:0]),
		.m_axi_awburst		(m_axi_awburst[1:0]),
		.m_axi_awlock		(m_axi_awlock[1:0]),
		.m_axi_awcache		(m_axi_awcache[3:0]),
		.m_axi_awprot		(m_axi_awprot[2:0]),
		.m_axi_awqos		(m_axi_awqos[3:0]),
		.m_axi_awvalid		(m_axi_awvalid),
		.m_axi_wid		(m_axi_wid[M_IDW-1:0]),
		.m_axi_wdata		(m_axi_wdata[63:0]),
		.m_axi_wstrb		(m_axi_wstrb[7:0]),
		.m_axi_wlast		(m_axi_wlast),
		.m_axi_wvalid		(m_axi_wvalid),
		.m_axi_bready		(m_axi_bready),
		.m_axi_arid		(m_axi_arid[M_IDW-1:0]),
		.m_axi_araddr		(m_axi_araddr[31:0]),
		.m_axi_arlen		(m_axi_arlen[7:0]),
		.m_axi_arsize		(m_axi_arsize[2:0]),
		.m_axi_arburst		(m_axi_arburst[1:0]),
		.m_axi_arlock		(m_axi_arlock[1:0]),
		.m_axi_arcache		(m_axi_arcache[3:0]),
		.m_axi_arprot		(m_axi_arprot[2:0]),
		.m_axi_arqos		(m_axi_arqos[3:0]),
		.m_axi_arvalid		(m_axi_arvalid),
		.m_axi_rready		(m_axi_rready),
		// Inputs
		.rxwr_access		(rxwr_access),
		.rxwr_packet		(rxwr_packet[PW-1:0]),
		.rxrd_access		(rxrd_access),
		.rxrd_packet		(rxrd_packet[PW-1:0]),
		.txrr_wait		(txrr_wait),
		.m_axi_aresetn		(m_axi_aresetn),
		.m_axi_awready		(m_axi_awready),
		.m_axi_wready		(m_axi_wready),
		.m_axi_bid		(m_axi_bid[M_IDW-1:0]),
		.m_axi_bresp		(m_axi_bresp[1:0]),
		.m_axi_bvalid		(m_axi_bvalid),
		.m_axi_arready		(m_axi_arready),
		.m_axi_rid		(m_axi_rid[M_IDW-1:0]),
		.m_axi_rdata		(m_axi_rdata[63:0]),
		.m_axi_rresp		(m_axi_rresp[1:0]),
		.m_axi_rlast		(m_axi_rlast),
		.m_axi_rvalid		(m_axi_rvalid));

      
endmodule // elink
// Local Variables:
// verilog-library-directories:("." "../../erx/hdl" "../../etx/hdl"  "../../memory/hdl")
// End:

