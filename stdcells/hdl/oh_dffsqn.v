//#############################################################################
//# Function:  Positive edge-triggered static inverting D-type flop-flop with #
//             async active low set.                                          # 
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:   MIT (see LICENSE file in OH repository)                        # 
//#############################################################################

module oh_dffsqn #(parameter DW = 1) // array width
   (
    input [DW-1:0] 	d,
    input [DW-1:0] 	clk,
    input [DW-1:0] 	nset,
    output reg [DW-1:0] qn
    );
   
   always @ (posedge clk or negedge nset)
     if(!nset)
       qn <= 'b0;
     else
       qn <= ~d;
   
endmodule
