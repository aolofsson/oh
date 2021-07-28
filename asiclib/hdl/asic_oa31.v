//#############################################################################
//# Function: Or-And (oa31) Gate                                              #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         #
//#############################################################################

module asic_oa31 #(parameter PROP = "DEFAULT")   (
    input  a0,
    input  a1,
    input  a2,
    input  b0,
    output z
    );

   assign z = (a0 | a1 | a2) & b0;

endmodule
