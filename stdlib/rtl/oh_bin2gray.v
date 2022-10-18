//#############################################################################
//# Function: Binary to gray encoder                                          #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_bin2gray
  #(parameter N = 32 // width of data inputs
    )
   (
    input [N-1:0]  in, //binary encoded input
    output [N-1:0] out //gray encoded output
    );

   assign out[N-1:0] =  in[N-1:0] ^ {1'b0, in[N-1:1]};

endmodule // oh_bin2gray
