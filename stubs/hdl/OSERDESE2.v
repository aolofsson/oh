

/*


An OSERDESE2 is a device with an input register running on the rising edge of the CLKDIV
clock and a loadable parallel-to-serial register running on the rising edges of the CLK clock. An
internal state machine with the DATA_WIDTH parameter as set point makes sure the data from
the parallel input register is transferred at the right moment into the parallel-to-serial register.

An internal state machine controls the connection between the two registers. The state
machine bounds CLK, CLKDIV, and the DATA_WITDH attribute to make sure data is always
transferred from the parallel input register into the parallel-to-serial register at the correct
moment.

  The parallel input register has no enable (OCE) or reset (RST). This means that as soon
as a rising CLKDIV edge is applied, any data available on the input pins of the
OSERDESE2 is loaded into the register.

  To prevent the OSERDESE2 from starting to generate unknown data immediately after
release of the reset, keep the enable input deasserted for a number of CLKDIV clock
cycles by using a LUT as programmable shift register (SRL32). The amount of clock
cycles the enable input is held deasserted after releasing the reset is now programmable
via the address input of the SRL32.

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
   output SHIFTOUT1;              // connect to shift in of master, example?
   output SHIFTOUT2;              // connect to shift in of master, example?
   output TBYTEOUT;               // byte group tristate output to IOB
   output TFB;                    // 3-state control output for ODELAYE2
   output TQ;                     // 3-state control output
   input  CLK;                    // high speed clock
   input  CLKDIV;                 // low speed clock (/8 for example)
   input  D1;                     // 
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

   always @ (negedge CLK)
     if(load_parallel)
       even[3:0]<={buffer[6],buffer[4],buffer[2],buffer[0]};
     else
       even[3:0]<={1'b0,even[3:1]};

   always @ (negedge CLK)
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

