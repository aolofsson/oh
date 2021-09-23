//#############################################################################
//# Function: Falling Edge Sampled Register                                   #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module ohr_reg0 #(parameter N = 1)       // data width
   ( input          nreset, //async active low reset
     input 	    clk, // clk, latch when clk=0
     input [N-1:0]  in, // input data
     output [N-1:0] out  // output data (stable/latched when clk=1)
     );

`ifdef CFG_ASIC
   asic_reg0 ireg [N-1:0] (.nreset(nreset),
			    .clk(clk),
			    .in(in[N-1:0]),
			    .out(out[N-1:0]));
`else
   reg [N-1:0]      out_reg;
   always @ (negedge clk or negedge nreset)
     if(~nreset)
       out_reg[N-1:0] <= 'b0;
     else
       out_reg[N-1:0] <= in[N-1:0];
   assign out[N-1:0] = out_reg[N-1:0];
`endif

endmodule // ohr_reg0
