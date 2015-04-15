module OBUFTDS (/*AUTOARG*/
   // Outputs
   O, OB,
   // Inputs
   I, T
   );

   parameter IOSTANDARD=0;
   parameter SLEW=0;
   
   input I;    //input
   input T;    //tristate signal
   output O;   //output
   output OB;  //output_bar

   assign O  = T ? 1'bz : I;
   assign OB = T ? 1'bz : ~I;
   
   
endmodule // OBUFTDS

