/CSA3:2 Compressor
module oh_csa32 (/*AUTOARG*/
   // Outputs
   c, s,
   // Inputs
   in0, in1, in2
   );

   input in0;
   input in1;
   input in2;

   output c;
   output s;

   assign s = in0 ^ in1 ^ in2;
   assign c = (in0 & in1) | ( in1 & in2) | ( in2 & in0 );

endmodule // oh_csa32


