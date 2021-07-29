//#############################################################################
//# Function:  Positive edge-triggered static D-type flop-flop with async     #
//#            active low reset.                                              # 
//#                                                                           #
//# Copyright: OH Project Authors. All rights Reserved.                       #
//# License:   MIT (see LICENSE file in OH repository)                        # 
//#############################################################################

module oh_dffrq #(parameter DW = 1) // array width
   (
    input [DW-1:0] 	d,
    input [DW-1:0] 	clk,
    input [DW-1:0] 	nreset,
    output reg [DW-1:0] q
    );
   
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       q <= 'b0;
     else
       q <= d;
      
endmodule
