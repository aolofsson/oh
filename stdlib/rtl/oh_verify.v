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
    input 	   en, // enable random counter
    input [N-1:0]  seed, // seed
    input [N-1:0]  in, // input data
    output [N-1:0] out, // generated random number
    output 	   error // difference found
    );

   // Recreate random number
   oh_random oh_random(.mask	({(PW){1'b1}}),
		       .taps	({(PW){1'b1}}),
		       .entaps	(1'b0),
		       /*AUTOINST*/
		       // Outputs
		       .out		(out[N-1:0]),
		       // Inputs
		       .clk		(clk),
		       .nreset		(nreset),
		       .en		(en),
		       .seed		(seed[N-1:0]));


   // Compare random number to data
   // TODO: add
   assign error = (out[N-1:0] != in[N-1:0]);


endmodule // oh_random
