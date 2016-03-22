module oh_abs (/*AUTOARG*/
   // Outputs
   out, overflow,
   // Inputs
   in
   );
 
   parameter DW = 4;

   //inputs
   input [DW-1:0]  in;        //input operand

   //outputs
   output [DW-1:0] out;       //out = abs(in) (signed two's complement)
   output 	   overflow;  //high for max negative #


   assign out[DW-1:0] = in[DW-1] ? ~in[DW-1:0] + 1'b1 :
			            in[DW-1:0];

   assign overflow = in[DW-1] & ~(|in[DW-2:0]);

endmodule // oh_abs

