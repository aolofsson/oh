//#############################################################################
//# Function: Or-And (oa222) Gate                                             #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         #
//#############################################################################

module asic_oa222 #(parameter PROP = "DEFAULT")   (
    input  a0,
    input  a1,
    input  b0,
    input  b1,
    input  c0,
    input  c1,
    output z
    );

   assign z = (a0 | a1) & (b0 | b1) & (c0 | c1);

endmodule
