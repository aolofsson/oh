module oh_parity (/*AUTOARG*/
   // Outputs
   parity,
   // Inputs
   data
   );

   parameter DW = 64;         // width of converter

   input [DW-1:0]  data;      // data input
   output 	   parity;    // parity bit

   assign parity = ^data[DW-1:0];
      
endmodule // oh_parity




