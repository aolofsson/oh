//#############################################################################
//# Function: 2-Input And Gate                                                #
//# Copyright: OH Project Authors. All rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         #
//#############################################################################

module asic_and2 #(parameter PROP = "DEFAULT")  (
   input  a,
   input  b,
   output z
   );

   assign z = a & b;

endmodule
