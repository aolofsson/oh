module dut(/*AUTOARG*/
   // Outputs
   dut_active, wait_out, access_out, packet_out,
   // Inputs
   clk, nreset, vdd, vss, access_in, packet_in, wait_in
   );

   parameter AW    = 32;
   parameter DW    = 32;
   parameter CW    = 2; 
   parameter IDW   = 12;
   parameter S_IDW = 12; 
   parameter M_IDW = 6; 
   parameter PW    = 104;     
   parameter N     = 1;
   
   //#######################################
   //# CLOCK AND RESET
   //#######################################
   input            clk;
   input            nreset;
   input [N*N-1:0]  vdd;
   input 	    vss;
   output 	    dut_active;
   
   //#######################################
   //#EMESH INTERFACE 
   //#######################################
   
   //Stimulus Driven Transaction
   input [N-1:0]     access_in;
   input [N*PW-1:0]  packet_in;
   output [N-1:0]    wait_out;

   //DUT driven transactoin
   output [N-1:0]    access_out;
   output [N*PW-1:0] packet_out;
   input [N-1:0]     wait_in;

   /*AUTOINPUT*/

   //floating wires
   wire 	     elink0_cclk_n;		// From elink0 of elink.v
   wire 	     elink0_cclk_p;		// From elink0 of elink.v
   wire 	     elink0_chip_resetb;	// From elink0 of elink.v
   wire [11:0] 	     elink0_chipid;		// From elink0 of elink.v
   wire 	     elink0_mailbox_full;	// From elink0 of elink.v
   wire 	     elink0_mailbox_not_empty;// From elink0 of elink.v
   wire 	     elink0_timeout;		// From elink0 of elink.v
   wire 	     elink1_cclk_n;		// From elink1 of elink.v
   wire 	     elink1_cclk_p;		// From elink1 of elink.v
   wire 	     elink1_chip_resetb;	// From elink1 of elink.v
   wire [11:0] 	     elink1_chipid;		// From elink1 of elink.v
   wire 	     elink1_mailbox_full;	// From elink1 of elink.v
   wire 	     elink1_mailbox_not_empty;// From elink1 of elink.v
   wire 	     elink1_rxrd_access;	// From elink1 of elink.v
   wire [PW-1:0]     elink1_rxrd_packet;	// From elink1 of elink.v
   wire 	     elink1_rxrr_access;	// From elink1 of elink.v
   wire [PW-1:0]     elink1_rxrr_packet;	// From elink1 of elink.v
   wire 	     elink1_rxwr_access;	// From elink1 of elink.v
   wire [PW-1:0]     elink1_rxwr_packet;	// From elink1 of elink.v
   wire 	     elink1_timeout;		// From elink1 of elink.v
   wire 	     elink1_txrd_wait;	// From elink1 of elink.v
   wire 	     elink1_txrr_access;	// From emem of ememory.v
   wire [PW-1:0]     elink1_txrr_packet;	// From emem of ememory.v
   wire 	     elink1_txrr_wait;	// From elink1 of elink.v
   wire 	     elink1_txwr_wait;	// From elink1 of elink.v
 
   //memory wires
   wire 	     emem_access;
   wire [PW-1:0]     emem_packet;
   wire 	     elink1_rxrd_wait;
   wire 	     elink1_rxwr_wait;

   // Beginning of automatic outputs (from unused autoinst outputs)

   // End of automatics
  
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [31:0]		elink0_m_axi_araddr;	// From elink0 of axi_elink.v
   wire [1:0]		elink0_m_axi_arburst;	// From elink0 of axi_elink.v
   wire [3:0]		elink0_m_axi_arcache;	// From elink0 of axi_elink.v
   wire [M_IDW-1:0]	elink0_m_axi_arid;	// From elink0 of axi_elink.v
   wire [7:0]		elink0_m_axi_arlen;	// From elink0 of axi_elink.v
   wire [1:0]		elink0_m_axi_arlock;	// From elink0 of axi_elink.v
   wire [2:0]		elink0_m_axi_arprot;	// From elink0 of axi_elink.v
   wire [3:0]		elink0_m_axi_arqos;	// From elink0 of axi_elink.v
   wire [2:0]		elink0_m_axi_arsize;	// From elink0 of axi_elink.v
   wire			elink0_m_axi_arvalid;	// From elink0 of axi_elink.v
   wire [31:0]		elink0_m_axi_awaddr;	// From elink0 of axi_elink.v
   wire [1:0]		elink0_m_axi_awburst;	// From elink0 of axi_elink.v
   wire [3:0]		elink0_m_axi_awcache;	// From elink0 of axi_elink.v
   wire [M_IDW-1:0]	elink0_m_axi_awid;	// From elink0 of axi_elink.v
   wire [7:0]		elink0_m_axi_awlen;	// From elink0 of axi_elink.v
   wire [1:0]		elink0_m_axi_awlock;	// From elink0 of axi_elink.v
   wire [2:0]		elink0_m_axi_awprot;	// From elink0 of axi_elink.v
   wire [3:0]		elink0_m_axi_awqos;	// From elink0 of axi_elink.v
   wire [2:0]		elink0_m_axi_awsize;	// From elink0 of axi_elink.v
   wire			elink0_m_axi_awvalid;	// From elink0 of axi_elink.v
   wire			elink0_m_axi_bready;	// From elink0 of axi_elink.v
   wire			elink0_m_axi_rready;	// From elink0 of axi_elink.v
   wire [63:0]		elink0_m_axi_wdata;	// From elink0 of axi_elink.v
   wire [M_IDW-1:0]	elink0_m_axi_wid;	// From elink0 of axi_elink.v
   wire			elink0_m_axi_wlast;	// From elink0 of axi_elink.v
   wire [7:0]		elink0_m_axi_wstrb;	// From elink0 of axi_elink.v
   wire			elink0_m_axi_wvalid;	// From elink0 of axi_elink.v
   wire			elink0_rxo_rd_wait_n;	// From elink0 of axi_elink.v
   wire			elink0_rxo_rd_wait_p;	// From elink0 of axi_elink.v
   wire			elink0_rxo_wr_wait_n;	// From elink0 of axi_elink.v
   wire			elink0_rxo_wr_wait_p;	// From elink0 of axi_elink.v
   wire			elink0_rxrr_access;	// From emaxi of emaxi.v
   wire [PW-1:0]	elink0_rxrr_packet;	// From emaxi of emaxi.v
   wire [7:0]		elink0_txo_data_n;	// From elink0 of axi_elink.v
   wire [7:0]		elink0_txo_data_p;	// From elink0 of axi_elink.v
   wire			elink0_txo_frame_n;	// From elink0 of axi_elink.v
   wire			elink0_txo_frame_p;	// From elink0 of axi_elink.v
   wire			elink0_txo_lclk_n;	// From elink0 of axi_elink.v
   wire			elink0_txo_lclk_p;	// From elink0 of axi_elink.v
   wire			elink0_txrd_access;	// From emesh_if of emesh_if.v
   wire [PW-1:0]	elink0_txrd_packet;	// From emesh_if of emesh_if.v
   wire			elink0_txrd_wait;	// From emaxi of emaxi.v
   wire			elink0_txwr_access;	// From emesh_if of emesh_if.v
   wire [PW-1:0]	elink0_txwr_packet;	// From emesh_if of emesh_if.v
   wire			elink0_txwr_wait;	// From emaxi of emaxi.v
   wire			elink1_elink_active;	// From elink1 of elink.v
   wire			elink1_rxo_rd_wait_n;	// From elink1 of elink.v
   wire			elink1_rxo_rd_wait_p;	// From elink1 of elink.v
   wire			elink1_rxo_wr_wait_n;	// From elink1 of elink.v
   wire			elink1_rxo_wr_wait_p;	// From elink1 of elink.v
   wire [7:0]		elink1_txo_data_n;	// From elink1 of elink.v
   wire [7:0]		elink1_txo_data_p;	// From elink1 of elink.v
   wire			elink1_txo_frame_n;	// From elink1 of elink.v
   wire			elink1_txo_frame_p;	// From elink1 of elink.v
   wire			elink1_txo_lclk_n;	// From elink1 of elink.v
   wire			elink1_txo_lclk_p;	// From elink1 of elink.v
   wire [31:0]		m_axi_araddr;		// From emaxi of emaxi.v
   wire [1:0]		m_axi_arburst;		// From emaxi of emaxi.v
   wire [3:0]		m_axi_arcache;		// From emaxi of emaxi.v
   wire [M_IDW-1:0]	m_axi_arid;		// From emaxi of emaxi.v
   wire [7:0]		m_axi_arlen;		// From emaxi of emaxi.v
   wire [1:0]		m_axi_arlock;		// From emaxi of emaxi.v
   wire [2:0]		m_axi_arprot;		// From emaxi of emaxi.v
   wire [3:0]		m_axi_arqos;		// From emaxi of emaxi.v
   wire			m_axi_arready;		// From elink0 of axi_elink.v
   wire [2:0]		m_axi_arsize;		// From emaxi of emaxi.v
   wire			m_axi_arvalid;		// From emaxi of emaxi.v
   wire [31:0]		m_axi_awaddr;		// From emaxi of emaxi.v
   wire [1:0]		m_axi_awburst;		// From emaxi of emaxi.v
   wire [3:0]		m_axi_awcache;		// From emaxi of emaxi.v
   wire [M_IDW-1:0]	m_axi_awid;		// From emaxi of emaxi.v
   wire [7:0]		m_axi_awlen;		// From emaxi of emaxi.v
   wire [1:0]		m_axi_awlock;		// From emaxi of emaxi.v
   wire [2:0]		m_axi_awprot;		// From emaxi of emaxi.v
   wire [3:0]		m_axi_awqos;		// From emaxi of emaxi.v
   wire			m_axi_awready;		// From elink0 of axi_elink.v
   wire [2:0]		m_axi_awsize;		// From emaxi of emaxi.v
   wire			m_axi_awvalid;		// From emaxi of emaxi.v
   wire [S_IDW-1:0]	m_axi_bid;		// From elink0 of axi_elink.v
   wire			m_axi_bready;		// From emaxi of emaxi.v
   wire [1:0]		m_axi_bresp;		// From elink0 of axi_elink.v
   wire			m_axi_bvalid;		// From elink0 of axi_elink.v
   wire [31:0]		m_axi_rdata;		// From elink0 of axi_elink.v
   wire [S_IDW-1:0]	m_axi_rid;		// From elink0 of axi_elink.v
   wire			m_axi_rlast;		// From elink0 of axi_elink.v
   wire			m_axi_rready;		// From emaxi of emaxi.v
   wire [1:0]		m_axi_rresp;		// From elink0 of axi_elink.v
   wire			m_axi_rvalid;		// From elink0 of axi_elink.v
   wire [63:0]		m_axi_wdata;		// From emaxi of emaxi.v
   wire [M_IDW-1:0]	m_axi_wid;		// From emaxi of emaxi.v
   wire			m_axi_wlast;		// From emaxi of emaxi.v
   wire			m_axi_wready;		// From elink0 of axi_elink.v
   wire [7:0]		m_axi_wstrb;		// From emaxi of emaxi.v
   wire			m_axi_wvalid;		// From emaxi of emaxi.v
   // End of automatics
   
  
   //######################################################################
   //EMESH INTERFACE
   //######################################################################

   /*emesh_if AUTO_TEMPLATE (//Stimulus
                            .e2c_emesh_\(.*\)_in(\1_in[]),
                            .e2c_emesh_\(.*\)_out(\1_out[]),
                            //Response
                            .c2e_emesh_\(.*\)_out(\1_out[]),
                            .c2e_emesh_\(.*\)_in(\1_in[]),
                            .c2e_cmesh_\(.*\)_in(elink0_rxrr_\1[]),
                            //Link side transaction outgoing
                            .e2c_cmesh_\(.*\)_out(elink0_txwr_\1[]),
                            .e2c_cmesh_wait_in(elink0_txwr_wait),
                            .e2c_rmesh_\(.*\)_out(elink0_txrd_\1[]),
                            .e2c_rmesh_wait_in(elink0_txrd_wait), 
                            .c2e_\(.*\)_wait_out(),             
                             );
  */


   
   emesh_if #(.PW(PW)) emesh_if (.c2e_rmesh_access_in(1'b0),
				 .c2e_rmesh_packet_in({(PW){1'b0}}),
				 .c2e_xmesh_access_in(1'b0),
				 .c2e_xmesh_packet_in({(PW){1'b0}}),
				 .e2c_xmesh_wait_in(1'b0),
				 .e2c_xmesh_access_out(),
				 .e2c_xmesh_packet_out(),		      
				 /*AUTOINST*/
				 // Outputs
				 .c2e_cmesh_wait_out	(),		 // Templated
				 .e2c_cmesh_access_out	(elink0_txwr_access), // Templated
				 .e2c_cmesh_packet_out	(elink0_txwr_packet[PW-1:0]), // Templated
				 .c2e_rmesh_wait_out	(),		 // Templated
				 .e2c_rmesh_access_out	(elink0_txrd_access), // Templated
				 .e2c_rmesh_packet_out	(elink0_txrd_packet[PW-1:0]), // Templated
				 .c2e_xmesh_wait_out	(),		 // Templated
				 .e2c_emesh_wait_out	(wait_out),	 // Templated
				 .c2e_emesh_access_out	(access_out),	 // Templated
				 .c2e_emesh_packet_out	(packet_out[PW-1:0]), // Templated
				 // Inputs
				 .c2e_cmesh_access_in	(elink0_rxrr_access), // Templated
				 .c2e_cmesh_packet_in	(elink0_rxrr_packet[PW-1:0]), // Templated
				 .e2c_cmesh_wait_in	(elink0_txwr_wait), // Templated
				 .e2c_rmesh_wait_in	(elink0_txrd_wait), // Templated
				 .e2c_emesh_access_in	(access_in),	 // Templated
				 .e2c_emesh_packet_in	(packet_in[PW-1:0]), // Templated
				 .c2e_emesh_wait_in	(wait_in));	 // Templated
   

   //######################################################################
   //AXI MASTER
   //######################################################################
    /*emaxi AUTO_TEMPLATE (//Stimulus
               	.rxwr_access		(elink0_txwr_access),
		.rxwr_packet		(elink0_txwr_packet[PW-1:0]),
		.rxwr_wait		(elink0_txwr_wait),
		.rxrd_access		(elink0_txrd_access),
		.rxrd_packet		(elink0_txrd_packet[PW-1:0]),
		.rxrd_wait		(elink0_txrd_wait),	
		//outputs (read response back to monitor)
		.txrr_access		(elink0_rxrr_access),
		.txrr_packet		(elink0_rxrr_packet[PW-1:0]),
		.txrr_wait		(1'b0),
     );          
  */



   emaxi #(.M_IDW(M_IDW))
   emaxi (.m_axi_aclk		(clk),
	  .m_axi_aresetn	(nreset),
	  .m_axi_rdata		({m_axi_rdata[31:0],m_axi_rdata[31:0]}),
	  /*AUTOINST*/
	  // Outputs
	  .rxwr_wait			(elink0_txwr_wait),	 // Templated
	  .rxrd_wait			(elink0_txrd_wait),	 // Templated
	  .txrr_access			(elink0_rxrr_access),	 // Templated
	  .txrr_packet			(elink0_rxrr_packet[PW-1:0]), // Templated
	  .m_axi_awid			(m_axi_awid[M_IDW-1:0]),
	  .m_axi_awaddr			(m_axi_awaddr[31:0]),
	  .m_axi_awlen			(m_axi_awlen[7:0]),
	  .m_axi_awsize			(m_axi_awsize[2:0]),
	  .m_axi_awburst		(m_axi_awburst[1:0]),
	  .m_axi_awlock			(m_axi_awlock[1:0]),
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
	  .m_axi_arlock			(m_axi_arlock[1:0]),
	  .m_axi_arcache		(m_axi_arcache[3:0]),
	  .m_axi_arprot			(m_axi_arprot[2:0]),
	  .m_axi_arqos			(m_axi_arqos[3:0]),
	  .m_axi_arvalid		(m_axi_arvalid),
	  .m_axi_rready			(m_axi_rready),
	  // Inputs
	  .rxwr_access			(elink0_txwr_access),	 // Templated
	  .rxwr_packet			(elink0_txwr_packet[PW-1:0]), // Templated
	  .rxrd_access			(elink0_txrd_access),	 // Templated
	  .rxrd_packet			(elink0_txrd_packet[PW-1:0]), // Templated
	  .txrr_wait			(1'b0),			 // Templated
	  .m_axi_awready		(m_axi_awready),
	  .m_axi_wready			(m_axi_wready),
	  .m_axi_bid			(m_axi_bid[M_IDW-1:0]),
	  .m_axi_bresp			(m_axi_bresp[1:0]),
	  .m_axi_bvalid			(m_axi_bvalid),
	  .m_axi_arready		(m_axi_arready),
	  .m_axi_rid			(m_axi_rid[M_IDW-1:0]),
	  .m_axi_rresp			(m_axi_rresp[1:0]),
	  .m_axi_rlast			(m_axi_rlast),
	  .m_axi_rvalid			(m_axi_rvalid));
   
   
   
   //######################################################################
   //1ST ELINK
   //######################################################################


   /*axi_elink AUTO_TEMPLATE (
                          // Outputs                        
                          .sys_clk            (clk),
                          
                          .rxi_\(.*\)         (elink1_txo_\1[]),
                          .txi_\(.*\)         (elink1_rxo_\1[]),
                          .s_\(.*\)           (m_\1[]),
                          .\(.*\)             (@"(substring vl-cell-name  0 6)"_\1[]),

                         );
  */
   defparam elink0.ID    = 12'h810;   
   defparam elink0.ETYPE = 0; 
   axi_elink elink0 (.s_axi_aresetn	(nreset),
		     .reset             (~nreset), 
		     .elink_active	(dut_active),
		     .m_axi_aresetn	(1'b1),
		     .m_axi_awready	(1'b0),
		     .m_axi_wready	(1'b0),
		     .m_axi_bvalid	(1'b0),
		     .m_axi_arready	(1'b0),
		     .m_axi_rlast	(1'b0),
		     .m_axi_rvalid	(1'b0),
		     .m_axi_bid		(6'b0),
		     .m_axi_bresp	(2'b0),
		     .m_axi_rid		(6'b0),
		     .m_axi_rdata	(64'b0),
		     .m_axi_rresp	(2'b0),		    
		     /*AUTOINST*/
		     // Outputs
		     .rxo_wr_wait_p	(elink0_rxo_wr_wait_p),	 // Templated
		     .rxo_wr_wait_n	(elink0_rxo_wr_wait_n),	 // Templated
		     .rxo_rd_wait_p	(elink0_rxo_rd_wait_p),	 // Templated
		     .rxo_rd_wait_n	(elink0_rxo_rd_wait_n),	 // Templated
		     .txo_lclk_p	(elink0_txo_lclk_p),	 // Templated
		     .txo_lclk_n	(elink0_txo_lclk_n),	 // Templated
		     .txo_frame_p	(elink0_txo_frame_p),	 // Templated
		     .txo_frame_n	(elink0_txo_frame_n),	 // Templated
		     .txo_data_p	(elink0_txo_data_p[7:0]), // Templated
		     .txo_data_n	(elink0_txo_data_n[7:0]), // Templated
		     .chipid		(elink0_chipid[11:0]),	 // Templated
		     .chip_resetb	(elink0_chip_resetb),	 // Templated
		     .cclk_p		(elink0_cclk_p),	 // Templated
		     .cclk_n		(elink0_cclk_n),	 // Templated
		     .mailbox_not_empty	(elink0_mailbox_not_empty), // Templated
		     .mailbox_full	(elink0_mailbox_full),	 // Templated
		     .m_axi_awid	(elink0_m_axi_awid[M_IDW-1:0]), // Templated
		     .m_axi_awaddr	(elink0_m_axi_awaddr[31:0]), // Templated
		     .m_axi_awlen	(elink0_m_axi_awlen[7:0]), // Templated
		     .m_axi_awsize	(elink0_m_axi_awsize[2:0]), // Templated
		     .m_axi_awburst	(elink0_m_axi_awburst[1:0]), // Templated
		     .m_axi_awlock	(elink0_m_axi_awlock[1:0]), // Templated
		     .m_axi_awcache	(elink0_m_axi_awcache[3:0]), // Templated
		     .m_axi_awprot	(elink0_m_axi_awprot[2:0]), // Templated
		     .m_axi_awqos	(elink0_m_axi_awqos[3:0]), // Templated
		     .m_axi_awvalid	(elink0_m_axi_awvalid),	 // Templated
		     .m_axi_wid		(elink0_m_axi_wid[M_IDW-1:0]), // Templated
		     .m_axi_wdata	(elink0_m_axi_wdata[63:0]), // Templated
		     .m_axi_wstrb	(elink0_m_axi_wstrb[7:0]), // Templated
		     .m_axi_wlast	(elink0_m_axi_wlast),	 // Templated
		     .m_axi_wvalid	(elink0_m_axi_wvalid),	 // Templated
		     .m_axi_bready	(elink0_m_axi_bready),	 // Templated
		     .m_axi_arid	(elink0_m_axi_arid[M_IDW-1:0]), // Templated
		     .m_axi_araddr	(elink0_m_axi_araddr[31:0]), // Templated
		     .m_axi_arlen	(elink0_m_axi_arlen[7:0]), // Templated
		     .m_axi_arsize	(elink0_m_axi_arsize[2:0]), // Templated
		     .m_axi_arburst	(elink0_m_axi_arburst[1:0]), // Templated
		     .m_axi_arlock	(elink0_m_axi_arlock[1:0]), // Templated
		     .m_axi_arcache	(elink0_m_axi_arcache[3:0]), // Templated
		     .m_axi_arprot	(elink0_m_axi_arprot[2:0]), // Templated
		     .m_axi_arqos	(elink0_m_axi_arqos[3:0]), // Templated
		     .m_axi_arvalid	(elink0_m_axi_arvalid),	 // Templated
		     .m_axi_rready	(elink0_m_axi_rready),	 // Templated
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
		     .timeout		(elink0_timeout),	 // Templated
		     // Inputs
		     .sys_clk		(clk),			 // Templated
		     .rxi_lclk_p	(elink1_txo_lclk_p),	 // Templated
		     .rxi_lclk_n	(elink1_txo_lclk_n),	 // Templated
		     .rxi_frame_p	(elink1_txo_frame_p),	 // Templated
		     .rxi_frame_n	(elink1_txo_frame_n),	 // Templated
		     .rxi_data_p	(elink1_txo_data_p[7:0]), // Templated
		     .rxi_data_n	(elink1_txo_data_n[7:0]), // Templated
		     .txi_wr_wait_p	(elink1_rxo_wr_wait_p),	 // Templated
		     .txi_wr_wait_n	(elink1_rxo_wr_wait_n),	 // Templated
		     .txi_rd_wait_p	(elink1_rxo_rd_wait_p),	 // Templated
		     .txi_rd_wait_n	(elink1_rxo_rd_wait_n),	 // Templated
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


   //######################################################################
   //2ND ELINK (WITH EPIPHANY MEMORY)
   //######################################################################
   /*elink AUTO_TEMPLATE (
                          // Outputs                        
                          .sys_clk            (clk),
                          .sys_reset          (~nreset),
                          .rxi_\(.*\)         (elink0_txo_\1[]),
                          .txi_\(.*\)         (elink0_rxo_\1[]),
                          .\(.*\)             (@"(substring vl-cell-name  0 6)"_\1[]),

                         );
  */
   //No read/write from elink1 (for now)
   assign elink1_txrd_access = 1'b0;
   assign elink1_txrd_packet = 'b0;
   assign elink1_txwr_access = 1'b0;
   assign elink1_txwr_packet = 'b0;
   assign elink1_rxrr_wait   = 1'b0;
   
   defparam elink1.ID = 12'h820;   
   defparam elink1.ETYPE = 0; 

   elink elink1 (.rxrr_wait		(1'b0),
		 .txwr_access		(1'b0),
		 .txwr_packet		({(PW){1'b0}}),
		 .txrd_access		(1'b0),
		 .txrd_packet		({(PW){1'b0}}),
		 .txrr_access		(elink1_txrr_access),
		 .txrr_packet		(elink1_txrr_packet[PW-1:0]),		 
		 /*AUTOINST*/
		 // Outputs
		 .elink_active		(elink1_elink_active),	 // Templated
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
		 .sys_reset		(~nreset),		 // Templated
		 .sys_clk		(clk),			 // Templated
		 .rxi_lclk_p		(elink0_txo_lclk_p),	 // Templated
		 .rxi_lclk_n		(elink0_txo_lclk_n),	 // Templated
		 .rxi_frame_p		(elink0_txo_frame_p),	 // Templated
		 .rxi_frame_n		(elink0_txo_frame_n),	 // Templated
		 .rxi_data_p		(elink0_txo_data_p[7:0]), // Templated
		 .rxi_data_n		(elink0_txo_data_n[7:0]), // Templated
		 .txi_wr_wait_p		(elink0_rxo_wr_wait_p),	 // Templated
		 .txi_wr_wait_n		(elink0_rxo_wr_wait_n),	 // Templated
		 .txi_rd_wait_p		(elink0_rxo_rd_wait_p),	 // Templated
		 .txi_rd_wait_n		(elink0_rxo_rd_wait_n),	 // Templated
		 .rxwr_wait		(elink1_rxwr_wait),	 // Templated
		 .rxrd_wait		(elink1_rxrd_wait));	 // Templated
   

   //"Arbitration" between read/write transaction   
   assign  emem_access           = elink1_rxwr_access | elink1_rxrd_access;      

   assign  emem_packet[PW-1:0]   = elink1_rxwr_access ? elink1_rxwr_packet[PW-1:0]:
                                                        elink1_rxrd_packet[PW-1:0];

   assign elink1_rxrd_wait       = emem_wait | elink1_rxwr_access;
   assign elink1_rxwr_wait       = 1'b0;//TODO: elink1_random_wait
   
   /*ememory AUTO_TEMPLATE ( 
                        // Outputs
                        .\(.*\)_out       (elink1_txrr_\1[]),
                        .\(.*\)_in        (emem_\1[]),
                        .wait_out	  (emem_wait),
                        .reset            (~nreset),
                             );
   */

   ememory emem (.wait_in	        (elink1_txrr_wait),//pushback on reads
		 .clk		        (clk),
		 .wait_out		(emem_wait),
		 .coreid		(12'h0),
		 /*AUTOINST*/
		 // Outputs
		 .access_out		(elink1_txrr_access),	 // Templated
		 .packet_out		(elink1_txrr_packet[PW-1:0]), // Templated
		 // Inputs
		 .nreset		(nreset),
		 .access_in		(emem_access),		 // Templated
		 .packet_in		(emem_packet[PW-1:0]));	 // Templated

        
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

