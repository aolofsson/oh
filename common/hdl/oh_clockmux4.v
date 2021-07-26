//#############################################################################
//# Function: 4:1 Clock Mux                                                   #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_clockmux4
  #(parameter SYN  = "TRUE",   // synthesizable (or not)
    parameter TYPE = "DEFAULT" // implementation type
    )
   (
    input  en0, // clkin0 enable (stable high)
    input  en1, // clkin1 enable (stable high)
    input  en2, // clkin1 enable (stable high)
    input  en3, // clkin1 enable (stable high)
    input  clkin0, // clock input
    input  clkin1, // clock input
    input  clkin2, // clock input
    input  clkin3, // clock input
    output clkout // clock output
    );

   generate
      if(SYN == "TRUE") begin
	 assign clkout = en0 & clkin0 |
			 en1 & clkin1 |
			 en2 & clkin2 |
			 en3 & clkin3;
      end
      else begin
	 oh_clockmux4 #(.TYPE(TYPE))
	 oh_clockmux4(// Outputs
		      .clkout		(clkout),
		      // Inputs
		      .en0		(en0),
		      .en1		(en1),
		      .en2		(en2),
		      .en3		(en3),
		      .clkin0		(clkin0),
		      .clkin1		(clkin1),
		      .clkin2		(clkin2),
	              .clkin3		(clkin3));
      end
   endgenerate
endmodule
