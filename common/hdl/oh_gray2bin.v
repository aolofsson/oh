//#############################################################################
//# Function: Gray to binary encoder                                          #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_gray2bin #(parameter N = 32) // width of data inputs
   (
    input [N-1:0]  in,  //gray encoded input
    output [N-1:0] out  //binary encoded output
    );

   reg [N-1:0]     bin;
   wire [N-1:0]    gray;

   integer 	   i,j;

   assign gray[N-1:0] = in[N-1:0];
   assign out[N-1:0]  = bin[N-1:0];

   always @*
     begin
	bin[N-1] = gray[N-1];
	for (i=0; i<(N-1); i=i+1)
	  begin
	     bin[i] = 1'b0;
	     for (j=i; j<N; j=j+1)
	       bin[i] = bin[i] ^ gray [j];
	  end
     end

endmodule // oh_gray2bin
