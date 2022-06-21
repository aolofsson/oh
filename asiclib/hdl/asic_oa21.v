//#############################################################################
//# Function: Or-And (oa21) Gate                                              #
//# Copyright: asic
//# License:  MIT (see LICENSE file in OH repository)                         #
//#############################################################################

module asic_oa21 #(parameter PROP = "DEFAULT")   (
    input  a0,
    input  a1,
    input  b0,
    output z
    );

   assign z = (a0 | a1) & b0;

endmodule
