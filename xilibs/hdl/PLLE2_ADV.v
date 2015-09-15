module PLLE2_ADV #(
 
  parameter BANDWIDTH = "OPTIMIZED",
  parameter integer CLKFBOUT_MULT = 5,
  parameter real CLKFBOUT_PHASE = 0.000,
  parameter real CLKIN1_PERIOD = 0.000,
  parameter real CLKIN2_PERIOD = 0.000,
  parameter integer CLKOUT0_DIVIDE = 1,
  parameter real CLKOUT0_DUTY_CYCLE = 0.500,
  parameter real CLKOUT0_PHASE = 0.000,
  parameter integer CLKOUT1_DIVIDE = 1,
  parameter real CLKOUT1_DUTY_CYCLE = 0.500,
  parameter real CLKOUT1_PHASE = 0.000,
  parameter integer CLKOUT2_DIVIDE = 1,
  parameter real CLKOUT2_DUTY_CYCLE = 0.500,
  parameter real CLKOUT2_PHASE = 0.000,
  parameter integer CLKOUT3_DIVIDE = 1,
  parameter real CLKOUT3_DUTY_CYCLE = 0.500,
  parameter real CLKOUT3_PHASE = 0.000,
  parameter integer CLKOUT4_DIVIDE = 1,
  parameter real CLKOUT4_DUTY_CYCLE = 0.500,
  parameter real CLKOUT4_PHASE = 0.000,
  parameter integer CLKOUT5_DIVIDE = 1,
  parameter real CLKOUT5_DUTY_CYCLE = 0.500,
  parameter real CLKOUT5_PHASE = 0.000,
  parameter COMPENSATION = "ZHOLD",
  parameter integer DIVCLK_DIVIDE = 1,
  parameter [0:0] IS_CLKINSEL_INVERTED = 1'b0,
  parameter [0:0] IS_PWRDWN_INVERTED = 1'b0,
  parameter [0:0] IS_RST_INVERTED = 1'b0,
  parameter real REF_JITTER1 = 0.010,
  parameter real REF_JITTER2 = 0.010,
  parameter STARTUP_WAIT = "FALSE"
)(
  
  output 	CLKOUT0,
  output 	CLKOUT1,
  output 	CLKOUT2,
  output 	CLKOUT3,
  output 	CLKOUT4,
  output 	CLKOUT5,
  output [15:0] DO,
  output 	DRDY,
  output 	LOCKED,
  output 	CLKFBOUT,
  input 	CLKFBIN,
  input 	CLKIN1,
  input 	CLKIN2,
  input 	CLKINSEL,
  input [6:0] 	DADDR,
  input 	DCLK,
  input 	DEN,
  input [15:0] 	DI,
  input 	DWE,
  input 	PWRDWN,
  input 	RST
);

  //#LOCAL DERIVED PARAMETERS
   localparam real VCO_PERIOD = (CLKIN1_PERIOD * DIVCLK_DIVIDE) / CLKFBOUT_MULT;
   localparam real CLK0_DELAY = VCO_PERIOD * CLKOUT0_DIVIDE * (CLKOUT0_PHASE/360);
   localparam real CLK1_DELAY = VCO_PERIOD * CLKOUT1_DIVIDE * (CLKOUT1_PHASE/360);
   localparam real CLK2_DELAY = VCO_PERIOD * CLKOUT2_DIVIDE * (CLKOUT2_PHASE/360);
   localparam real CLK3_DELAY = VCO_PERIOD * CLKOUT3_DIVIDE * (CLKOUT3_PHASE/360);
   localparam real CLK4_DELAY = VCO_PERIOD * CLKOUT4_DIVIDE * (CLKOUT4_PHASE/360);
   localparam real CLK5_DELAY = VCO_PERIOD * CLKOUT5_DIVIDE * (CLKOUT5_PHASE/360);

   localparam phases = CLKFBOUT_MULT / DIVCLK_DIVIDE;
   
   //########################################################################
   //# CLOCK MULTIPLIER
   //########################################################################

   //TODO: implement  DIVCLK_DIVIDE
   //   
   integer 	j;   
   reg [2*phases-1:0] 	delay;
   always @ (CLKIN1)
     begin	
	for(j=0; j<(2*phases); j=j+1)
	  delay[j] <= #(CLKIN1_PERIOD*j/(2*phases)) CLKIN1;
     end
   
   reg [(phases)-1:0] 	clk_comb;
    always @ (delay)
      begin
	 for(j=0; j<(phases); j=j+1)
	   clk_comb[j] <= delay[2*j] & ~delay[2*j+1];	 
      end
   
   reg vco_clk;   
   integer k;   
   always @*
     begin
	vco_clk = 1'b0;
	for(k=0; k<(phases); k=k+1)
	  vco_clk = vco_clk | clk_comb[k];
     end
 

   //########################################################################
   //# POR
   //########################################################################

   wire 	 reset = POR | RST;
   
   //##############
   //#DIVIDERS
   //##############
   wire [3:0] 	 DIVCFG[5:0]; 
   wire [5:0] 	 CLKOUT_DIV;
      
   assign DIVCFG[0] = $clog2(CLKOUT0_DIVIDE);
   assign DIVCFG[1] = $clog2(CLKOUT1_DIVIDE);
   assign DIVCFG[2] = $clog2(CLKOUT2_DIVIDE);
   assign DIVCFG[3] = $clog2(CLKOUT3_DIVIDE);
   assign DIVCFG[4] = $clog2(CLKOUT4_DIVIDE);
   assign DIVCFG[5] = $clog2(CLKOUT5_DIVIDE);

   //ugly POR reset
   reg 	      POR;
   initial
     begin
	POR=1'b1;
	#1
	POR=1'b0;	
     end

   genvar i;
   generate for(i=0; i<6; i=i+1)
     begin : gen_clkdiv
	clock_divider clkdiv (/*AUTOINST*/
			      // Outputs
			      .clkout		(CLKOUT_DIV[i]),
			      // Inputs
			      .clkin		(vco_clk),
			      .divcfg		(DIVCFG[i]),
			      .reset		(reset));		
     end      
   endgenerate

   //##############
   //#PHASE DELAY
   //##############
   reg CLKOUT0;
   reg CLKOUT1;
   reg CLKOUT2;
   reg CLKOUT3;
   reg CLKOUT4;
   reg CLKOUT5;
   
   always @ (CLKOUT_DIV)
     begin	
	CLKOUT0 <= #(CLK0_DELAY) ~reset & CLKOUT_DIV[0];
	CLKOUT1 <= #(CLK1_DELAY) ~reset & CLKOUT_DIV[1];
	CLKOUT2 <= #(CLK2_DELAY) ~reset & CLKOUT_DIV[2];
	CLKOUT3 <= #(CLK3_DELAY) ~reset & CLKOUT_DIV[3];
	CLKOUT4 <= #(CLK4_DELAY) ~reset & CLKOUT_DIV[4];
	CLKOUT5 <= #(CLK5_DELAY) ~reset & CLKOUT_DIV[5];
     end

   //##############
   //#DUMMY DRIVES
   //##############
   assign CLKFBOUT=CLKIN1;

   //###########################
   //#SANITY CHECK LOCK COUNTER
   //############################
   localparam LCW=4;   
   reg [LCW-1:0] lock_counter;
 
   
   always @ (posedge CLKIN1 or posedge reset)
     if(reset)
       lock_counter[LCW-1:0]  <= {(LCW){1'b1}};
     else if(~LOCKED)
       lock_counter[LCW-1:0] <= lock_counter[LCW-1:0] - 1'b1;

   assign LOCKED = ~(|lock_counter[LCW-1:0]);
      
endmodule // PLLE2_ADV
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:

