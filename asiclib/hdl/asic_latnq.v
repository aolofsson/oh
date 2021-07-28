//#############################################################################
//# Function:  D-type active-low transparent latch                            #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:   MIT (see LICENSE file in OH repository)                        #
//#############################################################################

module asic_latnq #(parameter PROP = "DEFAULT")   (
    input      d,
    input      clk,
    output reg q
    );

   always @ (clk or d)
     if(~clk)
       q <= d;

endmodule
