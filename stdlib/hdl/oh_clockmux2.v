//#############################################################################
//# Function: 2:1 Clock Mux                                                   #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_clockmux2
  #(parameter N    = 1,        // vector width
    parameter SYN  = "TRUE",   // synthesizable (or not)
    parameter TYPE = "DEFAULT" // implementation type
    )
   (
    input [N-1:0]  en0, // clkin0 enable (stable high)
    input [N-1:0]  en1, // clkin1 enable (stable high)
    input [N-1:0]  clkin0, // clock input
    input [N-1:0]  clkin1, // clock input
    output [N-1:0] clkout // clock output
    );

   generate
      if(SYN == "TRUE") begin
	 assign clkout[N-1:0] = (en0[N-1:0] & clkin0[N-1:0]) |
				(en1[N-1:0] & clkin1);
      end
      else begin
	 genvar 	     i;
	 for (i=0;i<N;i=i+1) begin
	    asic_clockmux2 #(.TYPE(TYPE))
	    asic_clockmux2(// Outputs
			   .clkout	(clkout[N-1:0]),
			   // Inputs
			   .en0		(en0[N-1:0]),
			   .en1		(en1[N-1:0]),
			   .clkin0	(clkin0[N-1:0]),
			   .clkin1	(clkin1[N-1:0]));
	 end
      end
   endgenerate
endmodule
