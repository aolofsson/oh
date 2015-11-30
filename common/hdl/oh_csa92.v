//CSA9:2 Compressor
module oh_csa92 (/*AUTOARG*/
   // Outputs
   s, c, c_out0, c_out1, c_out2, c_out3, c_out4, c_out5,
   // Inputs
   in0, in1, in2, in3, in4, in5, in6, in7, in8, c_in0, c_in1, c_in2,
   c_in3, c_in4, c_in5
   );

   input in0;
   input in1;
   input in2;
   input in3;
   input in4;
   input in5;
   input in6;
   input in7;
   input in8;

   input c_in0;
   input c_in1;
   input c_in2;
   input c_in3;
   input c_in4;
   input c_in5;

   output s;
   output c;
   output c_out0;
   output c_out1;
   output c_out2;
   output c_out3;
   output c_out4;
   output c_out5;

   wire   s_int0;
   wire   s_int1;
   wire   s_int2;

   oh_csa32 csa32_0 (.in0(in0),.in1(in1),.in2(in2),.c(c_out0),.s(s_int0));
   oh_csa32 csa32_1 (.in0(in3),.in1(in4),.in2(in5),.c(c_out1),.s(s_int1));
   oh_csa32 csa32_2 (.in0(in6),.in1(in7),.in2(in8),.c(c_out2),.s(s_int2));

   oh_csa62 csa62 (.in0(s_int0),   .in1(s_int1),   .in2(s_int2),
                .in3(c_in0),    .in4(c_in1),    .in5(c_in2),
		.c_in0(c_in3),  .c_in1(c_in4),  .c_in2(c_in5),
		.c_out0(c_out3),.c_out1(c_out4),.c_out2(c_out5),
		.c(c),.s(s));

endmodule // oh_csa92

