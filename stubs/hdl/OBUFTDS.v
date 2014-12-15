module OBUFTDS (/*AUTOARG*/
   // Outputs
   O, OB,
   // Inputs
   I, T
   );

   parameter IOSTANDARD=0;
   parameter SLEW=0;
   

   input I;
   input T;
   output O;
   output OB;

   assign O  = T ? 1'bz : I;
   assign OB = T ? 1'bz : ~I;
   
   
endmodule // OBUFTDS

