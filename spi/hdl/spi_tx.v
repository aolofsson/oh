module spi_tx(/*AUTOARG*/
   // Outputs
   sclk, mosi, miso, ss,
   // Inputs
   nreset, clk, access, txdata, cpol, cpha
   );

   //##############################################################
   //#INTERFACE
   //###############################################################

   //clk,reset
   input              nreset;       // async active low reset
   input 	      clk;          // clock input

   //tx
   input              access;       // fifo not empty	      
   input [7:0] 	      txdata;       // data to transmit on 'mosi'

   //config
   input 	      cpol;         // clock polarity (0=base value is 0)
   input 	      cpha;         // clock phase (0=sample on first edge)  
     
   //serial interface to and from IO
   output 	      sclk;         // serial clock
   output 	      mosi;         // master output
   output 	      miso;         // slave output
   output 	      ss;           // slave select
   
   //##############################################################
   //#BODY
   //############################################################### 

   
   
endmodule // spi_tx



