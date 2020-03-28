//#############################################################################
//# Function: Delays input signal by N clock cycles                           #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_delay  #(parameter DW = 1, // width of data
		   parameter N  = 1  // clock cycle delay by
		   )   
   (
    input [DW-1:0]  in, // input
    input 	    clk,//clock input
    output [DW-1:0] out // output
    );

   reg [DW-1:0]     sync_pipe[N-1:0];
      
   genvar 	    i;
   generate
      always @ (posedge clk)
	sync_pipe[0]<=in[DW-1:0];
      for(i=1;i<N;i=i+1)
        always @ (posedge clk)
	  sync_pipe[i]<=sync_pipe[i-1];
   endgenerate

   assign out[DW-1:0] = sync_pipe[N-1];
   
endmodule // oh_delay



