module oh_shifter (/*AUTOARG*/
   // Outputs
   out, zero,
   // Inputs
   a, b
   );

   //###############################################################
   //# Parameters
   //###############################################################
   parameter DW   = 64;
   parameter TYPE = "LSL"; //shift type
                           //LSL, LSR, or ASR
   //###############################################################
   //# Interface
   //###############################################################

   //inputs
   input [DW-1:0]  a;         //first operand
   input [DW-1:0]  b;         //shift amount

   //outputs
   output [DW-1:0] out;       
   output 	   zero;     //set if all output bits are zero
                             //TODO: catch shift out?
   
endmodule // oh_shifter




