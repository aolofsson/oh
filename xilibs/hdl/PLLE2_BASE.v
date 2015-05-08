module PLLE2_BASE (/*AUTOARG*/
   // Outputs
   LOCKED, CLKOUT0, CLKOUT1, CLKOUT2, CLKOUT3, CLKOUT4, CLKOUT5,
   CLKFBOUT,
   // Inputs
   CLKIN1, RST, PWRDWN, CLKFBIN
   );

   parameter BANDWIDTH          = 0;
   parameter CLKFBOUT_MULT      = 1;
   parameter CLKFBOUT_PHASE     = 0;
   parameter CLKIN1_PERIOD      = 10;
   parameter DIVCLK_DIVIDE      = 1;
   parameter REF_JITTER1        = 0;
   parameter STARTUP_WAIT       = 0;

   parameter CLKOUT0_DIVIDE     = 1;
   parameter CLKOUT0_DUTY_CYCLE = 0.5;
   parameter CLKOUT0_PHASE      = 0;

   parameter CLKOUT1_DIVIDE     = 1;
   parameter CLKOUT1_DUTY_CYCLE = 0.5;
   parameter CLKOUT1_PHASE      = 0;

   parameter CLKOUT2_DIVIDE     = 1;
   parameter CLKOUT2_DUTY_CYCLE = 0.5;
   parameter CLKOUT2_PHASE      = 0;
   
   parameter CLKOUT3_DIVIDE     = 1;
   parameter CLKOUT3_DUTY_CYCLE = 0.5;
   parameter CLKOUT3_PHASE      = 0;

   parameter CLKOUT4_DIVIDE     = 1;   
   parameter CLKOUT4_DUTY_CYCLE = 0.5;
   parameter CLKOUT4_PHASE      = 0;

   parameter CLKOUT5_DIVIDE     = 1;
   parameter CLKOUT5_DUTY_CYCLE = 0.5;
   parameter CLKOUT5_PHASE      = 0;

   //#LOCAL DERIVED PARAMETERS
   parameter VCO_PERIOD = (CLKIN1_PERIOD * DIVCLK_DIVIDE) / CLKFBOUT_MULT;
   parameter CLK0_DELAY = VCO_PERIOD * CLKOUT0_DIVIDE * (CLKOUT0_PHASE/360);
   parameter CLK1_DELAY = VCO_PERIOD * CLKOUT1_DIVIDE * (CLKOUT1_PHASE/360);
   parameter CLK2_DELAY = VCO_PERIOD * CLKOUT2_DIVIDE * (CLKOUT2_PHASE/360);
   parameter CLK3_DELAY = VCO_PERIOD * CLKOUT3_DIVIDE * (CLKOUT3_PHASE/360);
   parameter CLK4_DELAY = VCO_PERIOD * CLKOUT4_DIVIDE * (CLKOUT4_PHASE/360);
   parameter CLK5_DELAY = VCO_PERIOD * CLKOUT5_DIVIDE * (CLKOUT5_PHASE/360);
      
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
  
   //##############
   //#VCO 
   //##############
   reg 	  vco_clk;
   initial
     begin
	vco_clk = 1'b0;	
     end
   
   always
     #(VCO_PERIOD/2) vco_clk = ~vco_clk;

   //##############
   //#DIVIDERS
   //##############
   wire [3:0] DIVCFG[5:0]; 
   wire [5:0] CLKOUT_DIV;
      
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
			      .reset		(RST | POR)
			      );		
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
	CLKOUT0 <= #(CLK0_DELAY) CLKOUT_DIV[0];
	CLKOUT1 <= #(CLK1_DELAY) CLKOUT_DIV[1];
	CLKOUT2 <= #(CLK2_DELAY) CLKOUT_DIV[2];
	CLKOUT3 <= #(CLK3_DELAY) CLKOUT_DIV[3];
	CLKOUT4 <= #(CLK4_DELAY) CLKOUT_DIV[4];
	CLKOUT5 <= #(CLK5_DELAY) CLKOUT_DIV[5];
     end

   //##############
   //#DUMMY DRIVES
   //##############
   assign CLKFBOUT=CLKIN1;
   assign LOCKED=1'b0;
  
   
endmodule // PLLE2_BASE
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:
