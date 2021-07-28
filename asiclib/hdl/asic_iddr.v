//#############################################################################
//# Function: Dual data rate input buffer                                     #
//# Copyright: OH Project Authors. All rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         #
//#############################################################################
module asic_iddr #(parameter PROP = "DEFAULT")   (
    input      clk,     // clock
    input      in,      // data input sampled on both edges of clock
    output reg outrise, // rising edge sample
    output reg outfall  // falling edge sample
    );

   // Negedge Sample
   always @ (negedge clk)
     outfall <= in;

   // Posedge Sample
   reg 	       inrise;
   always @ (posedge clk)
     inrise <= in;

   // Posedge Latch (for hold)
   always @ (clk or inrise)
     if(~clk)
       outrise <= inrise;

endmodule
