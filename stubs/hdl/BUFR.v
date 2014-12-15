module BUFR (/*AUTOARG*/
   // Outputs
   O,
   // Inputs
   I, CE, CLR
   );

   parameter BUFR_DIVIDE=0;
   parameter SIM_DEVICE=0;

   input I;
   input CE;
   input CLR;
   output O;

   assign O=I & CE & ~CLR;
   
endmodule // IBUFDS
