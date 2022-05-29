//#############################################################################
//# Function: Non-inverting Buffer                                            #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         #
//#############################################################################

module asic_buf #(parameter PROP = "DEFAULT")   (
    input  a,
    output z
    );

   assign z = a;

endmodule
