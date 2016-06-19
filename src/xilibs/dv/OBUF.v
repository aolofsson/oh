module OBUF (/*AUTOARG*/
   // Outputs
   O,
   // Inputs
   I
   );

    parameter CAPACITANCE   = "DONT_CARE";
    parameter integer DRIVE = 12;
    parameter IOSTANDARD    = "DEFAULT";
`ifdef XIL_TIMING
    parameter LOC = " UNPLACED";
`endif
    parameter SLEW = "SLOW";
   
   output 	      O;
   input 	      I;
   
   wire 	      GTS = 1'b0;  //Note, uses globals, ugly! 

   bufif0 B1 (O, I, GTS);
    
endmodule






