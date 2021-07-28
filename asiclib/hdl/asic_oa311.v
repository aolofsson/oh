//#############################################################################
//# Function: Or-And (oa311) Gate                                             #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         #
//#############################################################################

module asic_oa311 #(parameter PROP = "DEFAULT")   (
    input  a0,
    input  a1,
    input  a2,
    input  b0,
    input  c0,
    output z
    );

   assign z = (a0 | a1 | a2) & b0 & c0;

endmodule
