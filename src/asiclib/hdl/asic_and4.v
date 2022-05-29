//#############################################################################
//# Function: 4-Input And Gate                                                #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         #
//#############################################################################

module asic_and4 #(parameter PROP = "DEFAULT")  (
   input  a,
   input  b,
   input  c,
   input  d,
   output z
   );

   assign z = a & b & c & d;

endmodule
