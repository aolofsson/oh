//#######################################################
//# Target specific IO logic (fast, timing sensitive)
//#######################################################
module mrx_io (/*AUTOARG*/
   // Outputs
   io_access, io_packet,
   // Inputs
   nreset, clk, rx_packet, rx_access
   );

   //#####################################################################
   //# INTERFACE
   //#####################################################################

   //parameters
   parameter  N  = 16;  

   //RESET
   input            nreset;        // async active low reset
   input 	    clk;           // clock for IO
   //IO interface
   input [N-1:0]    rx_packet;     // data for IO
   input 	    rx_access;     // access signal for IO
   
   //FIFO interface (core side)
   output 	    io_access;     // fifo packet valid
   output [2*N-1:0] io_packet;     // fifo packet
   
   //regs
   reg 		    io_access;
   
   //########################################
   //# CLOCK, RESET
   //########################################

   //synchronize reset to rx_clk
   oh_rsync oh_rsync(.nrst_out	(io_nreset),
		     .clk	(clk),
		     .nrst_in	(nreset)
		     );
      
   //########################################
   //# ACCESS (SDR)
   //########################################

   always @ (posedge clk or negedge io_nreset)
     if(!nreset)
       io_access   <= 1'b0;
     else
       io_access   <= rx_access;
   
   //########################################
   //# DATA (DDR) 
   //########################################
   
   oh_iddr #(.DW(N))
   data_iddr(.q1			(io_packet[N-1:0]),
	     .q2			(io_packet[2*N-1:N]),
	     .clk			(clk),
	     .ce			(rx_access),
	     .din			(rx_packet[N-1:0])
	     );
   
endmodule // mrx_io

// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:

  
