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
 input 		       a_signed,//a operand is signed
 input [DW-1:0]        b, // b input
 input 		       b_signed,//b oeprand is signed
 output [(2*DW+2)-1:0] pp1,// partial product output (carry save format)
 output [(2*DW+2)-1:0] pp2, // partial product output (carry save format)
 output [2*DW-1:0]     product // output
 );
   
   wire signed [2*DW+1:0] product_signed;

   assign a_sext = a_signed & a[DW-1];
   assign b_sext = b_signed & b[DW-1];
    
   
   assign product_signed[2*DW+1:0] = $signed({a_sext,a[DW-1:0]}) *
				     $signed({b_sext,b[DW-1:0]});

   assign product = product_signed[2*DW-1:0];
   
endmodule // oh_multiplier

