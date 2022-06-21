//#############################################################################
//# Function: 2-Input Inverting Mux                                           #
//#                                                                           #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         #
//#############################################################################

module asic_muxi2 #(parameter PROP = "DEFAULT")   (
    input  d0,
    input  d1,
    input  s,
    output z
    );

   assign z = ~((d0 & ~s) | (d1 & s));

endmodule
