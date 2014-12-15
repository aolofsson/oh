module OSERDESE2 ( /*AUTOARG*/
   // Outputs
   OFB, OQ, SHIFTOUT1, SHIFTOUT2, TBYTEOUT, TFB, TQ, D1, D2, D3, D4,
   D5, D6, D7, D8,
   // Inputs
   CLK, CLKDIV, OCE, RST, SHIFTIN1, SHIFTIN2, T1, T2, T3, T4, TBYTEIN,
   TCE
   );

   parameter DATA_RATE_OQ=0;
   parameter DATA_RATE_TQ=0;
   parameter DATA_WIDTH=0;
   parameter INIT_OQ=0;
   parameter INIT_TQ=0;
   parameter SERDES_MODE=0;
   parameter SRVAL_OQ=0;
   parameter SRVAL_TQ=0;
   parameter TBYTE_CTL=0;
   parameter TBYTE_SRC=0;
   parameter TRISTATE_WIDTH=0;

   
   

   output OFB;
   output OQ;
   output SHIFTOUT1;
   output SHIFTOUT2;
   output TBYTEOUT;
   output TFB;
   output TQ;
   input  CLK;
   input  CLKDIV;
   input  D1;
   input  D2;
   input  D3;
   input  D4;   
   input  D5;
   input  D6;
   input  D7;
   input  D8;
   input  OCE;
   input  RST;
   input  SHIFTIN1;
   input  SHIFTIN2;
   input  T1;
   input  T2;
   input  T3;
   input  T4;
   input  TBYTEIN;
   input  TCE;

endmodule // OSERDESE2
