//CSA34:2 Compressor
module oh_csa34to2 (/*AUTOARG*/
   // Outputs
   s, c, c_out0, c_out1, c_out2, c_out3, c_out4, c_out5, c_out6,
   c_out7, c_out8, c_out9, c_out10, c_out11, c_out12, c_out13,
   c_out14, c_out15, c_out16, c_out17, c_out18, c_out19, c_out20,
   c_out21, c_out22, c_out23, c_out24, c_out25, c_out26, c_out27,
   c_out28, c_out29, c_out30,
   // Inputs
   in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12,
   in13, in14, in15, in16, in17, in18, in19, in20, in21, in22, in23,
   in24, in25, in26, in27, in28, in29, in30, in31, in32, in33, c_in0,
   c_in1, c_in2, c_in3, c_in4, c_in5, c_in6, c_in7, c_in8, c_in9,
   c_in10, c_in11, c_in12, c_in13, c_in14, c_in15, c_in16, c_in17,
   c_in18, c_in19, c_in20, c_in21, c_in22, c_in23, c_in24, c_in25,
   c_in26, c_in27, c_in28, c_in29, c_in30
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
   input in9;
   input in10;
   input in11;
   input in12;
   input in13;
   input in14;
   input in15;
   input in16;
   input in17;
   input in18;
   input in19;
   input in20;
   input in21;
   input in22;
   input in23;
   input in24;
   input in25;
   input in26;
   input in27;
   input in28;
   input in29;
   input in30;
   input in31;
   input in32;
   input in33;

   input c_in0;
   input c_in1;
   input c_in2;
   input c_in3;
   input c_in4;
   input c_in5;
   input c_in6;
   input c_in7;
   input c_in8;
   input c_in9;
   input c_in10;
   input c_in11;
   input c_in12;
   input c_in13;
   input c_in14;
   input c_in15;
   input c_in16;
   input c_in17;
   input c_in18;
   input c_in19;
   input c_in20;
   input c_in21;
   input c_in22;
   input c_in23;
   input c_in24;
   input c_in25;
   input c_in26;
   input c_in27;
   input c_in28;
   input c_in29;
   input c_in30;

   output s;
   output c;
   output c_out0;
   output c_out1;
   output c_out2;
   output c_out3;
   output c_out4;
   output c_out5;
   output c_out6;
   output c_out7;
   output c_out8;
   output c_out9;
   output c_out10;
   output c_out11;
   output c_out12;
   output c_out13;
   output c_out14;
   output c_out15;
   output c_out16;
   output c_out17;
   output c_out18;
   output c_out19;
   output c_out20;
   output c_out21;
   output c_out22;
   output c_out23;
   output c_out24;
   output c_out25;
   output c_out26;
   output c_out27;
   output c_out28;
   output c_out29;
   output c_out30;

   wire   s_int0;
   wire   s_int1;
   wire   s_int2;
   wire   s_int3;

   oh_csa92 csa92_00 (.in0(in0),      .in1(in1),      .in2(in2),
		   .in3(in3),      .in4(in4),      .in5(in5),
		   .in6(in6),      .in7(in7),      .in8(in8),
		   .c_in0(c_in0),  .c_in1(c_in1),  .c_in2(c_in2),
		   .c_in3(c_in3),  .c_in4(c_in4),  .c_in5(c_in5),
		   .c_out0(c_out0),.c_out1(c_out1),.c_out2(c_out2),
		   .c_out3(c_out3),.c_out4(c_out4),.c_out5(c_out5),
		   .c(c_out21), .s(s_int0));

   oh_csa92 csa92_01 (.in0(in9),      .in1(in10),      .in2(in11),
		   .in3(in12),     .in4(in13),      .in5(in14),
		   .in6(in15),     .in7(in16),      .in8(in17),
		   .c_in0(c_in6),  .c_in1(c_in7),   .c_in2(c_in8),
		   .c_in3(c_in9),  .c_in4(c_in10),  .c_in5(c_in11),
		   .c_out0(c_out6),.c_out1(c_out7), .c_out2(c_out8),
		   .c_out3(c_out9),.c_out4(c_out10),.c_out5(c_out11),
		   .c(c_out22), .s(s_int1));

   oh_csa92 csa92_02 (.in0(in18),      .in1(in19),      .in2(in20),
		   .in3(in21),      .in4(in22),      .in5(in23),
		   .in6(in24),      .in7(in25),      .in8(in26),
		   .c_in0(c_in12),  .c_in1(c_in13),  .c_in2(c_in14),
		   .c_in3(c_in15),  .c_in4(c_in16),  .c_in5(c_in17),
		   .c_out0(c_out12),.c_out1(c_out13),.c_out2(c_out14),
		   .c_out3(c_out15),.c_out4(c_out16),.c_out5(c_out17),
		   .c(c_out23), .s(s_int2));

   oh_csa62 csa62_03 (.in0(in27),      .in1(in28),      .in2(in29),
                   .in3(in30),      .in4(in31),      .in5(in32),
		   .c_in0(c_in18),  .c_in1(c_in19),  .c_in2(c_in20),
	 	   .c_out0(c_out18),.c_out1(c_out19),.c_out2(c_out20),
		   .c(c_out24),.s(s_int3));

   oh_csa92 csa92_10 (.in0(in33),      .in1(s_int0),    .in2(s_int1),
		   .in3(s_int2),    .in4(s_int3),    .in5(c_in21),
		   .in6(c_in22),    .in7(c_in23),    .in8(c_in24),
		   .c_in0(c_in25),  .c_in1(c_in26),  .c_in2(c_in27),
		   .c_in3(c_in28),  .c_in4(c_in29),  .c_in5(c_in30),
		   .c_out0(c_out25),.c_out1(c_out26),.c_out2(c_out27),
		   .c_out3(c_out28),.c_out4(c_out29),.c_out5(c_out30),
		   .c(c), .s(s));


endmodule // oh_csa34to2


