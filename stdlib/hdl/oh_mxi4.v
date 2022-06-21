//#############################################################################
//# Function: 4-Input Inverting Mux                                           #
//#                                                                           #
//# Copyright: OH Project Authors. All rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         # 
//#############################################################################

module oh_mxi4 #(parameter DW = 1 ) // array width
   (
    input [DW-1:0]  d0,
    input [DW-1:0]  d1,
    input [DW-1:0]  d2,
    input [DW-1:0]  d3,
    input [DW-1:0]  s0,
    input [DW-1:0]  s1,
    output [DW-1:0] z
    );
   
   assign z = ~((d0 & ~s1 & ~s0) |
		(d1 & ~s1 &  s0) |
		(d2 &  s1 & ~s0) |
		(d2 &  s1 &  s0));
   
endmodule
