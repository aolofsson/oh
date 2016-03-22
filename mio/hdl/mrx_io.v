//#######################################################
//# Target specific IO logic (fast, timing sensitive)
//#######################################################
module mrx_io (/*AUTOARG*/
   // Outputs
   io_access, io_packet,
   // Inputs
   nreset, rx_clk, ddr_mode, lsbfirst, rx_packet, rx_access
   );

   //#####################################################################
   //# INTERFACE
   //#####################################################################

   //parameters
   parameter  N  = 16;  

   //RESET
   input            nreset;        // async active low reset
   input 	    rx_clk;        // clock for IO
   input 	    ddr_mode;      // select between sdr/ddr data
   input 	    lsbfirst;      // shufle data in msbfirst mode
   
   //IO interface
   input [N-1:0]    rx_packet;     // data for IO
   input 	    rx_access;     // access signal for IO
   
   //FIFO interface (core side)
   output 	    io_access;     // fifo packet valid
   output [2*N-1:0] io_packet;     // fifo packet
   
   //regs
   reg 		    io_access;
   wire [2*N-1:0]   ddr_data;
   reg [2*N-1:0]    sdr_data;
   reg 		    byte0_sel;
   
   //########################################
   //# CLOCK, RESET
   //########################################

   //synchronize reset to rx_clk
   oh_rsync oh_rsync(.nrst_out	(io_nreset),
		     .clk	(rx_clk),
		     .nrst_in	(nreset)
		     );
      
   //########################################
   //# ACCESS (SDR)
   //########################################

   always @ (posedge rx_clk or negedge io_nreset)
     if(!nreset)
       io_access   <= 1'b0;
     else
       io_access   <= rx_access;
   
   //########################################
   //# DATA (DDR) 
   //########################################
   
   oh_iddr #(.DW(N))
   data_iddr(.q1			(ddr_data[N-1:0]),
	     .q2			(ddr_data[2*N-1:N]),
	     .clk			(rx_clk),
	     .ce			(rx_access),
	     .din			(rx_packet[N-1:0])
	     );
   //########################################
   //# DATA (SDR) 
   //########################################
   //select 2nd byte (stall on this signal)

   always @ (posedge rx_clk)
     if(~rx_access)
       byte0_sel <= 1'b1;
     else if (~ddr_mode)
       byte0_sel <= rx_access ^ byte0_sel;
   
   always @ (posedge rx_clk)
     if(byte0_sel)
       sdr_data[N-1:0]  <= rx_packet[N-1:0];
     else
       sdr_data[2*N-1:N] <= rx_packet[N-1:0];

   //########################################
   //# HANDL DDR/SDR
   //########################################
   
   assign io_packet[2*N-1:0] =  ~ddr_mode            ? sdr_data[2*N-1:0] :
				ddr_mode & ~lsbfirst ? {ddr_data[N-1:0],
						       ddr_data[2*N-1:N]} :
			                               ddr_data[2*N-1:0];
   
endmodule // mrx_io

// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:

  
