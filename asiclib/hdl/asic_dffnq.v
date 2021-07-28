//#############################################################################
//# Function: Negative edge-triggered static D-type flop-flop                 #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         #
//#############################################################################

module asic_dffnq #(parameter PROP = "DEFAULT")   (
    input      d,
    input      clk,
    output reg q
    );

   always @ (negedge clk)
     q <= d;

endmodule
