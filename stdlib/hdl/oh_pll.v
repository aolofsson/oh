//#############################################################################
//# Function: Phase Locked Loop                                               #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_pll #(parameter N = 8) // number of clocks
   ( input            clkin,    // primary clock input
     input 	      nreset, // async active low reset
     input 	      clkfb, // feedback clock
     input 	      pll_en, // enable pll   
     input [N*8-1:0]  clkdiv, // clock divider settings (per clock)
     input [N*16-1:0] clkphase, // clock phase setting (rise/fall edge)
     input [7:0]      clkmult, // feedback clock multiplier 	       
     output [N-1:0]   clkout, // output clocks
     output 	      locked // PLL locked status
     );

`ifdef TARGET_SIM

   //insert PLL simulation model
   
`endif
      
endmodule // oh_pll
