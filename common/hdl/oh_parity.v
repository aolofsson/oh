module oh_parity (/*AUTOARG*/
   // Outputs
   out,
   // Inputs
   in
   );

   parameter DW = 64;       // width of converter

   input [DW-1:0]  in;      // data input
   output 	   out;     // calculated parity bit

   assign parity = ^data[DW-1:0];
      
endmodule // oh_parity




