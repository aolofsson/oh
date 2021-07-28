//#############################################################################
//# Function: 3-Input Exclusive-Or Gate                                       #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         #
//#############################################################################

module asic_xor3 #(parameter PROP = "DEFAULT")  (
   input  a,
   input  b,
   input  c,
   output z
   );

   assign z =  a ^ b ^ c;

endmodule
