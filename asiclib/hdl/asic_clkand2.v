//#############################################################################
//# Function: 2 Input Clock And Gate                                          #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         #
//#############################################################################

module asic_clkand2
   (
    input  a,
    input  b,
    output z
    );

   assign z = a & b;

endmodule
