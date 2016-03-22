//########################################################################
//# FIFO based clock Domain Crosser
//########################################################################
module oh_fifo_cdc (/*AUTOARG*/
   // Outputs
   wait_out, access_out, packet_out, prog_full, full, empty,
   // Inputs
   nreset, clk_in, access_in, packet_in, clk_out, wait_in
   );

   //#####################################################################
   //# INTERFACE
   //#####################################################################
   parameter DW         = 104;          // FIFO width
   parameter DEPTH      = 32;           // FIFO depth (entries)
   parameter TARGET     = "GENERIC";    // GENERIC,XILINX,ALTERA,GENERIC,ASIC
   parameter WAIT       = 0;            // assert random prog_full wait
   
   //shared async reset
   input              nreset;      

   //input packet
   input              clk_in;     
   input 	      access_in;   
   input [DW-1:0]     packet_in;   
   output 	      wait_out;   

   //output packet
   input              clk_out;   
   output 	      access_out;   
   output [DW-1:0]    packet_out;   
   input 	      wait_in;   

   //status
   output 	      prog_full;
   output 	      full;
   output 	      empty;
      
   //#####################################################################
   //# BODY
   //#####################################################################
   //Local wires
   wire 	      wr_en;
   wire 	      rd_en;   
   wire 	      empty;
   wire 	      full;
   wire 	      prog_full;   
   reg 		      access_out;
      
   //We use the prog_full clean out any buffers in pipe
   //Assumption: The "full" state should never be reached!
   assign wr_en    = access_in;
   assign rd_en    = ~empty & ~wait_in;
   assign wait_out = prog_full;

   //Holds access high while waiting
   always @ (posedge clk_out or negedge nreset)
     if(!nreset)
       access_out <= 1'b0;   
     else if(~wait_in)
       access_out <= rd_en;

   //Read response fifo (from master)
   oh_fifo_async  #(.TARGET(TARGET),
		    .DW(DW),
		    .DEPTH(DEPTH),
		    .WAIT(WAIT))
   fifo (.prog_full (prog_full),
	 .full	    (full),
	 .rd_count  (),
	 .nreset    (nreset),
	 .dout	    (packet_out[DW-1:0]),
	 .empty	    (empty),
	 .wr_clk    (clk_in),
	 .rd_clk    (clk_out),
	 .wr_en	    (wr_en),
	 .din	    (packet_in[DW-1:0]),
	 .rd_en	    (rd_en)
	 );
   
endmodule // fifo_cdc
