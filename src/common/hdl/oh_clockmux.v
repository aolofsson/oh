//#############################################################################
//# Function: One hot safe clock mux                                          #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_clockmux #(parameter ASIC = `CFG_ASIC, // use ASIC lib
		     parameter N    = 1)    // number of clock inputs
   (
    input 	  clk, // local clock to sync enable to
    input [N-1:0] en, // one hot enable vector
    input [N-1:0] clkin,// one hot clock inputs (only one is active!) 
    output 	  clkout 
    );

   generate
      if(ASIC)
	begin : asic
	   asic_clockmux #(.N(N)) imux (.clk(clk),
					.clkin(clkin[N-1:0]),
					.en(en[N-1:0]),
					.clkout(clkout));
	end
      else
	begin : generic
	   reg [N-1:0] en_sh;		  
	   always @ (clk or en)
	     if (!clk)
	       en_sh[N-1:0] <= en[N-1:0];
	   assign clkout = |(clkin[N-1:0] & en_sh[N-1:0]);
	end
   endgenerate   
endmodule // oh_clockmux


