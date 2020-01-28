module etx_core(/*AUTOARG*/
   // Outputs
   tx_data_slow, tx_frame_slow, txrd_wait, txrr_wait, txwr_wait,
   etx_cfg_access, etx_cfg_packet,
   // Inputs
   nreset, clk, tx_rd_wait, tx_wr_wait, txrd_access, txrd_packet,
   txrd_full, txrr_access, txrr_packet, txrr_full, txwr_access,
   txwr_packet, txwr_full, etx_cfg_wait
   );
   parameter AW      = 32;
   parameter DW      = 32;
   parameter PW      = 104;
   parameter RFAW    = 6;
   parameter ID      = 12'h999;
   
   //Clocks,reset,config
   input           nreset;
   input 	   clk;   
  
   //IO interface
   output [63:0]   tx_data_slow;
   output [3:0]    tx_frame_slow;     
   input 	   tx_rd_wait;
   input 	   tx_wr_wait;
   
   //TXRD
   input 	   txrd_access;
   input [PW-1:0]  txrd_packet;
   output 	   txrd_wait;
   input 	   txrd_full;//sysclk domain
   
   //TXRR
   input 	   txrr_access;
   input [PW-1:0]  txrr_packet;
   output 	   txrr_wait;
   input 	   txrr_full;//sysclk domain
   
   //TXWR
   input 	   txwr_access;
   input [PW-1:0]  txwr_packet;
   output 	   txwr_wait;
   input 	   txwr_full; //sysclk domain
   
   //Configuration Interface (for ERX)
   output 	   etx_cfg_access;
   output [PW-1:0] etx_cfg_packet;
   input 	   etx_cfg_wait;

   //for status?
   wire[15:0] 	   tx_status; 
     
   // End of automatics
   /*AUTOINPUT*/
        
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			burst_enable;		// From etx_cfg of etx_cfg.v
   wire			cfg_access;		// From etx_arbiter of etx_arbiter.v
   wire			cfg_mmu_access;		// From etx_cfg of etx_cfg.v
   wire [3:0]		ctrlmode;		// From etx_cfg of etx_cfg.v
   wire			ctrlmode_bypass;	// From etx_cfg of etx_cfg.v
   wire			emmu_access;		// From etx_mmu of emmu.v
   wire [PW-1:0]	emmu_packet;		// From etx_mmu of emmu.v
   wire			etx_access;		// From etx_arbiter of etx_arbiter.v
   wire [PW-1:0]	etx_packet;		// From etx_arbiter of etx_arbiter.v
   wire			etx_rd_wait;		// From etx_protocol of etx_protocol.v
   wire			etx_remap_access;	// From etx_remap of etx_remap.v
   wire [PW-1:0]	etx_remap_packet;	// From etx_remap of etx_remap.v
   wire			etx_wait;		// From etx_protocol of etx_protocol.v
   wire			etx_wr_wait;		// From etx_protocol of etx_protocol.v
   wire [8:0]		gpio_data;		// From etx_cfg of etx_cfg.v
   wire			gpio_enable;		// From etx_cfg of etx_cfg.v
   wire			mmu_enable;		// From etx_cfg of etx_cfg.v
   wire			remap_enable;		// From etx_cfg of etx_cfg.v
   wire			tx_access;		// From etx_protocol of etx_protocol.v
   wire			tx_burst;		// From etx_protocol of etx_protocol.v
   wire			tx_enable;		// From etx_cfg of etx_cfg.v
   // End of automatics
        
   //##################################################################
   //# ARBITER (SELECT BETWEEN TX, RX, RR)
   //##################################################################

   etx_arbiter #(.ID(ID))
   etx_arbiter (
		/*AUTOINST*/
		// Outputs
		.txwr_wait		(txwr_wait),
		.txrd_wait		(txrd_wait),
		.txrr_wait		(txrr_wait),
		.etx_access		(etx_access),
		.cfg_access		(cfg_access),
		.etx_packet		(etx_packet[PW-1:0]),
		// Inputs
		.clk			(clk),
		.nreset			(nreset),
		.txwr_access		(txwr_access),
		.txwr_packet		(txwr_packet[PW-1:0]),
		.txrd_access		(txrd_access),
		.txrd_packet		(txrd_packet[PW-1:0]),
		.txrr_access		(txrr_access),
		.txrr_packet		(txrr_packet[PW-1:0]),
		.etx_wait		(etx_wait),
		.etx_cfg_wait		(etx_cfg_wait));
   
   //##################################################################
   //# REMAPPING DESTINATION ADDRESS
   //##################################################################
   /*etx_remap  AUTO_TEMPLATE (	
                          .emesh_\(.*\)_in  (etx_\1[]),
                          .emesh_\(.*\)_out (etx_remap_\1[]),
                          .remap_en	    (remap_enable),
                          );
   */

   etx_remap etx_remap (
			/*AUTOINST*/
			// Outputs
			.emesh_access_out(etx_remap_access),	 // Templated
			.emesh_packet_out(etx_remap_packet[PW-1:0]), // Templated
			// Inputs
			.clk		(clk),
			.nreset		(nreset),
			.emesh_access_in(etx_access),		 // Templated
			.emesh_packet_in(etx_packet[PW-1:0]),	 // Templated
			.remap_en	(remap_enable),		 // Templated
			.etx_wait	(etx_wait));
   

   //##################################################################
   //# TABLE LOOKUP ADDRESS TRANSLATION
   //##################################################################
  
   /*emmu  AUTO_TEMPLATE (.reg_access	       (cfg_mmu_access),
		          .reg_packet	       (etx_packet[PW-1:0]),	
                          .emesh_\(.*\)_in     (etx_remap_\1[]),
                          .emesh_\(.*\)_out    (emmu_\1[]),
                          .mmu_en	       (mmu_enable),
                          .\(.*\)_clk          (clk),
                          .emesh_wait_in       (etx_wait),
                         );
   */

   emmu etx_mmu (.reg_rdata		(), // not used (no readback from MMU)
	    /*AUTOINST*/
		 // Outputs
		 .emesh_access_out	(emmu_access),		 // Templated
		 .emesh_packet_out	(emmu_packet[PW-1:0]),	 // Templated
		 // Inputs
		 .wr_clk		(clk),			 // Templated
		 .rd_clk		(clk),			 // Templated
		 .nreset		(nreset),
		 .mmu_en		(mmu_enable),		 // Templated
		 .reg_access		(cfg_mmu_access),	 // Templated
		 .reg_packet		(etx_packet[PW-1:0]),	 // Templated
		 .emesh_access_in	(etx_remap_access),	 // Templated
		 .emesh_packet_in	(etx_remap_packet[PW-1:0]), // Templated
		 .emesh_wait_in		(etx_wait));		 // Templated
   
   //##################################################################
   //# ELINK PROTOCOL CONVERTER (104 bit-->64 bits)
   //##################################################################

   /*etx_protocol  AUTO_TEMPLATE (			       
                                  .etx_rd_wait     (etx_rd_wait),
                                  .etx_wr_wait     (etx_wr_wait),
                                  .etx_wait	   (etx_wait),    
                                  .etx_\(.*\)      (emmu_\1[]),
                             );
   */
  
   etx_protocol #(.ID(ID))
   etx_protocol (
		 /*AUTOINST*/
		 // Outputs
		 .etx_rd_wait		(etx_rd_wait),		 // Templated
		 .etx_wr_wait		(etx_wr_wait),		 // Templated
		 .etx_wait		(etx_wait),		 // Templated
		 .tx_burst		(tx_burst),
		 .tx_access		(tx_access),
		 .tx_data_slow		(tx_data_slow[63:0]),
		 .tx_frame_slow		(tx_frame_slow[3:0]),
		 // Inputs
		 .nreset		(nreset),
		 .clk			(clk),
		 .etx_access		(emmu_access),		 // Templated
		 .etx_packet		(emmu_packet[PW-1:0]),	 // Templated
		 .tx_enable		(tx_enable),
		 .burst_enable		(burst_enable),
		 .gpio_data		(gpio_data[8:0]),
		 .gpio_enable		(gpio_enable),
		 .ctrlmode_bypass	(ctrlmode_bypass),
		 .ctrlmode		(ctrlmode[3:0]),
		 .tx_rd_wait		(tx_rd_wait),
		 .tx_wr_wait		(tx_wr_wait));
   
   
   //##################################################################
   //# TX CONFIGURATION
   //##################################################################  
 
   etx_cfg etx_cfg (.tx_status	({7'b0,
				  tx_burst,     
				  tx_rd_wait,
				  tx_wr_wait,
				  txrr_wait,
				  txrd_wait,
				  txwr_wait,
				  txrr_full,
				  txrd_full,
				  txwr_full
				  }),
		    /*AUTOINST*/
		    // Outputs
		    .cfg_mmu_access	(cfg_mmu_access),
		    .etx_cfg_access	(etx_cfg_access),
		    .etx_cfg_packet	(etx_cfg_packet[PW-1:0]),
		    .tx_enable		(tx_enable),
		    .mmu_enable		(mmu_enable),
		    .gpio_enable	(gpio_enable),
		    .remap_enable	(remap_enable),
		    .burst_enable	(burst_enable),
		    .gpio_data		(gpio_data[8:0]),
		    .ctrlmode		(ctrlmode[3:0]),
		    .ctrlmode_bypass	(ctrlmode_bypass),
		    // Inputs
		    .nreset		(nreset),
		    .clk		(clk),
		    .cfg_access		(cfg_access),
		    .etx_access		(etx_access),
		    .etx_packet		(etx_packet[PW-1:0]),
		    .etx_wait		(etx_wait));

endmodule // elink
// Local Variables:
// verilog-library-directories:("." "../../emmu/hdl" "../../memory/hdl" "../../common/hdl")
// End:
