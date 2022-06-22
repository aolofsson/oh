//#############################################################################
//# Function: 3-Input Exclusive-Or Gate                                       #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         # 
//#############################################################################

module oh_xor3 #(parameter DW = 1 ) // array width
   (
    input [DW-1:0]  a,
    input [DW-1:0]  b,
    input [DW-1:0]  c,
    output [DW-1:0] z
    );
   
   assign z =  a ^ b ^ c;
   
endmodule
