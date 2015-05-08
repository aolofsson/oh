module MMCME2_ADV # (
  parameter BANDWIDTH = "OPTIMIZED",
  parameter real CLKFBOUT_MULT_F = 5.000,
  parameter real CLKFBOUT_PHASE = 0.000,
  parameter CLKFBOUT_USE_FINE_PS = "FALSE",
  parameter real CLKIN1_PERIOD = 0.000,
  parameter real CLKIN2_PERIOD = 0.000,
  parameter real CLKOUT0_DIVIDE_F = 1.000,
  parameter real CLKOUT0_DUTY_CYCLE = 0.500,
  parameter real CLKOUT0_PHASE = 0.000,
  parameter CLKOUT0_USE_FINE_PS = "FALSE",
  parameter integer CLKOUT1_DIVIDE = 1,
  parameter real CLKOUT1_DUTY_CYCLE = 0.500,
  parameter real CLKOUT1_PHASE = 0.000,
  parameter CLKOUT1_USE_FINE_PS = "FALSE",
  parameter integer CLKOUT2_DIVIDE = 1,
  parameter real CLKOUT2_DUTY_CYCLE = 0.500,
  parameter real CLKOUT2_PHASE = 0.000,
  parameter CLKOUT2_USE_FINE_PS = "FALSE",
  parameter integer CLKOUT3_DIVIDE = 1,
  parameter real CLKOUT3_DUTY_CYCLE = 0.500,
  parameter real CLKOUT3_PHASE = 0.000,
  parameter CLKOUT3_USE_FINE_PS = "FALSE",
  parameter CLKOUT4_CASCADE = "FALSE",
  parameter integer CLKOUT4_DIVIDE = 1,
  parameter real CLKOUT4_DUTY_CYCLE = 0.500,
  parameter real CLKOUT4_PHASE = 0.000,
  parameter CLKOUT4_USE_FINE_PS = "FALSE",
  parameter integer CLKOUT5_DIVIDE = 1,
  parameter real CLKOUT5_DUTY_CYCLE = 0.500,
  parameter real CLKOUT5_PHASE = 0.000,
  parameter CLKOUT5_USE_FINE_PS = "FALSE",
  parameter integer CLKOUT6_DIVIDE = 1,
  parameter real CLKOUT6_DUTY_CYCLE = 0.500,
  parameter real CLKOUT6_PHASE = 0.000,
  parameter CLKOUT6_USE_FINE_PS = "FALSE",
  parameter COMPENSATION = "ZHOLD",
  parameter integer DIVCLK_DIVIDE = 1,
  parameter [0:0] IS_CLKINSEL_INVERTED = 1'b0,
  parameter [0:0] IS_PSEN_INVERTED = 1'b0,
  parameter [0:0] IS_PSINCDEC_INVERTED = 1'b0,
  parameter [0:0] IS_PWRDWN_INVERTED = 1'b0,
  parameter [0:0] IS_RST_INVERTED = 1'b0,
  parameter real REF_JITTER1 = 0.010,
  parameter real REF_JITTER2 = 0.010,
  parameter SS_EN = "FALSE",
  parameter SS_MODE = "CENTER_HIGH",
  parameter integer SS_MOD_PERIOD = 10000,
  parameter STARTUP_WAIT = "FALSE"
)(
  output 	CLKFBOUT,     //feedback clock to connect to CLKFBIN
  output 	CLKFBOUTB,    //inverted feedback clock output
  output 	CLKFBSTOPPED, //indicates that FB clock as stoppped
  output 	CLKINSTOPPED, //indicates that input clock has stopped
  output 	CLKOUT0,      //clock output
  output 	CLKOUT0B,     //inverted clock output
  output 	CLKOUT1,
  output 	CLKOUT1B,
  output 	CLKOUT2,
  output 	CLKOUT2B,
  output 	CLKOUT3,
  output 	CLKOUT3B,
  output 	CLKOUT4,
  output 	CLKOUT5,
  output 	CLKOUT6,
  output [15:0] DO,
  output 	DRDY,
  output 	LOCKED,
  output 	PSDONE,       //phase shift done
  input 	CLKFBIN,
  input 	CLKIN1,
  input 	CLKIN2,
  input 	CLKINSEL,
  input [6:0] 	DADDR,
  input 	DCLK,
  input 	DEN,
  input [15:0] 	DI,
  input 	DWE,
  input 	PSCLK,      //phase shift clock
  input 	PSEN,       //phase shift enable
  input 	PSINCDEC,   //phase shift decrement/increment  
  input 	PWRDWN,     //global power down pin
  input 	RST         //async global reset   
);


   //No mult function, but insert divider

   
   
endmodule // MMCME2_ADV

