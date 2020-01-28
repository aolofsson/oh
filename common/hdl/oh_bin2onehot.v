//#############################################################################
//# Function: Binary to one hot encoder                                       #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_bin2onehot #(parameter DW = 32) // width of data inputs
(
 input [NB-1:0]  in, // unsigned binary input  
 output [DW-1:0] out   // one hot output vector
 );
   
   parameter NB = $clog2(DW);  // encoded bit width
   
   integer 	  i;      
   reg [DW-1:0] 	  out;  

   always @*
     for(i=0;i<DW;i=i+1)
       out[i]=(in[NB-1:0]==i);
   
endmodule // oh_bin2onehot





