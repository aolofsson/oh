//#############################################################################
//# Function: Power supply header switch                                      #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module asic_header #(parameter PROP = "DEFAULT")   (
    input  sleep,  // 1 = disabled vdd
    input  vddin,  // input supply
    output vddout  // gated output supply
    );

   // Primitive Device
   pmos m0 (vddout, vssin, sleep); //d,s,g

endmodule
