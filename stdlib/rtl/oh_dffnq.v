//#############################################################################
//# Function: Negative edge-triggered static D-type flop-flop                 #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         # 
//#############################################################################

module oh_dffnq #(parameter DW = 1) // array width
   (
    input [DW-1:0] 	d,
    input [DW-1:0] 	clk,
    output reg [DW-1:0] q
    );
   
   always @ (negedge clk)
     q <= d;
      
endmodule
