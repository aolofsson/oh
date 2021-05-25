//#############################################################################
//# Function: And-Or (ao33) Gate                                              #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         # 
//#############################################################################

module oh_ao33 #(parameter DW = 1 ) // array width
   (
    input [DW-1:0]  a0,
    input [DW-1:0]  a1,
    input [DW-1:0]  a2,
    input [DW-1:0]  b0,
    input [DW-1:0]  b1,
    input [DW-1:0]  b2, 
    output [DW-1:0] z
    );
   
   assign z = (a0 & a1 & a2) | (b0 & b1 & b2);
   
endmodule
