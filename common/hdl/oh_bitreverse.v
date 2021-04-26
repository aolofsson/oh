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
   
   
   reg [DW-1:0]    out;        
   integer 	   i;
   
   always @*
     for (i=0;i<DW;i=i+1)
       out[i]=in[DW-1-i];   
   
endmodule // oh_bitreverse






