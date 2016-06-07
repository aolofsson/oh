//#######################################################
//# Target specific IO logic (fast, timing sensitive)
//#######################################################
module mrx_io (/*AUTOARG*/
   // Outputs
   io_access, io_packet,
   // Inputs
   nreset, rx_clk, ddr_mode, lsbfirst, framepol, rx_packet, rx_access
   );

   //#####################################################################
   //# INTERFACE
   //#####################################################################

   //parameters
   parameter  NMIO  = 16;  

   //RESET
   input               nreset;        // async active low reset
   input 	       rx_clk;        // clock for IO
   input 	       ddr_mode;      // select between sdr/ddr data
   input 	       lsbfirst;      // shufle data in msbfirst mode
   input 	       framepol;      // frame polarity
   
   //IO interface
   input [NMIO-1:0]    rx_packet;     // data for IO
   input 	       rx_access;     // access signal for IO
   
   //FIFO interface (core side)
   output 	       io_access;     // fifo packet valid
   output [2*NMIO-1:0] io_packet;     // fifo packet

   //#####################################################################
   //# BODY
   //#####################################################################

   //regs
   reg 		       io_access;
   wire [2*NMIO-1:0]   ddr_data;
   reg [2*NMIO-1:0]    sdr_data;
   reg 		       byte0_sel;
   
   //########################################
   //# SELECT FRAME POLARITY
   //########################################

   assign rx_frame =  framepol ^ rx_access;
   
   //########################################
   //# ACCESS (SDR)
   //########################################

   always @ (posedge rx_clk or negedge nreset)
     if(!nreset)
       io_access <= 1'b0;
     else
       io_access <= rx_frame;
   
   //########################################
   //# DATA (DDR) 
   //########################################
   
   oh_iddr #(.DW(NMIO))
   data_iddr(.q1			(ddr_data[NMIO-1:0]),
	     .q2			(ddr_data[2*NMIO-1:NMIO]),
	     .clk			(rx_clk),
	     .ce			(rx_frame),
	     .din			(rx_packet[NMIO-1:0])
	     );
   //########################################
   //# DATA (SDR) 
   //########################################
   //select 2nd byte (stall on this signal)

   always @ (posedge rx_clk)
     if(~rx_frame)
       byte0_sel <= 1'b1;
     else if (~ddr_mode)
       byte0_sel <= rx_frame ^ byte0_sel;
   
   always @ (posedge rx_clk)
     if(byte0_sel)
       sdr_data[NMIO-1:0]  <= rx_packet[NMIO-1:0];
     else
       sdr_data[2*NMIO-1:NMIO] <= rx_packet[NMIO-1:0];

   //########################################
   //# HANDL DDR/SDR
   //########################################
   
   assign io_packet[2*NMIO-1:0] =  ~ddr_mode             ? sdr_data[2*NMIO-1:0] :
			  	    ddr_mode & ~lsbfirst ? {ddr_data[NMIO-1:0],
				   		           ddr_data[2*NMIO-1:NMIO]} :
			                                   ddr_data[2*NMIO-1:0];
   
endmodule // mrx_io

// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:

  
