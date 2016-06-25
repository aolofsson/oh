//#############################################################################
//# Function: One hot 4:1 mux for clocks                                      #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_clockmux #(parameter ASIC = `CFG_ASIC, // use ASIC lib
		     parameter N    = 1)    // number of clock inputs
   (
    input [N-1:0] en,   // one hot enable, valid rising edge wrt to its clock
    input [N-1:0] clkin,// free running input clocks
    output 	  clkout 
    );

   wire [N-1:0]   eclk;
   
   //One clock gate per clock
   oh_clockgate #(.ASIC(ASIC)) 
   i_clockgate [N-1:0] (.eclk	(eclk[N-1:0]),			
			.clk	(clkin[N-1:0]),
			.te	(1'b0), //do something about this>
			.en	(en[N-1:0]));

   //Or gated clocks together
   assign clkout = |(eclk[N-1:0]);
   
endmodule // oh_clockmux


