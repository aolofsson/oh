//#############################################################################
//# Function: Clock mux                                                       #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_clockmux #(parameter ASIC = `CFG_ASIC, // use ASIC lib
		     parameter N    = 1)    // number of clock inputs
   (
    input [N-1:0] en, // one hot enable vector (needs to be stable!)
    input [N-1:0] clkin,// one hot clock inputs (only one is active!) 
    output 	  clkout 
    );

   generate
      if(ASIC)
	begin : g0
	   asic_clockmux #(.N(N)) asic_clockmux (.clkin(clkin[N-1:0]),
						 .en(en[N-1:0]),
						 .clkout(clkout));
	end
      else
	begin : g0
	   assign clkout = |(clkin[N-1:0] & en[N-1:0]);
	end
   endgenerate   
endmodule // oh_clockmux


