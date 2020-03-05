//#############################################################################
//# Function: Low power data gate                                             #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################
//
  
module oh_datagate #(parameter DW = 32, // width of data inputs
		     parameter N  = 3   // min quiet time before shutdown
		     )
   ( 
     input 	     clk, // clock
     input 	     en,  // data valid
     input [DW-1:0]  din, // data input
     output [DW-1:0] dout // data output    
     );
  	  	 
   reg [N-1:0]    enable_pipe;   
   
   always @ (posedge clk)
     enable_pipe[N-1:0] <= {enable_pipe[N-2:0],en};
   
   //Mask to 0 if no valid for last N cycles
   assign enable = en | (|enable_pipe[N-1:0]);

   assign dout[DW-1:0] = {(DW){enable}} & din[DW-1:0];
  
endmodule // oh_datagate
