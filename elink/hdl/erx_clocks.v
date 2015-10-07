`include "elink_constants.v"
module erx_clocks (/*AUTOARG*/
   // Outputs
   rx_lclk, rx_lclk_div4, erx_reset,
   // Inputs
   sys_reset, soft_reset, sys_clk, rx_clkin
   );

`ifdef SIM
   parameter RCW                 = 4;          // reset counter width
`else
   parameter RCW                 = 8;          // reset counter width
`endif

   //Frequency Settings (Mhz)
   parameter FREQ_SYSCLK     = 100;
   parameter FREQ_RXCLK      = 300;   
   parameter FREQ_IDELAY     = 200;   
   parameter RXCLK_PHASE     = 0;    //270;  //-90 deg rxclk phase shift
   
   //VCO multiplers
   parameter PLL_VCO_MULT    = 4;   //RX
      
   //Input clock, reset, config interface
   input      sys_reset;         // por reset (hw)
   input      soft_reset;        // rx enable signal (sw)
   
   //Main input clocks
   input      sys_clk;            // always on input clk cclk/TX MMCM
   input      rx_clkin;           // input clk for RX only PLL
   
   //RX Clocks
   output     rx_lclk;           // rx high speed clock for DDR IO
   output     rx_lclk_div4;      // rx slow clock for logic

   output     erx_reset;         // async reset for logic
    
   //Don't touch these! (derived parameters)
   localparam real    RXCLK_PERIOD  = 1000.000000/FREQ_RXCLK; 
   localparam integer IREF_DIVIDE   = PLL_VCO_MULT*FREQ_RXCLK/FREQ_IDELAY;
   localparam integer RXCLK_DIVIDE  = PLL_VCO_MULT; //1:1
   
   //############
   //# WIRES
   //############
 
   //Idelay controller
   wire       idelay_reset;
   wire       idelay_ready; //ignore this? 
   wire       idelay_ref_clk;
   
   //pll outputs
   wire       rx_lclk_pll;
   wire       rx_lclk_div4_pll;
   wire       idelay_ref_clk_pll;
   
   //PLL
   wire       rx_lclk_fb_in;
   wire       rx_lclk_fb_out;   
 
   
   //###########################
   // RESET STATE MACHINE
   //###########################
  
   reg [RCW:0] reset_counter = 'b0; //works b/c of free running counter!
   reg 	       heartbeat;   
   reg 	       pll_locked_reg;
   reg 	       pll_locked_sync;     
   reg [2:0]   reset_state;
   wire        pll_reset;

   
   //wrap around counter that generates a 1 cycle heartbeat       
   //free running counter...
   always @ (posedge sys_clk)
     begin
	reset_counter[RCW-1:0] <= reset_counter[RCW-1:0]+1'b1;
	heartbeat              <= ~(|reset_counter[RCW-1:0]);
     end
   
   //two clock synchronizer
   always @ (posedge sys_clk)
     begin
        pll_locked_reg    <= pll_locked;	
        pll_locked_sync   <= pll_locked_reg;	
     end

   
`define RESET_ALL        3'b000
`define START_PLL        3'b001
`define ACTIVE           3'b010

   //Reset sequence state machine
   
   always @ (posedge sys_clk or posedge sys_reset)
     if(sys_reset)
       reset_state[2:0]        <= `RESET_ALL;   
     else if(heartbeat)
       case(reset_state[2:0])
	 `RESET_ALL :
	   if(~soft_reset)
	     reset_state[2:0]  <= `START_PLL;	 
	 `START_PLL :
	   if(pll_locked_sync & idelay_ready)
	     reset_state[2:0]  <= `ACTIVE; 
	 `ACTIVE:
	   if(soft_reset)
	     reset_state[2:0]  <= `RESET_ALL; //stay there until next reset
       endcase // case (reset_state[2:0])
   
   //reset PLL during 'reset' and during quiet time around reset edge
   assign pll_reset    =  (reset_state[2:0]==`RESET_ALL);   
   assign idelay_reset =  (reset_state[2:0]==`RESET_ALL);

   //asynch rx reset
   assign erx_reset    =  (reset_state[2:0]!=`ACTIVE);
   
`ifdef TARGET_XILINX	

   //###########################
   // PLL RX
   //###########################  
   
   PLLE2_ADV
     #(
       .BANDWIDTH("OPTIMIZED"),          
       .CLKFBOUT_MULT(PLL_VCO_MULT),              
       .CLKFBOUT_PHASE(0.0),
       .CLKIN1_PERIOD(RXCLK_PERIOD),
       .CLKOUT0_DIVIDE(128),
       .CLKOUT1_DIVIDE(128),
       .CLKOUT2_DIVIDE(128),
       .CLKOUT3_DIVIDE(IREF_DIVIDE),    // idelay ref clk
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
       .CLKOUT2_PHASE(0.0),
       .CLKOUT3_PHASE(0.0),
       .CLKOUT4_PHASE(RXCLK_PHASE),
       .CLKOUT5_PHASE(RXCLK_PHASE/4),
       .DIVCLK_DIVIDE(1.0), 
       .REF_JITTER1(0.01), 
       .STARTUP_WAIT("FALSE") 
       ) pll_rx
       (
        .CLKOUT0(),
        .CLKOUT1(),
        .CLKOUT2(),
        .CLKOUT3(idelay_ref_clk_pll),
        .CLKOUT4(rx_lclk_pll),
        .CLKOUT5(rx_lclk_div4_pll),
	.PWRDWN(1'b0),
        .RST(pll_reset),
        .CLKFBIN(rx_lclk_fb_in),    
        .CLKFBOUT(rx_lclk_fb_out),       
        .CLKIN1(rx_clkin),
	.CLKIN2(1'b0),
	.CLKINSEL(1'b1),      
	.DADDR(7'b0),
        .DCLK(1'b0),
	.DEN(1'b0),
	.DI(16'b0),
	.DWE(1'b0),
	.DRDY(),
	.DO(), 
	.LOCKED(pll_locked)
        );
   
   //Clock network
   BUFG rx_lclk_bufg_i      (.I(rx_lclk_pll),      .O(rx_lclk));       //300Mhz
   BUFG rx_lclk_div4_bufg_i (.I(rx_lclk_div4_pll), .O(rx_lclk_div4));  //75 MHz (300/4)
   BUFG idelay_ref_bufg_i   (.I(idelay_ref_clk_pll), .O(idelay_ref_clk));//idelay ctrl clock
   
   //Feedback buffers
   BUFG lclk_fb_bufg_i0(.I(rx_lclk_fb_in), .O(rx_lclk_fb_out));           //feedback
   
   //###########################
   // Idelay controller
   //###########################
   
   (* IODELAY_GROUP = "IDELAY_GROUP" *) // Group name for IDELAYCTRL
   IDELAYCTRL idelayctrl_inst 
     (
      .RDY(idelay_ready), // check ready flag in reset sequence?
      .REFCLK(idelay_ref_clk),//200MHz clk (78ps tap delay)
      .RST(idelay_reset));
   
`endif //  `ifdef TARGET_XILINX


endmodule // eclocks
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:

/*
  Copyright (C) 2015 Adapteva, Inc.
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
