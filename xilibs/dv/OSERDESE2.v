/*WARNING: INCOMPLETE MODEL, DON'T USE. I RECOMMEND AGAINST USING THIS
 *BLOCK ALL TOGETHER. NOT OPEN SOURCE FRIENDLY /AO
 */

module OSERDESE2 ( /*AUTOARG*/
   // Outputs
   OFB, OQ, SHIFTOUT1, SHIFTOUT2, TBYTEOUT, TFB, TQ,
   // Inputs
   CLK, CLKDIV, D1, D2, D3, D4, D5, D6, D7, D8, OCE, RST, SHIFTIN1,
   SHIFTIN2, T1, T2, T3, T4, TBYTEIN, TCE
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

     
   output OFB;                    // output feedback port
   output OQ;                     // data output port, D1 appears first
   output SHIFTOUT1;              // connect to shift in of master
   output SHIFTOUT2;              // connect to shift in of master
   output TBYTEOUT;               // byte group tristate output to IOB
   output TFB;                    // 3-state control output for ODELAYE2
   output TQ;                     // 3-state control output
   input  CLK;                    // high speed shift out clock
   input  CLKDIV;                 // low speed clock (/4 for example)
   input  D1;                     // first bit to shift out
   input  D2;                     //
   input  D3;                     //
   input  D4;                     //
   input  D5;                     //
   input  D6;                     //
   input  D7;                     //
   input  D8;                     //
   input  OCE;                    // active high clock enable for datapath
   input  RST;                    // async reset, all output flops driven low
   input  SHIFTIN1;               // connect to shift out of other
   input  SHIFTIN2;               // connect to shift out of other
   input  T1;                     // parallel 3-state signals
   input  T2;                     // ??why 4??
   input  T3;                     //
   input  T4;                     //
   input  TBYTEIN;                // byte group tristate input
   input  TCE;                    // active high clock enable for 3-state

   //Statemachine
   reg [2:0] state;


   reg [7:0] buffer;
   reg [1:0] clkdiv_sample;
   reg [3:0] even;
   reg [3:0] odd;
   
   //parallel sample
   always @ (posedge CLKDIV)
     buffer[7:0]<={D8,D7,D6,D5,D4,D3,D2,D1};
   
   //sample clkdiv
   always @ (negedge CLK)
     clkdiv_sample[1:0] <= {clkdiv_sample[0],CLKDIV};

   //shift on second consective clk rising edge that clkdi_sample==0

   wire      load_parallel = (clkdiv_sample[1:0]==2'b00);

   always @ (posedge CLK)
     if(load_parallel)
       even[3:0]<={buffer[6],buffer[4],buffer[2],buffer[0]};
     else
       even[3:0]<={1'b0,even[3:1]};

   always @ (posedge CLK)
     if(load_parallel)
       odd[3:0]<={buffer[7],buffer[5],buffer[3],buffer[1]};
     else
       odd[3:0]<={1'b0,odd[3:1]};
     
   assign OQ = CLK ? even[0] : odd[0];
   
   //setting other outputs
   assign OFB       = 1'b0;
   assign TQ        = 1'b0;
   assign TBYTEOUT  = 1'b0;
   assign SHIFTOUT1 = 1'b0;   		      
   assign SHIFTOUT2 = 1'b0;   
   assign TFB       = 1'b0;
   
endmodule // OSERDESE2

