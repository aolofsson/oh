//#############################################################################
//# Function:  Positive edge-triggered static D-type flop-flop with async     #
//#            active low preset.                                             #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:   MIT (see LICENSE file in OH repository)                        #
//#############################################################################

module asic_dffsq #(parameter PROP = "DEFAULT")   (
    input      d,
    input      clk,
    input      nset,
    output reg q
    );

   always @ (posedge clk or negedge nset)
     if(!nset)
       q <= 1'b1;
     else
       q <= d;

endmodule
