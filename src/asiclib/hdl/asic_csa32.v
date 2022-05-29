//#############################################################################
//# Function: Carry Save Adder (3:2)                                          #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         #
//#############################################################################

module asic_csa32 #(parameter PROP = "DEFAULT")
   (
     input  a,
     input  b,
     input  c,
     output sum,
     output carry
     );

   assign sum = a ^ b ^ c;
   assign carry = (a & b) | (b & c) | (c & a);

endmodule
