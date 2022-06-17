//#############################################################################
//# Function: Random length pulse generator
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_pulse
  #(parameter N = 32 //width of counter (max value)
    )
   (
    input 	  clk,
    input 	  nreset,
    input 	  en, //enable pulse generator
    input [N-1:0] mask, //mask output to limit range
    output reg 	  out  //random output pulse
    );

   wire [N-1:0]   random;
   reg [N-1:0] 	  counter;
   wire 	  match;

   oh_random oh_random(//output
		       .out	(random[N-1:0]),
		       // Inputs
		       .clk	(clk),
		       .mask    (mask[N-1:0]),
		       .nreset	(nreset),
		       .en	(match));

   assign match = (random[N-1:0] == counter[N-1:0]);

   always @ (posedge clk or negedge nreset)
     if(~nreset)
       counter[N-1:0] <= 'b0;
     else if(match)
       counter[N-1:0] <= 'b0;
     else
       counter[N-1:0] <= counter[N-1:0] + 1;

   always @ (posedge clk or negedge nreset)
     if(~nreset)
       out <= 'b0;
     else
       out <= out ^ match;

endmodule // oh_pulse
