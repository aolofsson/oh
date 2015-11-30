//CSA6:2 Compressor
module oh_csa62 (/*AUTOARG*/
   // Outputs
   s, c, c_out0, c_out1, c_out2,
   // Inputs
   in0, in1, in2, in3, in4, in5, c_in0, c_in1, c_in2
   );

   input in0;
   input in1;
   input in2;
   input in3;
   input in4;
   input in5;
   input c_in0;
   input c_in1;
   input c_in2;

   output s;
   output c;
   output c_out0;
   output c_out1;
   output c_out2;

   wire   s_int0;
   wire   s_int1;

   oh_csa32 csa32_0 (.in0(in0),.in1(in1),.in2(in2),.c(c_out0),.s(s_int0));
   oh_csa32 csa32_1 (.in0(in3),.in1(in4),.in2(in5),.c(c_out1),.s(s_int1));

   oh_csa42 csa42 (.in0(s_int0),.in1(s_int1),.in2(c_in0),.in3(c_in1),.c_in(c_in2),
                .c_out(c_out2),.c(c),.s(s));

endmodule // oh_csa62

