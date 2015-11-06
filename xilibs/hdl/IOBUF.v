module IOBUF(/*AUTOARG*/
   // Outputs
   O,
   // Inouts
   IO,
   // Inputs
   T, I
   );

   parameter DRIVE        = 8;
   parameter IOSTANDARD   = "LVDS_25";
   parameter DIFF_TERM    = "TRUE";
   parameter SLEW         = "FAST";
   parameter IBUF_LOW_PWR = "TRUE";
   
   inout IO;
   input T;
   input I;
   output O;

   assign O  = IO;

   assign IO = T ? 1'bz : I;
   
endmodule // IOBUF

   
