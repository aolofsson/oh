//#############################################################################
//# Function: Clock 'OR' gate                                                 #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_clockor #(parameter N    = 1)    // number of clock inputs
   (
    input [N-1:0] clkin,// one hot clock inputs (only one is active!) 
    output 	  clkout 
    );

   localparam ASIC = `CFG_ASIC;

   generate
      if(ASIC & (N==4))
	begin : asic
	   asic_clockor4 ior (/*AUTOINST*/
			      // Outputs
			      .clkout		(clkout),
			      // Inputs
			      .clkin		(clkin[3:0]));
	   
	end // block: g0
      else if(ASIC & (N==2))
	begin : asic
	   asic_clockor2 ior (/*AUTOINST*/
			      // Outputs
			      .clkout		(clkout),
			      // Inputs
			      .clkin		(clkin[1:0]));
	   
	end // block: g0
      else
	begin : generic
	   assign clkout = |(clkin[N-1:0]);
	end
   endgenerate   
endmodule // oh_clockmux


