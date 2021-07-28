//#############################################################################
//# Function: Inverter                                                        #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         #
//#############################################################################

module asic_inv
   (
    input  a,
    output z
    );

   assign z = ~a;

endmodule
