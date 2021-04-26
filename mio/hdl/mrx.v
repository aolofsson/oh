//#############################################################################
//# Purpose: MIO Receive Datapath                                             #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################
module mrx # ( parameter PW         = 104,               // fifo width
	       parameter AW         = 32,               // fifo width
	       parameter IOW        = 8,                 // I./O data width
	       parameter FIFO_DEPTH = 16,                // fifo depth  
	       parameter TARGET     = "GENERIC"         // fifo target
	       )
   (//reset, clk, cfg
    input 	    clk, // main core clock   
    input 	    nreset, // async active low reset
    input 	    ddr_mode,
    input [1:0]     iowidth,
    input 	    amode, // To mrx_fifo of mrx_fifo.v
    input [4:0]     ctrlmode, // To mrx_fifo of mrx_fifo.v
    input [1:0]     datamode, // To mrx_fifo of mrx_fifo.v
    input [AW-1:0]  dstaddr, // To mrx_fifo of mrx_fifo.v
    input 	    emode, // To mrx_fifo of mrx_fifo.v
    //status
    output 	    rx_empty, // rx fifo is empty
    output 	    rx_full, // rx fifo is full (should never happen!) 
    output 	    rx_prog_full,// rx is getting full (stop sending!)
    //IO interface
    input 	    rx_clk, // clock from IO
    input 	    rx_access, // access signal for IO
    input [IOW-1:0] rx_packet, // packet from IO
    output 	    rx_wait, // pushback for IO
    // data 
    output 	    access_out, // fifo data valid
    output [PW-1:0] packet_out, // fifo packet
    input 	    wait_in     // wait pushback for fifo
    );
   
   /*AUTOOUTPUT*/
   /*AUTOINPUT*/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			io_access;		// From mrx_io of mrx_io.v
   wire [63:0]		io_packet;		// From mrx_io of mrx_io.v
   wire [7:0]		io_valid;		// From mrx_io of mrx_io.v
   // End of automatics

   //########################################
   //# Synchronization FIFO
   //########################################

   mrx_fifo #(.PW(PW),
	      .AW(AW),
	      .FIFO_DEPTH(FIFO_DEPTH),
	      .TARGET(TARGET))  
   mrx_fifo (/*AUTOINST*/
	     // Outputs
	     .rx_wait			(rx_wait),
	     .access_out		(access_out),
	     .packet_out		(packet_out[PW-1:0]),
	     // Inputs
	     .clk			(clk),
	     .nreset			(nreset),
	     .emode			(emode),
	     .ctrlmode			(ctrlmode[4:0]),
	     .amode			(amode),
	     .dstaddr			(dstaddr[AW-1:0]),
	     .datamode			(datamode[1:0]),
	     .io_access			(io_access),
	     .io_valid			(io_valid[7:0]),
	     .io_packet			(io_packet[63:0]),
	     .rx_clk			(rx_clk),
	     .wait_in			(wait_in));
   
   
   //########################################
   //# FAST IO (DDR)
   //########################################
   
   mrx_io #(.IOW(IOW))
   mrx_io (
	   /*AUTOINST*/
	   // Outputs
	   .io_access			(io_access),
	   .io_valid			(io_valid[7:0]),
	   .io_packet			(io_packet[63:0]),
	   // Inputs
	   .nreset			(nreset),
	   .ddr_mode			(ddr_mode),
	   .iowidth			(iowidth[1:0]),
	   .rx_clk			(rx_clk),
	   .rx_packet			(rx_packet[IOW-1:0]),
	   .rx_access			(rx_access));
  
endmodule // ctx


// Local Variables:
// verilog-library-directories:("." "../../common/hdl" "../../../oh/emesh/hdl")
// End:
