/******************************************************************************
 * Function: Linear Feedback Shift Register (Galois)
 * Author: Andreas Olofsson
 * License:  MIT (see LICENSE file in OH! repository)
 *
 * Documentation:
 *
 * - A generic Galois LFSR with taps and seeds feed in externally to enable
 *   dynamically programming the taps and seed. Shift is from MSB to LSB,
 *   feedback bit is from LSB.
 *
 * - The state is updated when 'en' is high.
 *
 * - Any non-zero seed value is legal.
 *
 * - An LSFR of size N can create pseudo random cycles of shorter polynomials
 *   by zero padding the taps value up to the MSB.
 *
 * - Driving taps externally is only practical with GALOIS configuration,
 *   since the massive xor tree would be prohibitive with FIBONACCI.

 * - Example terms from: https://users.ece.cmu.edu/~koopman/lfsr/index.html
 *
 *   N   POLYNOMIAL
 *   -------------------
 *   4   9
 *   5   12
 *   6   21
 *   7   41
 *   8   8E
 *   9   108
 *   10  204
 *   11  402
 *   12  829
 *   13  100D
 *   14  2015
 *   15  4001
 *   16  8016
 *   17  10004
 *   18  20013
 *   19  40013
 *   20  80004
 *   21  100002
 *   22  200001
 *   23  400010
 *   24  80000D
 *   25  1000004
 *   26  2000023
 *   27  4000013
 *   28  8000004
 *   29  10000002
 *   30  20000029
 *   31  40000004
 *   32  80000057
 *   58  200000000000031
 *   64  800000000000000D
 *
 ****************************************************************************/

module oh_lfsr
  #(parameter N    =  32,      // length of LFSR
    parameter TYPE = "GALOIS"  // lfsr type (only galois supported ...)
    )
   (
    input 	       clk,
    input 	       nreset, //async reset
    input 	       en, // enables (advances) lfsr
    input [N-1:0]      taps, // taps
    input [N-1:0]      seed, // seed
    output reg [N-1:0] out  // output value/state vector
    );

   generate
      if (TYPE == "GALOIS") begin
	 always @ (posedge clk or negedge nreset)
	   if(~nreset)
	     out[N-1:0] <= seed[N-1:0];
	   else if(en)
	     out[N-1:0] <= ({(N){out[0]}} & taps[N-1:0]) ^
	                   (out[N-1:0] >> 1);
      end
      else if (TYPE == "FIBONACCI") begin
	 initial
	   $display("UNSUPPORTED");
      end
   endgenerate

endmodule // oh_lfsr
