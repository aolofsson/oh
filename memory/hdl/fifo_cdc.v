/*
 ########################################################################
 Generic Clock Domain Crossing Block
 ########################################################################
 */

module fifo_cdc (/*AUTOARG*/
   // Outputs
   wait_out, access_out, packet_out,
   // Inputs
   clk_in, reset_in, access_in, packet_in, clk_out, reset_out,
   wait_in
   );

   parameter DW    = 104;
   parameter DEPTH = 32;

   /********************************/
   /*Incoming Packet               */
   /********************************/
   input              clk_in;   
   input              reset_in;
   input 	      access_in;   
   input [DW-1:0]     packet_in;   
   output 	      wait_out;   

   /********************************/
   /*Outgoing Packet               */
   /********************************/  
   input              clk_out;   
   input              reset_out;
   output 	      access_out;   
   output [DW-1:0]    packet_out;   
   input 	      wait_in;   
   
   //Local wires
   wire 	      wr_en;
   wire 	      rd_en;   
   wire 	      empty;
   wire 	      full;
   wire 	      valid;   
   reg 		      access_out;
      
   assign wr_en    = access_in & ~full;
   assign rd_en    = ~empty & ~wait_in;
   assign wait_out = full;

   //Keep access high until "acknowledge"
   always @ (posedge clk_out or posedge reset_out)
     if(reset_out)
       access_out <=1'b0;   
     else if(~wait_in)
       access_out <=rd_en;

   //Read response fifo (from master)
   defparam fifo.DW    = DW;
   defparam fifo.DEPTH = DEPTH;

   fifo_async  fifo (.prog_full		(full),//stay safe for now
		     .full		(),
		     // Outputs
		     .dout		(packet_out[DW-1:0]),
		     .empty		(empty),
		     .valid		(valid), 
		     // Inputs
		     .wr_rst		(reset_in),
		     .rd_rst		(reset_out),
		     .wr_clk		(clk_in),
		     .rd_clk		(clk_out),
		     .wr_en		(wr_en),
		     .din		(packet_in[DW-1:0]),
		     .rd_en		(rd_en)
		     );
      
endmodule // fifo_cdc
