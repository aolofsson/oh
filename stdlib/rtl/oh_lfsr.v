//#############################################################################
//# Function: Random number generator                                         #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################
//
// References:
// https://users.ece.cmu.edu/~koopman/lfsr/index.html
//
//############################################################################
module oh_random
  #(parameter N    = 32      //support multiple of 32 for now...
    )
   (
    input 	   clk,
    input 	   nreset, //async reset
    input 	   en, // enable counter
    input [1:0]    mode,// 0=fibonacci,1=galois
    input 	   lsbfirst,// 1=shift from lsb, 0=shift from msb
    input [N-1:0]  taps, // taps
    input [N-1:0]  seed, // seed
    input [N-1:0]  mask, // mask output (1 = active)
    output [N-1:0] out  // output value
    );

   // TODO: support non-multiples of 32
   reg [N-1:0] 	   lfsr_reg[0:N/32-1];
   wire [N-1:0]    lfsr_in[0:N/32-1];
   wire [N-1:0]    taps_sel[0:N/32-1];
   wire [N/32-1:0] feedback;

   // instantiate multiple 32bit rngs
   genvar 	   i,j;
   generate
      for(i=0;i<(N/32);i=i+1) begin
	 //taps
	 assign taps_sel[i] = entaps ? taps[(i+1)*32-1:i*32]: 32'h80000057 << 1;
	 //lfsr reg
	 always @(posedge clk or negedge nreset)
	   if(~nreset)
	     lfsr_reg[i] <= seed[(i+1)*32-1:i*32];
	   else if(en)
	     lfsr_reg[i] <= lfsr_in[i];
	 // feeback
	 assign feedback[i]     = lfsr_reg[i][31];
	 assign lfsr_in[i][0]   = feedback[i];
	 for(j=1;j<32;j=j+1) begin
	      assign lfsr_in[i][j] = taps_sel[i][j] ? (lfsr_reg[i][j-1] ^ feedback[i]) :
				     lfsr_reg[i][j-1];

	 end
	 assign out[(i+1)*32-1:i*32] = mask[(i+1)*32-1:i*32] & lfsr_reg[i];
      end // for (i=0;<N/32;i=i+1)
   endgenerate


endmodule // oh_random
