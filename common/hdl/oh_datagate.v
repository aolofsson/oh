//#############################################################################
//# Function: Low power data gate                                             #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_datagate #(parameter DW   = 32, // width of data inputs
		     parameter PS   = 3   // min quiet time before shutdown
		     )
   ( 
     input 	     clk, // clock
     input 	     en,  // data valid
     input [DW-1:0]  din, // data input
     output [DW-1:0] dout // data output    
     );
   
 	  	 
   reg [PS-1:0]    enable_pipe;   
   wire 	   enable;
   
   always @ (posedge clk)
     enable_pipe[PS-1:0] <= {enable_pipe[PS-2:0],en};
   
   assign enable = {enable_pipe[PS-1:0],en};

   assign dout[DW-1:0] =  {(DW){enable}} & din[DW-1:0];
  
endmodule // oh_datagate
