//#############################################################################
//# Function: 3-Input Inverting Mux                                           #
//#                                                                           #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         # 
//#############################################################################

module oh_mxi3 #(parameter DW = 1 ) // array width
   (
    input [DW-1:0]  d0,
    input [DW-1:0]  d1,
    input [DW-1:0]  d2,
    input [DW-1:0]  s0,
    input [DW-1:0]  s1,
    output [DW-1:0] z
    );
   
   assign z = ~((d0 & ~s0 & ~s1) |
		(d1 & s0  & ~s1) |
		(d2 & s1));
   
endmodule
