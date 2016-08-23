module erx_core (/*AUTOARG*/
   // Outputs
   rx_rd_wait, rx_wr_wait, idelay_value, load_taps, rxrd_access,
   rxrd_packet, rxrr_access, rxrr_packet, rxwr_access, rxwr_packet,
   erx_cfg_wait, mailbox_irq,
   // Inputs
   nreset, clk, rx_packet, rx_access, rx_burst, rxrd_wait, rxrr_wait,
   rxwr_wait, erx_cfg_access, erx_cfg_packet
   );

   parameter AW      = 32;
   parameter DW      = 32;
   parameter PW      = 104;
   parameter RFAW    = 6;
   parameter ID      = 12'h999;
   parameter TARGET  = "GENERIC";

   //clock and reset
   input		nreset;  //synced to clk
   input		clk;

   //IO Interface
   input [PW-1:0] 	rx_packet;
   input 		rx_access;
   input 		rx_burst;
   output 		rx_rd_wait;
   output 		rx_wr_wait;
   output [44:0] 	idelay_value;
   output 		load_taps;
   
   //FIFO Access
   output		rxrd_access;
   output [PW-1:0]	rxrd_packet;
   input		rxrd_wait;
   
   output		rxrr_access;
   output [PW-1:0]	rxrr_packet;
   input		rxrr_wait;
   
   output		rxwr_access;
   output [PW-1:0]	rxwr_packet;
   input		rxwr_wait;

   //register interface
   input		erx_cfg_access;
   input [PW-1:0]	erx_cfg_packet;
   output 		erx_cfg_wait;

   //mailbox outputs
   output		mailbox_irq;    
   
   /*AUTOINPUT*/
  
   // End of automatics
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			dma_access;		// From erx_cfg of erx_cfg.v
   wire			ecfg_access;		// From erx_cfg of erx_cfg.v
   wire [PW-1:0]	ecfg_packet;		// From erx_cfg of erx_cfg.v
   wire			edma_wait;		// From erx_arbiter of erx_arbiter.v
   wire			emesh_remap_access;	// From erx_remap of erx_remap.v
   wire [PW-1:0]	emesh_remap_packet;	// From erx_remap of erx_remap.v
   wire			emmu_access;		// From erx_mmu of emmu.v
   wire [PW-1:0]	emmu_packet;		// From erx_mmu of emmu.v
   wire			erx_access;		// From erx_protocol of erx_protocol.v
   wire [PW-1:0]	erx_packet;		// From erx_protocol of erx_protocol.v
   wire			mailbox_access;		// From erx_cfg of erx_cfg.v
   wire			mailbox_irq_en;		// From erx_cfg of erx_cfg.v
   wire [31:0]		mailbox_rdata;		// From erx_mailbox of emailbox.v
   wire			mailbox_wait;		// From erx_mailbox of emailbox.v
   wire			mmu_access;		// From erx_cfg of erx_cfg.v
   wire			mmu_enable;		// From erx_cfg of erx_cfg.v
   wire [31:0]		remap_base;		// From erx_cfg of erx_cfg.v
   wire [1:0]		remap_mode;		// From erx_cfg of erx_cfg.v
   wire [11:0]		remap_pattern;		// From erx_cfg of erx_cfg.v
   wire [11:0]		remap_sel;		// From erx_cfg of erx_cfg.v
   wire			test_mode;		// From erx_cfg of erx_cfg.v
   // End of automatics
     
   //regs
   wire [8:0] 		gpio_datain;
   wire [15:0] 		rx_status;
   wire 		rxwr_full;
   wire 		rxrr_full;
   wire 		rxrd_full;
   wire 		rxrd_empty;
   wire 		rxwr_empty;
   wire 		rxrr_empty;
   wire [103:0] 	edma_packet;
   

   /**************************************************************/
   /*ELINK PROTOCOL LOGIC                                        */
   /**************************************************************/

   erx_protocol #(.ID(ID))
   erx_protocol (/*AUTOINST*/
		 // Outputs
		 .erx_access		(erx_access),
		 .erx_packet		(erx_packet[PW-1:0]),
		 // Inputs
		 .clk			(clk),
		 .test_mode		(test_mode),
		 .rx_packet		(rx_packet[PW-1:0]),
		 .rx_burst		(rx_burst),
		 .rx_access		(rx_access));

   /**************************************************************/
   /*ADDRESS REMPAPPING                                          */
   /**************************************************************/

   /*erx_remap AUTO_TEMPLATE ( 
                        .emesh_\(.*\)_out	(emesh_remap_\1[]),   
                         //Inputs
                        .emesh_access_in        (erx_access),
                        .emesh_\(.*\)_in	(erx_\1[]),   
                        .mmu_en			(ecfg_rx_mmu_enable),
                        .emesh_packet_hi_out	(),
                           );
   */

   erx_remap #(.ID(ID))
   erx_remap (/*AUTOINST*/
	      // Outputs
	      .emesh_access_out		(emesh_remap_access),	 // Templated
	      .emesh_packet_out		(emesh_remap_packet[PW-1:0]), // Templated
	      // Inputs
	      .clk			(clk),
	      .emesh_access_in		(erx_access),		 // Templated
	      .emesh_packet_in		(erx_packet[PW-1:0]),	 // Templated
	      .remap_mode		(remap_mode[1:0]),
	      .remap_sel		(remap_sel[11:0]),
	      .remap_pattern		(remap_pattern[11:0]),
	      .remap_base		(remap_base[31:0]));
   
    
   /************************************************************/
   /*ELINK MEMORY MANAGEMENT UNIT                              */
   /************************************************************/
   /*emmu AUTO_TEMPLATE (.reg_access	       (mmu_access),
		         .reg_packet	       (erx_cfg_packet[PW-1:0]), 
                         .emesh_\(.*\)_out     (emmu_\1[]),   
                         .emesh_\(.*\)_in      (emesh_remap_\1[]),   
                         .mmu_en	       (mmu_enable),
                         .\(.*\)_clk           (clk),
                         );
   */

   emmu erx_mmu (.emesh_wait_in		(1'b0),
		 .reg_rdata		(),
		 /*AUTOINST*/
		 // Outputs
		 .emesh_access_out	(emmu_access),		 // Templated
		 .emesh_packet_out	(emmu_packet[PW-1:0]),	 // Templated
		 // Inputs
		 .nreset		(nreset),
		 .mmu_en		(mmu_enable),		 // Templated
		 .wr_clk		(clk),			 // Templated
		 .reg_access		(mmu_access),		 // Templated
		 .reg_packet		(erx_cfg_packet[PW-1:0]), // Templated
		 .rd_clk		(clk),			 // Templated
		 .emesh_access_in	(emesh_remap_access),	 // Templated
		 .emesh_packet_in	(emesh_remap_packet[PW-1:0])); // Templated
   
   /************************************************************/
   /*EMAILBOX                                                  */
   /************************************************************/
   /*emailbox AUTO_TEMPLATE ( 
    .mi_en              (mi_cfg_en),
    .mi_dout            (mi_mailbox_dout[]),
    .\(.*\)_clk		(clk),
    .emesh_\(.*\)	(emmu_\1[]),
    .reg_access		(mailbox_access),
    .reg_rdata		(mailbox_rdata[31:0]),
    .reg_packet		(erx_cfg_packet[PW-1:0]),
    );
        */

   emailbox #(.ID(ID), .TARGET(TARGET))
   erx_mailbox(
	       /*AUTOINST*/
	       // Outputs
	       .reg_rdata		(mailbox_rdata[31:0]),	 // Templated
	       .mailbox_irq		(mailbox_irq),
	       .mailbox_wait		(mailbox_wait),
	       // Inputs
	       .nreset			(nreset),
	       .wr_clk			(clk),			 // Templated
	       .rd_clk			(clk),			 // Templated
	       .emesh_access		(emmu_access),		 // Templated
	       .emesh_packet		(emmu_packet[PW-1:0]),	 // Templated
	       .reg_access		(mailbox_access),	 // Templated
	       .reg_packet		(erx_cfg_packet[PW-1:0]), // Templated
	       .mailbox_irq_en		(mailbox_irq_en));
      
   /************************************************************/
   /* ERX CONFIGURATION                                        */
   /************************************************************/
      
   erx_cfg erx_cfg (.gpio_datain	(9'b0),
		    .rx_status    	({11'b0,
					  rx_rd_wait,
					  rx_wr_wait,
					  rxrr_wait,
					  rxrd_wait,
					  rxwr_wait		       
					 }
					),
		    .edma_rdata		(32'b0),
		    /*AUTOINST*/
		    // Outputs
		    .mmu_access		(mmu_access),
		    .dma_access		(dma_access),
		    .mailbox_access	(mailbox_access),
		    .ecfg_access	(ecfg_access),
		    .ecfg_packet	(ecfg_packet[PW-1:0]),
		    .mmu_enable		(mmu_enable),
		    .remap_mode		(remap_mode[1:0]),
		    .remap_base		(remap_base[31:0]),
		    .remap_pattern	(remap_pattern[11:0]),
		    .remap_sel		(remap_sel[11:0]),
		    .idelay_value	(idelay_value[44:0]),
		    .load_taps		(load_taps),
		    .test_mode		(test_mode),
		    .mailbox_irq_en	(mailbox_irq_en),
		    // Inputs
		    .nreset		(nreset),
		    .clk		(clk),
		    .erx_cfg_access	(erx_cfg_access),
		    .erx_cfg_packet	(erx_cfg_packet[PW-1:0]),
		    .mailbox_rdata	(mailbox_rdata[31:0]),
		    .erx_access		(erx_access),
		    .erx_packet		(erx_packet[PW-1:0]));
   
				 
   /************************************************************/
   /*ELINK RECEIVE DISTRIBUTOR ("DEMUX")                       */
   /*(figures out who RX transaction belongs to)               */
   /************************************************************/
   /*erx_arbiter AUTO_TEMPLATE ( 
                        //Inputs
                        .mmu_en		(ecfg_rx_mmu_enable),
                        .ecfg_wait	(erx_cfg_wait),
                        .erx_access	(emmu_access),
			.erx_packet	(emmu_packet[PW-1:0]),
    )
    */

   erx_arbiter #(.ID(ID))
   erx_arbiter (.edma_access		(1'b0),
		.edma_packet		({(PW){1'b0}}),
		/*AUTOINST*/
		// Outputs
		.rx_rd_wait		(rx_rd_wait),
		.rx_wr_wait		(rx_wr_wait),
		.edma_wait		(edma_wait),
		.ecfg_wait		(erx_cfg_wait),		 // Templated
		.rxwr_access		(rxwr_access),
		.rxwr_packet		(rxwr_packet[PW-1:0]),
		.rxrd_access		(rxrd_access),
		.rxrd_packet		(rxrd_packet[PW-1:0]),
		.rxrr_access		(rxrr_access),
		.rxrr_packet		(rxrr_packet[PW-1:0]),
		// Inputs
		.erx_access		(emmu_access),		 // Templated
		.erx_packet		(emmu_packet[PW-1:0]),	 // Templated
		.mailbox_wait		(mailbox_wait),
		.ecfg_access		(ecfg_access),
		.ecfg_packet		(ecfg_packet[PW-1:0]),
		.rxwr_wait		(rxwr_wait),
		.rxrd_wait		(rxrd_wait),
		.rxrr_wait		(rxrr_wait));
   
endmodule // erx_core

// Local Variables:
// verilog-library-directories:("." "../../emmu/hdl" "../../edma/hdl" "../../memory/hdl" "../../emailbox/hdl")
// End:

