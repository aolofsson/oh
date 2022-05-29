//#############################################################################
//# Function:  Positive edge-triggered static inverting D-type flop-flop with #
//             async active low reset.                                        #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:   MIT (see LICENSE file in OH repository)                        #
//#############################################################################

module asic_dffrqn #(parameter PROP = "DEFAULT")   (
    input      d,
    input      clk,
    input      nreset,
    output reg qn
    );

   always @ (posedge clk or negedge nreset)
     if(!nreset)
       qn <= 1'b1;
     else
       qn <= ~d;

endmodule
