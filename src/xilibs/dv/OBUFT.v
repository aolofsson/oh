
module OBUFT (O, I, T);

   parameter CAPACITANCE   = "DONT_CARE";
   parameter integer DRIVE = 12;
   parameter IOSTANDARD    = "DEFAULT";
   parameter SLEW          = "FAST";
   
   output 	      O;
   input 	      I, T;

   assign O = T ? 1'bz : I;
   
endmodule

