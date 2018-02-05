module oh_abs (/*AUTOARG*/
   a,
   out,
   overflow
);

   //###############################################################
   //# Parameters
   //###############################################################
   parameter DW = 64;
          
   //###############################################################
   //# Interface
   //###############################################################

   //inputs
   input [DW-1:0]  a;         //first operand

   //outputs
   output [DW-1:0] out;       //out=abs(a)
   output 	   overflow;  //high for max negative #
   
endmodule // oh_abs

