//#############################################################################
//# Function: Signature Checker                                               #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_verify
  #(parameter N = 32  // width of verifier
    )
   (
    input 	   clk,
    input 	   nreset, //async reset
    input 	   en, // enable counter
    input 	   entaps, // enable taps input
    input [N-1:0]  taps, // user driven taps
    input [N-1:0]  seed, // seed
    input [N-1:0]  mask, // mask output (1 = active)
    input [N-1:0]  in, // input data
    output [N-1:0] out, // generated random number
    output 	   error // difference found
    );

   // Recreate random number
   oh_random oh_random(/*AUTOINST*/
		       // Outputs
		       .out		(out[N-1:0]),
		       // Inputs
		       .clk		(clk),
		       .nreset		(nreset),
		       .en		(en),
		       .entaps		(entaps),
		       .taps		(taps[N-1:0]),
		       .seed		(seed[N-1:0]),
		       .mask		(mask[N-1:0]));


   // Compare random number to data
   // TODO: add
   assign error = (out[N-1:0] != in[N-1:0]);


endmodule // oh_random
