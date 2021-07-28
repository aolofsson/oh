//#############################################################################
//# Function: Positive edge-triggered static D-type flop-flop                 #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         #
//#############################################################################

module asic_dffq #(parameter PROP = "DEFAULT")   (
    input      d,
    input      clk,
    output reg q
    );

   always @ (posedge clk)
     q <= d;

endmodule
