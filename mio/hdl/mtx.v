module mtx (/*AUTOARG*/
   // Outputs
   wait_out, tx_access, tx_packet,
   // Inputs
   clk, io_clk, nreset, access_in, packet_in, datasize, tx_wait
   );

   //#####################################################################
   //# INTERFACE
   //#####################################################################

   //parameters
   parameter PW         = 104;               // data width (core)
   parameter MIOW       = 16;                // IO data width
   parameter FIFO_DEPTH = 32;                // fifo depth  
   localparam CW        = $clog2(2*PW/MIOW); // transfer count width

   //reset, clk
   input              clk;         // main core clock   
   input              io_clk;      // clock for tx logic
   input              nreset;      // async active low reset
	         
   // data to transmit
   input 	      access_in;   // fifo data valid
   input [PW-1:0]     packet_in;   // fifo packet
   input [CW-1:0]     datasize;    // size of data transmitted/received
   output 	      wait_out;    // wait pushback for fifo

   //IO interface (90 deg clock supplied outside this block)
   output 	      tx_access;   // access signal for IO
   output [MIOW-1:0]  tx_packet;   // packet for IO
   input 	      tx_wait;     // pushback from IO

   //#####################################################################
   //# BODY
   //#####################################################################
   /*AUTOOUTPUT*/
   /*AUTOINPUT*/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			fifo_access;		// From fifo of oh_fifo_cdc.v
   wire [PW-1:0]	fifo_packet;		// From fifo of oh_fifo_cdc.v
   wire			fifo_wait;		// From mtx_protocol of mtx_protocol.v
   wire			io_access;		// From mtx_protocol of mtx_protocol.v
   wire [2*MIOW-1:0]	io_packet;		// From mtx_protocol of mtx_protocol.v
   // End of automatics


   //########################################
   //# SYNCHRONIZATION FIFO
   //########################################

  /*oh_fifo_cdc  AUTO_TEMPLATE (
   .wait_out    (wait_out),
   .access_out  (fifo_access),
   .packet_out  (fifo_packet[PW-1:0]),
   // Inputs
   .nreset	(nreset),
   .clk_in	(clk),
   .access_in	(access_in),
   .packet_in	(packet_in[PW-1:0]),
   .clk_out	(io_clk),
   .wait_in	(fifo_wait),
    );
   */
   
   oh_fifo_cdc  #(.DW(PW),
		  .DEPTH(FIFO_DEPTH))
   fifo  (/*AUTOINST*/
	  // Outputs
	  .wait_out			(wait_out),		 // Templated
	  .access_out			(fifo_access),		 // Templated
	  .packet_out			(fifo_packet[PW-1:0]),	 // Templated
	  // Inputs
	  .nreset			(nreset),		 // Templated
	  .clk_in			(clk),			 // Templated
	  .access_in			(access_in),		 // Templated
	  .packet_in			(packet_in[PW-1:0]),	 // Templated
	  .clk_out			(io_clk),		 // Templated
	  .wait_in			(fifo_wait));		 // Templated
   
   //########################################
   //# PROTOCOL
   //########################################
   /*mtx_protocol  AUTO_TEMPLATE (
    .clk	(io_clk),
    );
   */
   mtx_protocol #(.MIOW(MIOW),
		  .PW(PW))

   mtx_protocol (/*AUTOINST*/
		 // Outputs
		 .fifo_wait		(fifo_wait),
		 .io_access		(io_access),
		 .io_packet		(io_packet[2*MIOW-1:0]),
		 // Inputs
		 .clk			(io_clk),		 // Templated
		 .nreset		(nreset),
		 .datasize		(datasize[CW-1:0]),
		 .fifo_access		(fifo_access),
		 .fifo_packet		(fifo_packet[PW-1:0]),
		 .tx_wait		(tx_wait));
      
   //########################################
   //# FAST IO (DDR)
   //########################################
   /*ctx_io  AUTO_TEMPLATE (
    .clk	(io_clk),
    );
   */
   mtx_io #(.MIOW(MIOW))
   mtx_io (/*AUTOINST*/
	   // Outputs
	   .tx_packet			(tx_packet[MIOW-1:0]),
	   .tx_access			(tx_access),
	   // Inputs
	   .nreset			(nreset),
	   .clk				(clk),
	   .io_access			(io_access),
	   .io_packet			(io_packet[2*MIOW-1:0]),
	   .tx_wait			(tx_wait));

   
endmodule // ctx
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:

