//#############################################################################
//# Purpose: MIO Receive Synchronization FIFO                                 #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################
module mrx_fifo # ( parameter PW         = 104,        // fifo width
		    parameter AW         = 32,         // fifo width
		    parameter FIFO_DEPTH = 16,         // fifo depth  
		    parameter TARGET     = "GENERIC"   // fifo target
		    )
   (// reset, clk, cfg
    input 	    clk, // main core clock   
    input 	    nreset, // async active low reset
    // IO interface
    input 	    io_access,// fifo write
    input [7:0]     io_valid, // fifo byte valid
    input [63:0]    io_packet, // fifo packet
    output 	    rx_wait,
    input 	    rx_clk,
    // transaction for mesh
    output 	    access_out, // fifo data valid
    output [PW-1:0] packet_out, // fifo packet
    input 	    wait_in     // wait pushback for fifo
    );

   wire [71:0] 	    fifo_packet_out;
   wire 	    fifo_access_out;
   wire 	    fifo_wait_out;
   
   //########################################################
   //# FIFO 
   //#######################################################   
   
   oh_fifo_cdc  #(.TARGET(TARGET),
		  .DW(72),
		  .DEPTH(FIFO_DEPTH))
   fifo  (// Outputs
	  .wait_out			(rx_wait),
	  .access_out			(fifo_access_out),
	  .packet_out			(fifo_packet_out[71:0]),
	  .prog_full			(),
	  .full				(),
	  .empty			(),
	  // Inputs
	  .nreset			(nreset),
	  .clk_in			(rx_clk),
	  .access_in			(io_access),
	  .packet_in			({io_packet[63:0],io_valid[7:0]}),
	  .clk_out			(clk),
	  .wait_in			(wait_in));
   
   //########################################################
   //# Packet Processing
   //#######################################################   
   
   
   
endmodule // mrx_fifo

// Local Variables:
// verilog-library-directories:("." "../../common/hdl" "../../../oh/emesh/hdl")
// End:
