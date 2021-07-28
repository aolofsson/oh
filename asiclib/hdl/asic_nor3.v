//#############################################################################
//# Function: 3 Input Nor Gate                                                #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         #
//#############################################################################

module asic_nor3
   (
    input  a,
    input  b,
    input  c,
    output z
    );

   assign z = ~(a | b | c);

endmodule
