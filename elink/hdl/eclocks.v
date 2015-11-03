/*###########################################################################
 # Function:  Clock and reset generator
 #      
 #  tx_lclk_div4 - Parallel data clock (125Mhz)
 #
 #  tx_lclk      - DDR data clock (500MHz)
 #
 #  tx_lclk90    - DDR "Clock" for IO (500MHz)
 #
 #  rx_lclk      - High speed RX clock for IO (300MHz phase shifted)
 #
 #  rx_lclk_div4 - Low speed RX clock for logic (75MHz)
 ############################################################################
 
 */

`include "elink_constants.v"

module eclocks (/*AUTOARG*/
   // Outputs
   tx_lclk, tx_lclk90, tx_lclk_div4, rx_lclk, rx_lclk_div4, e_cclk_p,
   e_cclk_n, elink_reset, e_resetb,
   // Inputs
   reset, elink_en, sys_clk, rx_clkin
   );

//TODO: change to parameter 
`ifdef TARGET_SIMPLE
   parameter RCW                 = 4;          // reset counter width
`else
   parameter RCW                 = 8;          // reset counter width
`endif

   //Frequency Settings (Mhz)
   parameter FREQ_SYSCLK     = 100;
   parameter FREQ_RXCLK      = 300;
   parameter FREQ_TXCLK      = 300;
   parameter FREQ_IDELAY     = 200;   
   parameter FREQ_CCLK       = 600;  
   parameter TXCLK_PHASE     = 90;   //txclk phase shift
   parameter RXCLK_PHASE     = 0;    //270;  //-90 deg rxclk phase shift
   
   //VCO multiplers
   parameter MMCM_VCO_MULT   = 12;  //TX + CCLK
   parameter PLL_VCO_MULT    = 4;   //RX
      
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
 
   //Epiphany "free running" clock
   output     e_cclk_p, e_cclk_n;

   //Reset
   output     elink_reset;       // reset for elink logic & IO   
   output     e_resetb;          // reset fpr Epiphany chip


   //Don't touch these! (derived parameters)
   localparam real    SYSCLK_PERIOD = 1000.000000/FREQ_SYSCLK;
   localparam real    RXCLK_PERIOD  = 1000.000000/FREQ_RXCLK;
   localparam integer TXCLK_DIVIDE  = MMCM_VCO_MULT*FREQ_SYSCLK/FREQ_TXCLK;
   localparam integer CCLK_DIVIDE   = MMCM_VCO_MULT*FREQ_SYSCLK/FREQ_CCLK;
   localparam integer IREF_DIVIDE   = MMCM_VCO_MULT*FREQ_SYSCLK/FREQ_IDELAY;
   localparam integer RXCLK_DIVIDE  = PLL_VCO_MULT;
   
   //############
   //# WIRES
   //############

   //CCLK
   wire       cclk_reset;
   wire       cclk_i;
   wire       cclk_bufio;
   wire       cclk_oddr;
   
   //Idelay controller
   wire       idelay_reset;
   wire       idelay_ready; //ignore this?
   wire       idelay_ref_clk_i;
   wire       idelay_ref_clk;
   
   //RX
   wire       rx_lclk_i;
   wire       rx_lclk_div4_i;
   
   //TX
   wire       tx_lclk_i;
   wire       tx_lclk90_i;
   wire       tx_lckl_div4_i;

   //MMCM & PLL
   wire       cclk_fb_in;
   wire       cclk_fb_out;
   wire       lclk_fb_i;
   wire       pll_reset;
   wire       cclk_locked;
   wire       lclk_fb_in;
   wire       lclk_fb_out;
   reg 	      cclk_locked_reg;
   reg 	      cclk_locked_sync;
   reg 	      rx_locked_reg;
   reg 	      rx_locked_sync;
   wire       lclk_locked;   
   
   //###########################
   // RESET STATE MACHINE
   //###########################
  
   reg [RCW:0] reset_counter = 'b0; //works b/c of free running counter!
   reg 	       heartbeat;   
   wire	       reset_in;
   reg 	       reset_sync;

   reg [2:0]   reset_state;

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
	//TODO: Does rx_lclk always run when cclk does? Restb ?
        rx_locked_reg     <= lclk_locked;	
        rx_locked_sync    <= rx_locked_reg;	
	cclk_locked_reg   <= cclk_locked; // & clk_locked 
	cclk_locked_sync  <= cclk_locked_reg;	
     end

  
   
`define RESET_ALL        3'b000
`define START_CCLK       3'b001
`define STOP_CCLK        3'b010
`define START_EPIPHANY   3'b011
`define HOLD_IT          3'b100
`define TX_ACTIVE        3'b101
`define ACTIVE           3'b110

   //Reset sequence state machine
   
   always @ (posedge sys_clk or posedge reset)
     if(reset)
       reset_state[2:0]        <= `RESET_ALL;   
     else if(heartbeat)
       case(reset_state[2:0])
	 `RESET_ALL :
	   reset_state[2:0]    <= `START_CCLK;	 
	 `START_CCLK :
	   if(cclk_locked_sync)
	     reset_state[2:0]  <= `STOP_CCLK; 
	 `STOP_CCLK :
	   reset_state[2:0]    <= `START_EPIPHANY;
	 `START_EPIPHANY :
	   reset_state[2:0]    <= `HOLD_IT;
	 `HOLD_IT :
	   if(cclk_locked_sync)
	     reset_state[2:0]  <= `TX_ACTIVE;
	 `TX_ACTIVE :
	   reset_state[2:0]    <= `ACTIVE;
	 `ACTIVE:
	   if(~elink_en)
	     reset_state[2:0]    <= `RESET_ALL; //stay there until nex reset

       endcase // case (reset_state[2:0])

   
   //reset PLL during 'reset' and during quiet time around reset edge

   //TODO: this is a bug if the RX gets a clock that is not a turnaround from TX
   assign pll_reset   =  (reset_state[2:0] != `ACTIVE);
    
   assign idelay_reset =  (reset_state[2:0]==`RESET_ALL)  |
			  (reset_state[2:0]==`START_CCLK) |
			  reset;
   
   assign cclk_reset =  (reset_state[2:0]==`RESET_ALL)      |
			(reset_state[2:0]==`STOP_CCLK)      |  
			(reset_state[2:0]==`START_EPIPHANY) |
			reset
			;
   
   assign e_resetb    =  (reset_state[2:0]==`START_EPIPHANY) |
		         (reset_state[2:0]==`HOLD_IT)        |
		         (reset_state[2:0]==`ACTIVE)         |
   		         (reset_state[2:0]==`TX_ACTIVE)
			 ;
   

   assign elink_reset  =  reset |
			  ~((reset_state[2:0] == `TX_ACTIVE) |
			    (reset_state[2:0] == `ACTIVE));
   
			     
`ifdef TARGET_XILINX	

   //###########################
   // MMCM FOR TXCLK + CCLK
   //###########################
   MMCME2_ADV
     #(
       .BANDWIDTH("OPTIMIZED"),          
       .CLKFBOUT_MULT_F(MMCM_VCO_MULT),
       .CLKFBOUT_PHASE(0.0),
       .CLKIN1_PERIOD(SYSCLK_PERIOD),   
       .CLKOUT0_DIVIDE_F(CCLK_DIVIDE),   //cclk_c
       .CLKOUT1_DIVIDE(TXCLK_DIVIDE),    //tx_lclk
       .CLKOUT2_DIVIDE(TXCLK_DIVIDE),    //tx_lclk90
       .CLKOUT3_DIVIDE(TXCLK_DIVIDE*4),  //tx_lclk_div4
       .CLKOUT4_DIVIDE(IREF_DIVIDE),     //idelay_refclk
       .CLKOUT5_DIVIDE(128),             //
       .CLKOUT6_DIVIDE(128),             //
       .CLKOUT0_DUTY_CYCLE(0.5),         
       .CLKOUT1_DUTY_CYCLE(0.5),
       .CLKOUT2_DUTY_CYCLE(0.5),
       .CLKOUT3_DUTY_CYCLE(0.5),
       .CLKOUT4_DUTY_CYCLE(0.5),
       .CLKOUT5_DUTY_CYCLE(0.5),
       .CLKOUT6_DUTY_CYCLE(0.5),
       .CLKOUT0_PHASE(0.0),
       .CLKOUT1_PHASE(0.0),
       .CLKOUT2_PHASE(TXCLK_PHASE),
       .CLKOUT3_PHASE(0.0),
       .CLKOUT4_PHASE(0.0),
       .CLKOUT5_PHASE(0.0),
       .CLKOUT6_PHASE(0.0),
       .DIVCLK_DIVIDE(1.0), 
       .REF_JITTER1(0.01), 
       .STARTUP_WAIT("FALSE") 
       ) mmcm_cclk
       (
        .CLKOUT0(cclk_i),
	.CLKOUT0B(),
        .CLKOUT1(tx_lclk_i),
	.CLKOUT1B(),
        .CLKOUT2(tx_lclk90_i),
	.CLKOUT2B(),
        .CLKOUT3(tx_lclk_div4_i),
	.CLKOUT3B(),
        .CLKOUT4(idelay_ref_clk_i),
        .CLKOUT5(),
	.CLKOUT6(),
	.PWRDWN(1'b0),
        .RST(cclk_reset),     //reset
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
   

   //Idelay ref clock buffer
   BUFG idelay_ref_bufg_i(.I(idelay_ref_clk_i), .O(idelay_ref_clk));
   
   //Feedback buffer
   BUFG cclk_fb_bufg_i(.I(cclk_fb_out), .O(cclk_fb_in));

   //Tx clock buffers
   BUFG tx_lclk_bufg_i      (.I(tx_lclk_i),      .O(tx_lclk));
   BUFG tx_lclk_div4_bufg_i (.I(tx_lclk_div4_i), .O(tx_lclk_div4));
   BUFG tx_lclk90_bufg_i    (.I(tx_lclk90_i),    .O(tx_lclk90));

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
       .CLKOUT3_DIVIDE(128),
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
        .CLKOUT3(),
        .CLKOUT4(rx_lclk_i),
        .CLKOUT5(rx_lclk_div4_i),
	.PWRDWN(1'b0),
        .RST(pll_reset),
        .CLKFBIN(lclk_fb_in),//lclk_fb_in
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
   
   //Rx clock buffers
   BUFG rx_lclk_bufg_i(.I(rx_lclk_i), .O(rx_lclk));                 //goes to erx_io
   BUFG rx_lclk_div4_bufg_i(.I(rx_lclk_div4_i), .O(rx_lclk_div4));  //goes to erx_io

    
   //Feedback buffers
   BUFG lclk_fb_bufg_i0(.I(rx_lclk), .O(lclk_fb_in)); //.I(lclk_fb_in),
   
 //###########################
   // CCLK
   //###########################

   //CCLK differential buffer
   OBUFDS  cclk_obuf (.O   (e_cclk_p),
		      .OB  (e_cclk_n),
		      .I   (cclk_oddr)
		      );

   //CCLK oddr 
   ODDR #(.DDR_CLK_EDGE  ("SAME_EDGE"),
	  .SRTYPE("ASYNC"))
   oddr_lclk (
              .Q  (cclk_oddr),
              .C  (cclk_bufio),
              .CE (1'b1),
              .D1 (1'b1),
              .D2 (1'b0),
              .R  (1'b0),
              .S  (1'b0));

   //CCLK bufio
   BUFIO bufio_cclk(.O(cclk_bufio), .I(cclk_i));
   
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
