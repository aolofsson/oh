module etx(/*AUTOARG*/
   // Outputs
   tx_active, txo_lclk_p, txo_lclk_n, txo_frame_p, txo_frame_n,
   txo_data_p, txo_data_n, cclk_p, cclk_n, chip_nreset, txrd_wait,
   txwr_wait, txrr_wait, etx_cfg_access, etx_cfg_packet, etx_nreset,
   tx_lclk_div4,
   // Inputs
   sys_clk, sys_nreset, soft_reset, txi_wr_wait_p, txi_wr_wait_n,
   txi_rd_wait_p, txi_rd_wait_n, txrd_access, txrd_packet,
   txwr_access, txwr_packet, txrr_access, txrr_packet, etx_cfg_wait
   );
   parameter AW          = 32;
   parameter DW          = 32;
   parameter PW          = 104;
   parameter RFAW        = 6;
   parameter ID          = 12'h000;
   parameter ETYPE       = 0;   

   //Reset and clocks
   input 	  sys_clk;                      // clock for fifos      
   input 	  sys_nreset;                   // reset for fifos   
   input 	  soft_reset;		        // software controlled reset
   output 	  tx_active;		        // tx ready to transmit
   
   //Transmit signals for IO
   output 	  txo_lclk_p,   txo_lclk_n;     // tx clock output
   output 	  txo_frame_p, txo_frame_n;     // tx frame signal
   output [7:0]   txo_data_p, txo_data_n;       // tx data (dual data rate)
   input 	  txi_wr_wait_p,txi_wr_wait_n;  // tx async write pushback
   input 	  txi_rd_wait_p, txi_rd_wait_n; // tx async read pushback
   
   //Epiphany Chip Signals
   output 	  cclk_p,cclk_n;   
   output 	  chip_nreset;
         
   //Read Request Channel Input
   input 	  txrd_access;
   input [PW-1:0] txrd_packet;
   output 	  txrd_wait;
   
   //Write Channel Input
   input 	  txwr_access;
   input [PW-1:0] txwr_packet;
   output 	  txwr_wait;
   
   //Read Response Channel Input
   input 	  txrr_access;
   input [PW-1:0] txrr_packet;
   output 	  txrr_wait;

   //Configuration Interface (for ERX)
   output 	   etx_cfg_access;
   output [PW-1:0] etx_cfg_packet;
   output 	   etx_nreset;      
   output 	   tx_lclk_div4;
   input 	   etx_cfg_wait;
   
   /*AUTOOUTPUT*/   
   /*AUTOINPUT*/        
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			tx_lclk;		// From etx_clocks of etx_clocks.v
   wire			tx_lclk90;		// From etx_clocks of etx_clocks.v
   wire			tx_lclk_io;		// From etx_clocks of etx_clocks.v
   // End of automatics
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			tx_access;		// From etx_core of etx_core.v
   wire			tx_burst;		// From etx_core of etx_core.v
   wire			tx_io_wait;		// From etx_io of etx_io.v
   wire [PW-1:0]	tx_packet;		// From etx_core of etx_core.v
   wire			tx_rd_wait;		// From etx_io of etx_io.v
   wire			tx_wr_wait;		// From etx_io of etx_io.v
   wire			txrd_fifo_access;	// From etx_fifo of etx_fifo.v
   wire [PW-1:0]	txrd_fifo_packet;	// From etx_fifo of etx_fifo.v
   wire			txrd_fifo_wait;		// From etx_core of etx_core.v
   wire			txrr_fifo_access;	// From etx_fifo of etx_fifo.v
   wire [PW-1:0]	txrr_fifo_packet;	// From etx_fifo of etx_fifo.v
   wire			txrr_fifo_wait;		// From etx_core of etx_core.v
   wire			txwr_fifo_access;	// From etx_fifo of etx_fifo.v
   wire [PW-1:0]	txwr_fifo_packet;	// From etx_fifo of etx_fifo.v
   wire			txwr_fifo_wait;		// From etx_core of etx_core.v
  
   /************************************************************/
   /*Clocks                                                    */
   /************************************************************/
   etx_clocks etx_clocks (.etx_io_nreset	(etx_io_nreset),
			  /*AUTOINST*/
			  // Outputs
			  .tx_lclk		(tx_lclk),
			  .tx_lclk_io		(tx_lclk_io),
			  .tx_lclk90		(tx_lclk90),
			  .tx_lclk_div4		(tx_lclk_div4),
			  .cclk_p		(cclk_p),
			  .cclk_n		(cclk_n),
			  .etx_nreset		(etx_nreset),
			  .chip_nreset		(chip_nreset),
			  .tx_active		(tx_active),
			  // Inputs
			  .sys_nreset		(sys_nreset),
			  .soft_reset		(soft_reset),
			  .sys_clk		(sys_clk));
   

   /************************************************************/
   /*FIFOs                                                     */
   /************************************************************/
   etx_fifo etx_fifo (/*AUTOINST*/
		      // Outputs
		      .txrd_wait	(txrd_wait),
		      .txwr_wait	(txwr_wait),
		      .txrr_wait	(txrr_wait),
		      .etx_cfg_access	(etx_cfg_access),
		      .etx_cfg_packet	(etx_cfg_packet[PW-1:0]),
		      .txrd_fifo_access	(txrd_fifo_access),
		      .txrd_fifo_packet	(txrd_fifo_packet[PW-1:0]),
		      .txrr_fifo_access	(txrr_fifo_access),
		      .txrr_fifo_packet	(txrr_fifo_packet[PW-1:0]),
		      .txwr_fifo_access	(txwr_fifo_access),
		      .txwr_fifo_packet	(txwr_fifo_packet[PW-1:0]),
		      // Inputs
		      .etx_nreset	(etx_nreset),
		      .sys_nreset	(sys_nreset),
		      .sys_clk		(sys_clk),
		      .tx_lclk_div4	(tx_lclk_div4),
		      .txrd_access	(txrd_access),
		      .txrd_packet	(txrd_packet[PW-1:0]),
		      .txwr_access	(txwr_access),
		      .txwr_packet	(txwr_packet[PW-1:0]),
		      .txrr_access	(txrr_access),
		      .txrr_packet	(txrr_packet[PW-1:0]),
		      .etx_cfg_wait	(etx_cfg_wait),
		      .txrd_fifo_wait	(txrd_fifo_wait),
		      .txrr_fifo_wait	(txrr_fifo_wait),
		      .txwr_fifo_wait	(txwr_fifo_wait));

   /***********************************************************/
   /*ELINK CORE LOGIC                                         */
   /***********************************************************/
   /*etx_core   AUTO_TEMPLATE ( .tx_access	(tx_access),
		                .tx_burst	(tx_burst),
    		                .tx_io_wait	(tx_io_wait), 
                                .tx_rd_wait	(tx_rd_wait),
		                .tx_wr_wait	(tx_wr_wait),
		                .tx_packet	(tx_packet[PW-1:0]),
                                .etx_cfg_access	(etx_cfg_access),
		                .etx_cfg_packet	(etx_cfg_packet[PW-1:0]),
                                .etx_cfg_wait	(etx_cfg_wait),
                               
    			        .\(.*\)_packet   (\1_fifo_packet[PW-1:0]),
    			        .\(.*\)_access   (\1_fifo_access),
       			        .\(.*\)_wait     (\1_fifo_wait),
    );
    */
   
   defparam etx_core.ID=ID;   
   etx_core etx_core (.clk		(tx_lclk_div4),
		      .nreset		(etx_nreset),
		      /*AUTOINST*/
		      // Outputs
		      .tx_access	(tx_access),		 // Templated
		      .tx_burst		(tx_burst),		 // Templated
		      .tx_packet	(tx_packet[PW-1:0]),	 // Templated
		      .txrd_wait	(txrd_fifo_wait),	 // Templated
		      .txrr_wait	(txrr_fifo_wait),	 // Templated
		      .txwr_wait	(txwr_fifo_wait),	 // Templated
		      .etx_cfg_access	(etx_cfg_access),	 // Templated
		      .etx_cfg_packet	(etx_cfg_packet[PW-1:0]), // Templated
		      // Inputs
		      .tx_io_wait	(tx_io_wait),		 // Templated
		      .tx_rd_wait	(tx_rd_wait),		 // Templated
		      .tx_wr_wait	(tx_wr_wait),		 // Templated
		      .txrd_access	(txrd_fifo_access),	 // Templated
		      .txrd_packet	(txrd_fifo_packet[PW-1:0]), // Templated
		      .txrr_access	(txrr_fifo_access),	 // Templated
		      .txrr_packet	(txrr_fifo_packet[PW-1:0]), // Templated
		      .txwr_access	(txwr_fifo_access),	 // Templated
		      .txwr_packet	(txwr_fifo_packet[PW-1:0]), // Templated
		      .etx_cfg_wait	(etx_cfg_wait));		 // Templated
   
   
   /***********************************************************/
   /*TRANSMIT I/O LOGIC                                       */
   /***********************************************************/

   etx_io #(.ETYPE(ETYPE))
   etx_io (.nreset		(etx_io_nreset),
		  /*AUTOINST*/
	   // Outputs
	   .txo_lclk_p			(txo_lclk_p),
	   .txo_lclk_n			(txo_lclk_n),
	   .txo_frame_p			(txo_frame_p),
	   .txo_frame_n			(txo_frame_n),
	   .txo_data_p			(txo_data_p[7:0]),
	   .txo_data_n			(txo_data_n[7:0]),
	   .tx_io_wait			(tx_io_wait),
	   .tx_wr_wait			(tx_wr_wait),
	   .tx_rd_wait			(tx_rd_wait),
	   // Inputs
	   .tx_lclk			(tx_lclk),
	   .tx_lclk_io			(tx_lclk_io),
	   .tx_lclk90			(tx_lclk90),
	   .txi_wr_wait_p		(txi_wr_wait_p),
	   .txi_wr_wait_n		(txi_wr_wait_n),
	   .txi_rd_wait_p		(txi_rd_wait_p),
	   .txi_rd_wait_n		(txi_rd_wait_n),
	   .tx_packet			(tx_packet[PW-1:0]),
	   .tx_access			(tx_access),
	   .tx_burst			(tx_burst));
   
   
endmodule // elink
// Local Variables:
// verilog-library-directories:("." "../../emmu/hdl" "../../memory/hdl" "../../edma/hdl/")
// End:



