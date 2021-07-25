//#############################################################################
//# Function: Binary to one hot encoder                                       #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_bitreverse #(parameter DW = 32 // width of data inputs
		       )
   (
    input [DW-1:0]  in, // data input
    output [DW-1:0] out // bit reversed output
    );

   genvar 	   i;

   generate
      for (i=0;i<DW;i=i+1)
	assign out[i] = in[DW-1-i];
   endgenerate

endmodule // oh_bitreverse
