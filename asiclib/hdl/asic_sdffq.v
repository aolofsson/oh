//#############################################################################
//# Function: Positive edge-triggered static D-type flop-flop with scan input #
//#                                                                           #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         #
//#############################################################################

module asic_sdffq #(parameter PROP = "DEFAULT")   (
    input      d,
    input      si,
    input      se,
    input      clk,
    output reg q
    );

   always @ (posedge clk)
       q <= se ? si : d;

endmodule
