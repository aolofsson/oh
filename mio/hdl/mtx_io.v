//#######################################################
//# Target specific IO logic (fast, timing sensitive)
//#######################################################
module mtx_io (/*AUTOARG*/
   // Outputs
   tx_packet, tx_access, io_wait,
   // Inputs
   nreset, io_clk, ddr_mode, lsbfirst, tx_wait, io_access, io_packet
   );

   //#####################################################################
   //# INTERFACE
   //#####################################################################

   //parameters
   parameter N  = 16;  
   
   //reset, clk, cfg
   input           nreset;        // async active low reset
   input           io_clk;        // clock from divider
   input 	   ddr_mode;      // send data as ddr
   input 	   lsbfirst;      // send data lsbfirst
   
   //IO interface
   output [N-1:0]  tx_packet;     // data for IO
   output 	   tx_access;     // access signal for IO
   input 	   tx_wait;       // IO wait signals
   
   //Core side 
   input           io_access;     // valid packet
   input [2*N-1:0] io_packet;     // packet
   output 	   io_wait;       // pushback to serializer in sdr mode   

   //regs
   reg 		   tx_access;
   wire [N-1:0]    tx_packet_ddr;
   reg [N-1:0] 	   tx_packet_sdr;
   reg 		   byte0_sel;
   wire [2*N-1:0]  ddr_data;
   
   //########################################
   //# RESET
   //########################################
   
   //synchronize reset to io_clk
   oh_rsync oh_rsync(.nrst_out	(io_nreset),
		     .clk	(io_clk),
		     .nrst_in	(nreset));
   
   //########################################
   //# ACCESS (SDR)
   //########################################

   always @ (posedge io_clk or negedge io_nreset)
     if(!io_nreset)
       tx_access   <= 1'b0;
     else
       tx_access   <= io_access;

   //########################################
   //# SDR DATA SELECTOR
   //########################################

   // sampling data for sdr
   always @ (posedge io_clk)
     if(io_access)
       tx_packet_sdr[N-1:0] <= byte0_sel ? io_packet[N-1:0] :
	                                   io_packet[2*N-1:N];   

   //select 2nd byte (stall on this signal)
   always @ (posedge io_clk)
     if(~io_access)
       byte0_sel <= 1'b0;
     else if (~ddr_mode)
       byte0_sel <= io_access ^ byte0_sel;

   // TODO: add synchronizer?!
   assign io_wait = tx_wait | byte0_sel;
   
   //########################################
   //# DATA SAMPLING (DDR/SDR) 
   //########################################      

   // shuffle bits when in msb mode
   assign ddr_data[2*N-1:0] = (~lsbfirst & ddr_mode) ? {io_packet[N-1:0],
					               io_packet[2*N-1:N]} : 
			                               io_packet[2*N-1:0];
   oh_oddr#(.DW(N))
   data_oddr (.out	(tx_packet_ddr[N-1:0]),
              .clk	(io_clk),
	      .ce	(1'b1),
	      .din1	(ddr_data[N-1:0]),
	      .din2	(ddr_data[2*N-1:N])
	      );

   //select between ddr/sdr data
   assign tx_packet[N-1:0] = ddr_mode ? tx_packet_ddr[N-1:0] :
		                        tx_packet_sdr[N-1:0];
         
endmodule // mtx_io
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:


  
