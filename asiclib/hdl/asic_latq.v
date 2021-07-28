//#############################################################################
//# Function:  D-type active-high transparent latch                           #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:   MIT (see LICENSE file in OH repository)                        #
//#############################################################################

module asic_latq #(parameter PROP = "DEFAULT")   (
    input      d,
    input      clk,
    output reg q
    );

   always @ (clk or d)
     if(clk)
       q <= d;

endmodule
