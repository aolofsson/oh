//#############################################################################
//# Function: Mutiplier                                                       #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_multiplier #(parameter DW  = 16  //multiplier width
		       ) 
(
 input [DW-1:0]        a, // a input
 input [DW-1:0]        b, // b input
 input 		       cfg_signed,//1=signed operands, 0=unsigned
 output [(2*DW+2)-1:0] pp1,// partial product output (carry save format)
 output [(2*DW+2)-1:0] pp2, // partial product output (carry save format)
 output [DW-1:0]       product // output
 );

   wire signed [DW-1:0] product_signed;
   wire signed [DW-1:0] product_unsigned;
   
   assign product[DW-1:0] = cfg_signed ? $unsigned(product_signed) :
			                 product_unsigned;
   
 
endmodule // oh_multiplier

