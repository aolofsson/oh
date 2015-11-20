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
   wire			elink0_chip_nreset;	// From elink0 of elink.v
   wire			elink0_rxo_rd_wait_n;	// From elink0 of elink.v
   wire			elink0_rxo_rd_wait_p;	// From elink0 of elink.v
   wire			elink0_rxo_wr_wait_n;	// From elink0 of elink.v
   wire			elink0_rxo_wr_wait_p;	// From elink0 of elink.v
   wire			elink0_rxrr_access;	// From elink0 of elink.v
   wire [PW-1:0]	elink0_rxrr_packet;	// From elink0 of elink.v
   wire [7:0]		elink0_txo_data_n;	// From elink0 of elink.v
   wire [7:0]		elink0_txo_data_p;	// From elink0 of elink.v
   wire			elink0_txo_frame_n;	// From elink0 of elink.v
   wire			elink0_txo_frame_p;	// From elink0 of elink.v
   wire			elink0_txo_lclk_n;	// From elink0 of elink.v
   wire			elink0_txo_lclk_p;	// From elink0 of elink.v
   wire			elink0_txrd_access;	// From emesh_if of emesh_if.v
   wire [PW-1:0]	elink0_txrd_packet;	// From emesh_if of emesh_if.v
   wire			elink0_txrd_wait;	// From elink0 of elink.v
   wire			elink0_txwr_access;	// From emesh_if of emesh_if.v
   wire [PW-1:0]	elink0_txwr_packet;	// From emesh_if of emesh_if.v
   wire			elink0_txwr_wait;	// From elink0 of elink.v
   wire			elink1_chip_nreset;	// From elink1 of axi_elink.v
   wire			elink1_elink_active;	// From elink1 of axi_elink.v
   wire [31:0]		elink1_m_axi_araddr;	// From elink1 of axi_elink.v
   wire [1:0]		elink1_m_axi_arburst;	// From elink1 of axi_elink.v
   wire [3:0]		elink1_m_axi_arcache;	// From elink1 of axi_elink.v
   wire [M_IDW-1:0]	elink1_m_axi_arid;	// From elink1 of axi_elink.v
   wire [7:0]		elink1_m_axi_arlen;	// From elink1 of axi_elink.v
   wire			elink1_m_axi_arlock;	// From elink1 of axi_elink.v
   wire [2:0]		elink1_m_axi_arprot;	// From elink1 of axi_elink.v
   wire [3:0]		elink1_m_axi_arqos;	// From elink1 of axi_elink.v
   wire			elink1_m_axi_arready;	// From esaxi of esaxi.v
   wire [2:0]		elink1_m_axi_arsize;	// From elink1 of axi_elink.v
   wire			elink1_m_axi_arvalid;	// From elink1 of axi_elink.v
   wire [31:0]		elink1_m_axi_awaddr;	// From elink1 of axi_elink.v
   wire [1:0]		elink1_m_axi_awburst;	// From elink1 of axi_elink.v
   wire [3:0]		elink1_m_axi_awcache;	// From elink1 of axi_elink.v
   wire [M_IDW-1:0]	elink1_m_axi_awid;	// From elink1 of axi_elink.v
   wire [7:0]		elink1_m_axi_awlen;	// From elink1 of axi_elink.v
   wire			elink1_m_axi_awlock;	// From elink1 of axi_elink.v
   wire [2:0]		elink1_m_axi_awprot;	// From elink1 of axi_elink.v
   wire [3:0]		elink1_m_axi_awqos;	// From elink1 of axi_elink.v
   wire			elink1_m_axi_awready;	// From esaxi of esaxi.v
   wire [2:0]		elink1_m_axi_awsize;	// From elink1 of axi_elink.v
   wire			elink1_m_axi_awvalid;	// From elink1 of axi_elink.v
   wire [S_IDW-1:0]	elink1_m_axi_bid;	// From esaxi of esaxi.v
   wire			elink1_m_axi_bready;	// From elink1 of axi_elink.v
   wire [1:0]		elink1_m_axi_bresp;	// From esaxi of esaxi.v
   wire			elink1_m_axi_bvalid;	// From esaxi of esaxi.v
   wire [31:0]		elink1_m_axi_rdata;	// From esaxi of esaxi.v
   wire [S_IDW-1:0]	elink1_m_axi_rid;	// From esaxi of esaxi.v
   wire			elink1_m_axi_rlast;	// From esaxi of esaxi.v
   wire			elink1_m_axi_rready;	// From elink1 of axi_elink.v
   wire [1:0]		elink1_m_axi_rresp;	// From esaxi of esaxi.v
   wire			elink1_m_axi_rvalid;	// From esaxi of esaxi.v
   wire [63:0]		elink1_m_axi_wdata;	// From elink1 of axi_elink.v
   wire [M_IDW-1:0]	elink1_m_axi_wid;	// From elink1 of axi_elink.v
   wire			elink1_m_axi_wlast;	// From elink1 of axi_elink.v
   wire			elink1_m_axi_wready;	// From esaxi of esaxi.v
   wire [7:0]		elink1_m_axi_wstrb;	// From elink1 of axi_elink.v
   wire			elink1_m_axi_wvalid;	// From elink1 of axi_elink.v
   wire			elink1_rxo_rd_wait_n;	// From elink1 of axi_elink.v
   wire			elink1_rxo_rd_wait_p;	// From elink1 of axi_elink.v
   wire			elink1_rxo_wr_wait_n;	// From elink1 of axi_elink.v
   wire			elink1_rxo_wr_wait_p;	// From elink1 of axi_elink.v
   wire			elink1_rxrr_wait;	// From esaxi of esaxi.v
   wire [7:0]		elink1_txo_data_n;	// From elink1 of axi_elink.v
   wire [7:0]		elink1_txo_data_p;	// From elink1 of axi_elink.v
   wire			elink1_txo_frame_n;	// From elink1 of axi_elink.v
   wire			elink1_txo_frame_p;	// From elink1 of axi_elink.v
   wire			elink1_txo_lclk_n;	// From elink1 of axi_elink.v
   wire			elink1_txo_lclk_p;	// From elink1 of axi_elink.v
   wire			elink1_txrd_access;	// From esaxi of esaxi.v
   wire [PW-1:0]	elink1_txrd_packet;	// From esaxi of esaxi.v
   wire			elink1_txwr_access;	// From esaxi of esaxi.v
   wire [PW-1:0]	elink1_txwr_packet;	// From esaxi of esaxi.v
   wire			emem_txrd_access;	// From etx_fifo of etx_fifo.v
   wire [PW-1:0]	emem_txrd_packet;	// From etx_fifo of etx_fifo.v
   wire			emem_txrr_access;	// From etx_fifo of etx_fifo.v
   wire [PW-1:0]	emem_txrr_packet;	// From etx_fifo of etx_fifo.v
   wire			emem_txwr_access;	// From etx_fifo of etx_fifo.v
   wire [PW-1:0]	emem_txwr_packet;	// From etx_fifo of etx_fifo.v
   wire [31:0]		stub_m_axi_araddr;	// From aximaster_stub of aximaster_stub.v
   wire [1:0]		stub_m_axi_arburst;	// From aximaster_stub of aximaster_stub.v
   wire [3:0]		stub_m_axi_arcache;	// From aximaster_stub of aximaster_stub.v
   wire [M_IDW-1:0]	stub_m_axi_arid;	// From aximaster_stub of aximaster_stub.v
   wire [7:0]		stub_m_axi_arlen;	// From aximaster_stub of aximaster_stub.v
   wire			stub_m_axi_arlock;	// From aximaster_stub of aximaster_stub.v
   wire [2:0]		stub_m_axi_arprot;	// From aximaster_stub of aximaster_stub.v
   wire [3:0]		stub_m_axi_arqos;	// From aximaster_stub of aximaster_stub.v
   wire			stub_m_axi_arready;	// From elink1 of axi_elink.v
   wire [2:0]		stub_m_axi_arsize;	// From aximaster_stub of aximaster_stub.v
   wire			stub_m_axi_arvalid;	// From aximaster_stub of aximaster_stub.v
   wire [31:0]		stub_m_axi_awaddr;	// From aximaster_stub of aximaster_stub.v
   wire [1:0]		stub_m_axi_awburst;	// From aximaster_stub of aximaster_stub.v
   wire [3:0]		stub_m_axi_awcache;	// From aximaster_stub of aximaster_stub.v
   wire [M_IDW-1:0]	stub_m_axi_awid;	// From aximaster_stub of aximaster_stub.v
   wire [7:0]		stub_m_axi_awlen;	// From aximaster_stub of aximaster_stub.v
   wire			stub_m_axi_awlock;	// From aximaster_stub of aximaster_stub.v
   wire [2:0]		stub_m_axi_awprot;	// From aximaster_stub of aximaster_stub.v
   wire [3:0]		stub_m_axi_awqos;	// From aximaster_stub of aximaster_stub.v
   wire			stub_m_axi_awready;	// From elink1 of axi_elink.v
   wire [2:0]		stub_m_axi_awsize;	// From aximaster_stub of aximaster_stub.v
   wire			stub_m_axi_awvalid;	// From aximaster_stub of aximaster_stub.v
   wire [S_IDW-1:0]	stub_m_axi_bid;		// From elink1 of axi_elink.v
   wire			stub_m_axi_bready;	// From aximaster_stub of aximaster_stub.v
   wire [1:0]		stub_m_axi_bresp;	// From elink1 of axi_elink.v
   wire			stub_m_axi_bvalid;	// From elink1 of axi_elink.v
   wire [31:0]		stub_m_axi_rdata;	// From elink1 of axi_elink.v
   wire [S_IDW-1:0]	stub_m_axi_rid;		// From elink1 of axi_elink.v
   wire			stub_m_axi_rlast;	// From elink1 of axi_elink.v
   wire			stub_m_axi_rready;	// From aximaster_stub of aximaster_stub.v
   wire [1:0]		stub_m_axi_rresp;	// From elink1 of axi_elink.v
   wire			stub_m_axi_rvalid;	// From elink1 of axi_elink.v
   wire [63:0]		stub_m_axi_wdata;	// From aximaster_stub of aximaster_stub.v
   wire [M_IDW-1:0]	stub_m_axi_wid;		// From aximaster_stub of aximaster_stub.v
   wire			stub_m_axi_wlast;	// From aximaster_stub of aximaster_stub.v
   wire			stub_m_axi_wready;	// From elink1 of axi_elink.v
   wire [7:0]		stub_m_axi_wstrb;	// From aximaster_stub of aximaster_stub.v
   wire			stub_m_axi_wvalid;	// From aximaster_stub of aximaster_stub.v
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
   //AXI MASTER (DRIVES STIMULUS)
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

  /*
   emaxi #(.M_IDW(M_IDW))
   emaxi (.m_axi_aclk		(clk),
	  .m_axi_aresetn	(nreset),
	  .m_axi_rdata		({m_axi_rdata[31:0],m_axi_rdata[31:0]}),	  
	  );
   */
   
   
   //######################################################################
   //TIE OFF UNUSED MASTER PORT ON ELINK0
   //######################################################################
   /*axislave_stub AUTO_TEMPLATE (
                          // Outputs                        
                          .s_\(.*\)   (stub_m_\1[]),
                         );
    */

/*
   defparam axislave_stub.S_IDW = S_IDW;
   axislave_stub  axislave_stub (.s_axi_aclk	(clk),
				 .s_axi_aresetn	(nreset),
				 // Outputs
				 .s_axi_arready		(stub_m_axi_arready),
				 .s_axi_awready		(stub_m_axi_awready),
				 .s_axi_bid		(stub_m_axi_bid[S_IDW-1:0]),
				 .s_axi_bresp		(stub_m_axi_bresp[1:0]),
				 .s_axi_bvalid		(stub_m_axi_bvalid),
				 .s_axi_rid		(stub_m_axi_rid[S_IDW-1:0]),
				 .s_axi_rdata		(stub_m_axi_rdata[31:0]),
				 .s_axi_rlast		(stub_m_axi_rlast),
				 .s_axi_rresp		(stub_m_axi_rresp[1:0]),
				 .s_axi_rvalid		(stub_m_axi_rvalid),
				 .s_axi_wready		(stub_m_axi_wready),
				 // Inputs
				 .s_axi_arid		(stub_m_axi_arid[S_IDW-1:0]),
				 .s_axi_araddr		(stub_m_axi_araddr[31:0]),
				 .s_axi_arburst		(stub_m_axi_arburst[1:0]),
				 .s_axi_arcache		(stub_m_axi_arcache[3:0]),
				 .s_axi_arlock		(stub_m_axi_arlock),
				 .s_axi_arlen		(stub_m_axi_arlen[7:0]),
				 .s_axi_arprot		(stub_m_axi_arprot[2:0]),
				 .s_axi_arqos		(stub_m_axi_arqos[3:0]),
				 .s_axi_arsize		(stub_m_axi_arsize[2:0]),
				 .s_axi_arvalid		(stub_m_axi_arvalid),
				 .s_axi_awid		(stub_m_axi_awid[S_IDW-1:0]),
				 .s_axi_awaddr		(stub_m_axi_awaddr[31:0]),
				 .s_axi_awburst		(stub_m_axi_awburst[1:0]),
				 .s_axi_awcache		(stub_m_axi_awcache[3:0]),
				 .s_axi_awlock		(stub_m_axi_awlock),
				 .s_axi_awlen		(stub_m_axi_awlen[7:0]),
				 .s_axi_awprot		(stub_m_axi_awprot[2:0]),
				 .s_axi_awqos		(stub_m_axi_awqos[3:0]),
				 .s_axi_awsize		(stub_m_axi_awsize[2:0]),
				 .s_axi_awvalid		(stub_m_axi_awvalid),
				 .s_axi_bready		(stub_m_axi_bready),
				 .s_axi_rready		(stub_m_axi_rready),
				 .s_axi_wid		(stub_m_axi_wid[S_IDW-1:0]),
				 .s_axi_wdata		(stub_m_axi_wdata[31:0]),
				 .s_axi_wlast		(stub_m_axi_wlast),
				 .s_axi_wstrb		(stub_m_axi_wstrb[3:0]),
				 .s_axi_wvalid		(stub_m_axi_wvalid));
*/
   
   //######################################################################
   //1ST ELINK
   //######################################################################

/* .s_\(.*\)           (m_\1[]),
                          .m_\(.*\)           (stub_m_\1[]),
  .s_axi_wstrb	( m_axi_wstrb[3:0] | m_axi_wstrb[7:4] ),
		     .s_axi_aresetn	(nreset),
		     .sys_nreset        (nreset),  
		     .m_axi_aresetn	(nreset),
		     .elink_active	(dut_active),
 
 */
   
   /*elink AUTO_TEMPLATE (
                          // Outputs                        
                          .sys_clk            (clk),
                          
                          .rxi_\(.*\)         (elink1_txo_\1[]),
                          .txi_\(.*\)         (elink1_rxo_\1[]),
                         
                          .\(.*\)             (@"(substring vl-cell-name  0 6)"_\1[]),

                         );
  */

   defparam elink0.ID    = 12'h810;   
   defparam elink0.ETYPE = 0;
   elink elink0 (.sys_nreset		(nreset),
                 .elink_active		(dut_active),
		 .txrr_access		(1'b0),//not tested
		 .txrr_packet		({(PW){1'b0}}),	
		 .txrr_wait		(),    //not tested
		 .rxwr_access		(),
		 .rxwr_packet		(),
		 .rxrd_access		(),
		 .rxrd_packet		(),
		 .rxwr_wait		(1'b0),//not tested
		 .rxrd_wait		(1'b0),//not tested
		 .rxrr_wait		(1'b0),//not tested
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
		 .chip_nreset		(elink0_chip_nreset),	 // Templated
		 .mailbox_not_empty	(elink0_mailbox_not_empty), // Templated
		 .mailbox_full		(elink0_mailbox_full),	 // Templated
		 .timeout		(elink0_timeout),	 // Templated
		 .rxrr_access		(elink0_rxrr_access),	 // Templated
		 .rxrr_packet		(elink0_rxrr_packet[PW-1:0]), // Templated
		 .txwr_wait		(elink0_txwr_wait),	 // Templated
		 .txrd_wait		(elink0_txrd_wait),	 // Templated
		 // Inputs
		 .sys_clk		(clk),			 // Templated
		 .rxi_lclk_p		(elink1_txo_lclk_p),	 // Templated
		 .rxi_lclk_n		(elink1_txo_lclk_n),	 // Templated
		 .rxi_frame_p		(elink1_txo_frame_p),	 // Templated
		 .rxi_frame_n		(elink1_txo_frame_n),	 // Templated
		 .rxi_data_p		(elink1_txo_data_p[7:0]), // Templated
		 .rxi_data_n		(elink1_txo_data_n[7:0]), // Templated
		 .txi_wr_wait_p		(elink1_rxo_wr_wait_p),	 // Templated
		 .txi_wr_wait_n		(elink1_rxo_wr_wait_n),	 // Templated
		 .txi_rd_wait_p		(elink1_rxo_rd_wait_p),	 // Templated
		 .txi_rd_wait_n		(elink1_rxo_rd_wait_n),	 // Templated
		 .txwr_access		(elink0_txwr_access),	 // Templated
		 .txwr_packet		(elink0_txwr_packet[PW-1:0]), // Templated
		 .txrd_access		(elink0_txrd_access),	 // Templated
		 .txrd_packet		(elink0_txrd_packet[PW-1:0])); // Templated

  
   //######################################################################
   //2ND ELINK 
   //######################################################################
 
   /*axi_elink AUTO_TEMPLATE (
                          // Outputs                        
                          .sys_clk            (clk),
                          .rxi_\(.*\)         (elink1_txo_\1[]),
                          .txi_\(.*\)         (elink1_rxo_\1[]),
                          .s_\(.*\)           (stub_m_\1[]),
                          .m_\(.*\)           (elink1_m_\1[]),
                          .\(.*\)             (@"(substring vl-cell-name  0 6)"_\1[]),

    );
    */
      
   defparam elink1.ID    = 12'h820;   
   defparam elink1.ETYPE = 0; 
   defparam elink1.S_IDW = S_IDW;
   defparam elink1.M_IDW = M_IDW;
		   
   axi_elink elink1 ( .m_axi_rdata	({elink1_m_axi_rdata[31:0],elink1_m_axi_rdata[31:0]}),
		      .m_axi_aresetn	(nreset), 
		     .s_axi_aresetn	(nreset), 
		     .sys_nreset	(nreset),
		     .rxi_lclk_p	(elink0_txo_lclk_p),
		     .rxi_lclk_n	(elink0_txo_lclk_n),
		     .rxi_frame_p	(elink0_txo_frame_p),
		     .rxi_frame_n	(elink0_txo_frame_n),
		     .rxi_data_p	(elink0_txo_data_p[7:0]),
		     .rxi_data_n	(elink0_txo_data_n[7:0]),
		     .txi_wr_wait_p	(elink0_rxo_wr_wait_p),
		     .txi_wr_wait_n	(elink0_rxo_wr_wait_n),
		     .txi_rd_wait_p	(elink0_rxo_rd_wait_p),
		     .txi_rd_wait_n	(elink0_rxo_rd_wait_n),
		     /*AUTOINST*/
		     // Outputs
		     .elink_active	(elink1_elink_active),	 // Templated
		     .rxo_wr_wait_p	(elink1_rxo_wr_wait_p),	 // Templated
		     .rxo_wr_wait_n	(elink1_rxo_wr_wait_n),	 // Templated
		     .rxo_rd_wait_p	(elink1_rxo_rd_wait_p),	 // Templated
		     .rxo_rd_wait_n	(elink1_rxo_rd_wait_n),	 // Templated
		     .txo_lclk_p	(elink1_txo_lclk_p),	 // Templated
		     .txo_lclk_n	(elink1_txo_lclk_n),	 // Templated
		     .txo_frame_p	(elink1_txo_frame_p),	 // Templated
		     .txo_frame_n	(elink1_txo_frame_n),	 // Templated
		     .txo_data_p	(elink1_txo_data_p[7:0]), // Templated
		     .txo_data_n	(elink1_txo_data_n[7:0]), // Templated
		     .chipid		(elink1_chipid[11:0]),	 // Templated
		     .chip_nreset	(elink1_chip_nreset),	 // Templated
		     .cclk_p		(elink1_cclk_p),	 // Templated
		     .cclk_n		(elink1_cclk_n),	 // Templated
		     .mailbox_not_empty	(elink1_mailbox_not_empty), // Templated
		     .mailbox_full	(elink1_mailbox_full),	 // Templated
		     .m_axi_awid	(elink1_m_axi_awid[M_IDW-1:0]), // Templated
		     .m_axi_awaddr	(elink1_m_axi_awaddr[31:0]), // Templated
		     .m_axi_awlen	(elink1_m_axi_awlen[7:0]), // Templated
		     .m_axi_awsize	(elink1_m_axi_awsize[2:0]), // Templated
		     .m_axi_awburst	(elink1_m_axi_awburst[1:0]), // Templated
		     .m_axi_awlock	(elink1_m_axi_awlock),	 // Templated
		     .m_axi_awcache	(elink1_m_axi_awcache[3:0]), // Templated
		     .m_axi_awprot	(elink1_m_axi_awprot[2:0]), // Templated
		     .m_axi_awqos	(elink1_m_axi_awqos[3:0]), // Templated
		     .m_axi_awvalid	(elink1_m_axi_awvalid),	 // Templated
		     .m_axi_wid		(elink1_m_axi_wid[M_IDW-1:0]), // Templated
		     .m_axi_wdata	(elink1_m_axi_wdata[63:0]), // Templated
		     .m_axi_wstrb	(elink1_m_axi_wstrb[7:0]), // Templated
		     .m_axi_wlast	(elink1_m_axi_wlast),	 // Templated
		     .m_axi_wvalid	(elink1_m_axi_wvalid),	 // Templated
		     .m_axi_bready	(elink1_m_axi_bready),	 // Templated
		     .m_axi_arid	(elink1_m_axi_arid[M_IDW-1:0]), // Templated
		     .m_axi_araddr	(elink1_m_axi_araddr[31:0]), // Templated
		     .m_axi_arlen	(elink1_m_axi_arlen[7:0]), // Templated
		     .m_axi_arsize	(elink1_m_axi_arsize[2:0]), // Templated
		     .m_axi_arburst	(elink1_m_axi_arburst[1:0]), // Templated
		     .m_axi_arlock	(elink1_m_axi_arlock),	 // Templated
		     .m_axi_arcache	(elink1_m_axi_arcache[3:0]), // Templated
		     .m_axi_arprot	(elink1_m_axi_arprot[2:0]), // Templated
		     .m_axi_arqos	(elink1_m_axi_arqos[3:0]), // Templated
		     .m_axi_arvalid	(elink1_m_axi_arvalid),	 // Templated
		     .m_axi_rready	(elink1_m_axi_rready),	 // Templated
		     .s_axi_arready	(stub_m_axi_arready),	 // Templated
		     .s_axi_awready	(stub_m_axi_awready),	 // Templated
		     .s_axi_bid		(stub_m_axi_bid[S_IDW-1:0]), // Templated
		     .s_axi_bresp	(stub_m_axi_bresp[1:0]), // Templated
		     .s_axi_bvalid	(stub_m_axi_bvalid),	 // Templated
		     .s_axi_rid		(stub_m_axi_rid[S_IDW-1:0]), // Templated
		     .s_axi_rdata	(stub_m_axi_rdata[31:0]), // Templated
		     .s_axi_rlast	(stub_m_axi_rlast),	 // Templated
		     .s_axi_rresp	(stub_m_axi_rresp[1:0]), // Templated
		     .s_axi_rvalid	(stub_m_axi_rvalid),	 // Templated
		     .s_axi_wready	(stub_m_axi_wready),	 // Templated
		     .timeout		(elink1_timeout),	 // Templated
		     // Inputs
		     .sys_clk		(clk),			 // Templated
		     .m_axi_awready	(elink1_m_axi_awready),	 // Templated
		     .m_axi_wready	(elink1_m_axi_wready),	 // Templated
		     .m_axi_bid		(elink1_m_axi_bid[M_IDW-1:0]), // Templated
		     .m_axi_bresp	(elink1_m_axi_bresp[1:0]), // Templated
		     .m_axi_bvalid	(elink1_m_axi_bvalid),	 // Templated
		     .m_axi_arready	(elink1_m_axi_arready),	 // Templated
		     .m_axi_rid		(elink1_m_axi_rid[M_IDW-1:0]), // Templated
		     .m_axi_rresp	(elink1_m_axi_rresp[1:0]), // Templated
		     .m_axi_rlast	(elink1_m_axi_rlast),	 // Templated
		     .m_axi_rvalid	(elink1_m_axi_rvalid),	 // Templated
		     .s_axi_arid	(stub_m_axi_arid[S_IDW-1:0]), // Templated
		     .s_axi_araddr	(stub_m_axi_araddr[31:0]), // Templated
		     .s_axi_arburst	(stub_m_axi_arburst[1:0]), // Templated
		     .s_axi_arcache	(stub_m_axi_arcache[3:0]), // Templated
		     .s_axi_arlock	(stub_m_axi_arlock),	 // Templated
		     .s_axi_arlen	(stub_m_axi_arlen[7:0]), // Templated
		     .s_axi_arprot	(stub_m_axi_arprot[2:0]), // Templated
		     .s_axi_arqos	(stub_m_axi_arqos[3:0]), // Templated
		     .s_axi_arsize	(stub_m_axi_arsize[2:0]), // Templated
		     .s_axi_arvalid	(stub_m_axi_arvalid),	 // Templated
		     .s_axi_awid	(stub_m_axi_awid[S_IDW-1:0]), // Templated
		     .s_axi_awaddr	(stub_m_axi_awaddr[31:0]), // Templated
		     .s_axi_awburst	(stub_m_axi_awburst[1:0]), // Templated
		     .s_axi_awcache	(stub_m_axi_awcache[3:0]), // Templated
		     .s_axi_awlock	(stub_m_axi_awlock),	 // Templated
		     .s_axi_awlen	(stub_m_axi_awlen[7:0]), // Templated
		     .s_axi_awprot	(stub_m_axi_awprot[2:0]), // Templated
		     .s_axi_awqos	(stub_m_axi_awqos[3:0]), // Templated
		     .s_axi_awsize	(stub_m_axi_awsize[2:0]), // Templated
		     .s_axi_awvalid	(stub_m_axi_awvalid),	 // Templated
		     .s_axi_bready	(stub_m_axi_bready),	 // Templated
		     .s_axi_rready	(stub_m_axi_rready),	 // Templated
		     .s_axi_wid		(stub_m_axi_wid[S_IDW-1:0]), // Templated
		     .s_axi_wdata	(stub_m_axi_wdata[31:0]), // Templated
		     .s_axi_wlast	(stub_m_axi_wlast),	 // Templated
		     .s_axi_wstrb	(stub_m_axi_wstrb[3:0]), // Templated
		     .s_axi_wvalid	(stub_m_axi_wvalid));	 // Templated

   //######################################################################
   //TIE OFF UNUSED SLAVE PORT ON ELINK1
   //######################################################################
   
   /*aximaster_stub AUTO_TEMPLATE (
                          // Outputs                        
                          .m_\(.*\)           (stub_m_\1[]),
                         );
    */
   aximaster_stub 
     #(.M_IDW(M_IDW)) 
   aximaster_stub (.m_axi_aclk		(aclk),
		   .m_axi_aresetn	(nreset),
		  /*AUTOINST*/
		   // Outputs
		   .m_axi_awid		(stub_m_axi_awid[M_IDW-1:0]), // Templated
		   .m_axi_awaddr	(stub_m_axi_awaddr[31:0]), // Templated
		   .m_axi_awlen		(stub_m_axi_awlen[7:0]), // Templated
		   .m_axi_awsize	(stub_m_axi_awsize[2:0]), // Templated
		   .m_axi_awburst	(stub_m_axi_awburst[1:0]), // Templated
		   .m_axi_awlock	(stub_m_axi_awlock),	 // Templated
		   .m_axi_awcache	(stub_m_axi_awcache[3:0]), // Templated
		   .m_axi_awprot	(stub_m_axi_awprot[2:0]), // Templated
		   .m_axi_awqos		(stub_m_axi_awqos[3:0]), // Templated
		   .m_axi_awvalid	(stub_m_axi_awvalid),	 // Templated
		   .m_axi_wid		(stub_m_axi_wid[M_IDW-1:0]), // Templated
		   .m_axi_wdata		(stub_m_axi_wdata[63:0]), // Templated
		   .m_axi_wstrb		(stub_m_axi_wstrb[7:0]), // Templated
		   .m_axi_wlast		(stub_m_axi_wlast),	 // Templated
		   .m_axi_wvalid	(stub_m_axi_wvalid),	 // Templated
		   .m_axi_bready	(stub_m_axi_bready),	 // Templated
		   .m_axi_arid		(stub_m_axi_arid[M_IDW-1:0]), // Templated
		   .m_axi_araddr	(stub_m_axi_araddr[31:0]), // Templated
		   .m_axi_arlen		(stub_m_axi_arlen[7:0]), // Templated
		   .m_axi_arsize	(stub_m_axi_arsize[2:0]), // Templated
		   .m_axi_arburst	(stub_m_axi_arburst[1:0]), // Templated
		   .m_axi_arlock	(stub_m_axi_arlock),	 // Templated
		   .m_axi_arcache	(stub_m_axi_arcache[3:0]), // Templated
		   .m_axi_arprot	(stub_m_axi_arprot[2:0]), // Templated
		   .m_axi_arqos		(stub_m_axi_arqos[3:0]), // Templated
		   .m_axi_arvalid	(stub_m_axi_arvalid),	 // Templated
		   .m_axi_rready	(stub_m_axi_rready),	 // Templated
		   // Inputs
		   .m_axi_awready	(stub_m_axi_awready),	 // Templated
		   .m_axi_wready	(stub_m_axi_wready),	 // Templated
		   .m_axi_bid		(stub_m_axi_bid[M_IDW-1:0]), // Templated
		   .m_axi_bresp		(stub_m_axi_bresp[1:0]), // Templated
		   .m_axi_bvalid	(stub_m_axi_bvalid),	 // Templated
		   .m_axi_arready	(stub_m_axi_arready),	 // Templated
		   .m_axi_rid		(stub_m_axi_rid[M_IDW-1:0]), // Templated
		   .m_axi_rdata		(stub_m_axi_rdata[63:0]), // Templated
		   .m_axi_rresp		(stub_m_axi_rresp[1:0]), // Templated
		   .m_axi_rlast		(stub_m_axi_rlast),	 // Templated
		   .m_axi_rvalid	(stub_m_axi_rvalid));	 // Templated

   //######################################################################
   //AXI SLAVE PORT FOR MEMORY
   //######################################################################
   
   /*esaxi AUTO_TEMPLATE (
    .s_\(.*\)           (elink1_m_\1[]),
    .\(.*\) (elink1_\1[]),
    .\(.*\) (elink1_\1[]),

                         );
    */
   
   esaxi #(.S_IDW(S_IDW)) esaxi (.s_axi_aclk		(clk),
				 .s_axi_aresetn		(nreset),
				 .s_axi_wstrb	        ( elink1_m_axi_wstrb[3:0] | elink1_m_axi_wstrb[7:4] ),
				 /*AUTOINST*/
				 // Outputs
				 .txwr_access		(elink1_txwr_access), // Templated
				 .txwr_packet		(elink1_txwr_packet[PW-1:0]), // Templated
				 .txrd_access		(elink1_txrd_access), // Templated
				 .txrd_packet		(elink1_txrd_packet[PW-1:0]), // Templated
				 .rxrr_wait		(elink1_rxrr_wait), // Templated
				 .s_axi_arready		(elink1_m_axi_arready), // Templated
				 .s_axi_awready		(elink1_m_axi_awready), // Templated
				 .s_axi_bid		(elink1_m_axi_bid[S_IDW-1:0]), // Templated
				 .s_axi_bresp		(elink1_m_axi_bresp[1:0]), // Templated
				 .s_axi_bvalid		(elink1_m_axi_bvalid), // Templated
				 .s_axi_rid		(elink1_m_axi_rid[S_IDW-1:0]), // Templated
				 .s_axi_rdata		(elink1_m_axi_rdata[31:0]), // Templated
				 .s_axi_rlast		(elink1_m_axi_rlast), // Templated
				 .s_axi_rresp		(elink1_m_axi_rresp[1:0]), // Templated
				 .s_axi_rvalid		(elink1_m_axi_rvalid), // Templated
				 .s_axi_wready		(elink1_m_axi_wready), // Templated
				 // Inputs
				 .txwr_wait		(elink1_txwr_wait), // Templated
				 .txrd_wait		(elink1_txrd_wait), // Templated
				 .rxrr_access		(elink1_rxrr_access), // Templated
				 .rxrr_packet		(elink1_rxrr_packet[PW-1:0]), // Templated
				 .s_axi_arid		(elink1_m_axi_arid[S_IDW-1:0]), // Templated
				 .s_axi_araddr		(elink1_m_axi_araddr[31:0]), // Templated
				 .s_axi_arburst		(elink1_m_axi_arburst[1:0]), // Templated
				 .s_axi_arcache		(elink1_m_axi_arcache[3:0]), // Templated
				 .s_axi_arlock		(elink1_m_axi_arlock), // Templated
				 .s_axi_arlen		(elink1_m_axi_arlen[7:0]), // Templated
				 .s_axi_arprot		(elink1_m_axi_arprot[2:0]), // Templated
				 .s_axi_arqos		(elink1_m_axi_arqos[3:0]), // Templated
				 .s_axi_arsize		(elink1_m_axi_arsize[2:0]), // Templated
				 .s_axi_arvalid		(elink1_m_axi_arvalid), // Templated
				 .s_axi_awid		(elink1_m_axi_awid[S_IDW-1:0]), // Templated
				 .s_axi_awaddr		(elink1_m_axi_awaddr[31:0]), // Templated
				 .s_axi_awburst		(elink1_m_axi_awburst[1:0]), // Templated
				 .s_axi_awcache		(elink1_m_axi_awcache[3:0]), // Templated
				 .s_axi_awlock		(elink1_m_axi_awlock), // Templated
				 .s_axi_awlen		(elink1_m_axi_awlen[7:0]), // Templated
				 .s_axi_awprot		(elink1_m_axi_awprot[2:0]), // Templated
				 .s_axi_awqos		(elink1_m_axi_awqos[3:0]), // Templated
				 .s_axi_awsize		(elink1_m_axi_awsize[2:0]), // Templated
				 .s_axi_awvalid		(elink1_m_axi_awvalid), // Templated
				 .s_axi_bready		(elink1_m_axi_bready), // Templated
				 .s_axi_rready		(elink1_m_axi_rready), // Templated
				 .s_axi_wid		(elink1_m_axi_wid[S_IDW-1:0]), // Templated
				 .s_axi_wdata		(elink1_m_axi_wdata[31:0]), // Templated
				 .s_axi_wlast		(elink1_m_axi_wlast), // Templated
				 .s_axi_wvalid		(elink1_m_axi_wvalid)); // Templated

   /*etx_fifo AUTO_TEMPLATE (
                          .\(.*\)_fifo_\(.*\) (emem_\1_\2[]),	
                          .\(.*\)	      (elink1_\1[]),

    );
    */

   etx_fifo etx_fifo (.sys_nreset	(nreset),
		      .sys_clk		(clk),
		      .tx_lclk_div4	(clk),
		      .txrd_fifo_wait	(emem_txrd_wait),
		      .txrr_fifo_wait	(emem_txrr_wait),
		      .txwr_fifo_wait	(emem_txwr_wait),
		      /*AUTOINST*/
		      // Outputs
		      .txrd_wait	(elink1_txrd_wait),	 // Templated
		      .txwr_wait	(elink1_txwr_wait),	 // Templated
		      .txrr_wait	(elink1_txrr_wait),	 // Templated
		      .txrd_fifo_access	(emem_txrd_access),	 // Templated
		      .txrd_fifo_packet	(emem_txrd_packet[PW-1:0]), // Templated
		      .txrr_fifo_access	(emem_txrr_access),	 // Templated
		      .txrr_fifo_packet	(emem_txrr_packet[PW-1:0]), // Templated
		      .txwr_fifo_access	(emem_txwr_access),	 // Templated
		      .txwr_fifo_packet	(emem_txwr_packet[PW-1:0]), // Templated
		      // Inputs
		      .txrd_access	(elink1_txrd_access),	 // Templated
		      .txrd_packet	(elink1_txrd_packet[PW-1:0]), // Templated
		      .txwr_access	(elink1_txwr_access),	 // Templated
		      .txwr_packet	(elink1_txwr_packet[PW-1:0]), // Templated
		      .txrr_access	(elink1_txrr_access),	 // Templated
		      .txrr_packet	(elink1_txrr_packet[PW-1:0])); // Templated
   

   //######################################################################
   //AXI SLAVE PORT FOR MEMORY
   //######################################################################
   
   //"Arbitration" between read/write transaction   
   assign  emem_access           = emem_txwr_access | emem_txrd_access;
   
   assign  emem_packet[PW-1:0]   = emem_txwr_access ? emem_txwr_packet[PW-1:0]:
                                                      emem_txrd_packet[PW-1:0];

   //HACK!
   assign emem_txrd_wait      = (emem_wait & emem_txrd_access) | emem_txwr_access;
   assign emem_txwr_wait      = (emem_wait & emem_txwr_access);
   
   /*ememory AUTO_TEMPLATE ( 
                        // Outputsd
                        .\(.*\)_out       (elink1_rxrr_\1[]),
                        .\(.*\)_in        (emem_\1[]),
                        .wait_out	  (emem_wait),
                             );
   */

   ememory emem (.wait_in	        (elink1_rxrr_wait),//pushback on reads
		 .clk		        (clk),
		 .wait_out		(emem_wait),
		 .coreid		(12'h0),
		 /*AUTOINST*/
		 // Outputs
		 .access_out		(elink1_rxrr_access),	 // Templated
		 .packet_out		(elink1_rxrr_packet[PW-1:0]), // Templated
		 // Inputs
		 .nreset		(nreset),
		 .access_in		(emem_access),		 // Templated
		 .packet_in		(emem_packet[PW-1:0]));	 // Templated

endmodule // dv_elink
// Local Variables:
// verilog-library-directories:("." "../hdl" "../../emesh/dv" "../../axi/dv" "../../emesh/hdl" "../../memory/hdl")
// End:


