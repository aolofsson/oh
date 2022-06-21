//#############################################################################
//# Function: 2-Input Exclusive-Nor Gate                                      #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         #
//#############################################################################

module asic_xnor2 #(parameter PROP = "DEFAULT")   (
    input  a,
    input  b,
    output z
    );

   assign z =  ~(a ^ b);

endmodule
