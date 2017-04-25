`include "elink_constants.vh"
module erx_clocks (/*AUTOARG*/
   // Outputs
   rx_lclk, rx_lclk_div4, rx_active, erx_nreset, erx_io_nreset,
   // Inputs
   sys_nreset, soft_reset, tx_active, sys_clk, rx_clkin
   );
   
   //Frequency Settings (Mhz)   
   parameter FREQ_RXCLK      = 300;   
   parameter FREQ_IDELAY     = 200;   
   parameter RXCLK_PHASE     = 0;           // 270;
   parameter PLL_VCO_MULT    = 4;           // RX
   parameter TARGET          = `CFG_TARGET; // "XILINX", "ALTERA" etc

   //Override reset counter size for simulation
`ifdef TARGET_SIM
   parameter RCW                 = 4;       // reset counter width
`else
   parameter RCW                 = 8;       // reset counter width
`endif

   //Don't touch these! (derived parameters)
   localparam real    RXCLK_PERIOD  = 1000.000000 / FREQ_RXCLK; //? Why is the period needed here?
   localparam integer IREF_DIVIDE   = PLL_VCO_MULT * FREQ_RXCLK / FREQ_IDELAY;
   localparam integer RXCLK_DIVIDE  = PLL_VCO_MULT; //1:1
      
   //Input clock, reset, config interface
   input      sys_nreset;        // active low system reset (hw)
   input      soft_reset;        // rx enable signal (sw)
   input      tx_active;         // tx active input
   
   
   //Main input clocks
   input      sys_clk;            // always on input clk cclk/TX MMCM
   input      rx_clkin;           // input clk for RX only PLL
   
   //RX Clocks
   output     rx_lclk;           // rx high speed clock for DDR IO
   output     rx_lclk_div4;      // rx slow clock for logic

   //Reset
   output     rx_active;          // rx active
   output     erx_nreset;         // reset for rx core logic
   output     erx_io_nreset;      // io reset (synced to high speed clock)
       
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
   wire       rx_lclk_fb;
   wire       rx_nreset_in;
   
   //###########################
   // RESET STATE MACHINE
   //###########################
  
   reg [RCW:0] reset_counter = 'b0; //works b/c of free running counter!
   reg 	       heartbeat;   
   wire        pll_locked_sync;     
   reg [2:0]   reset_state;
   wire        pll_reset;
   reg 	       rx_nreset;
   wire        pll_locked;
   
   //Reset 
   assign rx_nreset_in  =  sys_nreset & tx_active;   
   
   //wrap around counter that generates a 1 cycle heartbeat       
   always @ (posedge sys_clk)
     begin
	reset_counter[RCW-1:0] <= reset_counter[RCW-1:0]+1'b1;
	heartbeat              <= ~(|reset_counter[RCW-1:0]);
     end
     
`define RX_RESET_ALL        3'b000
`define RX_START_PLL        3'b001
`define RX_ACTIVE           3'b010

   //Reset sequence state machine

   always @ (posedge sys_clk or negedge rx_nreset_in)
     if(!rx_nreset_in)
       reset_state[2:0]        <= `RX_RESET_ALL;   
     else if(heartbeat)
       case(reset_state[2:0])
	 `RX_RESET_ALL :
	   if(~soft_reset)
	     reset_state[2:0]  <= `RX_START_PLL;	 
	 `RX_START_PLL :
	   if(pll_locked_sync & idelay_ready)
	     reset_state[2:0]  <= `RX_ACTIVE; 
	 `RX_ACTIVE:
	   if(soft_reset)
	     reset_state[2:0]  <= `RX_RESET_ALL; //stay there until next reset
       endcase // case (reset_state[2:0])
   
   assign pll_reset    =  (reset_state[2:0]==`RX_RESET_ALL);   
   assign idelay_reset =  (reset_state[2:0]==`RX_RESET_ALL);

   
   //Reset for RX (pipeline to improve timing)
   always @ (posedge sys_clk)
     rx_nreset <= ~(reset_state[2:0] != `RX_ACTIVE);
   
   //active indicator
   assign rx_active   =  (reset_state[2:0] == `RX_ACTIVE);
   
   //#############################
   //#RESET SYNCING
   //#############################
   oh_rsync rsync_io (// Outputs
		      .nrst_out		(erx_io_nreset),
		      // Inputs
		      .clk		(rx_lclk),
		      .nrst_in		(rx_nreset)
		      );
   
   oh_rsync rsync_core (// Outputs
			.nrst_out	(erx_nreset),
			// Inputs
			.clk		(rx_lclk_div4),
			.nrst_in	(rx_nreset)
			);

   generate
      if(TARGET=="XILINX")
	begin
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
	       .CLKOUT4_PHASE(0.0),//RXCLK_PHASE
	       .CLKOUT5_PHASE(0.0),//RXCLK_PHASE/4
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
		.CLKFBIN(rx_lclk_fb),    
		.CLKFBOUT(rx_lclk_fb),       
		.CLKIN1(rx_clkin),
		.CLKIN2(1'b0),
		.CLKINSEL(1'b1),      
		.DADDR(7'b0),
		.DCLK(1'b0),
		.DEN(1'b0),
		.DI(16'b0),
		.DWE(1'b0),
		.DRDY(),//??
		.DO(), //??
		.LOCKED(pll_locked)
		);
	   
	   //Clock network
	   BUFG i_lclk_bufg      (.I(rx_lclk_pll),      .O(rx_lclk));       //300Mhz
	   BUFG i_lclk_div4_bufg (.I(rx_lclk_div4_pll), .O(rx_lclk_div4)); //(300Mhz/4)
	   
	   BUFG i_idelay_bufg  (.I(idelay_ref_clk_pll),.O(idelay_ref_clk));//idelay ctrl clock
	   
	   //two clock synchronizer for lock signal
	   oh_dsync dsync (.dout (pll_locked_sync),
			   .clk	 (sys_clk),
			   .nreset (1'b1),
			   .din	 (pll_locked)
			   );
	   
	   //###########################
	   // Idelay controller
	   //###########################
	   
`define IDELAYCTRL_WONT_SYNTHESIZE
`ifdef IDELAYCTRL_WONT_SYNTHESIZE
	  assign idelay_ready = 'b1;
`else
	   (* IODELAY_GROUP = "IDELAY_GROUP" *) // Group name for IDELAYCTRL
	   IDELAYCTRL
	    #(
	      .SIM_DEVICE("ULTRASCALE_PLUS_ES2")
	     ) idelayctrl_inst
	     (
	      .RDY(idelay_ready), // check ready flag in reset sequence?
	      .REFCLK(idelay_ref_clk),//200MHz clk (78ps tap delay)
	      .RST(idelay_reset)
	      );
`endif
	   
	end // if (TARGET=="XILINX")
   endgenerate

endmodule // eclocks
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:

