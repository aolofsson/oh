//#############################################################################
//# Function: 2-Input Exclusive-Or Gate                                       #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         #
//#############################################################################

module asic_xor2 #(parameter PROP = "DEFAULT")   (
    input  a,
    input  b,
    output z
    );

   assign z =  a ^ b;

endmodule
