//#############################################################################
//# Function: Clock 'OR' gate                                                 #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_clockor #(parameter ASIC = `CFG_ASIC, // use ASIC lib
		    parameter N    = 1)    // number of clock inputs
   (
    input [N-1:0] clkin,// one hot clock inputs (only one is active!) 
    output 	  clkout 
    );

   generate
      if(ASIC)
	begin : asic
	   asic_clockor #(.N(N)) ior (.clkin(clkin[N-1:0]),
				      .clkout(clkout));
	end
      else
	begin : generic
	   assign clkout = |(clkin[N-1:0]);
	end
   endgenerate   
endmodule // oh_clockmux


