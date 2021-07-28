//#############################################################################
//# Function: 2-Input Clock NOr Gate                                          #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         #
//#############################################################################

module asic_clknor2 #(parameter PROP = "DEFAULT")   (
    input  a,
    input  b,
    output z
    );

   assign z = ~(a | b);

endmodule
