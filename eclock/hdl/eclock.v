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

/*###########################################################################
 # Function:  Generates clocks for eLink module:
 #      CCLK_N/P - Epiphany Core Clock, Differential, must be connected
 #                 directly to IO pins.
 #
 #      lclk_p - Parallel data clock, at bit rate / 8
 #
 #      lclk_s - Serial DDR data clock, at bit rate / 2
 #
 #      lclk_out - DDR "Clock" clock, to generate LCLK output
 #                 At bit rate / 2, 90deg shifted from lclk_s
 #
 # Inputs:
 #      ecfg_cclk_en - Enable the CCLK output
 #      ecfg_cclk_div - CCLK divider
 #      ecfg_cclk_pllcfg - PLL configuration (not implemented)
 #
 # Notes:    Uses Xilinx macros throughout
 #
 ############################################################################
 */

`timescale 1ns/1ps

module eclock (/*AUTOARG*/
   // Outputs
   CCLK_P, CCLK_N, lclk_s, lclk_out, lclk_p,
   // Inputs
   clkin, reset, ecfg_cclk_en, ecfg_cclk_div, ecfg_cclk_pllcfg
   );

   // Parameters must be set as follows:
   //   PFD input frequency = 1/CLKIN1_PERIOD / DIVCLK_DIVIDE (10-450MHz)
   //   VCO frequency = PFD input frequency * CLKFBOUT_MULT (800-1600MHz)
   //   Output frequency = VCO frequency / CLKOUTn_DIVIDE
   parameter  CLKIN_PERIOD = 10.000; // ns -> 100MHz
   parameter  CLKIN_DIVIDE = 1;
   parameter  VCO_MULT = 12;         // VCO = 1200MHz
   parameter  CCLK_DIVIDE = 2;       // CCLK = 600MHz (at /1 setting)
   parameter  LCLK_DIVIDE = 4;       // LCLK = 300MHz (600MB/s eLink, 75MW/s parallel)
   parameter  FEATURE_CCLK_DIV = 1'b1;
   parameter  IOSTD_ELINK = "LVDS_25";
   
   // input clock & reset
   input        clkin;
   input        reset;
   
   // From configuration register
   input        ecfg_cclk_en;           //cclk enable   
   input [3:0]  ecfg_cclk_div;          //cclk divider setting
   input [3:0]  ecfg_cclk_pllcfg;       //pll configuration TODO: ??

   output       CCLK_P, CCLK_N;
   output       lclk_s;
   output       lclk_out;
   output       lclk_p;

   // Wires
   wire         cclk_src;
   wire         cclk_base;
   wire         cclk_p_src;
   wire         cclk_p;
   wire         cclk;
   wire         lclk_s_src;
   wire         lclk_out_src;
   wire         lclk_p_src;
   wire         clkfb;
   
   // PLL Primitive
   PLLE2_BASE
     #(
       .BANDWIDTH("OPTIMIZED"),     // OPTIMIZED, HIGH, LOW
       .CLKFBOUT_MULT(VCO_MULT),    // Multiply value for all CLKOUT, (2-64)
       .CLKFBOUT_PHASE(0.0),        // Phase offset in degrees of CLKFB, (-360.000-360.000).
       .CLKIN1_PERIOD(CLKIN_PERIOD),// Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
       // CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for each CLKOUT (1-128)
       .CLKOUT0_DIVIDE(CCLK_DIVIDE),
       .CLKOUT1_DIVIDE(LCLK_DIVIDE),
       .CLKOUT2_DIVIDE(LCLK_DIVIDE),
       .CLKOUT3_DIVIDE(LCLK_DIVIDE * 4),
       .CLKOUT4_DIVIDE(CCLK_DIVIDE * 4),
       .CLKOUT5_DIVIDE(128),
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
       .REF_JITTER1(0.01),          // Reference input jitter in UI, (0.000-0.999).
       .STARTUP_WAIT("FALSE")       // Delay DONE until PLL Locks, ("TRUE"/"FALSE")
       ) eclk_pll
       (
        // Clock Outputs: 1-bit (each) output: User configurable clock outputs
        .CLKOUT0(cclk_src),     // 1-bit output: CLKOUT0
        .CLKOUT1(lclk_s_src),   // 1-bit output: CLKOUT1
        .CLKOUT2(lclk_out_src), // 1-bit output: CLKOUT2
        .CLKOUT3(lclk_p_src),   // 1-bit output: CLKOUT3
        .CLKOUT4(cclk_p_src),   // 1-bit output: CLKOUT4
        .CLKOUT5(),             // 1-bit output: CLKOUT5
        // Feedback Clocks: 1-bit (each) output: Clock feedback ports
        .CLKFBOUT(clkfb),       // 1-bit output: Feedback clock
        .LOCKED(),              // 1-bit output: LOCK
        .CLKIN1(clkin),         // 1-bit input: Input clock
        // Control Ports: 1-bit (each) inpu: PLL control ports
        .PWRDWN(1'b0),          // 1-bit input: Power-down
        .RST(1'b0),            // 1-bit input: Reset
        // Feedback Clocks: 1-bit (each) input: Clock feedback ports
        .CLKFBIN(clkfb)         // 1-bit input: Feedback clock
        );

   // Output buffering

   BUFG cclk_buf
     (.O   (cclk_base),
      .I   (cclk_src));

   BUFG cclk_p_buf
     (.O   (cclk_p),
      .I   (cclk_p_src));
   
   BUFG lclk_s_buf
     (.O   (lclk_s),
      .I   (lclk_s_src));

   BUFG lclk_out_buf
     (.O   (lclk_out),
      .I   (lclk_out_src));

   BUFG lclk_p_buf
     (.O   (lclk_p),
      .I   (lclk_p_src));

generate
   if( FEATURE_CCLK_DIV ) begin : gen_cclk_div

         // Create adjustable (but fast) CCLK
   wire      rxi_cclk_out;
   reg [8:1] cclk_pattern;
   reg [3:0] clk_div_sync;
   reg       enb_sync;
   
   always @ (posedge cclk_p) begin  // Might need x-clock TIG here

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

   end // always @ (posedge lclk_p)
         
   OSERDESE2 
     #(
       .DATA_RATE_OQ("DDR"),  // DDR, SDR
       .DATA_RATE_TQ("SDR"),  // DDR, BUF, SDR
       .DATA_WIDTH(8),        // Parallel data width (2-8,10,14)
       .INIT_OQ(1'b0),        // Initial value of OQ output (1'b0,1'b1)
       .INIT_TQ(1'b0),        // Initial value of TQ output (1'b0,1'b1)
       .SERDES_MODE("MASTER"), // MASTER, SLAVE
       .SRVAL_OQ(1'b0),       // OQ output value when SR is used (1'b0,1'b1)
       .SRVAL_TQ(1'b0),       // TQ output value when SR is used (1'b0,1'b1)
       .TBYTE_CTL("FALSE"),   // Enable tristate byte operation (FALSE, TRUE)
       .TBYTE_SRC("FALSE"),   // Tristate byte source (FALSE, TRUE)
       .TRISTATE_WIDTH(1)     // 3-state converter width (1,4)
       ) OSERDESE2_inst 
       (
        .OFB(),             // 1-bit output: Feedback path for data
        .OQ(cclk),          // 1-bit output: Data path output
        .SHIFTOUT1(),       // SHIFTOUTn: 1-bit (each): Data output expansion
        .SHIFTOUT2(),
        .TBYTEOUT(),        // 1-bit output: Byte group tristate
        .TFB(),             // 1-bit output: 3-state control
        .TQ(),              // 1-bit output: 3-state control
        .CLK(cclk_base),    // 1-bit input: High speed clock
        .CLKDIV(cclk_p),    // 1-bit input: Divided clock
        .D1(cclk_pattern[1]), // D1 - D8: Parallel data inputs (1-bit each)
        .D2(cclk_pattern[2]),
        .D3(cclk_pattern[3]),
        .D4(cclk_pattern[4]),
        .D5(cclk_pattern[5]),
        .D6(cclk_pattern[6]),
        .D7(cclk_pattern[7]),
        .D8(cclk_pattern[8]),
        .OCE(1'b1),         // 1-bit input: Output data clock enable
        .RST(reset),        // 1-bit input: Reset
        .SHIFTIN1(1'b0),    // SHIFTINn: Data input expansion (1-bit each)
        .SHIFTIN2(1'b0),
        .T1(1'b0),          // T1 - T4: Parallel 3-state inputs
        .T2(1'b0),
        .T3(1'b0),
        .T4(1'b0),
        .TBYTEIN(1'b0),     // 1-bit input: Byte group tristate
        .TCE(1'b0)          // 1-bit input: 3-state clock enable
        );

   end else begin : gen_fixed_cclk // Non-dividable CCLK

   reg       enb_sync;

   always @ (posedge cclk_p)
      enb_sync     <= ecfg_cclk_en;

   // The following does not result in timing failures,
   //  but doesn't seem glitch-safe
   assign cclk = cclk_base & enb_sync;
   
   end
endgenerate
   
   // xilinx OBUFDS instantiation
   //
   OBUFDS
     #(.IOSTANDARD (IOSTD_ELINK)) 
   obufds_cclk_inst
     (.O   (CCLK_P),
	  .OB  (CCLK_N),
	  .I   (cclk));
        
endmodule // eclock

