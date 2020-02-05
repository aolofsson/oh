//#############################################################################
//# Function: Clock mux                                                       #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_clockmux #(parameter N    = 1)    // number of clock inputs
   (
    input [N-1:0] en, // one hot enable vector (needs to be stable!)
    input [N-1:0] clkin,// one hot clock inputs (only one is active!) 
    output 	  clkout 
    );

`ifdef CFG_ASIC
    generate
       if((N==2))
	 begin : asic
	    asic_clockmux2 imux (.clkin(clkin[N-1:0]),
				 .en(en[N-1:0]),
				 .clkout(clkout));
	 end
       else if((N==4))
	 begin : asic
	    asic_clockmux4 imux (.clkin(clkin[N-1:0]),
				 .en(en[N-1:0]),
				 .clkout(clkout));
	 end
    endgenerate
`else // !`ifdef CFG_ASIC
       assign clkout = |(clkin[N-1:0] & en[N-1:0]);
`endif
       
endmodule // oh_clockmux


