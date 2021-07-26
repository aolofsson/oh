//#############################################################################
//# Function: Delays input signal by N clock cycles                           #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_delay
  #(parameter N        = 1,               // width of data
    parameter MAXDELAY = 4,               // maximum delay cycles
    parameter M        = $clog2(MAXDELAY) // delay selctor
    )
   (
    input 	   clk, //clock input
    input [N-1:0]  in, // input vector
    input [M-1:0]  sel, // delay selector
    output [N-1:0] out  // output vector
    );


   //Delay pipeline
   reg [N-1:0]     sync_pipe[MAXDELAY-1:0];
   genvar 	    i;
   generate
      always @ (posedge clk)
	sync_pipe[0]<=in[N-1:0];
      for(i=1;i<MAXDELAY;i=i+1) begin: gen_pipe
         always @ (posedge clk)
	   sync_pipe[i]<=sync_pipe[i-1];
      end
   endgenerate

   //Delay selector
   assign out[N-1:0] = sync_pipe[sel[M-1:0]];

endmodule
