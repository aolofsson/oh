//#############################################################################
//# Function: Random number generator
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_random
  #(parameter N    = 32,           //width of counter (max value)
    parameter SEED = 32'haaaaaaaa //non zero number to start with
    )
   (
    input 	   clk,
    input 	   nreset, //async reset
    input [N-1:0]  mask, //mask output (1 = active)
    input 	   en, //enable counter
    output [N-1:0] out  //random output pulse
    );

   wire [N-1:0]   taps_sel;
   reg [N-1:0] 	  lfsr_reg;
   wire [N-1:0]   lfsr_in;

   // LFSR tap selector (TODO: complete table)
   generate
      case(N)
	32: assign taps_sel[31:0] = 32'h80000057<<1;
      endcase // case (N)
   endgenerate

   // counter
   always @(posedge clk or negedge nreset)
     if(~nreset)
       lfsr_reg[N-1:0] <= SEED;
     else if(en)
       lfsr_reg[N-1:0] <= lfsr_in[N-1:0];

   assign feedback         = lfsr_reg[N-1]; //feedback from MSB
   assign lfsr_in[0]       = feedback; //unconditional feedback for [0]

   genvar 	  i;
   for(i=1;i<N;i=i+1)
     assign lfsr_in[i] = taps_sel[i] ? (lfsr_reg[i-1] ^ feedback) :
		         lfsr_reg[i-1];

   assign out[N-1:0] = mask[N-1:0] & lfsr_reg[N-1:0];


endmodule // oh_random
