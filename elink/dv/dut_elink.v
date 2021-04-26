module dut(/*AUTOARG*/
   // Outputs
   clkout, dut_active, wait_out, access_out, packet_out,
   // Inputs
   clk1, clk2, nreset, vdd, vss, access_in, packet_in, wait_in
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
   input            clk1;
   input            clk2;
   output 	    clkout; 	    
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
   wire			elink0_txrd_wait;	// From emesh_if of emesh_if.v, ...
   wire			elink0_txwr_access;	// From emesh_if of emesh_if.v
   wire [PW-1:0]	elink0_txwr_packet;	// From emesh_if of emesh_if.v
   wire			elink0_txwr_wait;	// From elink0 of elink.v
   wire			elink1_chip_nreset;	// From elink1 of elink.v
   wire			elink1_elink_active;	// From elink1 of elink.v
   wire			elink1_mailbox_irq;	// From elink1 of elink.v
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
   // End of automatics

   //###################
   // GLUE
   //###################
   assign clkout = clk1;
   
   //######################################################################
   //EMESH INTERFACE
   //######################################################################

   /*emesh_if AUTO_TEMPLATE (//Stimulus
                            .emesh_\(.*\)_in(\1_in[]),
                            .emesh_\(.*\)_out(\1_out[]),
                            //Response
                            .emesh_\(.*\)_out(\1_out[]),
                            .emesh_\(.*\)_in(\1_in[]),
                            .cmesh_\(.*\)_in(elink0_rxrr_\1[]),
                            //Link side transaction outgoing
                            .cmesh_\(.*\)_out(elink0_txwr_\1[]),
                            .cmesh_wait_in(elink0_txwr_wait),
                            .rmesh_\(.*\)_out(elink0_txrd_\1[]),
                            .rmesh_wait_in(elink0_txrd_wait), 
                            .\(.*\)_wait_out(),             
                             );
  */
   
   emesh_if #(.AW(AW)) emesh_if (.rmesh_access_in(1'b0),
				 .rmesh_packet_in({(PW){1'b0}}),
				 .xmesh_access_in(1'b0),
				 .xmesh_packet_in({(PW){1'b0}}),
				 .xmesh_wait_in(1'b0),
				 .xmesh_access_out(),
				 .xmesh_packet_out(),
				 .cmesh_wait_out  (elink0_rxrr_wait),
				 /*AUTOINST*/
				 // Outputs
				 .cmesh_access_out	(elink0_txwr_access), // Templated
				 .cmesh_packet_out	(elink0_txwr_packet[PW-1:0]), // Templated
				 .rmesh_wait_out	(elink0_txrd_wait), // Templated
				 .rmesh_access_out	(elink0_txrd_access), // Templated
				 .rmesh_packet_out	(elink0_txrd_packet[PW-1:0]), // Templated
				 .xmesh_wait_out	(),		 // Templated
				 .emesh_wait_out	(wait_out),	 // Templated
				 .emesh_access_out	(access_out),	 // Templated
				 .emesh_packet_out	(packet_out[PW-1:0]), // Templated
				 // Inputs
				 .cmesh_access_in	(elink0_rxrr_access), // Templated
				 .cmesh_packet_in	(elink0_rxrr_packet[PW-1:0]), // Templated
				 .cmesh_wait_in		(elink0_txwr_wait), // Templated
				 .rmesh_wait_in		(elink0_txrd_wait), // Templated
				 .emesh_access_in	(access_in),	 // Templated
				 .emesh_packet_in	(packet_in[PW-1:0]), // Templated
				 .emesh_wait_in		(wait_in));	 // Templated
   
   
   
   //######################################################################
   //1ST ELINK
   //######################################################################


   /*elink AUTO_TEMPLATE (
                          // Outputs                        
                          .sys_clk            (clk1),
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
		 .rxrr_wait		(elink0_rxrr_wait),
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
		 .sys_clk		(clk1),			 // Templated
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


   //elink checker
   elink_monitor elink_monitor (.frame		(elink0_txo_frame_p),
				.clk		(elink0_txo_lclk_p),
				.din		(elink0_txo_data_p[7:0])
				);
   
   
   //######################################################################
   //2ND ELINK (WITH EPIPHANY MEMORY)
   //######################################################################
   /*elink AUTO_TEMPLATE (
                          // Outputs                        
                          .sys_clk            (clk1),
                          .sys_nreset         (nreset),
                          .rxi_\(.*\)         (elink0_txo_\1[]),
                          .txi_\(.*\)         (elink0_rxo_\1[]),
                          .\(.*\)             (@"(substring vl-cell-name  0 6)"_\1[]),

                         );
  */
   //No read/write from elink1 (for now)
   wire elink1_txrd_access = 1'b0;
   wire elink1_txrd_packet = 'b0;
   wire elink1_txwr_access = 1'b0;
   wire elink1_txwr_packet = 'b0;
   wire elink1_rxrr_wait   = 1'b0;
   
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
		 .chip_nreset		(elink1_chip_nreset),	 // Templated
		 .mailbox_irq		(elink1_mailbox_irq),	 // Templated
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
		 .sys_nreset		(nreset),		 // Templated
		 .sys_clk		(clk1),			 // Templated
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
   

   wire emem_wait;
   
   //"Arbitration" between read/write transaction   
   assign  emem_access           = elink1_rxwr_access |  elink1_rxrd_access;

   assign  emem_packet[PW-1:0]   = elink1_rxwr_access ? elink1_rxwr_packet[PW-1:0]:
                                                        elink1_rxrd_packet[PW-1:0];

   assign elink1_rxrd_wait       = emem_wait | elink1_rxwr_access;
   assign elink1_rxwr_wait       = emem_wait;
    
   /*ememory AUTO_TEMPLATE ( 
                        // Outputs
                        .\(.*\)_out       (elink1_txrr_\1[]),
                        .\(.*\)_in        (emem_\1[]),
                        .wait_out	  (emem_wait),
                             );
   */

   defparam emem.WAIT=0;   
   ememory emem (.wait_in	        (elink1_txrr_wait),//pushback on reads
		 .clk		        (clk1),
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

