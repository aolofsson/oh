module crx (/*AUTOARG*/
   // Outputs
   rx_wait, access_out, packet_out,
   // Inputs
   clk, nreset, datasize, rx_clk, rx_access, rx_packet, wait_in
   );

   //#####################################################################
   //# INTERFACE
   //#####################################################################

   //parameters
   parameter PW         = 104;             // data width (core)
   parameter IOW        = 8;               // IO data width
   parameter FIFO_DEPTH = 32;              // fifo depth  
   localparam CW        = $clog2(2*PW/IOW);// transfer count width
   
   //reset, clk
   input              clk;         // main core clock   
   input              nreset;      // async active low reset
   
   //rx config
   input [CW-1:0]     datasize;    // size of data transmitted
   //delay, enable?
   
   //IO interface
   input 	      rx_clk;      // clock from IO
   input 	      rx_access;   // access signal for IO
   input [IOW-1:0]    rx_packet;   // packet from IO
   output 	      rx_wait;     // pushback for IO

   // data 
   output 	      access_out;  // fifo data valid
   output [PW-1:0]    packet_out;  // fifo packet
   input 	      wait_in;     // wait pushback for fifo

   //#####################################################################
   //# BODY
   //#####################################################################
   /*AUTOOUTPUT*/
   /*AUTOINPUT*/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			fifo_access;		// From crx_protocol of crx_protocol.v
   wire [PW-1:0]	fifo_packet;		// From crx_protocol of crx_protocol.v
   wire			io_access;		// From crx_io of crx_io.v
   wire [2*IOW-1:0]	io_packet;		// From crx_io of crx_io.v
   // End of automatics

 
      
   //########################################
   //# SYNCHRONIZATION FIFO
   //########################################

  /*oh_fifo_cdc  AUTO_TEMPLATE (
   .wait_out    (rx_wait),
   .access_out  (access_out),
   .packet_out  (packet_out[PW-1:0]),
   // Inputs
   .nreset	(nreset),
   .clk_in	(rx_clk),
   .access_in	(fifo_access),
   .packet_in	(fifo_packet[PW-1:0]),
   .clk_out	(clk),
   .wait_in	(wait_in),
    );
   */

   oh_fifo_cdc  #(.DW(PW),
		  .DEPTH(FIFO_DEPTH))
   fifo  (/*AUTOINST*/
	  // Outputs
	  .wait_out			(rx_wait),		 // Templated
	  .access_out			(access_out),		 // Templated
	  .packet_out			(packet_out[PW-1:0]),	 // Templated
	  // Inputs
	  .nreset			(nreset),		 // Templated
	  .clk_in			(rx_clk),		 // Templated
	  .access_in			(fifo_access),		 // Templated
	  .packet_in			(fifo_packet[PW-1:0]),	 // Templated
	  .clk_out			(clk),			 // Templated
	  .wait_in			(wait_in));		 // Templated
   

   //########################################
   //# PROTOCOL
   //########################################
   /*crx_protocol  AUTO_TEMPLATE (
    .clk	(rx_clk),
        );
   */
   crx_protocol #(.PW(PW),
		  .IOW(IOW))
   crx_protocol (/*AUTOINST*/
		 // Outputs
		 .fifo_access		(fifo_access),
		 .fifo_packet		(fifo_packet[PW-1:0]),
		 // Inputs
		 .clk			(rx_clk),		 // Templated
		 .nreset		(nreset),
		 .datasize		(datasize[CW-1:0]),
		 .io_access		(io_access),
		 .io_packet		(io_packet[2*IOW-1:0]));
   
   //########################################
   //# FAST IO (DDR)
   //########################################
   /*crx_io  AUTO_TEMPLATE (
    .clk	(rx_clk),
        );
   */
   crx_io #(.IOW(IOW))
   crx_io (
	   /*AUTOINST*/
	   // Outputs
	   .io_access			(io_access),
	   .io_packet			(io_packet[2*IOW-1:0]),
	   // Inputs
	   .nreset			(nreset),
	   .clk				(rx_clk),		 // Templated
	   .rx_packet			(rx_packet[IOW-1:0]),
	   .rx_access			(rx_access));
  
endmodule // ctx


// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:
