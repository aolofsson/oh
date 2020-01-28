module etx_fifo(/*AUTOARG*/
   // Outputs
   txrd_wait, txwr_wait, txrr_wait, txrd_fifo_access,
   txrd_fifo_packet, txrr_fifo_access, txrr_fifo_packet,
   txwr_fifo_access, txwr_fifo_packet,
   // Inputs
   sys_nreset, sys_clk, tx_lclk_div4, txrd_access, txrd_packet,
   txwr_access, txwr_packet, txrr_access, txrr_packet, txrd_fifo_wait,
   txrr_fifo_wait, txwr_fifo_wait
   );

   parameter AW      = 32;
   parameter DW      = 32;
   parameter PW      = 104;
   parameter RFAW    = 6;
   parameter ID      = 12'h000;
   parameter TARGET  = "GENERIC";
   
   //Clocks,reset,config
   input          sys_nreset;
   input 	  sys_clk;   
   input 	  tx_lclk_div4;	  // slow speed parallel clock
      
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

   //Read request for pins
   output 	   txrd_fifo_access;
   output [PW-1:0] txrd_fifo_packet;
   input 	   txrd_fifo_wait;

   //Read response for pins
   output 	   txrr_fifo_access;
   output [PW-1:0] txrr_fifo_packet;
   input 	   txrr_fifo_wait;

   //Write for pins
   output 	   txwr_fifo_access;
   output [PW-1:0] txwr_fifo_packet;
   input 	   txwr_fifo_wait;

   
   /*AUTOOUTPUT*/
   /*AUTOINPUT*/
   /*AUTOWIRE*/

   
   /************************************************************/
   /*FIFOs                                                     */
   /************************************************************/
   //TODO: Minimize depth and width

   /*fifo_cdc  AUTO_TEMPLATE (
			       // Outputs
                               .access_out (@"(substring vl-cell-name  0 4)"_fifo_access),
			       .packet_out (@"(substring vl-cell-name  0 4)"_fifo_packet[PW-1:0]),
                               .wait_out   (@"(substring vl-cell-name  0 4)"_wait),
                               .wait_in   (@"(substring vl-cell-name  0 4)"_fifo_wait),
    			       .clk_out	   (tx_lclk_div4),
                               .clk_in	   (sys_clk),
                               .access_in  (@"(substring vl-cell-name  0 4)"_access),
                               .rd_en      (@"(substring vl-cell-name  0 4)"_fifo_read),
			       .nreset     (sys_nreset),
                               .packet_in  (@"(substring vl-cell-name  0 4)"_packet[PW-1:0]),
    );
    */

   //Write fifo (from slave)
   oh_fifo_cdc #(.DW(104), .DEPTH(32), .TARGET(TARGET))
   txwr_fifo(
			                  /*AUTOINST*/
					      // Outputs
					      .wait_out		(txwr_wait),	 // Templated
					      .access_out	(txwr_fifo_access), // Templated
					      .packet_out	(txwr_fifo_packet[PW-1:0]), // Templated
					      // Inputs
					      .nreset		(sys_nreset),	 // Templated
					      .clk_in		(sys_clk),	 // Templated
					      .access_in	(txwr_access),	 // Templated
					      .packet_in	(txwr_packet[PW-1:0]), // Templated
					      .clk_out		(tx_lclk_div4),	 // Templated
					      .wait_in		(txwr_fifo_wait)); // Templated
   
   //Read request fifo (from slave)
   oh_fifo_cdc  #(.DW(104), .DEPTH(32), .TARGET(TARGET))
   txrd_fifo(
				             /*AUTOINST*/
					       // Outputs
					       .wait_out	(txrd_wait),	 // Templated
					       .access_out	(txrd_fifo_access), // Templated
					       .packet_out	(txrd_fifo_packet[PW-1:0]), // Templated
					       // Inputs
					       .nreset		(sys_nreset),	 // Templated
					       .clk_in		(sys_clk),	 // Templated
					       .access_in	(txrd_access),	 // Templated
					       .packet_in	(txrd_packet[PW-1:0]), // Templated
					       .clk_out		(tx_lclk_div4),	 // Templated
					       .wait_in		(txrd_fifo_wait)); // Templated
   

  
   //Read response fifo (from master)
   oh_fifo_cdc  #(.DW(104), .DEPTH(32), .TARGET(TARGET))
   txrr_fifo(
					    
					     /*AUTOINST*/
					       // Outputs
					       .wait_out	(txrr_wait),	 // Templated
					       .access_out	(txrr_fifo_access), // Templated
					       .packet_out	(txrr_fifo_packet[PW-1:0]), // Templated
					       // Inputs
					       .nreset		(sys_nreset),	 // Templated
					       .clk_in		(sys_clk),	 // Templated
					       .access_in	(txrr_access),	 // Templated
					       .packet_in	(txrr_packet[PW-1:0]), // Templated
					       .clk_out		(tx_lclk_div4),	 // Templated
					       .wait_in		(txrr_fifo_wait)); // Templated
  

   
endmodule // elink
// Local Variables:
// verilog-library-directories:("." "../../emmu/hdl" "../../memory/hdl" "../../edma/hdl/")
// End:



