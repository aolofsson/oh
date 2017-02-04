`include "elink_constants.vh"
module etx_clocks (/*AUTOARG*/
   // Outputs
   tx_lclk_io, tx_lclk90, tx_lclk_div4, cclk_p, cclk_n, etx_nreset,
   etx_io_nreset, chip_nreset, tx_active,
   // Inputs
   sys_nreset, soft_reset, sys_clk
   );



   //Frequency Settings (Mhz)
   parameter FREQ_SYSCLK     = 100; 
   parameter FREQ_TXCLK      = 300;  
   parameter FREQ_CCLK       = 600;  
   parameter TXCLK_PHASE     = 90;   //txclk phase shift
   parameter TARGET          = `CFG_TARGET; // "XILINX", "ALTERA" etc

   //Override reset counter size for simulation
`ifdef TARGET_SIM
   parameter RCW                 = 4;          // reset counter width
`else
   parameter RCW                 = 8;          // reset counter width
`endif
   
   
   //Don't touch these! (derived parameters)
   parameter          MMCM_VCO_MULT = 12;  //TX + CCLK
   localparam real    SYSCLK_PERIOD = 1000.000000 / FREQ_SYSCLK;
   localparam integer TXCLK_DIVIDE  = MMCM_VCO_MULT * FREQ_SYSCLK / FREQ_TXCLK;
   localparam integer CCLK_DIVIDE   = MMCM_VCO_MULT * FREQ_SYSCLK / FREQ_CCLK;
   
   //Input clock, reset, config interface
   input      sys_nreset;        // por reset (hw)
   input      soft_reset;        // rx enable signal (sw)
   
   //Main input clocks
   input      sys_clk;            // always on input clk cclk/TX MMCM
    
   //TX Clocks
   output     tx_lclk_io;        // tx clock for high speeed IO
   output     tx_lclk90;         // tx output clock shifted by 90 degrees
   output     tx_lclk_div4;      // tx slow clock for logic
     
   //Epiphany "free running" clock
   output     cclk_p, cclk_n;

   //Reset
   output     etx_nreset;        // reset for tx core logic
   output     etx_io_nreset;     // io reset (synced to high speed clock)
   output     chip_nreset;       // reset fpr Epiphany chip
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
   wire       tx_nreset;
   wire       mmcm_reset;
   wire       tx_lclk_div4_mmcm;
   
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
     
`define TX_RESET_ALL        3'b000
`define TX_START_CCLK       3'b001
`define TX_STOP_CCLK        3'b010
`define TX_DEASSERT_RESET   3'b011
`define TX_HOLD_IT          3'b100 //???
`define TX_ACTIVE           3'b101

   //Reset sequence state machine      
   always @ (posedge sys_clk or negedge sys_nreset)
     if(!sys_nreset)
       reset_state[2:0]        <= `TX_RESET_ALL;   
     else if(heartbeat)
       case(reset_state[2:0])
	 `TX_RESET_ALL :
	   if(~soft_reset)
	     reset_state[2:0]  <= `TX_START_CCLK;	 
	 `TX_START_CCLK :
	   if(mmcm_locked_sync)
	     reset_state[2:0]  <= `TX_STOP_CCLK; 
	 `TX_STOP_CCLK :
	   reset_state[2:0]    <= `TX_DEASSERT_RESET;
	 `TX_DEASSERT_RESET :
	   reset_state[2:0]    <= `TX_HOLD_IT;
	 `TX_HOLD_IT :
	   if(mmcm_locked_sync)
	     reset_state[2:0]  <= `TX_ACTIVE;
	 `TX_ACTIVE:
	   if(soft_reset)
	     reset_state[2:0]    <= `TX_RESET_ALL; //stay there until nex reset

       endcase // case (reset_state[2:0])
   
   //reset mmcm (async)
   assign mmcm_reset =  (reset_state[2:0]==`TX_RESET_ALL)      |
			(reset_state[2:0]==`TX_STOP_CCLK)      |  
			(reset_state[2:0]==`TX_DEASSERT_RESET)
			;
   
   //reset chip (active low)
   assign chip_nreset  = (reset_state[2:0]==`TX_DEASSERT_RESET) |
		         (reset_state[2:0]==`TX_HOLD_IT)        |
		         (reset_state[2:0]==`TX_ACTIVE);   
      
   //reset the elink
   assign tx_nreset      =  ~(reset_state[2:0] != `TX_ACTIVE);


   assign tx_active   =  (reset_state[2:0] == `TX_ACTIVE);

   //#############################
   //#RESET SYNCING
   //#############################
   
   oh_rsync rsync_io (// Outputs
		   .nrst_out		(etx_io_nreset),
		   // Inputs
		   .clk			(tx_lclk_io),
		   .nrst_in		(tx_nreset));
   
   oh_rsync rsync_core (// Outputs
		     .nrst_out		(etx_nreset),
		     // Inputs
		     .clk		(tx_lclk_div4),
		     .nrst_in		(tx_nreset));
   

  generate
      if(TARGET=="XILINX")
	begin
   
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
        .CLKOUT1(tx_lclk_mmcm),
	.CLKOUT1B(),
        .CLKOUT2(tx_lclk90_mmcm),//goes directly to IO
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
	.CLKFBOUTB(),        //inverted output feedback clock     
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
   BUFG i_lclk_bufg      (.I(tx_lclk_mmcm),     .O(tx_lclk_io));   //300MHz
   BUFG i_lclk_div4_bufg (.I(tx_lclk_div4_mmcm),.O(tx_lclk_div4)); //75MHz
   BUFG i_lclk90_bufg    (.I(tx_lclk90_mmcm),   .O(tx_lclk90));    //300MHz 90deg clock
//   BUFG i_fb_buf           (.I(cclk_fb_out), .O(cclk_fb_in));    //FB

   //###########################
   // CCLK
   //###########################

   //CCLK bufio
   BUFIO bufio_cclk(.O(cclk_bufio), .I(cclk_mmcm));

   //CCLK oddr 
   ODDRE1
   oddr_lclk (
              .Q  (cclk_oddr),
              .C  (cclk_bufio),
              .D1 (1'b1),
              .D2 (1'b0));
	    
   //CCLK differential buffer
   OBUFDS  cclk_obuf (.O   (cclk_p),
                      .OB  (cclk_n),
                      .I   (cclk_oddr)
                      );

	end // if (TARGET=="XILINX")
      else
	begin
	   assign cclk_p       = sys_clk;
	   assign cclk_n       = sys_clk;
	   assign tx_lclk_io   = sys_clk;
	   assign tx_lclk_div4 = sys_clk;
	   assign tx_lclk90    = sys_clk;
	end
  endgenerate
   
	   
 



endmodule // eclocks
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:

