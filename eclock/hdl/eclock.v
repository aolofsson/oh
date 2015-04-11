/*###########################################################################
 # Function:  High speed clock generator elink module
 #      
 #  cclk_p/n    - Epiphany Core Clock, Differential, must be connected
 #                directly to IO pins.
 #
 #  tx_lclk_par - Parallel data clock, at bit rate / 8 for etx
 #
 #  tx_lclk     - Serial DDR data clock, at bit rate / 2 for etx
 #
 #  tx_lclk_out - DDR "Clock" clock, to generate tx_lclk_p/n output
 #                At bit rate / 2, 90deg shifted from tx_lclk
 #
 # Notes: Uses Xilinx macros throughout
 #
 ############################################################################
 */

`timescale 1ns/1ps

module eclock (/*AUTOARG*/
   // Outputs
   cclk_p, cclk_n, tx_lclk, tx_lclk_out, tx_lclk_par,
   // Inputs
   clkin, reset, ecfg_cclk_en, ecfg_cclk_div, ecfg_cclk_pllcfg,
   ecfg_cclk_bypass, ecfg_tx_clkbypass
   );

   // Parameters must be set as follows:
   //   PFD input frequency = 1/CLKIN1_PERIOD / DIVCLK_DIVIDE (10-450MHz)
   //   VCO frequency = PFD input frequency * CLKFBOUT_MULT (800-1600MHz)
   //   Output frequency = VCO frequency / CLKOUTn_DIVIDE

   parameter  CLKIN_PERIOD     = 10.000;  // ns -> 100MHz
   parameter  CLKIN_DIVIDE     = 1;
   parameter  VCO_MULT         = 12;      // VCO = 1200MHz
   parameter  CCLK_DIVIDE      = 2;       // CCLK = 600MHz 
   parameter  LCLK_DIVIDE      = 4;       // LCLK = 300MHz (600MB/s eLink)
   parameter  FEATURE_CCLK_DIV = 1'b1;
   parameter  IOSTD_ELINK      = "LVDS_25";
   
   //Input clock & reset
   input        clkin;
   input        reset;
   
   //From configuration register
   input        ecfg_cclk_en;          //cclk enable   
   input [3:0]  ecfg_cclk_div;         //cclk divider setting
   input [3:0]  ecfg_cclk_pllcfg;      //pll configuration TODO: ??
   input	ecfg_cclk_bypass;      //ccclk==clkin 
   input 	ecfg_tx_clkbypass;     //tx_lclk==clkin (need manual divider for lclk_out)
   
   //Epiphany clock
   output       cclk_p, cclk_n;        //high speed clock directly to pin

   //Transmit clocks
   output       tx_lclk;               //for serialized in transmit serdes
   output       tx_lclk_out;           //for lclk output
   output       tx_lclk_par;           //slow clock for tx parallel logic 

   // Wires
   wire         clkfb;
   wire 	pll_cclk;          //full speed cclk
   wire 	pll_lclk;          //full speed lclk etx
   wire 	pll_lclk_out;      //full speed lclk for pin for etx
   wire 	pll_lclk_par;      //low speed lclk for etx
   wire 	pll_cclk_div;      //low speed cclk
   wire 	pll_cclk_standby;  //standby clock
   wire 	cclk;
   wire 	cclk_base;
   wire 	cclk_div;
   
   
   // PLL Primitive
   PLLE2_BASE
     #(
       .BANDWIDTH("OPTIMIZED"),     // OPTIMIZED, HIGH, LOW
       .CLKFBOUT_MULT(VCO_MULT),    // Multiply value for all CLKOUT, (2-64)
       .CLKFBOUT_PHASE(0.0),        // Phase offset in degrees of CLKFB, (-360.000-360.000).
       .CLKIN1_PERIOD(CLKIN_PERIOD),// Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
       // CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for each CLKOUT (1-128)
       .CLKOUT0_DIVIDE(CCLK_DIVIDE),      //full speed
       .CLKOUT1_DIVIDE(LCLK_DIVIDE),      //full speed  
       .CLKOUT2_DIVIDE(LCLK_DIVIDE),      //full speed
       .CLKOUT3_DIVIDE(LCLK_DIVIDE * 4),  //low speed
       .CLKOUT4_DIVIDE(CCLK_DIVIDE * 4),  //low speed
       .CLKOUT5_DIVIDE(128),              //veeery low speed
       // CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for each CLKOUT (0.001-0.999).
       .CLKOUT0_DUTY_CYCLE(0.5),
       .CLKOUT1_DUTY_CYCLE(0.5),
       .CLKOUT2_DUTY_CYCLE(0.5),
       .CLKOUT3_DUTY_CYCLE(0.5),
       .CLKOUT4_DUTY_CYCLE(0.5),
       .CLKOUT5_DUTY_CYCLE(0.5),
       // CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
       .CLKOUT0_PHASE(0.0),
       .CLKOUT1_PHASE(0.0),
       .CLKOUT2_PHASE(90.0),
       .CLKOUT3_PHASE(0.0),
       .CLKOUT4_PHASE(0.0),
       .CLKOUT5_PHASE(0.0),
       .DIVCLK_DIVIDE(CLKIN_DIVIDE),// Master division value, (1-56)
       .REF_JITTER1(0.01),          // Reference input jitter (0.000-0.999).
       .STARTUP_WAIT("FALSE")       // Delay DONE until PLL Locks, ("TRUE"/"FALSE")
       ) eclk_pll
       (
        // Clock Outputs: 1-bit (each) output: User configurable clock outputs
        .CLKOUT0(pll_cclk),         //full speed cclk
        .CLKOUT1(pll_lclk),         //full speed lclk etx
        .CLKOUT2(pll_lclk_out),     //full speed lclk for pin for etx
        .CLKOUT3(pll_lclk_par),     //low speed lclk for etx
        .CLKOUT4(pll_cclk_div),     //low speed cclk
        .CLKOUT5(pll_cclk_standby), //standby clock
        .CLKFBOUT(clkfb),           //feedback clock output
        .LOCKED(),                  //lock signal
        .CLKIN1(clkin),             //main input clock
        .PWRDWN(1'b0),              //pll power down
        .RST(1'b0),                 //reset
        .CLKFBIN(clkfb)             //feedback clock input
        );

   // Output buffering
   BUFG cclk_buf       (.O   (cclk_base),   .I   (pll_cclk));
   BUFG cclk_div_buf   (.O   (cclk_div),    .I   (pll_cclk_div));   
   BUFG lclk_buf       (.O   (tx_lclk),     .I   (pll_lclk));
   BUFG lclk_out_buf   (.O   (tx_lclk_out), .I   (pll_lclk_out));
   BUFG lclk_par_buf   (.O   (tx_lclk_par), .I   (pll_lclk_par));

generate
   if( FEATURE_CCLK_DIV ) begin : gen_cclk_div

      // Create adjustable (but fast) CCLK
      wire      rxi_cclk_out;
      reg [8:1] cclk_pattern;
      reg [3:0] clk_div_sync;
      reg       enb_sync;
   
      always @ (posedge cclk_div) begin  // Might need x-clock TIG here

	 clk_div_sync <= ecfg_cclk_div;
	 enb_sync     <= ecfg_cclk_en;
	 
	 if(enb_sync)
           case(clk_div_sync)
             4'h0:    cclk_pattern <= 8'd0;         // Clock OFF
             4'h7:    cclk_pattern <= 8'b10101010;  // Divide by 1
             4'h6:    cclk_pattern <= 8'b11001100;  // Divide by 2
             4'h5:    cclk_pattern <= 8'b11110000;  // Divide by 4
             default: cclk_pattern <= {8{~cclk_pattern[1]}}; // /8
           endcase
      else
        cclk_pattern <= 8'b00000000;	 
      end // always @ (posedge cclk_div)
      
      
      //CCLK CLOCK DIVIDER
      OSERDESE2 
     #(
       .DATA_RATE_OQ("DDR"),     // DDR, SDR
       .DATA_RATE_TQ("SDR"),     // DDR, BUF, SDR
       .DATA_WIDTH(8),           // Parallel data width (2-8,10,14)
       .INIT_OQ(1'b0),           // Initial value of OQ output (1'b0,1'b1)
       .INIT_TQ(1'b0),           // Initial value of TQ output (1'b0,1'b1)
       .SERDES_MODE("MASTER"),   // MASTER, SLAVE
       .SRVAL_OQ(1'b0),          // OQ output value when SR is used (1'b0,1'b1)
       .SRVAL_TQ(1'b0),          // TQ output value when SR is used (1'b0,1'b1)
       .TBYTE_CTL("FALSE"),      // Enable tristate byte operation (FALSE, TRUE)
       .TBYTE_SRC("FALSE"),      // Tristate byte source (FALSE, TRUE)
       .TRISTATE_WIDTH(1)        // 3-state converter width (1,4)
       ) OSERDESE2_inst 
       (
        .OFB(),                  // Feedback path for data
        .OQ(cclk),               // Data path output
        .SHIFTOUT1(),            
        .SHIFTOUT2(),
        .TBYTEOUT(),             // Byte group tristate
        .TFB(),                  // 1-bit output: 3-state control
        .TQ(),                   // 3-state control
        .CLK(cclk_base),         // High speed clock
        .CLKDIV(cclk_div),       // Divided clock
        .D1(cclk_pattern[1]),    // Parallel data inputs
        .D2(cclk_pattern[2]),
        .D3(cclk_pattern[3]),
        .D4(cclk_pattern[4]),
        .D5(cclk_pattern[5]),
        .D6(cclk_pattern[6]),
        .D7(cclk_pattern[7]),
        .D8(cclk_pattern[8]),
        .OCE(1'b1),             // Output data clock enable TODO: gating?
        .RST(reset),            // Reset
        .SHIFTIN1(1'b0),        // Data input expansion (1-bit each)
        .SHIFTIN2(1'b0),
        .T1(1'b0),              // Parallel 3-state inputs
        .T2(1'b0),
        .T3(1'b0),
        .T4(1'b0),
        .TBYTEIN(1'b0),         // Byte group tristate
        .TCE(1'b0)              // 3-state clock enable
        );

   end else 
     begin : gen_fixed_cclk // Non-dividable CCLK
	reg       enb_sync;

	always @ (posedge cclk_div)
	  enb_sync     <= ecfg_cclk_en;
	
	// The following does not result in timing failures,
	//  but doesn't seem glitch-safe
	assign cclk = cclk_base & enb_sync;
     end   
endgenerate
   
   //Clock output
   OBUFDS #(.IOSTANDARD (IOSTD_ELINK)) obufds_cclk_inst (.O  (cclk_p), .OB (cclk_n), .I  (cclk));
        
endmodule // eclock

/*
  Copyright (C) 2014 Adapteva, Inc.
  Contributed by Fred Huettig <fred@adapteva.com>
 
   This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.This program is distributed in the hope 
  that it will be useful,but WITHOUT ANY WARRANTY; without even the implied 
  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details. You should have received a copy 
  of the GNU General Public License along with this program (see the file 
  COPYING).  If not, see <http://www.gnu.org/licenses/>.
*/
