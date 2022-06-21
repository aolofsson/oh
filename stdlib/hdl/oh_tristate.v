//#############################################################################
//# Function: Tristate Driver                                                 #
//#############################################################################
//# Author:  Andreas Olofsson                                                 #
//# SPDX-License-Identifier:     MIT                                          #
//#############################################################################

module oh_tristate
  #(parameter N    = 1,         // block width
    parameter SYN  = "TRUE",    // synthesizable
    parameter TYPE = "DEFAULT"  // implementation type
    )
   (
    input [N-1:0]  in, // signal to io
    input [N-1:0]  oe, // output enable (1 = drive, 0 = high-z)
    output [N-1:0] out // output
    );

   genvar 	    i;
    generate
      if(SYN=="TRUE") begin
	 for (i = 0; i < N; i = i + 1) begin
	    assign out[i] = oe[i] ? in[i] : 1'bz;
	 end
      end
      else begin
	 asic_tristate #(.TYPE(TYPE),
			 .N(N))
	 asic_tristate (// Outputs
			.out	(out[N-1:0]),
			// Inputs
			.in	(in[N-1:0]),
			.ie	(ie[N-1:0]));
      end
    endgenerate
endmodule
