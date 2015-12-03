//CSA4:2 Compressor
module oh_csa42 (/*AUTOARG*/
   // Outputs
   s, c, cout,
   // Inputs
   in0, in1, in2, in3, cin
   );

   input in0;
   input in1;
   input in2;
   input in3;
   input cin;
   
   output s;
   output c;
   output cout;

   wire   s_int;

   assign s     = in0 ^ in1 ^in2 ^in3 ^ cin;
   assign s_int = in1 ^ in2 ^ in3;
   assign c     = (in0 & s_int) | (in0 & cin) | (s_int & cin);
   assign cout  = (in1 & in2)   | (in1 & in3)  | (in2 & in3);

endmodule // oh_csa42


