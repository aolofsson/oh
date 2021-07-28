//#############################################################################
//# Function: Tristate Buffer                                                 #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         #
//#############################################################################

module asic_tbuf
  (
   input  a,
   input  oe,
   output z
   );

   assign z = oe ? a : 1'bz;

endmodule
