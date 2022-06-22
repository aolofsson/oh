//#############################################################################
//# Function:  D-type active-low transparent latch                            #
//#                                                                           #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:   MIT (see LICENSE file in OH repository)                        # 
//#############################################################################

module oh_latnq #(parameter DW = 1) // array width
   (
    input [DW-1:0] 	d,
    input [DW-1:0] 	gn,
    output reg [DW-1:0] q
    );

   always_latch
     if(!gn)
       q <= d;
	    
endmodule
