//#############################################################################
//# Function: Parametrized clock mux (N to 1)                                 #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_clockmux
  #(parameter N    = 2,        // number of clock inputs)
    parameter SYN  = "TRUE",   // synthesizable (or not)
    parameter TYPE = "DEFAULT" // implementation type
    )
   (
    input [N-1:0] en,    // one hot enable vector (needs to be stable!)
    input [N-1:0] clkin, // one hot clock inputs (only one is active!)
    output 	  clkout // clock output
    );

   generate
      if(SYN == "TRUE") begin
	 assign clkout = |(clkin[N-1:0] & en[N-1:0]);
      end
      else begin
	 asic_clockmux #(.TYPE(TYPE),
			 .N(N))
	 asic_clockmux(// Outputs
		       .clkout		(clkout),
		       // Inputs
		       .en		(en[N-1:0]),
		       .clkin		(clkin[N-1:0]));
      end
   endgenerate
endmodule
