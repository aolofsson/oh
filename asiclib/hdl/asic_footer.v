//#############################################################################
//# Function: Power supply header switch                                      #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module asic_footer #(parameter PROP = "DEFAULT")   (
    input  nsleep, // 0 = disabled ground
    input  vssin,  // input supply
    output vssout  // gated output supply
    );

   // Primitive Device
   nmos m0 (vddout, vddin, nsleep); //d,s,g

endmodule
