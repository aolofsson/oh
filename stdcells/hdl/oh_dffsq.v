//#############################################################################
//# Function:  Positive edge-triggered static D-type flop-flop with async     #
//#            active low preset.                                             # 
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:   MIT (see LICENSE file in OH repository)                        # 
//#############################################################################

module oh_dffsq #(parameter DW = 1) // array width
   (
    input [DW-1:0]     d,
    input [DW-1:0]     clk,
    input [DW-1:0]     nset,
    output reg [DW-1:0] q
    );
   
   always @ (posedge clk or negedge nset)
     if(!nset)
       q <= {DW{1'b1}};
     else
       q <= d;
      
endmodule
