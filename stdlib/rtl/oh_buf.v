//#############################################################################
//# Function: Non-inverting Buffer                                            #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         # 
//#############################################################################

module oh_buf #(parameter DW = 1 ) // array width
   (
    input [DW-1:0]  a,
    output [DW-1:0] z
    );
   
   assign z = a;
      
endmodule
