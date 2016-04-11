//#############################################################################
//# Function: Calculates parity value for                                     #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH repository)                         # 
//#############################################################################

module oh_parity #( parameter DW      = 2 // data width
		 ) 
   (
    input [DW-1:0] in,  // data input
    output 	   out // calculated parity bit
    );
 
  assign  parity = ^in[DW-1:0];
   
endmodule // oh_parity




