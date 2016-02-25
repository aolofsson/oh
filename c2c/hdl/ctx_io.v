//#######################################################
//# Target specific IO logic (fast, timing sensitive)
//#######################################################
module ctx_io (/*AUTOARG*/
   // Outputs
   tx_packet, tx_access,
   // Inputs
   nreset, clk, io_access, io_packet, tx_wait
   );

   //#####################################################################
   //# INTERFACE
   //#####################################################################

   //parameters
   parameter  IOW  = 16;  
   
   //RESET
   input              nreset;          // async active low reset
   input              clk;             // clock from divider
   
   //Core side 
   input              io_access;       // valid packet
   input [2*IOW-1:0]  io_packet;       // packet
   
   //IO interface
   output [IOW-1:0]   tx_packet;       // data for IO
   output 	      tx_access;       // access signal for IO
   input 	      tx_wait;         // pushback from IO
   
   //regs
   reg [2*IOW-1:0]    packet_reg;
   reg [IOW-1:0]      packet_sh;
   reg 		      tx_access;
   
   //########################################
   //# RESET
   //########################################
   
   //synchronize reset to rx_clk
   oh_rsync oh_rsync(.nrst_out	(io_nreset),
		     .clk	(clk),
		     .nrst_in	(nreset));
   
   //########################################
   //# ACCESS (SDR)
   //########################################

   always @ (posedge clk or negedge io_nreset)
     if(!io_nreset)
       tx_access   <= 1'b0;
     else if(~tx_wait)
       tx_access   <= io_access;
   
   //########################################
   //# DATA (DDR) 
   //########################################

   oh_oddr#(.DW(IOW))
   data_oddr (.out	(tx_packet[IOW-1:0]),
              .clk	(clk),
	      .ce	(io_access & ~tx_wait),
	      .din1	(io_packet[IOW-1:0]),
	      .din2	(io_packet[2*IOW-1:IOW])
	      );
      
endmodule // ctx_io
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:


  
