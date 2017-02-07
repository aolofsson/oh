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

    localparam ASIC = `CFG_ASIC;

    generate
       if(ASIC& (N==2))
	 begin : asic
	    asic_clockmux2 imux (.clkin(clkin[N-1:0]),
				 .en(en[N-1:0]),
				 .clkout(clkout));
	 end
       else if(ASIC & (N==4))
	 begin : asic
	    asic_clockmux4 imux (.clkin(clkin[N-1:0]),
				 .en(en[N-1:0]),
				 .clkout(clkout));
	 end
       else
	 begin : generic
	    assign clkout = |(clkin[N-1:0] & en[N-1:0]);
	 end
    endgenerate   
endmodule // oh_clockmux


