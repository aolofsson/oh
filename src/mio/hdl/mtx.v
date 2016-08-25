//#############################################################################
//# Purpose: MIO Transmit Datapath                                            #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################
module mtx # ( parameter PW         = 104,               // fifo width
	       parameter AW         = 32,               // fifo width
	       parameter IOW        = 8,                 // I./O data width
	       parameter FIFO_DEPTH = 16,                // fifo depth  
	       parameter TARGET     = "GENERIC"         // fifo target
	      )
   (// reset, clk, cfg
    input 	     clk, // main core clock   
    input 	     io_clk, // clock for tx logic
    input 	     nreset, // async active low reset
    input 	     tx_en, // transmit enable   
    input 	     ddr_mode, // configure mio in ddr mode
    input 	     lsbfirst, // send bits lsb first
    input 	     emode, //emesh mode
    input [1:0]      iowidth,//input width
    // status
    output 	     tx_empty, // tx fifo is empty
    output 	     tx_full, // tx fifo is full (should never happen!) 
    output 	     tx_prog_full,// tx is getting full (stop sending!)    
    // data to transmit
    input 	     access_in, // fifo data valid
    input [PW-1:0]   packet_in, // fifo packet  
    output 	     wait_out, // wait pushback for fifo    
    // IO interface (90 deg clock supplied outside this block)
    output 	     tx_access, // access signal for IO
    output [IOW-1:0] tx_packet, // packet for IO
    input 	     tx_wait     // pushback from IO
    );

   //###############
   //# LOCAL WIRES
   //###############

   // End of automatics
   /*AUTOINPUT*/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [63:0]		io_packet;		// From mtx_fifo of mtx_fifo.v
   wire [7:0]		io_valid;		// From mtx_fifo of mtx_fifo.v
   wire			io_wait;		// From mtx_io of mtx_io.v
   // End of automatics

   //########################################
   //# Synchronization FIFO
   //########################################

   mtx_fifo #(.PW(PW),
	      .AW(AW),
	      .FIFO_DEPTH(FIFO_DEPTH),
	      .TARGET(TARGET))   
   mtx_fifo (/*AUTOINST*/
	     // Outputs
	     .wait_out			(wait_out),
	     .io_packet			(io_packet[63:0]),
	     .io_valid			(io_valid[7:0]),
	     // Inputs
	     .clk			(clk),
	     .io_clk			(io_clk),
	     .nreset			(nreset),
	     .tx_en			(tx_en),
	     .emode			(emode),
	     .access_in			(access_in),
	     .packet_in			(packet_in[PW-1:0]),
	     .io_wait			(io_wait));
   
   //########################################
   //# IO Logic (DDR, shift register)
   //########################################
 
   mtx_io #(.IOW(IOW))
   mtx_io (/*AUTOINST*/
	   // Outputs
	   .tx_packet			(tx_packet[IOW-1:0]),
	   .tx_access			(tx_access),
	   .io_wait			(io_wait),
	   // Inputs
	   .nreset			(nreset),
	   .io_clk			(io_clk),
	   .ddr_mode			(ddr_mode),
	   .iowidth			(iowidth[1:0]),
	   .tx_wait			(tx_wait),
	   .io_valid			(io_valid[7:0]),
	   .io_packet			(io_packet[IOW-1:0]));
   
endmodule // mtx
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:

