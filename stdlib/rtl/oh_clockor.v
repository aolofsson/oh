//#############################################################################
//# Function: Clock 'OR' gate                                                 #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_clockor
  #(parameter N    = 2,        // number of clock inputs)
    parameter SYN  = "TRUE",   // synthesizable (or not)
    parameter TYPE = "DEFAULT" // implementation type
    )
   (
    input [N-1:0] clkin, // clock input
    output 	  clkout // clock output
    );

   generate
      if(SYN == "TRUE") begin
	 assign clkout = |(clkin[N-1:0]);
      end
      else begin
	 asic_clockor #(.TYPE(TYPE),
			.N(N))
	 asic_clockor(// Outputs
		      .clkout		(clkout),
		      // Inputs
		      .clkin		(clkin[N-1:0]));
      end
   endgenerate
endmodule
