//#############################################################################
//# Function: Non-inverting Clock Buffer                                      #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         #
//#############################################################################

module asic_clkbuf #(parameter PROP = "DEFAULT")   (
    input  a,
    output z
    );

   assign z = a;

endmodule
