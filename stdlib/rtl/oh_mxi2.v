//#############################################################################
//# Function: 2-Input Inverting Mux                                           #
//#                                                                           #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         # 
//#############################################################################

module oh_mxi2 #(parameter DW = 1 ) // array width
   (
    input [DW-1:0]  d0,
    input [DW-1:0]  d1,
    input [DW-1:0]  s,
    output [DW-1:0] z
    );
   
   assign z = ~((d0 & ~s) | (d1 & s));
   
endmodule
