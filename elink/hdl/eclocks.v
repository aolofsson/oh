/*###########################################################################
 # Function:  High speed clock generator for elink
 #      
 #  cclk_p/n     - Epiphany Output Clock (>600MHz) 
 #
 #  tx_lclk_div4 - Parallel data clock (125Mhz)
 #
 #  tx_lclk      - Serial DDR data clock (500MHz)
 #
 #  tx_lclk90    - DDR "Clock" clock, to generate tx_lclk_p/n output
 #                 Same as lclk, shifted by 90 degrees
 #
 ############################################################################
 */

module eclocks (/*AUTOARG*/
   // Outputs
   cclk_p, cclk_n, tx_lclk, tx_lclk90, tx_lclk_div4,
   // Inputs
   clkin, hard_reset, ecfg_clk_settings, clkbypass
   );

   // Parameters must be set as follows:
   //   PFD input frequency = 1/CLKIN1_PERIOD / DIVCLK_DIVIDE (10-450MHz)
   //   VCO frequency = PFD input frequency * CLKFBOUT_MULT (800-1600MHz)
   //   Output frequency = VCO frequency / CLKOUTn_DIVIDE

   //Input clock, reset, config interface
   input        clkin;              // primary input clock 
   input        hard_reset;         //
   input [15:0] ecfg_clk_settings;  // clock settings
   input [2:0] 	clkbypass;          // for bypassing PLL
 	
   
   //Output Clocks
   output       cclk_p, cclk_n;     // high speed Epiphany clock (up to 1GHz)
   output       tx_lclk;            // elink tx serdes clock
   output       tx_lclk90;          // center aligned output clock for elink tx
   output       tx_lclk_div4;       // lclk/4 slow clock for tx parallel logic 

   // Wires
   wire 	cclk_en;
   wire 	lclk_en;
   wire 	cclk;
   
   //Register decoding
   assign cclk_en=ecfg_clk_settings[0];
   assign lclk_en=ecfg_clk_settings[1];

`ifdef TARGET_XILINX	

   //instantiate MMCM
   
`elsif TARGET_CLEAN
      
   clock_divider cclk_divider(
			      // Outputs
			      .clkout		(cclk),
			      .clkout90		(),
			      // Inputs
			      .clkin		(clkin & cclk_en), 
			      .reset            (hard_reset),
			      .divcfg		(ecfg_clk_settings[7:4])
			      );
   
   clock_divider lclk_divider(
			      // Outputs
			      .clkout		(tx_lclk),
			      .clkout90		(tx_lclk90),
			      // Inputs
			      .clkin		(clkin & lclk_en),
			      .reset            (hard_reset),
			      .divcfg		(ecfg_clk_settings[11:8])
			      );
   
   clock_divider lclk_par_divider(
				  // Outputs
				  .clkout	(tx_lclk_div4),
				  .clkout90	(),
				  // Inputs
				  .clkin	(clkin & lclk_en),
				  .reset        (hard_reset),
				  .divcfg	(ecfg_clk_settings[11:8] + 4'd2)
				  );

   
   //Output buffer
   assign cclk_p = cclk & cclk_en ;
   assign cclk_n = ~cclk_p;
    
`endif
          
endmodule // eclocks
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:

/*
  Copyright (C) 2014 Adapteva, Inc.
  Contributed by Andreas Olofsson <andreas@adapteva.com>
 
   This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.This program is distributed in the hope 
  that it will be useful,but WITHOUT ANY WARRANTY without even the implied 
  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details. You should have received a copy 
  of the GNU General Public License along with this program (see the file 
  COPYING).  If not, see <http://www.gnu.org/licenses/>.
*/
