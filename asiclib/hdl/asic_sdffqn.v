//#############################################################################
//# Function: Positive edge-triggered inverting static D-type flop-flop       #
//#           with scan input.                                                #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         #
//#############################################################################

module asic_sdffqn #(parameter PROP = "DEFAULT")   (
    input      d,
    input      si,
    input      se,
    input      clk,
    output reg qn
    );

   always @ (posedge clk)
     qn <= se ? ~si : ~d;

endmodule
