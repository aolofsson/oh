//#############################################################################
//# Function: Positive edge-triggered inverting static D-type flop-flop       #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         #
//#############################################################################

module asic_dffqn #(parameter PROP = "DEFAULT")   (
    input  	d,
    input  	clk,
    output reg  qn
    );

   always @ (posedge clk)
     qn <= ~d;

endmodule
