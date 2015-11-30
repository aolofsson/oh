//CSA4:2 Compressor
module oh_csa42 (/*AUTOARG*/
   // Outputs
   s, c, c_out,
   // Inputs
   in0, in1, in2, in3, c_in
   );

   input in0;
   input in1;
   input in2;
   input in3;
   input c_in;
   
   output s;
   output c;
   output c_out;

   wire   s_int;

   assign s     = in0 ^ in1 ^in2 ^in3 ^ c_in;
   assign s_int = in1 ^ in2 ^ in3;
   assign c     = (in0 & s_int) | (in0 & c_in) | (s_int & c_in);
   assign c_out = (in1 & in2)   | (in1 & in3)  | (in2 & in3);

endmodule // oh_csa42


