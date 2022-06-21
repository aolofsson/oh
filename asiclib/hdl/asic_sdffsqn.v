//#############################################################################
//# Function:  Positive edge-triggered static inverting D-type flop-flop with #
//             async active low set and scan input                            #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:   MIT (see LICENSE file in OH repository)                        #
//#############################################################################

module asic_sdffsqn #(parameter PROP = "DEFAULT")   (
    input      d,
    input      si,
    input      se,
    input      clk,
    input      nset,
    output reg qn
    );

   always @ (posedge clk or negedge nset)
     if(!nset)
       qn <= 1'b0;
     else
       qn <= se ? ~si : ~d;

endmodule
