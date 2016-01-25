module spi_rx(/*AUTOARG*/
   // Outputs
   access, rxdata,
   // Inputs
   nreset, clk, cpol, cpha, sclk, mosi, miso, ss
   );

   //##############################################################
   //#INTERFACE
   //###############################################################
    
   //clk,reset
   input              nreset;       // async active low reset
   input 	      clk;          // core clock

   //config
   input 	      cpol;         // clock polarity (0=base value is 0)
   input 	      cpha;         // clock phase (0=sample on first edge)  

   //IO interface
   input 	      sclk;         // serial clock
   input 	      mosi;         // slave input (from master)
   input 	      miso;         // slave output (to master)
   input 	      ss;           // slave select

   //data received
   output 	      access;       // write fifo   
   output [7:0]       rxdata;       // data for fifo
                                    // (synchronized to clk)
   
   //##############################################################
   //#BODY
   //###############################################################

endmodule // spi_rx




