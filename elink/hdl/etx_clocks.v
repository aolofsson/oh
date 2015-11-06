`include "elink_constants.v"
module etx_clocks (/*AUTOARG*/
   // Outputs
   tx_lclk, tx_lclk_io, tx_lclk90, tx_lclk_div4, cclk_p, cclk_n,
   etx_reset, etx_io_reset, chip_resetb, tx_active,
   // Inputs
   sys_reset, soft_reset, sys_clk
   );

`ifdef TARGET_SIMPLE
   parameter RCW                 = 4;          // reset counter width
`else
   parameter RCW                 = 8;          // reset counter width
`endif

   //Frequency Settings (Mhz)
   parameter FREQ_SYSCLK     = 100; 
   parameter FREQ_TXCLK      = 300;
   parameter FREQ_CCLK       = 600;  
   parameter TXCLK_PHASE     = 90;   //txclk phase shift

   //Don't touch these! (derived parameters)
   localparam real    SYSCLK_PERIOD = 1000.000000/FREQ_SYSCLK;
   localparam integer TXCLK_DIVIDE  = MMCM_VCO_MULT*FREQ_SYSCLK/FREQ_TXCLK;
   localparam integer CCLK_DIVIDE   = MMCM_VCO_MULT*FREQ_SYSCLK/FREQ_CCLK;
   
   //VCO multiplers
   parameter MMCM_VCO_MULT   = 12;  //TX + CCLK
      
   //Input clock, reset, config interface
   input      sys_reset;         // por reset (hw)
   input      soft_reset;        // rx enable signal (sw)
   
   //Main input clocks
   input      sys_clk;            // always on input clk cclk/TX MMCM
    
   //TX Clocks
   output     tx_lclk;           // tx clock for IO state machine
   output     tx_lclk_io;        // tx clock for DDR IO
   output     tx_lclk90;         // tx output clock shifted by 90 degrees
   output     tx_lclk_div4;      // tx slow clock for logic
     
   //Epiphany "free running" clock
   output     cclk_p, cclk_n;

   //Reset
   output     etx_reset;         // reset for tx core logic
   output     etx_io_reset;      // io reset (synced to high speed clock)
   output     chip_resetb;       // reset fpr Epiphany chip
   output     tx_active;         // enable for rx path (ensures active clock)
   
   //############
   //# WIRES
   //############

   //CCLK
   wire       cclk_reset;
   wire       cclk_mmcm;
   wire       cclk_bufio;
   wire       cclk_oddr;
         
   //TX
   wire       tx_lclk_mmcm;
   wire       tx_lclk90_mmcm;
   wire       tx_lckl_div4_mmcm;

   //MMCM & PLL
   wire       cclk_fb;
   //wire       cclk_fb_out;
   wire       lclk_fb_i;
   wire       pll_reset;
   wire       mmcm_locked;
   reg 	      mmcm_locked_reg;
   reg 	      mmcm_locked_sync;
   wire       lclk_locked;   
   
   //###########################
   // RESET STATE MACHINE
   //###########################
  
   reg [RCW:0] reset_counter = 'b0; //works b/c of free running counter!
   reg 	       heartbeat;   
   reg [2:0]   reset_state;
   reg [1:0]   reset_pipe_lclkb;    
   reg [1:0]   reset_pipe_lclk_div4b;   

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
	mmcm_locked_reg   <= mmcm_locked;
	mmcm_locked_sync  <= mmcm_locked_reg;	
     end
     
`define RESET_ALL        3'b000
`define START_CCLK       3'b001
`define STOP_CCLK        3'b010
`define DEASSERT_RESET   3'b011
`define HOLD_IT          3'b100 //???
`define ACTIVE           3'b101

   //Reset sequence state machine      
   always @ (posedge sys_clk or posedge sys_reset)
     if(sys_reset)
       reset_state[2:0]        <= `RESET_ALL;   
     else if(heartbeat)
       case(reset_state[2:0])
	 `RESET_ALL :
	   if(~soft_reset)
	     reset_state[2:0]  <= `START_CCLK;	 
	 `START_CCLK :
	   if(mmcm_locked_sync)
	     reset_state[2:0]  <= `STOP_CCLK; 
	 `STOP_CCLK :
	   reset_state[2:0]    <= `DEASSERT_RESET;
	 `DEASSERT_RESET :
	   reset_state[2:0]    <= `HOLD_IT;
	 `HOLD_IT :
	   if(mmcm_locked_sync)
	     reset_state[2:0]  <= `ACTIVE;
	 `ACTIVE:
	   if(soft_reset)
	     reset_state[2:0]    <= `RESET_ALL; //stay there until nex reset

       endcase // case (reset_state[2:0])
   
   //reset mmcm (async)
   assign mmcm_reset =  (reset_state[2:0]==`RESET_ALL)      |
			(reset_state[2:0]==`STOP_CCLK)      |  
			(reset_state[2:0]==`DEASSERT_RESET)
			;
   
   //reset chip (active low)
   assign chip_resetb  = (reset_state[2:0]==`DEASSERT_RESET) |
		         (reset_state[2:0]==`HOLD_IT)        |
		         (reset_state[2:0]==`ACTIVE);   
      
   //reset the elink
   wire tx_reset      =  (reset_state[2:0] != `ACTIVE);


   assign tx_active   =  (reset_state[2:0] == `ACTIVE);

   //#############################
   //#RESET SYNC
   //#############################
   //async assert
   //sync deassert
   
   //lclk sync
   always @ (posedge tx_lclk or posedge tx_reset)
     if(tx_reset)
       reset_pipe_lclkb[1:0] <= 2'b00;
     else
       reset_pipe_lclkb[1:0]  <= {reset_pipe_lclkb[0], 1'b1};   

   assign etx_io_reset = ~reset_pipe_lclkb[1];

   //lclkdiv4 sync
   always @ (posedge tx_lclk_div4 or posedge tx_reset)
      if(tx_reset)
	reset_pipe_lclk_div4b[1:0] <= 2'b00;
      else
	reset_pipe_lclk_div4b[1:0]  <= {reset_pipe_lclk_div4b[0],1'b1};   

   assign etx_reset  = ~reset_pipe_lclk_div4b[1];
   			     
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
       .CLKOUT4_DIVIDE(128),             //N/A
       .CLKOUT5_DIVIDE(128),             //N/A
       .CLKOUT6_DIVIDE(128),             //N/A
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
        .CLKOUT0(cclk_mmcm),
	.CLKOUT0B(),
        .CLKOUT1(tx_lclk_io),
	.CLKOUT1B(),
        .CLKOUT2(tx_lclk90),
	.CLKOUT2B(),
        .CLKOUT3(tx_lclk_div4_mmcm),
	.CLKOUT3B(),
        .CLKOUT4(),
        .CLKOUT5(),
	.CLKOUT6(),
	.PWRDWN(1'b0),
        .RST(mmcm_reset),     //reset
        .CLKFBIN(cclk_fb),
        .CLKFBOUT(cclk_fb),  //feedback clock     
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
	.LOCKED(mmcm_locked), //locked indicator
	.PSCLK(1'b0),
	.PSEN(1'b0),
	.PSDONE(),
	.PSINCDEC(1'b0),
	.CLKFBSTOPPED(),
	.CLKINSTOPPED()
        );
        

   //Tx clock buffers
   BUFG i_lclk_bufg_i      (.I(tx_lclk_io),        .O(tx_lclk));     //300MHz
   BUFG i_lclk_div4_bufg_i (.I(tx_lclk_div4_mmcm), .O(tx_lclk_div4));//75MHz
//   BUFG i_fb_buf           (.I(cclk_fb_out), .O(cclk_fb_in));      //FB

   //###########################
   // CCLK
   //###########################

   //CCLK bufio
   BUFIO bufio_cclk(.O(cclk_bufio), .I(cclk_mmcm));

   //CCLK oddr 
   ODDR #(.DDR_CLK_EDGE  ("SAME_EDGE"), .SRTYPE("ASYNC"))
   oddr_lclk (
              .Q  (cclk_oddr),
              .C  (cclk_bufio),
              .CE (1'b1),
              .D1 (1'b1),
              .D2 (1'b0),
              .R  (1'b0),
              .S  (1'b0));
	    
   //CCLK differential buffer
   OBUFDS  cclk_obuf (.O   (cclk_p),
                      .OB  (cclk_n),
                      .I   (cclk_oddr)
                      );
`else // !`ifdef TARGET_XILINX
   assign cclk_p       = sys_clk;
   assign cclk_n       = sys_clk;
   assign tx_lclk      = sys_clk;
   assign tx_lclk_div4 = sys_clk;
   assign tx_lclk90    = sys_clk;

`endif //  `ifdef TARGET_XILINX

endmodule // eclocks
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:

