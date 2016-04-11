//#############################################################################
//# Function: Clock domain crossing FIFO                                      #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_fifo_cdc # (parameter DW        = 104,      //FIFO width
		      parameter DEPTH     = 32,       //FIFO depth (entries)
		      parameter TARGET    = "GENERIC" //XILINX,ALTERA,GENERIC,ASIC
		      )
   (
   input 	   nreset,  // shared domain async active low reset
   input 	   clk_in,  // write clock
   input 	   access_in, // write access
   input [DW-1:0]  packet_in, // write packet
   output 	   wait_out, // write pushback
   input 	   clk_out, //read clock
   output 	   access_out, //read access
   output [DW-1:0] packet_out, //read packet
   input 	   wait_in, // read pushback
   output 	   prog_full, // fifo is half full
   output 	   full, // fifo is full
   output 	   empty // fifo is empty
    );
   
   // local variables
   reg 		   access_out;
      
   // FIFO control logic
   assign wr_en    = access_in;
   assign rd_en    = ~empty & ~wait_in;
   assign wait_out = prog_full;        //wait_out should stall access_in signal

   //Holds access high while waiting
   always @ (posedge clk_out or negedge nreset)
     if(!nreset)
       access_out <= 1'b0;   
     else if(~wait_in)
       access_out <= rd_en;

   //Read response fifo (from master)
   oh_fifo_async  #(.TARGET(TARGET),
		    .DW(DW),
		    .DEPTH(DEPTH))
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
	 .rd_en	    (rd_en));
   
endmodule // oh_fifo_cdc

