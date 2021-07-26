//#############################################################################
//# Function: Tristate Driver                                                 #
//#############################################################################
//# Author:  Andreas Olofsson                                                 #
//# SPDX-License-Identifier:     MIT                                          #
//#############################################################################

module oh_tristate
  #(parameter DW   = 32,        // block width
    parameter SYN  = "TRUE",    // synthesizable
    parameter TYPE = "DEFAULT"  // implementation type
    )
   (
    input [DW-1:0]  in, // signal to io
    input [DW-1:0]  oe, // output enable (1 = drive, 0 = high-z)
    output [DW-1:0] out // output
    );

   genvar 	    i;
    generate
      if(SYN=="TRUE") begin
	 for (i = 0; i < DW; i = i + 1) begin
	    assign out[i] = oe[i] ? in[i] : 1'bz;
	 end
      end
      else begin
	 asic_tristate #(.TYPE(TYPE),
			 .DW(DW))
	 asic_tristate (// Outputs
			.out	(out[DW-1:0]),
			// Inputs
			.in	(in[DW-1:0]),
			.ie	(ie[DW-1:0]));
      end
    endgenerate
endmodule
