//#############################################################################
//# Function: Gray to binary encoder                                          #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_gray2bin #(parameter DW = 32) // width of data inputs
   (
    input [DW-1:0]  in,  //gray encoded input
    output [DW-1:0] out  //binary encoded output
    );
   
   reg [DW-1:0]     bin;
   wire [DW-1:0]    gray;
   
   integer 	   i,j;

   assign gray[DW-1:0] = in[DW-1:0];
   assign out[DW-1:0]  = bin[DW-1:0];

   always @*
     begin
	bin[DW-1] = gray[DW-1];   
	for (i=0; i<(DW-1); i=i+1)
	  begin
	     bin[i] = 1'b0;	
	     for (j=i; j<DW; j=j+1)
	       bin[i] = bin[i] ^ gray [j];
	  end
     end

endmodule // oh_gray2bin



