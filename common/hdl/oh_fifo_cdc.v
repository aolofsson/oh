/*
 ########################################################################
 Generic Clock Domain Crossing Block
 ########################################################################
 */

module oh_fifo_cdc (/*AUTOARG*/
   // Outputs
   wait_out, access_out, packet_out,
   // Inputs
   nreset, clk_in, access_in, packet_in, clk_out, wait_in
   );

   parameter DW    = 104;
   parameter DEPTH = 32;
   parameter WAIT  = 0;

   /********************************/
   /*Shard async reset             */
   /********************************/
   input              nreset;   

   /********************************/
   /*Incoming Packet               */
   /********************************/
   input              clk_in;     
   input 	      access_in;   
   input [DW-1:0]     packet_in;   
   output 	      wait_out;   

   /********************************/
   /*Outgoing Packet               */
   /********************************/  
   input              clk_out;   
   output 	      access_out;   
   output [DW-1:0]    packet_out;   
   input 	      wait_in;   
   
   //Local wires
   wire 	      wr_en;
   wire 	      rd_en;   
   wire 	      empty;
   wire 	      full;
   wire 	      prog_full;   
   wire 	      valid;   
   reg 		      access_out;
      
   //We use the prog_full clean out any buffers in pipe that are too hard
   //to stop. "slack"
   //Assumption: The "full" state should never be reached!

   assign wr_en    = access_in;
   assign rd_en    = ~empty & ~wait_in;
   assign wait_out = prog_full;

   //Holds access high until "acknowledge"
   always @ (posedge clk_out or negedge nreset)
     if(!nreset)
       access_out <=1'b0;   
     else if(~wait_in)
       access_out <=rd_en;

   //Read response fifo (from master)
   defparam fifo.DW    = DW;
   defparam fifo.DEPTH = DEPTH;
   defparam fifo.WAIT  = WAIT;

   oh_fifo_async  fifo (.prog_full		(prog_full),//stay safe for now
		     .full		(full),
		     .rst		(~nreset),
		     // Outputs
		     .dout		(packet_out[DW-1:0]),
		     .empty		(empty),
		     .valid		(valid), 
		     // Inputs
		     .wr_clk		(clk_in),
		     .rd_clk		(clk_out),
		     .wr_en		(wr_en),
		     .din		(packet_in[DW-1:0]),
		     .rd_en		(rd_en)
		     );
      
endmodule // fifo_cdc
