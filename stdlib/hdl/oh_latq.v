//#############################################################################
//# Function:  D-type active-high transparent latch                           #
//#                                                                           #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:   MIT (see LICENSE file in OH repository)                        # 
//#############################################################################

module oh_latq #(parameter DW = 1) // array width
   (
    input [DW-1:0] 	d,
    input [DW-1:0] 	g,
    output reg [DW-1:0] q
    );

   always_latch
     if(g)
       q <= d;
	    
endmodule
