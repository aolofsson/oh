/*###########################################################################
 # Function:  Clock generator for elink
 #      
 #  tx_lclk_div4 - Parallel data clock (125Mhz)
 #
 #  tx_lclk      - DDR data clock (500MHz)
 #
 #  tx_lclk90    - DDR "Clock" for IO (500MHz)
 #
 #  rx_lclk      - High speed RX clock for IO (clkin freq)
 #
 #  rx_lclk_div4 - Low speed RX clock for logic (75MHz)
 ############################################################################
 */

module eclocks (/*AUTOARG*/
   // Outputs
   tx_lclk, tx_lclk90, tx_lclk_div4, rx_lclk, rx_lclk_div4, cclk_p,
   cclk_n,
   // Inputs
   reset, clkin_elink, clkin_cclk
   );

   /****************************************************************/
   /*WARNING!! THIS CLOCK MUST MATCH THE ACTUAL INPUT CLOCK PERIOD!*/
   /****************************************************************/

   parameter  ELINK_CLKIN_PERIOD  = 3.3333333;  // (2.5-100ns, set by system)
   parameter  CCLK_CLKIN_PERIOD   = 10;         // (2.5-100ns, set by system)

   //Input clock, reset, config interface
   input      reset;             // hardware reset
   input      clkin_elink;       // clock input for elink PLL
   input      clkin_cclk;        // clock input for cclk PLL 
   
   //TX Clocks
   output     tx_lclk;             // tx clock for DDR IO
   output     tx_lclk90;           // tx output clock shifted by 90 degrees
   output     tx_lclk_div4;        // tx slow clock for logic
   
   //RX Clocks
   output     rx_lclk;            // rx high speed clock for DDR IO
   output     rx_lclk_div4;       // rx slow clock for logic

   //Epiphany "free running" clock
   output     cclk_p, cclk_n;
                 			
`ifdef TARGET_XILINX	

   wire       cclk_fb;
   wire       lclk_fb;
   wire       cclk;
   wire       cclk_alt;
   
   //###########################
   // MMCM/PLL FOR CCLK
   //###########################
   parameter CCLK_VCO_MULT = 12;
   parameter CCLK_DIVIDE   = 2;

   MMCME2_ADV
     #(
       .BANDWIDTH("OPTIMIZED"),          
       .CLKFBOUT_MULT_F(CCLK_VCO_MULT),
       .CLKFBOUT_PHASE(0.0),
       .CLKIN1_PERIOD(CCLK_CLKIN_PERIOD),
       .CLKOUT0_DIVIDE_F(CCLK_DIVIDE),    // cclk
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
	.CLKOUT0B(),
        .CLKOUT1(),
	.CLKOUT1B(),
        .CLKOUT2(),
	.CLKOUT2B(),
        .CLKOUT3(),
	.CLKOUT3B(),
        .CLKOUT4(),
        .CLKOUT5(),
	.CLKOUT6(),
	.PWRDWN(1'b0),
        .RST(1'b0),
        .CLKFBIN(cclk_fb),
        .CLKFBOUT(cclk_fb),       
        .CLKIN1(clkin_cclk),
	.CLKIN2(1'b0),
	.CLKINSEL(1'b1),      
	.DADDR(7'b0),
        .DCLK(1'b0),
	.DEN(1'b0),
	.DI(16'b0),
	.DWE(1'b0),
	.DRDY(),
	.DO(), 
	.LOCKED(),
	.PSCLK(1'b0),
	.PSEN(1'b0),
	.PSDONE(),
	.PSINCDEC(1'b0),
	.CLKFBSTOPPED(),
	.CLKINSTOPPED()
        );

   OBUFDS  cclk_obuf (.O   (cclk_p),
		      .OB  (cclk_n),
		      .I   (cclk)
		      );

   //###########################
   // PLL FOR ELIN
   //###########################  
   parameter LCLK_VCO_MULT = 5; //1500MHz
   parameter TXCLK_DIVIDE  = 3; //500MHz
   parameter RXCLK_DIVIDE  = 5; //300MHz
   
   PLLE2_ADV
     #(
       .BANDWIDTH("OPTIMIZED"),          
       .CLKFBOUT_MULT(LCLK_VCO_MULT),
       .CLKFBOUT_PHASE(0.0),
       .CLKIN1_PERIOD(ELINK_CLKIN_PERIOD),
       .CLKOUT0_DIVIDE(CCLK_DIVIDE),    // cclk
       .CLKOUT1_DIVIDE(TXCLK_DIVIDE),   // tx_lclk
       .CLKOUT2_DIVIDE(TXCLK_DIVIDE),   // tx_lclk90
       .CLKOUT3_DIVIDE(TXCLK_DIVIDE*4), // tx_lclk_div4
       .CLKOUT4_DIVIDE(RXCLK_DIVIDE),   // rx_lclk
       .CLKOUT5_DIVIDE(RXCLK_DIVIDE*4), // rx_lclk_div4          
       .CLKOUT0_DUTY_CYCLE(0.5),         
       .CLKOUT1_DUTY_CYCLE(0.5),
       .CLKOUT2_DUTY_CYCLE(0.5),
       .CLKOUT3_DUTY_CYCLE(0.5),
       .CLKOUT4_DUTY_CYCLE(0.5),
       .CLKOUT5_DUTY_CYCLE(0.5),
       .CLKOUT0_PHASE(0.0),
       .CLKOUT1_PHASE(0.0),
       .CLKOUT2_PHASE(90.0),
       .CLKOUT3_PHASE(0.0),
       .CLKOUT4_PHASE(0.0),
       .CLKOUT5_PHASE(0.0),
       .DIVCLK_DIVIDE(1.0), 
       .REF_JITTER1(0.01), 
       .STARTUP_WAIT("FALSE") 
       ) pll_elink
       (
        .CLKOUT0(cclk_alt),
        .CLKOUT1(tx_lclk),
        .CLKOUT2(tx_lclk90),
        .CLKOUT3(tx_lclk_div4),
        .CLKOUT4(rx_lclk),
        .CLKOUT5(rx_lclk_div4),
	.PWRDWN(1'b0),
        .RST(1'b0),
        .CLKFBIN(lclk_fb),
        .CLKFBOUT(lclk_fb),       
        .CLKIN1(clkin_elink),
	.CLKIN2(1'b0),
	.CLKINSEL(1'b1),      
	.DADDR(7'b0),
        .DCLK(1'b0),
	.DEN(1'b0),
	.DI(16'b0),
	.DWE(1'b0),
	.DRDY(),
	.DO(), 
	.LOCKED()
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
