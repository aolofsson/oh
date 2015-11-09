module etx_core(/*AUTOARG*/
   // Outputs
   tx_access, tx_burst, tx_packet, txrd_wait, txrr_wait, txwr_wait,
   etx_cfg_access, etx_cfg_packet,
   // Inputs
   nreset, clk, tx_io_ack, tx_rd_wait, tx_wr_wait, txrd_access,
   txrd_packet, txrr_access, txrr_packet, txwr_access, txwr_packet,
   etx_cfg_wait
   );
   parameter AW      = 32;
   parameter DW      = 32;
   parameter PW      = 104;
   parameter RFAW    = 6;
   parameter ID      = 12'h000;
   
   //Clocks,reset,config
   input           nreset;
   input 	   clk;   
  
   //IO interface
   output 	   tx_access;
   output 	   tx_burst;
   output [PW-1:0] tx_packet; 
   input 	   tx_io_ack;  
   input 	   tx_rd_wait;
   input 	   tx_wr_wait;
   
   //TXRD
   input 	   txrd_access;
   input [PW-1:0]  txrd_packet;
   output 	   txrd_wait;
   
   //TXRR
   input 	   txrr_access;
   input [PW-1:0]  txrr_packet;
   output 	   txrr_wait;
   
   //TXWR
   input 	   txwr_access;
   input [PW-1:0]  txwr_packet;
   output 	   txwr_wait;

   //Configuration Interface (for ERX)
   output 	   etx_cfg_access;
   output [PW-1:0] etx_cfg_packet;
   input 	   etx_cfg_wait;

   //for status?
   wire[15:0] 	   tx_status; 
   
   /*AUTOOUTPUT*/
   /*AUTOINPUT*/
     
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [3:0]		ctrlmode;		// From etx_cfg of etx_cfg.v
   wire			ctrlmode_bypass;	// From etx_cfg of etx_cfg.v
   wire			emmu_access;		// From etx_mmu of emmu.v
   wire [PW-1:0]	emmu_packet;		// From etx_mmu of emmu.v
   wire			etx_access;		// From etx_arbiter of etx_arbiter.v
   wire [PW-1:0]	etx_packet;		// From etx_arbiter of etx_arbiter.v
   wire			etx_rd_wait;		// From etx_protocol of etx_protocol.v
   wire			etx_remap_access;	// From etx_remap of etx_remap.v
   wire [PW-1:0]	etx_remap_packet;	// From etx_remap of etx_remap.v
   wire			etx_rr;			// From etx_arbiter of etx_arbiter.v
   wire			etx_wr_wait;		// From etx_protocol of etx_protocol.v
   wire [8:0]		gpio_data;		// From etx_cfg of etx_cfg.v
   wire			gpio_enable;		// From etx_cfg of etx_cfg.v
   wire [14:0]		mi_addr;		// From etx_cfgif of ecfg_if.v
   wire [DW-1:0]	mi_cfg_dout;		// From etx_cfg of etx_cfg.v
   wire			mi_cfg_en;		// From etx_cfgif of ecfg_if.v
   wire [63:0]		mi_din;			// From etx_cfgif of ecfg_if.v
   wire [DW-1:0]	mi_mmu_dout;		// From etx_mmu of emmu.v
   wire			mi_mmu_en;		// From etx_cfgif of ecfg_if.v
   wire			mi_we;			// From etx_cfgif of ecfg_if.v
   wire			mmu_enable;		// From etx_cfg of etx_cfg.v
   wire			remap_enable;		// From etx_cfg of etx_cfg.v
   wire			tx_enable;		// From etx_cfg of etx_cfg.v
   // End of automatics

     
   /************************************************************/
   /*ELINK TRANSMIT ARBITER                                    */
   /************************************************************/
   defparam etx_arbiter.ID=ID;   
   etx_arbiter etx_arbiter (
			      /*AUTOINST*/
			    // Outputs
			    .txwr_wait		(txwr_wait),
			    .txrd_wait		(txrd_wait),
			    .txrr_wait		(txrr_wait),
			    .etx_access		(etx_access),
			    .etx_packet		(etx_packet[PW-1:0]),
			    .etx_rr		(etx_rr),
			    // Inputs
			    .clk		(clk),
			    .nreset		(nreset),
			    .txwr_access	(txwr_access),
			    .txwr_packet	(txwr_packet[PW-1:0]),
			    .txrd_access	(txrd_access),
			    .txrd_packet	(txrd_packet[PW-1:0]),
			    .txrr_access	(txrr_access),
			    .txrr_packet	(txrr_packet[PW-1:0]),
			    .etx_rd_wait	(etx_rd_wait),
			    .etx_wr_wait	(etx_wr_wait),
			    .etx_cfg_wait	(etx_cfg_wait),
			    .ctrlmode_bypass	(ctrlmode_bypass),
			    .ctrlmode		(ctrlmode[3:0]));
      

   /************************************************************/
   /* CONFIGURATOIN PACKET                                     */
   /************************************************************/
   /*ecfg_if AUTO_TEMPLATE ( 
    .\(.*\)_in          (etx_\1[]),
    .\(.*\)_out         (etx_cfg_\1[]),
    .mi_dout0		({32'b0,mi_cfg_dout[31:0]}),
    .mi_dout2		({32'b0,mi_mmu_dout[31:0]}),
    .wait_in		(etx_cfg_wait),
    );
        */
   
   defparam etx_cfgif.RX =0;   
   ecfg_if etx_cfgif (.mi_dout3		(64'b0),
		      .mi_dout1		(64'b0), 
		      .mi_dma_en	(),
		      /*AUTOINST*/
		      // Outputs
		      .mi_mmu_en	(mi_mmu_en),
		      .mi_cfg_en	(mi_cfg_en),
		      .mi_we		(mi_we),
		      .mi_addr		(mi_addr[14:0]),
		      .mi_din		(mi_din[63:0]),
		      .access_out	(etx_cfg_access),	 // Templated
		      .packet_out	(etx_cfg_packet[PW-1:0]), // Templated
		      // Inputs
		      .clk		(clk),
		      .access_in	(etx_access),		 // Templated
		      .packet_in	(etx_packet[PW-1:0]),	 // Templated
		      .mi_dout0		({32'b0,mi_cfg_dout[31:0]}), // Templated
		      .mi_dout2		({32'b0,mi_mmu_dout[31:0]}), // Templated
		      .wait_in		(etx_cfg_wait));		 // Templated
   
   /************************************************************/
   /* ETX CONFIGURATION REGISTERS                              */
   /************************************************************/
    /*etx_cfg AUTO_TEMPLATE (.mi_dout       (mi_cfg_dout[DW-1:0]), 
                             .mi_en	    (mi_cfg_en),
    );
        */

   //todo: make more useufl
   assign tx_status[15:0]  = 16'b0;
/*   

{2'b0,                //15:14
			      etx_rd_wait,         //13
			      etx_wr_wait,         //12
			      txrr_fifo_read,      //11			
			      txrr_wait,           //10
			      txrr_access,         //9	 		
			      txrd_fifo_read,      //8			
			      txrd_wait,           //7
			      txrd_access,         //6
			      txwr_fifo_read,      //5
			      txwr_wait,           //4
			      txwr_access,         //3
			      1'b0,                //2
			      1'b0,                //1
			      1'b0	           //0
			      };
*/
 
   etx_cfg etx_cfg (
		    /*AUTOINST*/
		    // Outputs
		    .mi_dout		(mi_cfg_dout[DW-1:0]),	 // Templated
		    .tx_enable		(tx_enable),
		    .mmu_enable		(mmu_enable),
		    .gpio_enable	(gpio_enable),
		    .remap_enable	(remap_enable),
		    .gpio_data		(gpio_data[8:0]),
		    .ctrlmode		(ctrlmode[3:0]),
		    .ctrlmode_bypass	(ctrlmode_bypass),
		    // Inputs
		    .nreset		(nreset),
		    .clk		(clk),
		    .mi_en		(mi_cfg_en),		 // Templated
		    .mi_we		(mi_we),
		    .mi_addr		(mi_addr[RFAW+1:0]),
		    .mi_din		(mi_din[31:0]),
		    .tx_status		(tx_status[15:0]));
      
   /************************************************************/
   /* REMAPPING (SHIFT) DESTINATION ADDRESS                    */
   /************************************************************/
    /*etx_remap  AUTO_TEMPLATE (	
                          .emesh_\(.*\)_in  (etx_\1[]),
                          .emesh_\(.*\)_out (etx_remap_\1[]),
                          .remap_en	    (remap_enable),
                          .remap_bypass	    (etx_rr),
                          .emesh_wait       (etx_wait),
                          );
   */

   etx_remap etx_remap (/*AUTOINST*/
			// Outputs
			.emesh_access_out(etx_remap_access),	 // Templated
			.emesh_packet_out(etx_remap_packet[PW-1:0]), // Templated
			// Inputs
			.clk		(clk),
			.emesh_access_in(etx_access),		 // Templated
			.emesh_packet_in(etx_packet[PW-1:0]),	 // Templated
			.remap_en	(remap_enable),		 // Templated
			.remap_bypass	(etx_rr),		 // Templated
			.etx_rd_wait	(etx_rd_wait),
			.etx_wr_wait	(etx_wr_wait));
   
 
   /************************************************************/
   /* EMMU                                                     */
   /************************************************************/
   /*emmu  AUTO_TEMPLATE (	
                          .emesh_\(.*\)_in  (etx_remap_\1[]),
                          .emesh_\(.*\)_out (emmu_\1[]),
                          .mmu_en	    (mmu_enable),
                          .mmu_bp	    (etx_rr),
                          .rd_clk           (clk),
                          .wr_clk           (clk),
                          .emmu_access_out  (emmu_access),
                          .emmu_packet_out  (emmu_packet[PW-1:0]),
                          .mi_dout	    (mi_mmu_dout[DW-1:0]),
                          .emesh_wait       (etx_wr_wait),
                          .emesh_packet_hi_out	(),
                          .mi_en	    (mi_mmu_en),
                         );
   */

   emmu etx_mmu (
	      /*AUTOINST*/
		 // Outputs
		 .mi_dout		(mi_mmu_dout[DW-1:0]),	 // Templated
		 .emesh_access_out	(emmu_access),		 // Templated
		 .emesh_packet_out	(emmu_packet[PW-1:0]),	 // Templated
		 .emesh_packet_hi_out	(),			 // Templated
		 // Inputs
		 .rd_clk		(clk),			 // Templated
		 .wr_clk		(clk),			 // Templated
		 .mmu_en		(mmu_enable),		 // Templated
		 .mmu_bp		(etx_rr),		 // Templated
		 .mi_en			(mi_mmu_en),		 // Templated
		 .mi_we			(mi_we),
		 .mi_addr		(mi_addr[14:0]),
		 .mi_din		(mi_din[DW-1:0]),
		 .emesh_access_in	(etx_remap_access),	 // Templated
		 .emesh_packet_in	(etx_remap_packet[PW-1:0]), // Templated
		 .emesh_wait		(etx_wr_wait));		 // Templated
   

   /************************************************************/
   /*ELINK PROTOCOL LOGIC                                      */
   /************************************************************/
   /*etx_protocol  AUTO_TEMPLATE (			       
                                  .etx_rd_wait     (etx_rd_wait),
                                  .etx_wr_wait     (etx_wr_wait),
                                  .etx_\(.*\)      (emmu_\1[]),
                                  .etx_wait	   (etx_wait),    
                             );
   */

   defparam etx_protocol.ID=ID;   
   etx_protocol etx_protocol (
			      /*AUTOINST*/
			      // Outputs
			      .etx_rd_wait	(etx_rd_wait),	 // Templated
			      .etx_wr_wait	(etx_wr_wait),	 // Templated
			      .tx_packet	(tx_packet[PW-1:0]),
			      .tx_access	(tx_access),
			      .tx_burst		(tx_burst),
			      // Inputs
			      .nreset		(nreset),
			      .clk		(clk),
			      .etx_access	(emmu_access),	 // Templated
			      .etx_packet	(emmu_packet[PW-1:0]), // Templated
			      .tx_enable	(tx_enable),
			      .gpio_data	(gpio_data[8:0]),
			      .gpio_enable	(gpio_enable),
			      .tx_io_ack	(tx_io_ack),
			      .tx_rd_wait	(tx_rd_wait),
			      .tx_wr_wait	(tx_wr_wait));
   
endmodule // elink
// Local Variables:
// verilog-library-directories:("." "../../emmu/hdl" "../../memory/hdl")
// End:
