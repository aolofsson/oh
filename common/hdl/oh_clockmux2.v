//#############################################################################
//# Function: 2:1 Clock Mux                                                   #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_clockmux2
  #(parameter SYN  = "TRUE",   // synthesizable (or not)
    parameter TYPE = "DEFAULT" // implementation type
    )
   (
    input  en0, // clkin0 enable (stable high)
    input  en1, // clkin1 enable (stable high)
    input  clkin0, // clock input
    input  clkin1, // clock input
    output clkout // clock output
    );

   generate
      if(SYN == "TRUE") begin
	 assign clkout = en0 & clkin0 |
			 en1 & clkin1;
      end
      else begin
	 oh_clockmux2 #(.TYPE(TYPE))
	 oh_clockmux2(// Outputs
		      .clkout		(clkout),
		      // Inputs
		      .en0		(en0),
		      .en1		(en1),
		      .clkin0		(clkin0),
		      .clkin1		(clkin1));
      end
   endgenerate
endmodule
