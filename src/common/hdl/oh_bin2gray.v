//#############################################################################
//# Function: Binary to gray encoder                                          #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_bin2gray #(parameter DW = 32 // width of data inputs
		     ) 
   (
    input [DW-1:0]  in, //binary encoded input
    output [DW-1:0] out //gray encoded output
    );
   
   reg [DW-1:0]    gray; 
   wire [DW-1:0]   bin;

   integer 	   i;   

   assign bin[DW-1:0]  = in[DW-1:0];
   assign out[DW-1:0]  = gray[DW-1:0];
  
   always @*
     begin
	gray[DW-1] = bin[DW-1];   
	for (i=0; i<(DW-1); i=i+1)
	  gray[i] = bin[i] ^ bin[i+1];	      
     end
   
endmodule // oh_bin2gray
