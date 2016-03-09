module spi_tx(/*AUTOARG*/
   // Outputs
   mo, so,
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
   output 	      mo;           // master output
   output 	      so;           // slave output
   
   //##############################################################
   //#BODY
   //############################################################### 

   
   
endmodule // spi_tx



