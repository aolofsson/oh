//#############################################################################
//# Function: Binary to one hot encoder                                       #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_bin2onehot #(parameter N  = 2 // output vector width
		       )
   (
    input [NB-1:0] in, // unsigned binary input  
    output [N-1:0] out   // one hot output vector
    );
   
   localparam NB = $clog2(N); // binary encoded input
     
   genvar 	    i;      
   for(i=0;i<N;i=i+1)
     assign out[i] = (in[NB-1:0] == i);
   
endmodule // oh_bin2onehot







