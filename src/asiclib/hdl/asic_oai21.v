//#############################################################################
//# Function: Or-And-Inverter (oai21) Gate                                    #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         #
//#############################################################################

module asic_oai21 #(parameter PROP = "DEFAULT")   (
    input  a0,
    input  a1,
    input  b0,
    output z
    );

   assign z = ~((a0 | a1) & b0);

endmodule
