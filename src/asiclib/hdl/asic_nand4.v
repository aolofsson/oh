//#############################################################################
//# Function: 4 Input Nand Gate                                               #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         #
//#############################################################################

module asic_nand4 #(parameter PROP = "DEFAULT")   (
    input  a,
    input  b,
    input  c,
    input  d,
    output z
    );

   assign z = ~(a & b & c & d);

endmodule
