//#############################################################################
//# Function: Non-inverting Delay Cell                                        #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         #
//#############################################################################

module asic_delay #(parameter PROP = "DEFAULT")   (
    input  a,
    output z
    );

   assign z = a;

endmodule
