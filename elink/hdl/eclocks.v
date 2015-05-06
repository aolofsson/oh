/*###########################################################################
 # Function:  Clock generator for elink
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
   hard_reset, pll_clkin
   );

   
   parameter  CLKIN_PERIOD     = 10.000; // (2.5-100ns, set by system)
                                         // must match actual sytem clock
                                         //

   //Input clock, reset, config interface
   input        hard_reset;         // hardware reset
   input        pll_clkin;          // primary input clock  

   //outputs
   output       cclk_p, cclk_n;     // high speed Epiphany clock (up to 1GHz)
   output       tx_lclk;            // elink tx serdes clock
   output       tx_lclk90;          // center aligned output clock for elink tx
   output       tx_lclk_div4;       // lclk/4 slow clock for tx parallel logic 

   // Wires
   wire 	cclk_clkfb;   
   wire 	lclk_clkfb;
   
			
`ifdef TARGET_XILINX	

   //###########################
   // MMCM/PLL FOR CCLK
   //###########################
   parameter CCLK_VCO_MULT =12;
   parameter CCLK_DIVIDE   = 2;

   PLLE2_BASE
     #(
       .BANDWIDTH("OPTIMIZED"),          
       .CLKFBOUT_MULT(CCLK_VCO_MULT),
       .CLKFBOUT_PHASE(0.0),
       .CLKIN1_PERIOD(CLKIN_PERIOD),
       .CLKOUT0_DIVIDE(CCLK_DIVIDE),    // cclk
       .CLKOUT1_DIVIDE(CCLK_DIVIDE*2),  // cclk/2
       .CLKOUT2_DIVIDE(CCLK_DIVIDE*4),  // cclk/4
       .CLKOUT3_DIVIDE(CCLK_DIVIDE*8),  // cclk/8
       .CLKOUT4_DIVIDE(CCLK_DIVIDE*16), // cclk/16
       .CLKOUT5_DIVIDE(CCLK_DIVIDE*32), // cclk/32          
       .CLKOUT0_DUTY_CYCLE(0.5),         
       .CLKOUT1_DUTY_CYCLE(0.5),
       .CLKOUT2_DUTY_CYCLE(0.5),
       .CLKOUT3_DUTY_CYCLE(0.5),
       .CLKOUT4_DUTY_CYCLE(0.5),
       .CLKOUT5_DUTY_CYCLE(0.5),
       .CLKOUT0_PHASE(0.0),
       .CLKOUT1_PHASE(0.0),
       .CLKOUT2_PHASE(0.0),
       .CLKOUT3_PHASE(0.0),
       .CLKOUT4_PHASE(0.0),
       .CLKOUT5_PHASE(0.0),
       .DIVCLK_DIVIDE(1.0), 
       .REF_JITTER1(0.01), 
       .STARTUP_WAIT("FALSE") 
       ) pll_cclk
       (
        .CLKOUT0(cclk),
        .CLKOUT1(),
        .CLKOUT2(),
        .CLKOUT3(),
        .CLKOUT4(),
        .CLKOUT5(),
        .CLKFBOUT(cclk_clkfb),
        .LOCKED(),
        .CLKIN1(pll_clkin),
        .PWRDWN(1'b0),
        .RST(1'b0),
        .CLKFBIN(cclk_clkfb)
        );
   
   //###########################
   // MMCM/PLL FOR LCLK
   //###########################
   parameter LCLK_VCO_MULT =10;
   parameter LCLK_DIVIDE   = 2;

  PLLE2_BASE
     #(
       .BANDWIDTH("OPTIMIZED"),          
       .CLKFBOUT_MULT(LCLK_VCO_MULT),
       .CLKFBOUT_PHASE(0.0),
       .CLKIN1_PERIOD(CLKIN_PERIOD),
       .CLKOUT0_DIVIDE(LCLK_DIVIDE),    // lclk
       .CLKOUT1_DIVIDE(LCLK_DIVIDE),    // lclk90                              
       .CLKOUT2_DIVIDE(LCLK_DIVIDE*4),  // lclkdiv4
       .CLKOUT3_DIVIDE(LCLK_DIVIDE*4),  // lclk/4
       .CLKOUT4_DIVIDE(LCLK_DIVIDE*4),  // lclk/4 with 90 deg
       .CLKOUT5_DIVIDE(LCLK_DIVIDE*16), // lclk/4-->div4
       .CLKOUT0_DUTY_CYCLE(0.5),
       .CLKOUT1_DUTY_CYCLE(0.5),
       .CLKOUT2_DUTY_CYCLE(0.5),
       .CLKOUT3_DUTY_CYCLE(0.5),
       .CLKOUT4_DUTY_CYCLE(0.5),
       .CLKOUT5_DUTY_CYCLE(0.5),
       .CLKOUT0_PHASE(0.0),
       .CLKOUT1_PHASE(90.0),            // tx_lclk90 shifted by 90 degrees
       .CLKOUT2_PHASE(0.0),             
       .CLKOUT3_PHASE(0.0),
       .CLKOUT4_PHASE(90.0),            //slow mode shifted by 90 degrees
       .CLKOUT5_PHASE(0.0),
       .DIVCLK_DIVIDE(1.0),
       .REF_JITTER1(0.01),
       .STARTUP_WAIT("FALSE")
       ) pll_lclk
       (
        .CLKOUT0(tx_lclk),             //tx_lclk
        .CLKOUT1(tx_lclk90),           //tx_lclk90
        .CLKOUT2(tx_lclk_div4),        //tx_lclk_div4
        .CLKOUT3(),
        .CLKOUT4(),
        .CLKOUT5(),
        .CLKFBOUT(lclk_clkfb),
        .LOCKED(),
        .CLKIN1(pll_clkin),
        .PWRDWN(1'b0),
        .RST(1'b0),
        .CLKFBIN(lclk_clkfb)
        );

`endif //  `ifdef TARGET_XILINX


   /*
   
`elsif TARGET_CLEAN
      
   clock_divider cclk_divider(
			      // Outputs
			      .clkout		(cclk),
			      .clkout90		(),
			      // Inputs
			      .clkin		(clkin), 
			      .reset            (hard_reset),
			      .divcfg		(clk_config[7:4])
			      )
			      ;
   
   clock_divider lclk_divider(
			      // Outputs
			      .clkout		(lclk),
			      .clkout90		(lclk90),
			      // Inputs
			      .clkin		(clkin),
			      .reset            (hard_reset),
			      .divcfg		(clk_config[11:8])
			      );
   
   //This clock is always on!
   clock_divider lclk_par_divider(
				  // Outputs
				  .clkout	(lclk_div4),
				  .clkout90	(),
				  // Inputs
				  .clkin	(clkin),
				  .reset        (hard_reset),
				  .divcfg	(clk_config[11:8] + 4'd2)
				  );

   


   //cclk (hack for sim)
   assign cclk_p = hard_reset ? clkin :
		   cclk_bp    ? pll_bypass[0] :			      
			        cclk;
   assign cclk_n = ~cclk_p;

   //lclk (hack for sim)
   assign tx_lclk = hard_reset ? clkin :
		    lclk_bp    ? pll_bypass[1] : 
		                 lclk;
   
   assign tx_lclk90 = hard_reset ? clkin :
		      lclk_bp    ? pll_bypass[2] : 
		                   lclk90;

   assign tx_lclk_div4 = hard_reset ? clkin :
		         lclk_bp    ? pll_bypass[3] : 
		                      lclk_div4;
    
    
`endif

   reg 		clkint;
   
   initial
     begin
	clkint=1'b0;	
     end
   
    always
      #0.5  clkint = ~clkint;   

 */
    
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
