module ISERDESE2 (/*AUTOARG*/
   // Outputs
   O, QQ, SHIFTOUT1, SHIFTOUT2, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8,
   // Inputs
   BITSLIP, CE1, CE2, CLKDIVP, CLK, CLKB, CLKDIV, OCLK, OCLKB,
   DYNCLKDIVSEL, DYNCLKSEL, D, DDLY, OFB, RST, SHIFTIN1, SHIFTIN2
   );

   parameter DATA_RATE=0;
   parameter DATA_WIDTH=0;
   parameter DYN_CLK_INV_EN=0;
   parameter DYN_CLKDIV_INV_EN=0;
   parameter INIT_Q1=0;
   parameter INIT_Q2=0;
   parameter INIT_Q3=0;
   parameter INIT_Q4=0;
   parameter INTERFACE_TYPE=0;
   parameter IOBDELAY=0;   
   parameter NUM_CE=0;  
   parameter OFB_USED=0;  
   parameter SERDES_MODE=0;  
   parameter SRVAL_Q1=0;  
   parameter SRVAL_Q2=0;  
   parameter SRVAL_Q3=0;  
   parameter SRVAL_Q4=0;  
   
   output O;
   output QQ;
   output SHIFTOUT1;
   output SHIFTOUT2;
   output Q1;
   output Q2;
   output Q3;
   output Q4;   
   output Q5;
   output Q6;
   output Q7;
   output Q8;
   input  BITSLIP;
   input  CE1;
   input  CE2;
   input  CLKDIVP;
   input  CLK;
   input  CLKB;   
   input  CLKDIV;
   input  OCLK;
   input  OCLKB;
   input  DYNCLKDIVSEL;
   input  DYNCLKSEL;
   input  D;
   input  DDLY;
   input  OFB;
   input  RST;
   input  SHIFTIN1;
   input  SHIFTIN2;
   	
endmodule // ISERDESE2

