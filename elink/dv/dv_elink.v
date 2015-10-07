`define CFG_FAKECLK   1      /*stupid verilator doesn't get clock gating*/
`define CFG_MDW       32     /*Width of mesh network*/
`define CFG_DW        32     /*Width of datapath*/
`define CFG_AW        32     /*Width of address space*/
`define CFG_LW        8      /*Link port width*/

module dv_elink(/*AUTOARG*/
   // Outputs
   dut_passed, dut_failed, dut_rd_wait, dut_wr_wait, dut_access,
   dut_packet,
   // Inputs
   clk, reset, ext_access, ext_packet, ext_rd_wait, ext_wr_wait
   );

   parameter AW    = 32;
   parameter DW    = 32;
   parameter CW    = 2;             //number of clocks to send int
   parameter IDW   = 12;
   parameter M_IDW = 6;
   parameter S_IDW = 12;
   parameter PW    = 104;
   
   //Basic
   input           clk;        // system clock
   input           reset;      // Reset
   output          dut_passed; // Indicates passing test
   output          dut_failed; // Indicates failing test

   //Input Transaction
   input           ext_access;
   input [PW-1:0]  ext_packet; 
   output          dut_rd_wait;
   output          dut_wr_wait;

   //Output Transaction
   output          dut_access;
   output [PW-1:0] dut_packet; 
   input 	   ext_rd_wait;
   input 	   ext_wr_wait;

   /*AUTOINPUT*/
  
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [11:0]		chipid;			// From elink2 of axi_elink.v
   wire			elink0_cclk_n;		// From elink0 of elink.v
   wire			elink0_cclk_p;		// From elink0 of elink.v
   wire			elink0_chip_resetb;	// From elink0 of elink.v
   wire [11:0]		elink0_chipid;		// From elink0 of elink.v
   wire			elink0_mailbox_full;	// From elink0 of elink.v
   wire			elink0_mailbox_not_empty;// From elink0 of elink.v
   wire			elink0_rxo_rd_wait_n;	// From elink0 of elink.v
   wire			elink0_rxo_rd_wait_p;	// From elink0 of elink.v
   wire			elink0_rxo_wr_wait_n;	// From elink0 of elink.v
   wire			elink0_rxo_wr_wait_p;	// From elink0 of elink.v
   wire			elink0_rxrd_access;	// From elink0 of elink.v
   wire [PW-1:0]	elink0_rxrd_packet;	// From elink0 of elink.v
   wire			elink0_rxrr_access;	// From elink0 of elink.v
   wire [PW-1:0]	elink0_rxrr_packet;	// From elink0 of elink.v
   wire			elink0_rxwr_access;	// From elink0 of elink.v
   wire [PW-1:0]	elink0_rxwr_packet;	// From elink0 of elink.v
   wire			elink0_timeout;		// From elink0 of elink.v
   wire [7:0]		elink0_txo_data_n;	// From elink0 of elink.v
   wire [7:0]		elink0_txo_data_p;	// From elink0 of elink.v
   wire			elink0_txo_frame_n;	// From elink0 of elink.v
   wire			elink0_txo_frame_p;	// From elink0 of elink.v
   wire			elink0_txo_lclk_n;	// From elink0 of elink.v
   wire			elink0_txo_lclk_p;	// From elink0 of elink.v
   wire			elink0_txrd_wait;	// From elink0 of elink.v
   wire			elink0_txrr_wait;	// From elink0 of elink.v
   wire			elink0_txwr_wait;	// From elink0 of elink.v
   wire			elink1_cclk_n;		// From elink1 of elink.v
   wire			elink1_cclk_p;		// From elink1 of elink.v
   wire			elink1_chip_resetb;	// From elink1 of elink.v
   wire [11:0]		elink1_chipid;		// From elink1 of elink.v
   wire			elink1_mailbox_full;	// From elink1 of elink.v
   wire			elink1_mailbox_not_empty;// From elink1 of elink.v
   wire			elink1_rxo_rd_wait_n;	// From elink1 of elink.v
   wire			elink1_rxo_rd_wait_p;	// From elink1 of elink.v
   wire			elink1_rxo_wr_wait_n;	// From elink1 of elink.v
   wire			elink1_rxo_wr_wait_p;	// From elink1 of elink.v
   wire			elink1_rxrd_access;	// From elink1 of elink.v
   wire [PW-1:0]	elink1_rxrd_packet;	// From elink1 of elink.v
   wire			elink1_rxrr_access;	// From elink1 of elink.v
   wire [PW-1:0]	elink1_rxrr_packet;	// From elink1 of elink.v
   wire			elink1_rxwr_access;	// From elink1 of elink.v
   wire [PW-1:0]	elink1_rxwr_packet;	// From elink1 of elink.v
   wire			elink1_timeout;		// From elink1 of elink.v
   wire [7:0]		elink1_txo_data_n;	// From elink1 of elink.v
   wire [7:0]		elink1_txo_data_p;	// From elink1 of elink.v
   wire			elink1_txo_frame_n;	// From elink1 of elink.v
   wire			elink1_txo_frame_p;	// From elink1 of elink.v
   wire			elink1_txo_lclk_n;	// From elink1 of elink.v
   wire			elink1_txo_lclk_p;	// From elink1 of elink.v
   wire			elink1_txrd_wait;	// From elink1 of elink.v
   wire			elink1_txrr_access;	// From emem of ememory.v
   wire [PW-1:0]	elink1_txrr_packet;	// From emem of ememory.v
   wire			elink1_txrr_wait;	// From elink1 of elink.v
   wire			elink1_txwr_wait;	// From elink1 of elink.v
   wire [31:0]		m_axi_araddr;		// From tx_emaxi of emaxi.v
   wire [1:0]		m_axi_arburst;		// From tx_emaxi of emaxi.v
   wire [3:0]		m_axi_arcache;		// From tx_emaxi of emaxi.v
   wire [M_IDW-1:0]	m_axi_arid;		// From tx_emaxi of emaxi.v
   wire [7:0]		m_axi_arlen;		// From tx_emaxi of emaxi.v
   wire [1:0]		m_axi_arlock;		// From tx_emaxi of emaxi.v
   wire [2:0]		m_axi_arprot;		// From tx_emaxi of emaxi.v
   wire [3:0]		m_axi_arqos;		// From tx_emaxi of emaxi.v
   wire			m_axi_arready;		// From elink2 of axi_elink.v
   wire [2:0]		m_axi_arsize;		// From tx_emaxi of emaxi.v
   wire			m_axi_arvalid;		// From tx_emaxi of emaxi.v
   wire [31:0]		m_axi_awaddr;		// From tx_emaxi of emaxi.v
   wire [1:0]		m_axi_awburst;		// From tx_emaxi of emaxi.v
   wire [3:0]		m_axi_awcache;		// From tx_emaxi of emaxi.v
   wire [M_IDW-1:0]	m_axi_awid;		// From tx_emaxi of emaxi.v
   wire [7:0]		m_axi_awlen;		// From tx_emaxi of emaxi.v
   wire [1:0]		m_axi_awlock;		// From tx_emaxi of emaxi.v
   wire [2:0]		m_axi_awprot;		// From tx_emaxi of emaxi.v
   wire [3:0]		m_axi_awqos;		// From tx_emaxi of emaxi.v
   wire			m_axi_awready;		// From elink2 of axi_elink.v
   wire [2:0]		m_axi_awsize;		// From tx_emaxi of emaxi.v
   wire			m_axi_awvalid;		// From tx_emaxi of emaxi.v
   wire [S_IDW-1:0]	m_axi_bid;		// From elink2 of axi_elink.v
   wire			m_axi_bready;		// From tx_emaxi of emaxi.v
   wire [1:0]		m_axi_bresp;		// From elink2 of axi_elink.v
   wire			m_axi_bvalid;		// From elink2 of axi_elink.v
   wire [31:0]		m_axi_rdata;		// From elink2 of axi_elink.v
   wire [S_IDW-1:0]	m_axi_rid;		// From elink2 of axi_elink.v
   wire			m_axi_rlast;		// From elink2 of axi_elink.v
   wire			m_axi_rready;		// From tx_emaxi of emaxi.v
   wire [1:0]		m_axi_rresp;		// From elink2 of axi_elink.v
   wire			m_axi_rvalid;		// From elink2 of axi_elink.v
   wire [63:0]		m_axi_wdata;		// From tx_emaxi of emaxi.v
   wire [M_IDW-1:0]	m_axi_wid;		// From tx_emaxi of emaxi.v
   wire			m_axi_wlast;		// From tx_emaxi of emaxi.v
   wire			m_axi_wready;		// From elink2 of axi_elink.v
   wire [7:0]		m_axi_wstrb;		// From tx_emaxi of emaxi.v
   wire			m_axi_wvalid;		// From tx_emaxi of emaxi.v
   wire			rxo_rd_wait_n;		// From elink2 of axi_elink.v
   wire			rxo_rd_wait_p;		// From elink2 of axi_elink.v
   wire			rxo_wr_wait_n;		// From elink2 of axi_elink.v
   wire			rxo_wr_wait_p;		// From elink2 of axi_elink.v
   wire [31:0]		s_axi_araddr;		// From elink2 of axi_elink.v
   wire [1:0]		s_axi_arburst;		// From elink2 of axi_elink.v
   wire [3:0]		s_axi_arcache;		// From elink2 of axi_elink.v
   wire [M_IDW-1:0]	s_axi_arid;		// From elink2 of axi_elink.v
   wire [7:0]		s_axi_arlen;		// From elink2 of axi_elink.v
   wire [1:0]		s_axi_arlock;		// From elink2 of axi_elink.v
   wire [2:0]		s_axi_arprot;		// From elink2 of axi_elink.v
   wire [3:0]		s_axi_arqos;		// From elink2 of axi_elink.v
   wire			s_axi_arready;		// From rx_esaxi of esaxi.v
   wire [2:0]		s_axi_arsize;		// From elink2 of axi_elink.v
   wire			s_axi_arvalid;		// From elink2 of axi_elink.v
   wire [31:0]		s_axi_awaddr;		// From elink2 of axi_elink.v
   wire [1:0]		s_axi_awburst;		// From elink2 of axi_elink.v
   wire [3:0]		s_axi_awcache;		// From elink2 of axi_elink.v
   wire [M_IDW-1:0]	s_axi_awid;		// From elink2 of axi_elink.v
   wire [7:0]		s_axi_awlen;		// From elink2 of axi_elink.v
   wire [1:0]		s_axi_awlock;		// From elink2 of axi_elink.v
   wire [2:0]		s_axi_awprot;		// From elink2 of axi_elink.v
   wire [3:0]		s_axi_awqos;		// From elink2 of axi_elink.v
   wire			s_axi_awready;		// From rx_esaxi of esaxi.v
   wire [2:0]		s_axi_awsize;		// From elink2 of axi_elink.v
   wire			s_axi_awvalid;		// From elink2 of axi_elink.v
   wire [S_IDW-1:0]	s_axi_bid;		// From rx_esaxi of esaxi.v
   wire			s_axi_bready;		// From elink2 of axi_elink.v
   wire [1:0]		s_axi_bresp;		// From rx_esaxi of esaxi.v
   wire			s_axi_bvalid;		// From rx_esaxi of esaxi.v
   wire [31:0]		s_axi_rdata;		// From rx_esaxi of esaxi.v
   wire [S_IDW-1:0]	s_axi_rid;		// From rx_esaxi of esaxi.v
   wire			s_axi_rlast;		// From rx_esaxi of esaxi.v
   wire			s_axi_rready;		// From elink2 of axi_elink.v
   wire [1:0]		s_axi_rresp;		// From rx_esaxi of esaxi.v
   wire			s_axi_rvalid;		// From rx_esaxi of esaxi.v
   wire [63:0]		s_axi_wdata;		// From elink2 of axi_elink.v
   wire [M_IDW-1:0]	s_axi_wid;		// From elink2 of axi_elink.v
   wire			s_axi_wlast;		// From elink2 of axi_elink.v
   wire			s_axi_wready;		// From rx_esaxi of esaxi.v
   wire [7:0]		s_axi_wstrb;		// From elink2 of axi_elink.v
   wire			s_axi_wvalid;		// From elink2 of axi_elink.v
   wire [7:0]		txo_data_n;		// From elink2 of axi_elink.v
   wire [7:0]		txo_data_p;		// From elink2 of axi_elink.v
   wire			txo_frame_n;		// From elink2 of axi_elink.v
   wire			txo_frame_p;		// From elink2 of axi_elink.v
   wire			txo_lclk_n;		// From elink2 of axi_elink.v
   wire			txo_lclk_p;		// From elink2 of axi_elink.v
   // End of automatics
   wire		elink0_rxrd_wait;	// To elink0 of elink.v
   wire		elink0_rxrr_wait;	// To elink0 of elink.v
   wire		elink0_rxwr_wait;	// To elink0 of elink.v
   wire		elink1_rxrd_wait;	// To elink1 of elink.v
   wire		elink1_rxrr_wait;	// To elink1 of elink.v
   wire		elink1_rxwr_wait;	// To elink1 of elink.v
   wire [3:0] 		colid;
   wire [3:0] 		rowid;
   wire 		mailbox_full;
   wire 		mailbox_not_empty;
   wire 		cclk_p, cclk_n;
   wire 		chip_resetb;
   wire 		rx_lclk_pll;
   wire 		emem_access;
   wire [PW-1:0]	emem_packet;
   wire 		dut_access;
   wire [PW-1:0]	dut_packet;
   wire 		rxrr_access;
   wire [PW-1:0] 	rxrr_packet;
   wire 		rxwr_access;
   wire [PW-1:0] 	rxwr_packet;
   wire 		rxrd_access;
   wire [PW-1:0] 	rxrd_packet;

   wire 		elink0_txrr_access;
   wire [PW-1:0] 	elink0_txrr_packet;
   wire 		elink0_txwr_access;
   wire [PW-1:0] 	elink0_txwr_packet;
   wire 		elink0_txrd_access;
   wire [PW-1:0] 	elink0_txrd_packet;
  
   wire 		elink1_txwr_access;
   wire [PW-1:0] 	elink1_txwr_packet;
   wire 		elink1_txrd_access;
   wire [PW-1:0] 	elink1_txrd_packet;

   wire [7:0]           elink2_txo_data_p;
   wire 	        elink2_txo_frame_p;
   wire                 elink2_txo_lclk_p;

   
   wire                 emem_wait;

   
   reg [31:0] 		 etime;  
   wire 	 itrace = 1'b1;
 
   
   //Read path
   assign elink0_txrd_access         = ext_access & ~ext_packet[1];
   assign elink0_txrd_packet[PW-1:0] = ext_packet[PW-1:0];
        
   //Write path
   assign elink0_txwr_access         = ext_access & ext_packet[1];
   assign elink0_txwr_packet[PW-1:0] = ext_packet[PW-1:0];

   //TX Pushback
   assign dut_rd_wait                = elink0_txrd_wait;// | elink2_wait_out;   
   assign dut_wr_wait                = elink0_txwr_wait;// | elink2_wait_out ;
      
   //Getting results back
   assign dut_access                 = elink0_rxrr_access;
   assign dut_packet[PW-1:0]         = elink0_rxrr_packet[PW-1:0];
   
   //No pushback testing on elink0
   assign elink0_rxrd_wait = 1'b0;
   assign elink0_rxwr_wait = 1'b0;
   assign elink0_rxrr_wait = 1'b0;

   //not connected
   assign elink0_txrr_access         =  1'b0;
   assign elink0_txrr_packet[PW-1:0] =  'b0;


   //######################################################################
   //1ST ELINK
   //######################################################################

   /*elink AUTO_TEMPLATE (
                         // Outputs                        
                         .sys_clk            (clk),
                         .sys_reset          (reset),
                         .\(.*\)             (@"(substring vl-cell-name  0 6)"_\1[]),
                         );
  */

   defparam elink0.ID    = 12'h810;   
   defparam elink0.ETYPE = 0; 
   elink elink0 (
		 .rxi_lclk_p		(elink1_txo_lclk_p),
		 .rxi_lclk_n		(elink1_txo_lclk_n),
		 .rxi_frame_p		(elink1_txo_frame_p),
		 .rxi_frame_n		(elink1_txo_frame_n),
		 .rxi_data_p		(elink1_txo_data_p[7:0]),
		 .rxi_data_n		(elink1_txo_data_n[7:0]),
		 .txi_wr_wait_p		(elink1_rxo_wr_wait_p),
		 .txi_wr_wait_n		(elink1_rxo_wr_wait_n),
		 .txi_rd_wait_p		(elink1_rxo_rd_wait_p),
		 .txi_rd_wait_n		(elink1_rxo_rd_wait_n),
		 /*AUTOINST*/
		 // Outputs
		 .rxo_wr_wait_p		(elink0_rxo_wr_wait_p),	 // Templated
		 .rxo_wr_wait_n		(elink0_rxo_wr_wait_n),	 // Templated
		 .rxo_rd_wait_p		(elink0_rxo_rd_wait_p),	 // Templated
		 .rxo_rd_wait_n		(elink0_rxo_rd_wait_n),	 // Templated
		 .txo_lclk_p		(elink0_txo_lclk_p),	 // Templated
		 .txo_lclk_n		(elink0_txo_lclk_n),	 // Templated
		 .txo_frame_p		(elink0_txo_frame_p),	 // Templated
		 .txo_frame_n		(elink0_txo_frame_n),	 // Templated
		 .txo_data_p		(elink0_txo_data_p[7:0]), // Templated
		 .txo_data_n		(elink0_txo_data_n[7:0]), // Templated
		 .chipid		(elink0_chipid[11:0]),	 // Templated
		 .cclk_p		(elink0_cclk_p),	 // Templated
		 .cclk_n		(elink0_cclk_n),	 // Templated
		 .chip_resetb		(elink0_chip_resetb),	 // Templated
		 .mailbox_not_empty	(elink0_mailbox_not_empty), // Templated
		 .mailbox_full		(elink0_mailbox_full),	 // Templated
		 .timeout		(elink0_timeout),	 // Templated
		 .rxwr_access		(elink0_rxwr_access),	 // Templated
		 .rxwr_packet		(elink0_rxwr_packet[PW-1:0]), // Templated
		 .rxrd_access		(elink0_rxrd_access),	 // Templated
		 .rxrd_packet		(elink0_rxrd_packet[PW-1:0]), // Templated
		 .rxrr_access		(elink0_rxrr_access),	 // Templated
		 .rxrr_packet		(elink0_rxrr_packet[PW-1:0]), // Templated
		 .txwr_wait		(elink0_txwr_wait),	 // Templated
		 .txrd_wait		(elink0_txrd_wait),	 // Templated
		 .txrr_wait		(elink0_txrr_wait),	 // Templated
		 // Inputs
		 .sys_reset		(reset),		 // Templated
		 .sys_clk		(clk),			 // Templated
		 .rxwr_wait		(elink0_rxwr_wait),	 // Templated
		 .rxrd_wait		(elink0_rxrd_wait),	 // Templated
		 .rxrr_wait		(elink0_rxrr_wait),	 // Templated
		 .txwr_access		(elink0_txwr_access),	 // Templated
		 .txwr_packet		(elink0_txwr_packet[PW-1:0]), // Templated
		 .txrd_access		(elink0_txrd_access),	 // Templated
		 .txrd_packet		(elink0_txrd_packet[PW-1:0]), // Templated
		 .txrr_access		(elink0_txrr_access),	 // Templated
		 .txrr_packet		(elink0_txrr_packet[PW-1:0])); // Templated


   //######################################################################
   //2ND ELINK (WITH EPIPHANY MEMORY)
   //######################################################################

   //No read/write from elink1 (for now)
   assign elink1_txrd_access = 1'b0;
   assign elink1_txrd_packet = 'b0;
   assign elink1_txwr_access = 1'b0;
   assign elink1_txwr_packet = 'b0;
   assign elink1_rxrr_wait   = 1'b0;
   
   defparam elink1.ID = 12'h820;   
   defparam elink1.ETYPE = 0; 

   elink elink1 (
		 .rxi_lclk_p		(elink0_txo_lclk_p),
		 .rxi_lclk_n		(elink0_txo_lclk_n),
		 .rxi_frame_p		(elink0_txo_frame_p),
		 .rxi_frame_n		(elink0_txo_frame_n),
		 .rxi_data_p		(elink0_txo_data_p[7:0]),
		 .rxi_data_n		(elink0_txo_data_n[7:0]),
		 .txi_wr_wait_p		(elink0_rxo_wr_wait_p),
		 .txi_wr_wait_n		(elink0_rxo_wr_wait_n),
		 .txi_rd_wait_p		(elink0_rxo_rd_wait_p),
		 .txi_rd_wait_n		(elink0_rxo_rd_wait_n),	
		 /*AUTOINST*/
		 // Outputs
		 .rxo_wr_wait_p		(elink1_rxo_wr_wait_p),	 // Templated
		 .rxo_wr_wait_n		(elink1_rxo_wr_wait_n),	 // Templated
		 .rxo_rd_wait_p		(elink1_rxo_rd_wait_p),	 // Templated
		 .rxo_rd_wait_n		(elink1_rxo_rd_wait_n),	 // Templated
		 .txo_lclk_p		(elink1_txo_lclk_p),	 // Templated
		 .txo_lclk_n		(elink1_txo_lclk_n),	 // Templated
		 .txo_frame_p		(elink1_txo_frame_p),	 // Templated
		 .txo_frame_n		(elink1_txo_frame_n),	 // Templated
		 .txo_data_p		(elink1_txo_data_p[7:0]), // Templated
		 .txo_data_n		(elink1_txo_data_n[7:0]), // Templated
		 .chipid		(elink1_chipid[11:0]),	 // Templated
		 .cclk_p		(elink1_cclk_p),	 // Templated
		 .cclk_n		(elink1_cclk_n),	 // Templated
		 .chip_resetb		(elink1_chip_resetb),	 // Templated
		 .mailbox_not_empty	(elink1_mailbox_not_empty), // Templated
		 .mailbox_full		(elink1_mailbox_full),	 // Templated
		 .timeout		(elink1_timeout),	 // Templated
		 .rxwr_access		(elink1_rxwr_access),	 // Templated
		 .rxwr_packet		(elink1_rxwr_packet[PW-1:0]), // Templated
		 .rxrd_access		(elink1_rxrd_access),	 // Templated
		 .rxrd_packet		(elink1_rxrd_packet[PW-1:0]), // Templated
		 .rxrr_access		(elink1_rxrr_access),	 // Templated
		 .rxrr_packet		(elink1_rxrr_packet[PW-1:0]), // Templated
		 .txwr_wait		(elink1_txwr_wait),	 // Templated
		 .txrd_wait		(elink1_txrd_wait),	 // Templated
		 .txrr_wait		(elink1_txrr_wait),	 // Templated
		 // Inputs
		 .sys_reset		(reset),		 // Templated
		 .sys_clk		(clk),			 // Templated
		 .rxwr_wait		(elink1_rxwr_wait),	 // Templated
		 .rxrd_wait		(elink1_rxrd_wait),	 // Templated
		 .rxrr_wait		(elink1_rxrr_wait),	 // Templated
		 .txwr_access		(elink1_txwr_access),	 // Templated
		 .txwr_packet		(elink1_txwr_packet[PW-1:0]), // Templated
		 .txrd_access		(elink1_txrd_access),	 // Templated
		 .txrd_packet		(elink1_txrd_packet[PW-1:0]), // Templated
		 .txrr_access		(elink1_txrr_access),	 // Templated
		 .txrr_packet		(elink1_txrr_packet[PW-1:0])); // Templated
   



   reg [8:0] counter;
   wire      elink1_random_wait;
   
   always @ (posedge clk)
     if(reset)
       counter <= 'b0;
     else
       counter <= counter+1;

   assign elink1_random_wait = counter > 256;
   
   assign  emem_access           = (elink1_rxwr_access & ~(elink1_rxwr_packet[39:28]==elink1.ID)) |
				   (elink1_rxrd_access & ~(elink1_rxrd_packet[39:28]==elink1.ID));
   
   assign  emem_packet[PW-1:0]   = elink1_rxwr_access ? elink1_rxwr_packet[PW-1:0]:
                                                        elink1_rxrd_packet[PW-1:0];

   assign elink1_rxrd_wait = emem_wait | elink1_rxwr_access;
   assign elink1_rxwr_wait = 1'b0;//elink1_random_wait
   
   /*ememory AUTO_TEMPLATE ( 
                        // Outputs
                        .\(.*\)_out       (elink1_txrr_\1[]),
                        .\(.*\)_in        (emem_\1[]),
                        .wait_out	  (emem_wait),
                         );
   */

   ememory emem (.wait_in	        (1'b0),       //only one read at a time, set to zero for no1
		 .clk		        (clk),
		 .wait_out		(emem_wait),
		 /*AUTOINST*/
		 // Outputs
		 .access_out		(elink1_txrr_access),	 // Templated
		 .packet_out		(elink1_txrr_packet[PW-1:0]), // Templated
		 // Inputs
		 .reset			(reset),
		 .access_in		(emem_access),		 // Templated
		 .packet_in		(emem_packet[PW-1:0]));	 // Templated

   
   //######################################################################
   //3rd ELINK (LOOPBACK), WITH EMAXI,ESAXI
   //######################################################################
   /*axi_elink AUTO_TEMPLATE (.m_\(.*\)      (s_\1[]),
                              .s_\(.*\)      (m_\1[]),
                         );
  */

   defparam elink2.ID    = 12'h810;   
   defparam elink2.ETYPE = 0; 

   axi_elink elink2 (.sys_clk		(clk),
		     .m_axi_aresetn	(~reset),
		     .s_axi_aresetn	(~reset),
		     .rxi_lclk_p	(txo_lclk_p),
		     .rxi_lclk_n	(txo_lclk_n),
		     .rxi_frame_p	(txo_frame_p),
		     .rxi_frame_n	(txo_frame_n),
		     .rxi_data_p	(txo_data_p[7:0]),
		     .rxi_data_n	(txo_data_n[7:0]),
		     .txi_wr_wait_p	(rxo_wr_wait_p),
		     .txi_wr_wait_n	(rxo_wr_wait_n),
		     .txi_rd_wait_p	(rxo_rd_wait_p),
		     .txi_rd_wait_n	(rxo_rd_wait_n),
		     .chip_resetb   	(chip_resetb), 
		     .cclk_p		(cclk_p),
		     .cclk_n		(cclk_n),
		     /*AUTOINST*/
		     // Outputs
		     .rxo_wr_wait_p	(rxo_wr_wait_p),
		     .rxo_wr_wait_n	(rxo_wr_wait_n),
		     .rxo_rd_wait_p	(rxo_rd_wait_p),
		     .rxo_rd_wait_n	(rxo_rd_wait_n),
		     .txo_lclk_p	(txo_lclk_p),
		     .txo_lclk_n	(txo_lclk_n),
		     .txo_frame_p	(txo_frame_p),
		     .txo_frame_n	(txo_frame_n),
		     .txo_data_p	(txo_data_p[7:0]),
		     .txo_data_n	(txo_data_n[7:0]),
		     .chipid		(chipid[11:0]),
		     .mailbox_not_empty	(mailbox_not_empty),
		     .mailbox_full	(mailbox_full),
		     .m_axi_awid	(s_axi_awid[M_IDW-1:0]), // Templated
		     .m_axi_awaddr	(s_axi_awaddr[31:0]),	 // Templated
		     .m_axi_awlen	(s_axi_awlen[7:0]),	 // Templated
		     .m_axi_awsize	(s_axi_awsize[2:0]),	 // Templated
		     .m_axi_awburst	(s_axi_awburst[1:0]),	 // Templated
		     .m_axi_awlock	(s_axi_awlock[1:0]),	 // Templated
		     .m_axi_awcache	(s_axi_awcache[3:0]),	 // Templated
		     .m_axi_awprot	(s_axi_awprot[2:0]),	 // Templated
		     .m_axi_awqos	(s_axi_awqos[3:0]),	 // Templated
		     .m_axi_awvalid	(s_axi_awvalid),	 // Templated
		     .m_axi_wid		(s_axi_wid[M_IDW-1:0]),	 // Templated
		     .m_axi_wdata	(s_axi_wdata[63:0]),	 // Templated
		     .m_axi_wstrb	(s_axi_wstrb[7:0]),	 // Templated
		     .m_axi_wlast	(s_axi_wlast),		 // Templated
		     .m_axi_wvalid	(s_axi_wvalid),		 // Templated
		     .m_axi_bready	(s_axi_bready),		 // Templated
		     .m_axi_arid	(s_axi_arid[M_IDW-1:0]), // Templated
		     .m_axi_araddr	(s_axi_araddr[31:0]),	 // Templated
		     .m_axi_arlen	(s_axi_arlen[7:0]),	 // Templated
		     .m_axi_arsize	(s_axi_arsize[2:0]),	 // Templated
		     .m_axi_arburst	(s_axi_arburst[1:0]),	 // Templated
		     .m_axi_arlock	(s_axi_arlock[1:0]),	 // Templated
		     .m_axi_arcache	(s_axi_arcache[3:0]),	 // Templated
		     .m_axi_arprot	(s_axi_arprot[2:0]),	 // Templated
		     .m_axi_arqos	(s_axi_arqos[3:0]),	 // Templated
		     .m_axi_arvalid	(s_axi_arvalid),	 // Templated
		     .m_axi_rready	(s_axi_rready),		 // Templated
		     .s_axi_arready	(m_axi_arready),	 // Templated
		     .s_axi_awready	(m_axi_awready),	 // Templated
		     .s_axi_bid		(m_axi_bid[S_IDW-1:0]),	 // Templated
		     .s_axi_bresp	(m_axi_bresp[1:0]),	 // Templated
		     .s_axi_bvalid	(m_axi_bvalid),		 // Templated
		     .s_axi_rid		(m_axi_rid[S_IDW-1:0]),	 // Templated
		     .s_axi_rdata	(m_axi_rdata[31:0]),	 // Templated
		     .s_axi_rlast	(m_axi_rlast),		 // Templated
		     .s_axi_rresp	(m_axi_rresp[1:0]),	 // Templated
		     .s_axi_rvalid	(m_axi_rvalid),		 // Templated
		     .s_axi_wready	(m_axi_wready),		 // Templated
		     // Inputs
		     .reset		(reset),
		     .m_axi_awready	(s_axi_awready),	 // Templated
		     .m_axi_wready	(s_axi_wready),		 // Templated
		     .m_axi_bid		(s_axi_bid[M_IDW-1:0]),	 // Templated
		     .m_axi_bresp	(s_axi_bresp[1:0]),	 // Templated
		     .m_axi_bvalid	(s_axi_bvalid),		 // Templated
		     .m_axi_arready	(s_axi_arready),	 // Templated
		     .m_axi_rid		(s_axi_rid[M_IDW-1:0]),	 // Templated
		     .m_axi_rdata	(s_axi_rdata[63:0]),	 // Templated
		     .m_axi_rresp	(s_axi_rresp[1:0]),	 // Templated
		     .m_axi_rlast	(s_axi_rlast),		 // Templated
		     .m_axi_rvalid	(s_axi_rvalid),		 // Templated
		     .s_axi_arid	(m_axi_arid[S_IDW-1:0]), // Templated
		     .s_axi_araddr	(m_axi_araddr[31:0]),	 // Templated
		     .s_axi_arburst	(m_axi_arburst[1:0]),	 // Templated
		     .s_axi_arcache	(m_axi_arcache[3:0]),	 // Templated
		     .s_axi_arlock	(m_axi_arlock[1:0]),	 // Templated
		     .s_axi_arlen	(m_axi_arlen[7:0]),	 // Templated
		     .s_axi_arprot	(m_axi_arprot[2:0]),	 // Templated
		     .s_axi_arqos	(m_axi_arqos[3:0]),	 // Templated
		     .s_axi_arsize	(m_axi_arsize[2:0]),	 // Templated
		     .s_axi_arvalid	(m_axi_arvalid),	 // Templated
		     .s_axi_awid	(m_axi_awid[S_IDW-1:0]), // Templated
		     .s_axi_awaddr	(m_axi_awaddr[31:0]),	 // Templated
		     .s_axi_awburst	(m_axi_awburst[1:0]),	 // Templated
		     .s_axi_awcache	(m_axi_awcache[3:0]),	 // Templated
		     .s_axi_awlock	(m_axi_awlock[1:0]),	 // Templated
		     .s_axi_awlen	(m_axi_awlen[7:0]),	 // Templated
		     .s_axi_awprot	(m_axi_awprot[2:0]),	 // Templated
		     .s_axi_awqos	(m_axi_awqos[3:0]),	 // Templated
		     .s_axi_awsize	(m_axi_awsize[2:0]),	 // Templated
		     .s_axi_awvalid	(m_axi_awvalid),	 // Templated
		     .s_axi_bready	(m_axi_bready),		 // Templated
		     .s_axi_rready	(m_axi_rready),		 // Templated
		     .s_axi_wid		(m_axi_wid[S_IDW-1:0]),	 // Templated
		     .s_axi_wdata	(m_axi_wdata[31:0]),	 // Templated
		     .s_axi_wlast	(m_axi_wlast),		 // Templated
		     .s_axi_wstrb	(m_axi_wstrb[3:0]),	 // Templated
		     .s_axi_wvalid	(m_axi_wvalid));		 // Templated
   

   //HACK!!!!!
   wire          txrr_access;
   wire [PW-1:0] txrr_packet;

   //Read path
   assign rxrd_access         = elink_axi_access & ~elink_axi_packet[1];
   assign rxrd_packet[PW-1:0] = elink_axi_packet[PW-1:0];
        
   //Write path
   assign rxwr_access         = elink_axi_access & elink_axi_packet[1];
   assign rxwr_packet[PW-1:0] = elink_axi_packet[PW-1:0];

   wire 	 elink_axi_access;
   wire [PW-1:0] elink_axi_packet;
   
   defparam axi_fifo.DW    = 104;
   defparam axi_fifo.DEPTH = 32;  //TODO: fix the model, only 16/32 allowed!  
   fifo_cdc  axi_fifo(
			// Outputs
			.wait_out	(),
			.access_out	(elink_axi_access),
			.packet_out	(elink_axi_packet[PW-1:0]),
			// Inputs
			.clk_in		(clk),
			.clk_out	(clk),
			.reset_in	(reset),
			.reset_out	(reset),
			.access_in	(ext_access),
			.packet_in	(ext_packet[PW-1:0]),
			.wait_in	((rxwr_access & rxwr_wait) |
					 (rxrd_access & rxrd_wait)
					 )
			);   
   
   //master interface (driving stimulus to TX path)

   defparam tx_emaxi.M_IDW=M_IDW;
   emaxi tx_emaxi (.m_axi_aclk		(clk),
                   .m_axi_aresetn	(~reset),
		   .txrr_access		(),        //output for monitoring
		   .txrr_packet		(),//output for monitoring 
		   .rxwr_wait		(rxwr_wait),          //ignore for now?
		   .rxrd_wait		(rxrd_wait),          //ignore for now?		   
		   .rxwr_access		(rxwr_access),
		   .rxwr_packet		(rxwr_packet[PW-1:0]),
		   .rxrd_access		(rxrd_access),
		   .rxrd_packet		(rxrd_packet[PW-1:0]),
		   .txrr_wait		(1'b0),
		   /*AUTOINST*/
		   // Outputs
		   .m_axi_awid		(m_axi_awid[M_IDW-1:0]),
		   .m_axi_awaddr	(m_axi_awaddr[31:0]),
		   .m_axi_awlen		(m_axi_awlen[7:0]),
		   .m_axi_awsize	(m_axi_awsize[2:0]),
		   .m_axi_awburst	(m_axi_awburst[1:0]),
		   .m_axi_awlock	(m_axi_awlock[1:0]),
		   .m_axi_awcache	(m_axi_awcache[3:0]),
		   .m_axi_awprot	(m_axi_awprot[2:0]),
		   .m_axi_awqos		(m_axi_awqos[3:0]),
		   .m_axi_awvalid	(m_axi_awvalid),
		   .m_axi_wid		(m_axi_wid[M_IDW-1:0]),
		   .m_axi_wdata		(m_axi_wdata[63:0]),
		   .m_axi_wstrb		(m_axi_wstrb[7:0]),
		   .m_axi_wlast		(m_axi_wlast),
		   .m_axi_wvalid	(m_axi_wvalid),
		   .m_axi_bready	(m_axi_bready),
		   .m_axi_arid		(m_axi_arid[M_IDW-1:0]),
		   .m_axi_araddr	(m_axi_araddr[31:0]),
		   .m_axi_arlen		(m_axi_arlen[7:0]),
		   .m_axi_arsize	(m_axi_arsize[2:0]),
		   .m_axi_arburst	(m_axi_arburst[1:0]),
		   .m_axi_arlock	(m_axi_arlock[1:0]),
		   .m_axi_arcache	(m_axi_arcache[3:0]),
		   .m_axi_arprot	(m_axi_arprot[2:0]),
		   .m_axi_arqos		(m_axi_arqos[3:0]),
		   .m_axi_arvalid	(m_axi_arvalid),
		   .m_axi_rready	(m_axi_rready),
		   // Inputs
		   .m_axi_awready	(m_axi_awready),
		   .m_axi_wready	(m_axi_wready),
		   .m_axi_bid		(m_axi_bid[M_IDW-1:0]),
		   .m_axi_bresp		(m_axi_bresp[1:0]),
		   .m_axi_bvalid	(m_axi_bvalid),
		   .m_axi_arready	(m_axi_arready),
		   .m_axi_rid		(m_axi_rid[M_IDW-1:0]),
		   .m_axi_rdata		(m_axi_rdata[63:0]),
		   .m_axi_rresp		(m_axi_rresp[1:0]),
		   .m_axi_rlast		(m_axi_rlast),
		   .m_axi_rvalid	(m_axi_rvalid));
   
   wire [PW-1:0] txwr_packet;
   wire 	 txwr_access;
   wire [PW-1:0] txrd_packet;
   wire 	 txrd_access;
   wire 	 esaxi_rd_wait;
   wire 	 esaxi_wr_wait;
   
   //slave interface (receiving from 

   defparam rx_esaxi.S_IDW=S_IDW;   
   esaxi rx_esaxi (.s_axi_aclk		(clk),
                   .s_axi_aresetn	(~reset),
		   .txwr_access		(txwr_access),//output to emem2
		   .txwr_packet		(txwr_packet[PW-1:0]),
		   .txrd_access		(txrd_access),
		   .txrd_packet		(txrd_packet[PW-1:0]),
		   .rxrr_wait		(),
		   .txwr_wait		(esaxi_wr_wait),
		   .txrd_wait		(esaxi_rd_wait),
		   .rxrr_access		(rxrr_access),
		   .rxrr_packet		(rxrr_packet[PW-1:0]),
                   /*AUTOINST*/
		   // Outputs
		   .s_axi_arready	(s_axi_arready),
		   .s_axi_awready	(s_axi_awready),
		   .s_axi_bid		(s_axi_bid[S_IDW-1:0]),
		   .s_axi_bresp		(s_axi_bresp[1:0]),
		   .s_axi_bvalid	(s_axi_bvalid),
		   .s_axi_rid		(s_axi_rid[S_IDW-1:0]),
		   .s_axi_rdata		(s_axi_rdata[31:0]),
		   .s_axi_rlast		(s_axi_rlast),
		   .s_axi_rresp		(s_axi_rresp[1:0]),
		   .s_axi_rvalid	(s_axi_rvalid),
		   .s_axi_wready	(s_axi_wready),
		   // Inputs
		   .s_axi_arid		(s_axi_arid[S_IDW-1:0]),
		   .s_axi_araddr	(s_axi_araddr[31:0]),
		   .s_axi_arburst	(s_axi_arburst[1:0]),
		   .s_axi_arcache	(s_axi_arcache[3:0]),
		   .s_axi_arlock	(s_axi_arlock[1:0]),
		   .s_axi_arlen		(s_axi_arlen[7:0]),
		   .s_axi_arprot	(s_axi_arprot[2:0]),
		   .s_axi_arqos		(s_axi_arqos[3:0]),
		   .s_axi_arsize	(s_axi_arsize[2:0]),
		   .s_axi_arvalid	(s_axi_arvalid),
		   .s_axi_awid		(s_axi_awid[S_IDW-1:0]),
		   .s_axi_awaddr	(s_axi_awaddr[31:0]),
		   .s_axi_awburst	(s_axi_awburst[1:0]),
		   .s_axi_awcache	(s_axi_awcache[3:0]),
		   .s_axi_awlock	(s_axi_awlock[1:0]),
		   .s_axi_awlen		(s_axi_awlen[7:0]),
		   .s_axi_awprot	(s_axi_awprot[2:0]),
		   .s_axi_awqos		(s_axi_awqos[3:0]),
		   .s_axi_awsize	(s_axi_awsize[2:0]),
		   .s_axi_awvalid	(s_axi_awvalid),
		   .s_axi_bready	(s_axi_bready),
		   .s_axi_rready	(s_axi_rready),
		   .s_axi_wid		(s_axi_wid[S_IDW-1:0]),
		   .s_axi_wdata		(s_axi_wdata[31:0]),
		   .s_axi_wlast		(s_axi_wlast),
		   .s_axi_wstrb		(s_axi_wstrb[3:0]),
		   .s_axi_wvalid	(s_axi_wvalid));


   wire 	 emem2_access;
   wire [PW-1:0] emem2_packet;
 
   assign  emem2_access           = (txwr_access & ~(txwr_packet[39:28]==elink2.ID)) |
				    (txrd_access & ~(txrd_packet[39:28]==elink2.ID));
   
   assign  emem2_packet[PW-1:0]   = txwr_access ? txwr_packet[PW-1:0]:
                                                  txrd_packet[PW-1:0];

   assign esaxi_rd_wait = emem2_wait | txwr_access;
   assign esaxi_wr_wait = 1'b0; //no wait on write
   
   /*ememory AUTO_TEMPLATE ( 
                        // Outputs
                        .\(.*\)_out       (elink1_txrr_\1[]),
                        .\(.*\)_in        (emem_\1[]),
                        .wait_out	  (emem_wait),
                         );
   */

   ememory emem2 (.wait_in	        (1'b0),       //only one read at a time, set to zero for no1
		 .clk		        (clk),
		 .wait_out		(emem2_wait),
		 .access_out		(rxrr_access),
		 .packet_out		(rxrr_packet[PW-1:0]),
		  // Inputs
		  .reset		(reset),
		  .access_in		(emem2_access),
		  .packet_in		(emem2_packet[PW-1:0]));


   //######################################################################
   //4th ELINK (chip reference model)
   //######################################################################
   wire elink2_access;
   wire [PW-1:0] elink2_packet;
   
   defparam model_fifo.DW    = 104;
   defparam model_fifo.DEPTH = 32;   
   fifo_cdc  model_fifo(
			// Outputs
			.wait_out	(),
			.access_out	(elink2_access),
			.packet_out	(elink2_packet[PW-1:0]),
			// Inputs
			.clk_in		(clk),
			.clk_out	(clk),
			.reset_in	(reset),
			.reset_out	(reset),
			.access_in	(ext_access),
			.packet_in	(ext_packet[PW-1:0]),
			.wait_in	(1'b0)//elink2_wait_out
			);   

   elink_e16 elink_ref (
		     // Outputs
		     .rxi_rd_wait	(),
		     .rxi_wr_wait	(),
		     .txo_data		(elink2_txo_data_p[7:0]),
		     .txo_lclk		(elink2_txo_lclk_p),
		     .txo_frame		(elink2_txo_frame_p),
		     .c0_mesh_access_out(),
		     .c0_mesh_write_out	(),
		     .c0_mesh_dstaddr_out(),
		     .c0_mesh_srcaddr_out(),
		     .c0_mesh_data_out	(),
		     .c0_mesh_datamode_out(),
		     .c0_mesh_ctrlmode_out(),
		     .c0_emesh_wait_out	(),
		     .c0_mesh_wait_out	(elink2_wait_out),
		     // Inputs
		     .reset		(reset),
		     .c0_clk_in		(clk),
		     .c1_clk_in		(clk),
		     .c2_clk_in		(clk),
		     .c3_clk_in		(clk),
		     .rxi_data		(8'b0),
		     .rxi_lclk		(1'b0),
		     .rxi_frame		(1'b0),
		     .txo_rd_wait	(1'b0),
		     .txo_wr_wait	(1'b0),
		     .c0_mesh_access_in	(elink2_access),
		     .c0_mesh_write_in	(elink2_packet[1]),
		     .c0_mesh_dstaddr_in(elink2_packet[39:8]),
		     .c0_mesh_srcaddr_in(elink2_packet[103:72]),
		     .c0_mesh_data_in	(elink2_packet[71:40]),
		     .c0_mesh_datamode_in(elink2_packet[3:2]),
		     .c0_mesh_ctrlmode_in(elink2_packet[7:4])		     
		     );
   

  
 
   
   //######################################################################
   //TRANSACTION MONITORS
   //######################################################################
   always @ (posedge clk or posedge reset)
     if(reset)
       etime[31:0] <= 32'b0;
     else
       etime[31:0] <= etime[31:0]+1'b1;

  /*emesh_monitor AUTO_TEMPLATE ( 
                        // Outputs
                        .emesh_\(.*\)     (@"(substring vl-cell-name  0 3)"_\1[]),
                        );
   */


   emesh_monitor #(.NAME("stimulus")) ext_monitor (.emesh_wait		((dut_rd_wait | dut_wr_wait)),//TODO:fix collisions
						   .clk			(clk),
						   /*AUTOINST*/
						   // Inputs
						   .reset		(reset),
						   .itrace		(itrace),
						   .etime		(etime[31:0]),
						   .emesh_access	(ext_access),	 // Templated
						   .emesh_packet	(ext_packet[PW-1:0])); // Templated
   
   emesh_monitor #(.NAME("dut")) dut_monitor (.emesh_wait	(1'b0),
					      .clk		(clk),
					      /*AUTOINST*/
					      // Inputs
					      .reset		(reset),
					      .itrace		(itrace),
					      .etime		(etime[31:0]),
					      .emesh_access	(dut_access),	 // Templated
					      .emesh_packet	(dut_packet[PW-1:0])); // Templated

   emesh_monitor #(.NAME("emem")) mem_monitor (.emesh_wait	(1'b0),
						.clk		(clk),
					       .emesh_access	(emem_access),
					       .emesh_packet	(emem_packet[PW-1:0]),
						/*AUTOINST*/
					       // Inputs
					       .reset		(reset),
					       .itrace		(itrace),
					       .etime		(etime[31:0]));
   

  
     
endmodule // dv_elink
// Local Variables:
// verilog-library-directories:("." "../hdl" "../../memory/hdl" "../../emesh/hdl")
// End:

/*
 Copyright (C) 2014 Adapteva, Inc. 
 Contributed by Andreas Olofsson <andreas@adapteva.com>

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.This program is distributed in the hope 
 that it will be useful,but WITHOUT ANY WARRANTY; without even the implied 
 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details. You should have received a copy 
 of the GNU General Public License along with this program (see the file 
 COPYING).  If not, see <http://www.gnu.org/licenses/>.
 */

