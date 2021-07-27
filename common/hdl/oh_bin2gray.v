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

   reg [N-1:0] 	   gray;
   wire [N-1:0]    bin;

   integer 	   i;

   assign bin[N-1:0]  = in[N-1:0];
   assign out[N-1:0]  = gray[N-1:0];

   always @*
     begin
	gray[N-1] = bin[N-1];
	for (i=0; i<(N-1); i=i+1)
	  gray[i] = bin[i] ^ bin[i+1];
     end

endmodule // oh_bin2gray
