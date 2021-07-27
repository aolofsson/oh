//#############################################################################
//# Purpose: Stretches a pulse by N+1 clock cycles                            #
//#          Adds one cycle latency                                           #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_stretcher #(parameter CYCLES = 5) // "wakeup" cycles
   ( input  clk, // clock
     input  in, // input pulse
     input  nreset, // async active low reset
     output out // stretched output pulse
     );

   reg [CYCLES-1:0] valid;

   always @ (posedge clk or negedge nreset)
     if(!nreset)
       valid[CYCLES-1:0] <='b0;
     else if(in)
       valid[CYCLES-1:0] <={(CYCLES){1'b1}};
     else
       valid[CYCLES-1:0] <={valid[CYCLES-2:0],1'b0};

   assign out = valid[CYCLES-1];

endmodule // oh_stretcher
