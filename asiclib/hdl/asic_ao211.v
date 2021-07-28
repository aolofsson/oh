//#############################################################################
//# Function: And-Or (ao211) Gate                                             #
//# Copyright: OH Project Authors. All rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         #
//#############################################################################

module asic_ao211 #(parameter PROP = "DEFAULT")  (
   input  a0,
   input  a1,
   input  b0,
   input  c0,
   output z
   );

   assign z = (a0 & a1) | b0 | c0;

endmodule
