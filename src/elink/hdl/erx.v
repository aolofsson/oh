module erx (/*AUTOARG*/
   // Outputs
   rx_active, rxo_wr_wait_p, rxo_wr_wait_n, rxo_rd_wait_p,
   rxo_rd_wait_n, rxwr_access, rxwr_packet, rxrd_access, rxrd_packet,
   rxrr_access, rxrr_packet, erx_cfg_wait, rx_lclk_div4, erx_nreset,
   mailbox_irq,
   // Inputs
   soft_reset, sys_nreset, sys_clk, tx_active, rxi_lclk_p, rxi_lclk_n,
   rxi_frame_p, rxi_frame_n, rxi_data_p, rxi_data_n, rxwr_wait,
   rxrd_wait, rxrr_wait, erx_cfg_access, erx_cfg_packet
   );

   parameter AW          = 32;
   parameter DW          = 32;
   parameter PW          = 104;
   parameter RFAW        = 6;
   parameter ID          = 12'h800;
   parameter IOSTD_ELINK = "LVDS_25";
   parameter ETYPE       = 1;
   parameter TARGET      = "GENERIC";

   //Synched resets, clock
   input          soft_reset;                   // sw driven reset
   input          sys_nreset;                    // async reset
   input 	  sys_clk;	                // system clock for fifo/clocks
   input 	  tx_active;                    // holds rx in check until tx has booted 
   output 	  rx_active;                    // indicates RX and TX are active
   
   //FROM IO Pins
   input 	  rxi_lclk_p,   rxi_lclk_n;     // rx clock input
   input 	  rxi_frame_p,  rxi_frame_n;    // rx frame signal
   input [7:0] 	  rxi_data_p,   rxi_data_n;     // rx data
   output 	  rxo_wr_wait_p,rxo_wr_wait_n;  // rx write pushback output
   output 	  rxo_rd_wait_p,rxo_rd_wait_n;  // rx read pushback output

   //Master write
   output 	   rxwr_access;		
   output [PW-1:0] rxwr_packet;
   input 	   rxwr_wait;

   //Master read request
   output 	   rxrd_access;		
   output [PW-1:0] rxrd_packet;
   input 	   rxrd_wait;

   //Slave read response
   output 	   rxrr_access;		
   output [PW-1:0] rxrr_packet;
   input 	   rxrr_wait;
  
   //Configuration Interface (from ETX)
   input 	   erx_cfg_access;
   input [PW-1:0]  erx_cfg_packet;
   output 	   erx_cfg_wait;
   output 	   rx_lclk_div4;
   output 	   erx_nreset;
  
   
   //Mailbox interrupt
   output 	   mailbox_irq;	

   /*AUTOOUTPUT*/
   /*AUTOINPUT*/

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			erx_io_nreset;		// From erx_clocks of erx_clocks.v
   wire [44:0]		idelay_value;		// From erx_core of erx_core.v
   wire			load_taps;		// From erx_core of erx_core.v
   wire			rx_access;		// From erx_io of erx_io.v
   wire			rx_burst;		// From erx_io of erx_io.v
   wire			rx_clkin;		// From erx_io of erx_io.v
   wire			rx_lclk;		// From erx_clocks of erx_clocks.v
   wire [PW-1:0]	rx_packet;		// From erx_io of erx_io.v
   wire			rx_rd_wait;		// From erx_core of erx_core.v
   wire			rx_wr_wait;		// From erx_core of erx_core.v
   wire			rxrd_fifo_access;	// From erx_core of erx_core.v
   wire [PW-1:0]	rxrd_fifo_packet;	// From erx_core of erx_core.v
   wire			rxrd_fifo_wait;		// From erx_fifo of erx_fifo.v
   wire			rxrr_fifo_access;	// From erx_core of erx_core.v
   wire [PW-1:0]	rxrr_fifo_packet;	// From erx_core of erx_core.v
   wire			rxrr_fifo_wait;		// From erx_fifo of erx_fifo.v
   wire			rxwr_fifo_access;	// From erx_core of erx_core.v
   wire [PW-1:0]	rxwr_fifo_packet;	// From erx_core of erx_core.v
   wire			rxwr_fifo_wait;		// From erx_fifo of erx_fifo.v
   // End of automatics

   /***********************************************************/
   /*CLOCK/RESET                                              */
   /***********************************************************/
   erx_clocks erx_clocks(/*AUTOINST*/
			 // Outputs
			 .rx_lclk		(rx_lclk),
			 .rx_lclk_div4		(rx_lclk_div4),
			 .rx_active		(rx_active),
			 .erx_nreset		(erx_nreset),
			 .erx_io_nreset		(erx_io_nreset),
			 // Inputs
			 .sys_nreset		(sys_nreset),
			 .soft_reset		(soft_reset),
			 .tx_active		(tx_active),
			 .sys_clk		(sys_clk),
			 .rx_clkin		(rx_clkin));
   
   /***********************************************************/
   /*RECEIVER  I/O LOGIC                                      */
   /***********************************************************/
   erx_io #(.ETYPE(ETYPE))
   erx_io (
		  /*AUTOINST*/
	   // Outputs
	   .rx_clkin			(rx_clkin),
	   .rxo_wr_wait_p		(rxo_wr_wait_p),
	   .rxo_wr_wait_n		(rxo_wr_wait_n),
	   .rxo_rd_wait_p		(rxo_rd_wait_p),
	   .rxo_rd_wait_n		(rxo_rd_wait_n),
	   .rx_access			(rx_access),
	   .rx_burst			(rx_burst),
	   .rx_packet			(rx_packet[PW-1:0]),
	   // Inputs
	   .erx_io_nreset		(erx_io_nreset),
	   .rx_lclk			(rx_lclk),
	   .rx_lclk_div4		(rx_lclk_div4),
	   .idelay_value		(idelay_value[44:0]),
	   .load_taps			(load_taps),
	   .rxi_lclk_p			(rxi_lclk_p),
	   .rxi_lclk_n			(rxi_lclk_n),
	   .rxi_frame_p			(rxi_frame_p),
	   .rxi_frame_n			(rxi_frame_n),
	   .rxi_data_p			(rxi_data_p[7:0]),
	   .rxi_data_n			(rxi_data_n[7:0]),
	   .rx_wr_wait			(rx_wr_wait),
	   .rx_rd_wait			(rx_rd_wait));
   
   /**************************************************************/
   /*ELINK CORE LOGIC                                            */
   /**************************************************************/
   /*erx_core   AUTO_TEMPLATE ( .rx_packet	(rx_packet[PW-1:0]),
		                .rx_access	(rx_access),
                                .erx_cfg_access	(erx_cfg_access),
		                .erx_cfg_packet	(erx_cfg_packet[PW-1:0]),
                                .erx_cfg_wait	(erx_cfg_wait),
                                .rx_rd_wait	(rx_rd_wait),
		                .rx_wr_wait	(rx_wr_wait),
    			       .\(.*\)_packet   (\1_fifo_packet[PW-1:0]),
    			       .\(.*\)_access   (\1_fifo_access),
       			       .\(.*\)_wait     (\1_fifo_wait),
    );
    */

   erx_core #(.TARGET(TARGET), .ID(ID))
   erx_core ( .clk		(rx_lclk_div4),
		       .nreset           (erx_nreset),
		      /*AUTOINST*/
		      // Outputs
		      .rx_rd_wait	(rx_rd_wait),		 // Templated
		      .rx_wr_wait	(rx_wr_wait),		 // Templated
		      .idelay_value	(idelay_value[44:0]),
		      .load_taps	(load_taps),
		      .rxrd_access	(rxrd_fifo_access),	 // Templated
		      .rxrd_packet	(rxrd_fifo_packet[PW-1:0]), // Templated
		      .rxrr_access	(rxrr_fifo_access),	 // Templated
		      .rxrr_packet	(rxrr_fifo_packet[PW-1:0]), // Templated
		      .rxwr_access	(rxwr_fifo_access),	 // Templated
		      .rxwr_packet	(rxwr_fifo_packet[PW-1:0]), // Templated
		      .erx_cfg_wait	(erx_cfg_wait),		 // Templated
		      .mailbox_irq	(mailbox_irq),
		      // Inputs
		      .rx_packet	(rx_packet[PW-1:0]),	 // Templated
		      .rx_access	(rx_access),		 // Templated
		      .rx_burst		(rx_burst),
		      .rxrd_wait	(rxrd_fifo_wait),	 // Templated
		      .rxrr_wait	(rxrr_fifo_wait),	 // Templated
		      .rxwr_wait	(rxwr_fifo_wait),	 // Templated
		      .erx_cfg_access	(erx_cfg_access),	 // Templated
		      .erx_cfg_packet	(erx_cfg_packet[PW-1:0])); // Templated

   /************************************************************/
   /*FIFOs                                                     */
   /************************************************************/      
   erx_fifo #(.TARGET(TARGET))
   erx_fifo   (
		/*AUTOINST*/
			// Outputs
			.rxwr_access	(rxwr_access),
			.rxwr_packet	(rxwr_packet[PW-1:0]),
			.rxrd_access	(rxrd_access),
			.rxrd_packet	(rxrd_packet[PW-1:0]),
			.rxrr_access	(rxrr_access),
			.rxrr_packet	(rxrr_packet[PW-1:0]),
			.rxrd_fifo_wait	(rxrd_fifo_wait),
			.rxrr_fifo_wait	(rxrr_fifo_wait),
			.rxwr_fifo_wait	(rxwr_fifo_wait),
			// Inputs
			.sys_clk	(sys_clk),
			.rx_lclk_div4	(rx_lclk_div4),
			.erx_nreset	(erx_nreset),
			.rxwr_wait	(rxwr_wait),
			.rxrd_wait	(rxrd_wait),
			.rxrr_wait	(rxrr_wait),
			.rxrd_fifo_access(rxrd_fifo_access),
			.rxrd_fifo_packet(rxrd_fifo_packet[PW-1:0]),
			.rxrr_fifo_access(rxrr_fifo_access),
			.rxrr_fifo_packet(rxrr_fifo_packet[PW-1:0]),
			.rxwr_fifo_access(rxwr_fifo_access),
			.rxwr_fifo_packet(rxwr_fifo_packet[PW-1:0]));
   
endmodule // erx
// Local Variables:
// verilog-library-directories:(".")
// End:



