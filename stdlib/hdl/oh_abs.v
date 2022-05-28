//#############################################################################
//# Function: Calculates absolute value of input                              #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_abs
  #(parameter N    = 32,        // block width
    parameter SYN  = "TRUE",    // synthesizable
    parameter TYPE = "DEFAULT"  // implementation type
    )
   (
    input [N-1:0]  in,       // input operand
    output [N-1:0] out,      // out = abs(in) (signed two's complement)
    output 	   overflow  // high for max negative #
    );

   generate
      if(SYN == "TRUE")  begin
	 assign out[N-1:0] = in[N-1] ? ~in[N-1:0] + 1'b1 : in[N-1:0];
	 assign overflow   = in[N-1] & ~(|in[N-2:0]);
      end
      else begin
	 asic_abs #(.TYPE(TYPE),
		    .N(N))
	 asic_abs(// Outputs
		  .out	    (out[N-1:0]),
		  .overflow (overflow),
		  // Inputs
		  .in	    (in[N-1:0]));
      end

   endgenerate
endmodule
