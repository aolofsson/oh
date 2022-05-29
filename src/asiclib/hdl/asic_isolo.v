//#############################################################################
//# Function: Multi-domain isolation signal                                   #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module asic_isolo
  #(parameter PROP = "DEFAULT")
   (
    input  iso, // isolation signal
    input  in, // input
    output out  // out = ~iso & in
    );

   assign out = ~iso & in;

endmodule
