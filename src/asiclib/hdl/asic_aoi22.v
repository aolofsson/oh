//#############################################################################
//# Function: And-Or-Inverter (aoi22) Gate                                    #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         #
//#############################################################################

module asic_aoi22 #(parameter PROP = "DEFAULT")   (
    input  a0,
    input  a1,
    input  b0,
    input  b1,
    output z
    );

   assign z = ~((a0 & a1) | (b0 & b1));

endmodule
