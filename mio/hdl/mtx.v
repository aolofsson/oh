`include "mio_constants.vh"
module mtx (/*AUTOARG*/
   // Outputs
   wait_out, tx_access, tx_packet,
   // Inputs
   clk, io_clk, nreset, tx_en, datasize, ddr_mode, lsbfirst,
   access_in, packet_in, tx_wait
   );

   //#####################################################################
   //# INTERFACE
   //#####################################################################

   //parameters
   parameter PW         = 104;            // data width (core)
   parameter N          = 16;             // IO data width
   parameter FIFO_DEPTH = 32;             // fifo depth  
   parameter TARGET     = "GENERIC";      // GENERIC,XILINX,ALTERA,GENERIC,ASIC
   localparam CW        = $clog2(2*PW/N); // transfer count width

   //reset, clk, cfg
   input              clk;       // main core clock   
   input              io_clk;    // clock for tx logic
   input              nreset;    // async active low reset
   input 	      tx_en;     // transmit enable   
   input [7:0] 	      datasize;  // size of data transmitted/received
   input              ddr_mode;  // configure mio in ddr mode
   input 	      lsbfirst;  // send bits lsb first
   
   // data to transmit
   input 	      access_in; // fifo data valid
   input [PW-1:0]     packet_in; // fifo packet  
   output 	      wait_out;  // wait pushback for fifo

   //IO interface (90 deg clock supplied outside this block)
   output 	      tx_access; // access signal for IO
   output [N-1:0]     tx_packet; // packet for IO
   input 	      tx_wait;   // pushback from IO
 
   //#####################################################################
   //# BODY
   //#####################################################################
  
   // End of automatics
   /*AUTOINPUT*/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			empty;			// From fifo of oh_fifo_cdc.v
   wire			fifo_access;		// From fifo of oh_fifo_cdc.v
   wire [PW-1:0]	fifo_packet;		// From fifo of oh_fifo_cdc.v
   wire			fifo_wait;		// From par2ser of oh_par2ser.v
   wire			full;			// From fifo of oh_fifo_cdc.v
   wire			io_access;		// From par2ser of oh_par2ser.v
   wire [2*N-1:0]	io_packet;		// From par2ser of oh_par2ser.v
   wire			io_wait;		// From mtx_io of mtx_io.v
   wire			prog_full;		// From fifo of oh_fifo_cdc.v
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
   
   oh_fifo_cdc  #(.TARGET(TARGET),
		  .DW(PW),
		  .DEPTH(FIFO_DEPTH))
   fifo  (.access_in			(tx_en & access_in),
	  /*AUTOINST*/
	  // Outputs
	  .wait_out			(wait_out),		 // Templated
	  .access_out			(fifo_access),		 // Templated
	  .packet_out			(fifo_packet[PW-1:0]),	 // Templated
	  .prog_full			(prog_full),
	  .full				(full),
	  .empty			(empty),
	  // Inputs
	  .nreset			(nreset),		 // Templated
	  .clk_in			(clk),			 // Templated
	  .packet_in			(packet_in[PW-1:0]),	 // Templated
	  .clk_out			(io_clk),		 // Templated
	  .wait_in			(fifo_wait));		 // Templated
   
   //########################################
   //# PROTOCOL
   //########################################

   /*oh_par2ser  AUTO_TEMPLATE (// outputs
	    .dout			(io_packet[2*N-1:0]),
	    .access_out			(io_access),
	    .wait_out			(fifo_wait),
	    // inputs
	    .clk			(io_clk),
	    .nreset			(nreset),
	    .din			(fifo_packet[PW-1:0]),
	    .load			(fifo_access & ~io_wait),
	    .shift			(1'b1),
	    .datasize			(datasize),
	    .lsbfirst			(lsbfirst),
	    .fill			(1'b0),
	    .wait_in			(io_wait),
	    );
    */
 
   oh_par2ser #(.PW(PW),
		.SW(2*N))
   par2ser (/*AUTOINST*/
	    // Outputs
	    .dout			(io_packet[2*N-1:0]),	 // Templated
	    .access_out			(io_access),		 // Templated
	    .wait_out			(fifo_wait),		 // Templated
	    // Inputs
	    .clk			(io_clk),		 // Templated
	    .nreset			(nreset),		 // Templated
	    .din			(fifo_packet[PW-1:0]),	 // Templated
	    .load			(fifo_access & ~io_wait), // Templated
	    .shift			(1'b1),			 // Templated
	    .datasize			(datasize),		 // Templated
	    .lsbfirst			(lsbfirst),		 // Templated
	    .fill			(1'b0),			 // Templated
	    .wait_in			(io_wait));		 // Templated
  
   //########################################
   //# FAST IO (DDR)
   //########################################
 
   mtx_io #(.N(N))
   mtx_io (/*AUTOINST*/
	   // Outputs
	   .tx_packet			(tx_packet[N-1:0]),
	   .tx_access			(tx_access),
	   .io_wait			(io_wait),
	   // Inputs
	   .nreset			(nreset),
	   .io_clk			(io_clk),
	   .ddr_mode			(ddr_mode),
	   .tx_wait			(tx_wait),
	   .io_access			(io_access),
	   .io_packet			(io_packet[2*N-1:0]));
   
endmodule // mtx
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:

