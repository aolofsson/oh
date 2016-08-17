module erx_fifo (/*AUTOARG*/
   // Outputs
   rxwr_access, rxwr_packet, rxrd_access, rxrd_packet, rxrr_access,
   rxrr_packet, rxrd_fifo_wait, rxrr_fifo_wait, rxwr_fifo_wait,
   // Inputs
   sys_clk, rx_lclk_div4, erx_nreset, rxwr_wait, rxrd_wait, rxrr_wait,
   rxrd_fifo_access, rxrd_fifo_packet, rxrr_fifo_access,
   rxrr_fifo_packet, rxwr_fifo_access, rxwr_fifo_packet
   );

   parameter AW      = 32;
   parameter DW      = 32;
   parameter PW      = 104;
   parameter RFAW    = 6;
   parameter TARGET  = "GENERIC";

   //reset & clocks
   input 	   sys_clk;
   input 	   rx_lclk_div4;
   input           erx_nreset;     //keep in reset longer
   
   //WR to AXI master
   output 	   rxwr_access;		
   output [PW-1:0] rxwr_packet;
   input 	   rxwr_wait;

   //RD to AXI master
   output 	   rxrd_access;		
   output [PW-1:0] rxrd_packet;
   input 	   rxrd_wait;

   //RR to AXI slave
   output 	   rxrr_access;		
   output [PW-1:0] rxrr_packet;
   input 	   rxrr_wait;

   //RD from IO
   input 	   rxrd_fifo_access;	// To rxrd_fifo of fifo_cdc.v
   input [PW-1:0]  rxrd_fifo_packet;	// To rxrd_fifo of fifo_cdc.v
   output 	   rxrd_fifo_wait;		// From rxrd_fifo of fifo_cdc.v

   //RR from IO
   input 	   rxrr_fifo_access;	// To rxrr_fifo of fifo_cdc.v
   input [PW-1:0]  rxrr_fifo_packet;	// To rxrr_fifo of fifo_cdc.v
   output 	   rxrr_fifo_wait;		// From rxrr_fifo of fifo_cdc.v
   
   //WR from IO
   input 	   rxwr_fifo_access;	// To rxwr_fifo of fifo_cdc.v
   input [PW-1:0]  rxwr_fifo_packet;	// To rxwr_fifo of fifo_cdc.v
   output 	   rxwr_fifo_wait;	// From rxwr_fifo of fifo_cdc.v

   /*AUTOOUTPUT*/
   /*AUTOINPUT*/
   /*AUTOWIRE*/
   


   /************************************************************/
   /*FIFOs                                                     */
   /*(for AXI 1. read request, 2. write, and 3. read response) */
   /************************************************************/

   /*fifo_cdc   AUTO_TEMPLATE ( 
 			       // Outputs
			       .packet_out (@"(substring vl-cell-name  0 4)"_packet[PW-1:0]),
    			       .access_out (@"(substring vl-cell-name  0 4)"_access),
                               .wait_out   (@"(substring vl-cell-name  0 4)"_fifo_wait),
    			       // Inputs
			       .clk_out	   (sys_clk),
                               .clk_in	   (rx_lclk_div4),
                               .access_in  (@"(substring vl-cell-name  0 4)"_fifo_access),
                               .wait_in    (@"(substring vl-cell-name  0 4)"_wait),
			       .nreset     (erx_nreset),
                               .packet_in  (@"(substring vl-cell-name  0 4)"_fifo_packet[PW-1:0]),
    );
   */

      
   //Read request fifo (from Epiphany)
   oh_fifo_cdc #(.DW(104), .DEPTH(32), .TARGET(TARGET))
   rxrd_fifo   (
		/*AUTOINST*/
		// Outputs
		.wait_out		(rxrd_fifo_wait),	 // Templated
		.access_out		(rxrd_access),		 // Templated
		.packet_out		(rxrd_packet[PW-1:0]),	 // Templated
		// Inputs
		.nreset			(erx_nreset),		 // Templated
		.clk_in			(rx_lclk_div4),		 // Templated
		.access_in		(rxrd_fifo_access),	 // Templated
		.packet_in		(rxrd_fifo_packet[PW-1:0]), // Templated
		.clk_out		(sys_clk),		 // Templated
		.wait_in		(rxrd_wait));		 // Templated

 

   //Write fifo (from Epiphany)
   oh_fifo_cdc #(.DW(104), .DEPTH(32), .TARGET(TARGET))
   rxwr_fifo(
	     /*AUTOINST*/
	     // Outputs
	     .wait_out			(rxwr_fifo_wait),	 // Templated
	     .access_out		(rxwr_access),		 // Templated
	     .packet_out		(rxwr_packet[PW-1:0]),	 // Templated
	     // Inputs
	     .nreset			(erx_nreset),		 // Templated
	     .clk_in			(rx_lclk_div4),		 // Templated
	     .access_in			(rxwr_fifo_access),	 // Templated
	     .packet_in			(rxwr_fifo_packet[PW-1:0]), // Templated
	     .clk_out			(sys_clk),		 // Templated
	     .wait_in			(rxwr_wait));		 // Templated
   
 
   //Read response fifo (for host)
   oh_fifo_cdc #(.DW(104), .DEPTH(32), .TARGET(TARGET))
   rxrr_fifo(
	     /*AUTOINST*/
	     // Outputs
	     .wait_out			(rxrr_fifo_wait),	 // Templated
	     .access_out		(rxrr_access),		 // Templated
	     .packet_out		(rxrr_packet[PW-1:0]),	 // Templated
	     // Inputs
	     .nreset			(erx_nreset),		 // Templated
	     .clk_in			(rx_lclk_div4),		 // Templated
	     .access_in			(rxrr_fifo_access),	 // Templated
	     .packet_in			(rxrr_fifo_packet[PW-1:0]), // Templated
	     .clk_out			(sys_clk),		 // Templated
	     .wait_in			(rxrr_wait));		 // Templated
           
endmodule // erx
// Local Variables:
// verilog-library-directories:("." "../../emmu/hdl" "../../edma/hdl" "../../memory/hdl" "../../emailbox/hdl")
// End:

