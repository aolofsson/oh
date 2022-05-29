//#############################################################################
//# Function: Integrated "Or" Clock Gating Cell                               #
//# Copyright: OH Project Authors. ALl rights Reserved.                       #
//# License:  MIT (see LICENSE file in OH repository)                         #
//#############################################################################

module asic_clkicgor #(parameter PROP = "DEFAULT")  (
   input  clk,// clock input
   input  te, // test enable
   input  en, // enable
   output eclk  // enabled clock output
   );

   reg 	  en_stable;

   always @ (clk or en or te)
     if (clk)
       en_stable <= en | te;

   assign eclk =  clk | ~en_stable;

endmodule
