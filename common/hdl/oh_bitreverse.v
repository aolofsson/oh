//#############################################################################
//# Function: Binary to one hot encoder                                       #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_bitreverse
  #(parameter N = 32 // width of data inputs
    )
   (
    input [N-1:0]  in, // data input
    output [N-1:0] out // bit reversed output
    );

   genvar 	   i;

   generate
      for (i=0;i<N;i=i+1)
	assign out[i] = in[N-1-i];
   endgenerate

endmodule // oh_bitreverse
