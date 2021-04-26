module dut(/*AUTOARG*/
   // Outputs
   dut_active, wait_out, access_out, packet_out,
   // Inputs
   elink1_txo_lclk_p, elink1_txo_lclk_n, elink1_txo_frame_p,
   elink1_txo_frame_n, elink1_txo_data_p, elink1_txo_data_n,
   elink1_rxo_wr_wait_p, elink1_rxo_wr_wait_n, elink1_rxo_rd_wait_p,
   elink1_rxo_rd_wait_n, clk, nreset, vdd, vss, access_in, packet_in,
   wait_in
   );

   parameter AW    = 32;
   parameter DW    = 32;
   parameter CW    = 2; 
   parameter IDW   = 12;
   parameter M_IDW = 6;
   parameter S_IDW = 12;
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
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		elink1_rxo_rd_wait_n;	// To elink0 of elink.v
   input		elink1_rxo_rd_wait_p;	// To elink0 of elink.v
   input		elink1_rxo_wr_wait_n;	// To elink0 of elink.v
   input		elink1_rxo_wr_wait_p;	// To elink0 of elink.v
   input [7:0]		elink1_txo_data_n;	// To elink0 of elink.v
   input [7:0]		elink1_txo_data_p;	// To elink0 of elink.v
   input		elink1_txo_frame_n;	// To elink0 of elink.v
   input		elink1_txo_frame_p;	// To elink0 of elink.v
   input		elink1_txo_lclk_n;	// To elink0 of elink.v
   input		elink1_txo_lclk_p;	// To elink0 of elink.v
   // End of automatics
 
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
  

   // Beginning of automatic outputs (from unused autoinst outputs)

   // End of automatics
  
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			elink0_chip_nreset;	// From elink0 of elink.v
   wire			elink0_mailbox_irq;	// From elink0 of elink.v
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
   //1ST ELINK
   //######################################################################


   /*elink AUTO_TEMPLATE (
                          // Outputs                        
                          .sys_clk            (clk),
                          .sys_nreset         (nreset),
                          .rxi_\(.*\)         (elink1_txo_\1[]),
                          .txi_\(.*\)         (elink1_rxo_\1[]),
                          .\(.*\)             (@"(substring vl-cell-name  0 6)"_\1[]),

                         );
  */
   defparam elink0.ID    = 12'h810;   
   defparam elink0.ETYPE = 0; 
   elink elink0 (.elink_active		(dut_active),
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
		 .mailbox_irq		(elink0_mailbox_irq),	 // Templated
		 .rxrr_access		(elink0_rxrr_access),	 // Templated
		 .rxrr_packet		(elink0_rxrr_packet[PW-1:0]), // Templated
		 .txwr_wait		(elink0_txwr_wait),	 // Templated
		 .txrd_wait		(elink0_txrd_wait),	 // Templated
		 // Inputs
		 .sys_nreset		(nreset),		 // Templated
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
   //2ND ELINK (E16 REFERENCE MODEL)
   //######################################################################
   wire 		emem_wait;

   assign elink1_rxo_wr_wait_n = ~elink1_rxo_wr_wait_p;
   assign elink1_rxo_rd_wait_n = ~elink1_rxo_rd_wait_p;
   assign elink1_txo_frame_n   = ~elink1_txo_frame_p;
   assign elink1_txo_data_n    = ~elink1_txo_data_p;
   assign elink1_txo_lclk_n    = ~elink1_txo_lclk_p;
   
   elink_e16 elink_ref (
		     // Outputs
		     .rxi_rd_wait	(elink1_rxo_rd_wait_p),
		     .rxi_wr_wait	(elink1_rxo_wr_wait_p),
		     .txo_data		(elink1_txo_data_p[7:0]),
		     .txo_lclk		(elink1_txo_lclk_p),
		     .txo_frame		(elink1_txo_frame_p),
		     .c0_mesh_access_out(elink1_rcv_access),
		     .c0_mesh_write_out	(elink1_rcv_packet[0]),
		     .c0_mesh_dstaddr_out(elink1_rcv_packet[39:8]),
		     .c0_mesh_srcaddr_out(elink1_rcv_packet[103:72]),
		     .c0_mesh_data_out	(elink1_rcv_packet[71:40]),
		     .c0_mesh_datamode_out(elink1_rcv_packet[2:1]),
		     .c0_mesh_ctrlmode_out(elink1_rcv_packet[6:3]),
		     .c0_emesh_wait_out	(),
		     .c0_mesh_wait_out	(elink2_wait_out),
		     // Inputs
		     .reset		(~elink0_chip_nreset),
		     .c0_clk_in		(clk),
		     .c1_clk_in		(clk),
		     .c2_clk_in		(clk),
		     .c3_clk_in		(clk),
		     .rxi_data		(elink0_txo_data_p[7:0]),
		     .rxi_lclk		(elink0_txo_lclk_p),
		     .rxi_frame		(elink0_txo_frame_p),
		     .txo_rd_wait	(elink0_rxo_rd_wait_p),
		     .txo_wr_wait	(elink0_rxo_wr_wait_p),
                     .c0_mesh_wait_in	(emem_wait),//
		     .c0_mesh_write_in	(elink1_send_packet[0]),
		     .c0_mesh_dstaddr_in(elink1_send_packet[39:8]),
		     .c0_mesh_srcaddr_in(elink1_send_packet[103:72]),
		     .c0_mesh_data_in	(elink1_send_packet[71:40]),
		     .c0_mesh_datamode_in(elink1_send_packet[2:1]),
		     .c0_mesh_ctrlmode_in(elink1_send_packet[6:3])	     
		     );

   

  
   wire [103:0] elink1_rcv_packet;
   wire [103:0] elink1_send_packet;
   assign elink1_rcv_packet[7]=1'b0;
   
   //"Arbitration" between read/write transaction   
   assign emem_access           = elink1_rcv_access;

   assign emem_packet[PW-1:0]   = elink1_rcv_packet;
      
    
   /*ememory AUTO_TEMPLATE ( 
                        // Outputs
                        .\(.*\)_out       (elink1_txrr_\1[]),
                        .\(.*\)_in        (emem_\1[]),
                        .wait_out	  (emem_wait),
                             );
   */


   defparam emem.WAIT=1;
   ememory emem (.wait_in	        (1'b0),  //TODO: model burst reads!
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
// verilog-library-directories:("." "../hdl" "../../emesh/dv" "../../emesh/hdl")
// End:

