/*###########################################################################
 # Function:  Clock and reset generator
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

`include "elink_constants.v"

module eclocks (/*AUTOARG*/
   // Outputs
   tx_lclk, tx_lclk90, tx_lclk_div4, rx_lclk, rx_lclk_div4,
   rx_ref_clk, e_cclk_p, e_cclk_n, elink_reset, e_resetb,
   // Inputs
   reset, elink_en, sys_clk, rx_clkin
   );

   parameter RCW                 = 4;          // reset counter width

   //CCLK PLL
   parameter SYS_CLK_PERIOD      = 10;         // (2.5-100ns, set by system)
   parameter CCLK_VCO_MULT       = 12;         // 1200MHz
   parameter CCLK_DIVIDE         = 2;          // 600MHz

   //RX PLL
   parameter RXCLK_PERIOD        = 3.3333333;  // (2.5-100ns, set by system)
   parameter RXCLK_VCO_MULT      = 4;          // 1200MHz      
   parameter RXCLK_DIVIDE        = 4;          // 300MHz
   parameter RXCLK_PHASE         = 90;         // sim setting, tune for FPGA
   parameter RXCLK_DIV4_PHASE    = 22.5;       // tune for FPGA!

   //TX (WITH RX FOR NOW...)
   parameter TXCLK_DIVIDE        = 4;          // 300MHz default

   
   //Input clock, reset, config interface
   input      reset;             // async input reset
   input      elink_en;          // elink enable (from pin or register)
   
   //Main input clocks
   input      sys_clk;            // always on input clk cclk/TX MMCM
   input      rx_clkin;           // input clk for RX only PLL
   
   //TX Clocks
   output     tx_lclk;           // tx clock for DDR IO
   output     tx_lclk90;         // tx output clock shifted by 90 degrees
   output     tx_lclk_div4;      // tx slow clock for logic
   
   //RX Clocks
   output     rx_lclk;           // rx high speed clock for DDR IO
   output     rx_lclk_div4;      // rx slow clock for logic
   output     rx_ref_clk;        // clock for idelay element

   //Epiphany "free running" clock
   output     e_cclk_p, e_cclk_n;

   //Reset
   output     elink_reset;       // reset for elink logic & IO   
   output     e_resetb;          // reset fpr Epiphany chip
   
   //###########################
   // RESET STATE MACHINE
   //###########################
  
   wire        cclk_locked;
   wire        lclk_locked;   
   reg [RCW:0] reset_counter = 'b0; //works b/c of free running counter!
   reg 	       heartbeat;   
   reg 	       reset_in;
   reg 	       reset_sync;
   reg 	       pll_locked_sync;
   reg 	       pll_locked;
   wire        pll_reset;
   reg [2:0]   reset_state;
   reg 	       cclk_locked_reg;
   reg 	       cclk_locked_sync;
   
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
	cclk_locked_reg   <= cclk_locked;
	cclk_locked_sync  <= cclk_locked_reg;	
	pll_locked_sync   <= cclk_locked & lclk_locked;	
	reset_sync        <= (reset | ~elink_en);
	reset_in          <= reset_sync;
	pll_locked        <= pll_locked_sync;	
     end
   
`define RESET_ALL       3'b000
`define START_PLL       3'b001
`define STOP_PLL        3'b010
`define START_EPIPHANY  3'b011
`define HOLD_IT         3'b100
`define ACTIVE          3'b101
	     
   //Reset sequence state machine
   
   always @ (posedge sys_clk)
     if(reset_in)
       reset_state[2:0]        <= `RESET_ALL;   
     else if(heartbeat)
       case(reset_state[2:0])
	 `RESET_ALL :
	   reset_state[2:0]    <= `START_PLL;	 
	 `START_PLL :
	   if(cclk_locked_sync)
		reset_state[2:0]  <= `STOP_PLL; 
	 `STOP_PLL :
	   reset_state[2:0]    <= `START_EPIPHANY;
	 `START_EPIPHANY :
	   reset_state[2:0]    <= `HOLD_IT;
	 `HOLD_IT :
	   if(cclk_locked_sync)
	     reset_state[2:0]  <= `ACTIVE;
	 `ACTIVE:
	   reset_state[2:0]    <= `ACTIVE; //stay there until nex reset
       endcase // case (reset_state[2:0])

   
   //reset PLL during 'reset' and during quiet time around reset edge
   assign pll_reset   =  (reset_state[2:0]==`RESET_ALL)      |
			 (reset_state[2:0]==`STOP_PLL)       | 
			 (reset_state[2:0]==`START_EPIPHANY);
   
   assign e_resetb    =  (reset_state[2:0]==`START_EPIPHANY) |
		         (reset_state[2:0]==`HOLD_IT) |
		         (reset_state[2:0]==`ACTIVE);

   assign elink_reset  =  (reset_state[2:0]!=`ACTIVE);
     
`ifdef TARGET_XILINX	

   wire       cclk_fb_in;
   wire       cclk_fb_out;
   wire       lclk_fb_in;
   wire       lclk_fb_out;
   wire       cclk;
   wire       cclk_alt;
   
   //###########################
   // MMCM/PLL FOR CCLK AND TX
   //###########################
   MMCME2_ADV
     #(
       .BANDWIDTH("OPTIMIZED"),          
       .CLKFBOUT_MULT_F(CCLK_VCO_MULT),
       .CLKFBOUT_PHASE(0.0),
       .CLKIN1_PERIOD(SYS_CLK_PERIOD),
       .CLKOUT0_DIVIDE_F(CCLK_DIVIDE),  // cclk      
       .CLKOUT1_DIVIDE(TXCLK_DIVIDE),   // tx_lclk
       .CLKOUT2_DIVIDE(TXCLK_DIVIDE),   // tx_lclk90
       .CLKOUT3_DIVIDE(TXCLK_DIVIDE*4), // tx_lclk_div4
       .CLKOUT4_DIVIDE(6),              // rx_ref_clk (for idelay)
       .CLKOUT5_DIVIDE(128),            //   ??
       .CLKOUT6_DIVIDE(128),            //   ??        
       .CLKOUT0_DUTY_CYCLE(0.5),         
       .CLKOUT1_DUTY_CYCLE(0.5),
       .CLKOUT2_DUTY_CYCLE(0.5),
       .CLKOUT3_DUTY_CYCLE(0.5),
       .CLKOUT4_DUTY_CYCLE(0.5),
       .CLKOUT5_DUTY_CYCLE(0.5),
       .CLKOUT6_DUTY_CYCLE(0.5),
       .CLKOUT0_PHASE(0.0),
       .CLKOUT1_PHASE(0.0),
       .CLKOUT2_PHASE(90.0),
       .CLKOUT3_PHASE(0.0),
       .CLKOUT4_PHASE(0.0),
       .CLKOUT5_PHASE(0.0),
       .CLKOUT6_PHASE(0.0),
       .DIVCLK_DIVIDE(1.0), 
       .REF_JITTER1(0.01), 
       .STARTUP_WAIT("FALSE") 
       ) pll_cclk
       (
        .CLKOUT0(cclk),
	.CLKOUT0B(),
        .CLKOUT1(tx_lclk),
	.CLKOUT1B(),
        .CLKOUT2(tx_lclk90),
	.CLKOUT2B(),
        .CLKOUT3(tx_lclk_div4),
	.CLKOUT3B(),
        .CLKOUT4(rx_ref_clk),
        .CLKOUT5(),
	.CLKOUT6(),
	.PWRDWN(1'b0),
        .RST(pll_reset),     //reset
        .CLKFBIN(cclk_fb_in),
        .CLKFBOUT(cclk_fb_out),  //feedback clock     
        .CLKIN1(sys_clk),    //input clock
	.CLKIN2(1'b0),
	.CLKINSEL(1'b1),      
	.DADDR(7'b0),
        .DCLK(1'b0),
	.DEN(1'b0),
	.DI(16'b0),
	.DWE(1'b0),
	.DRDY(),
	.DO(), 
	.LOCKED(cclk_locked), //locked indicator
	.PSCLK(1'b0),
	.PSEN(1'b0),
	.PSDONE(),
	.PSINCDEC(1'b0),
	.CLKFBSTOPPED(),
	.CLKINSTOPPED()
        );
        
    BUFG pll_cclk_bufg(.I(cclk_fb_out), .O(cclk_fb_in));

`ifdef EPHYCARD //Ephycard has cclk in a different region
   wire cclk_bufmr;
   wire cclk_bufio;
   wire cclk_oddr;
   
   OBUFDS  cclk_obuf (.O   (e_cclk_p),
		      .OB  (e_cclk_n),
		      .I   (cclk_oddr)
		      );
		      
  ODDR #(.DDR_CLK_EDGE  ("SAME_EDGE"))
  oddr_lclk (
             .Q  (cclk_oddr),
             .C  (cclk_bufio),
             .CE (1'b1),
             .D1 (1'b1),
             .D2 (1'b0),
             .R  (1'b0),
             .S  (1'b0)
             );
	
	BUFIO bufio_cclk(.O(cclk_bufio), .I(cclk_bufmr));
    BUFMR bufmr_cclk(.O(cclk_bufmr), .I(cclk));
`else
   OBUFDS  cclk_obuf (.O   (e_cclk_p),
       .OB  (e_cclk_n),
       .I   (cclk)
       );
`endif

   //###########################
   // PLL RX CLOCK ALIGNMENT
   //###########################  
   
   PLLE2_ADV
     #(
       .BANDWIDTH("OPTIMIZED"),          
       .CLKFBOUT_MULT(RXCLK_VCO_MULT),
       .CLKFBOUT_PHASE(0.0),
       .CLKIN1_PERIOD(RXCLK_PERIOD),
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
       .CLKOUT4_PHASE(RXCLK_PHASE),
       .CLKOUT5_PHASE(RXCLK_DIV4_PHASE),
       .DIVCLK_DIVIDE(1.0), 
       .REF_JITTER1(0.01), 
       .STARTUP_WAIT("FALSE") 
       ) pll_elink
       (
        .CLKOUT0(cclk_alt),
        .CLKOUT1(),
        .CLKOUT2(),
        .CLKOUT3(),
        .CLKOUT4(rx_lclk),
        .CLKOUT5(rx_lclk_div4),
	.PWRDWN(1'b0),
        .RST(pll_reset),
        .CLKFBIN(lclk_fb_in),
        .CLKFBOUT(lclk_fb_out),       
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
	.LOCKED(lclk_locked)
        );
     
    BUFG pll_elink_bufg(.I(lclk_fb_out), .O(lclk_fb_in));
   
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
  Copyright (C) 2015 Adapteva, Inc.
  Contributed by Andreas Olofsson <andreas@adapteva.com>
  Contributed by Gunnar Hillerstrom 
 
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
