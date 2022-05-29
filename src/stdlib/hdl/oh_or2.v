//#############################################################################
//# Function: 2 Input Or Gate                                                 #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         # 
//#############################################################################

module oh_or2 #(parameter DW = 1 ) // array width
   (
    input [DW-1:0]  a,
    input [DW-1:0]  b,
    output [DW-1:0] z
    );
   
   assign z = ( a | b);
   
endmodule
