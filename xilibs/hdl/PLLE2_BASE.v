module PLLE2_BASE (/*AUTOARG*/
   // Outputs
   LOCKED, CLKOUT0, CLKOUT1, CLKOUT2, CLKOUT3, CLKOUT4, CLKOUT5,
   CLKFBOUT,
   // Inputs
   CLKIN1, RST, PWRDWN, CLKFBIN
   );

   parameter BANDWIDTH = 0;
   parameter CLKFBOUT_MULT = 0;
   parameter CLKFBOUT_PHASE = 0;
   parameter CLKIN1_PERIOD = 0;
   parameter CLKOUT0_DIVIDE = 0;
   parameter CLKOUT0_DUTY_CYCLE = 0;
   parameter CLKOUT0_PHASE = 0;

   parameter CLKOUT1_DIVIDE = 0;
   parameter CLKOUT1_DUTY_CYCLE = 0;
   parameter CLKOUT1_PHASE = 0;

   parameter CLKOUT2_DIVIDE = 0;
   parameter CLKOUT2_DUTY_CYCLE = 0;
   parameter CLKOUT2_PHASE = 0;
   
   parameter CLKOUT3_DIVIDE = 0;
   parameter CLKOUT3_DUTY_CYCLE = 0;
   parameter CLKOUT3_PHASE = 0;

   parameter CLKOUT4_DIVIDE = 0;
   parameter CLKOUT4_DUTY_CYCLE = 0;
   parameter CLKOUT4_PHASE = 0;

   parameter CLKOUT5_DIVIDE = 0;
   parameter CLKOUT5_DUTY_CYCLE = 0;
   parameter CLKOUT5_PHASE = 0;
      
   parameter DIVCLK_DIVIDE = 0;
   parameter REF_JITTER1 = 0;
   parameter STARTUP_WAIT = 0;
   parameter IOSTANDARD = 0;
   

   //inputs
   input CLKIN1;
   input RST;
   input PWRDWN;
   input CLKFBIN;
   
   //outputs
   output LOCKED;
   output CLKOUT0;
   output CLKOUT1;
   output CLKOUT2;
   output CLKOUT3;
   output CLKOUT4;
   output CLKOUT5;
   output CLKFBOUT;


   //Not a correct model
   assign CLKFBOUT=CLKIN1;
   assign LOCKED=1'b0;
   assign CLKOUT0=CLKIN1;
   assign CLKOUT1=CLKIN1;
   assign CLKOUT2=CLKIN1;
   assign CLKOUT3=CLKIN1;
   assign CLKOUT4=CLKIN1;
   assign CLKOUT5=CLKIN1;
   assign CLKFBOUT=CLKIN1;
   
endmodule // PLLE2_BASE
