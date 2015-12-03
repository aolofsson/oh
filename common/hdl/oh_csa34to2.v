//CSA34:2 Compressor
module oh_csa34to2 (/*AUTOARG*/
   // Outputs
   s, c, cout0, cout1, cout2, cout3, cout4, cout5, cout6, cout7,
   cout8, cout9, cout10, cout11, cout12, cout13, cout14, cout15,
   cout16, cout17, cout18, cout19, cout20, cout21, cout22, cout23,
   cout24, cout25, cout26, cout27, cout28, cout29, cout30,
   // Inputs
   in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12,
   in13, in14, in15, in16, in17, in18, in19, in20, in21, in22, in23,
   in24, in25, in26, in27, in28, in29, in30, in31, in32, in33, cin0,
   cin1, cin2, cin3, cin4, cin5, cin6, cin7, cin8, cin9, cin10, cin11,
   cin12, cin13, cin14, cin15, cin16, cin17, cin18, cin19, cin20,
   cin21, cin22, cin23, cin24, cin25, cin26, cin27, cin28, cin29,
   cin30
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

   input cin0;
   input cin1;
   input cin2;
   input cin3;
   input cin4;
   input cin5;
   input cin6;
   input cin7;
   input cin8;
   input cin9;
   input cin10;
   input cin11;
   input cin12;
   input cin13;
   input cin14;
   input cin15;
   input cin16;
   input cin17;
   input cin18;
   input cin19;
   input cin20;
   input cin21;
   input cin22;
   input cin23;
   input cin24;
   input cin25;
   input cin26;
   input cin27;
   input cin28;
   input cin29;
   input cin30;

   output s;
   output c;
   output cout0;
   output cout1;
   output cout2;
   output cout3;
   output cout4;
   output cout5;
   output cout6;
   output cout7;
   output cout8;
   output cout9;
   output cout10;
   output cout11;
   output cout12;
   output cout13;
   output cout14;
   output cout15;
   output cout16;
   output cout17;
   output cout18;
   output cout19;
   output cout20;
   output cout21;
   output cout22;
   output cout23;
   output cout24;
   output cout25;
   output cout26;
   output cout27;
   output cout28;
   output cout29;
   output cout30;

   wire   s_int0;
   wire   s_int1;
   wire   s_int2;
   wire   s_int3;

   oh_csa92 csa92_00 (.in0(in0),      .in1(in1),      .in2(in2),
		   .in3(in3),      .in4(in4),      .in5(in5),
		   .in6(in6),      .in7(in7),      .in8(in8),
		   .cin0(cin0),  .cin1(cin1),  .cin2(cin2),
		   .cin3(cin3),  .cin4(cin4),  .cin5(cin5),
		   .cout0(cout0),.cout1(cout1),.cout2(cout2),
		   .cout3(cout3),.cout4(cout4),.cout5(cout5),
		   .c(cout21), .s(s_int0));

   oh_csa92 csa92_01 (.in0(in9),      .in1(in10),      .in2(in11),
		   .in3(in12),     .in4(in13),      .in5(in14),
		   .in6(in15),     .in7(in16),      .in8(in17),
		   .cin0(cin6),  .cin1(cin7),   .cin2(cin8),
		   .cin3(cin9),  .cin4(cin10),  .cin5(cin11),
		   .cout0(cout6),.cout1(cout7), .cout2(cout8),
		   .cout3(cout9),.cout4(cout10),.cout5(cout11),
		   .c(cout22), .s(s_int1));

   oh_csa92 csa92_02 (.in0(in18),      .in1(in19),      .in2(in20),
		   .in3(in21),      .in4(in22),      .in5(in23),
		   .in6(in24),      .in7(in25),      .in8(in26),
		   .cin0(cin12),  .cin1(cin13),  .cin2(cin14),
		   .cin3(cin15),  .cin4(cin16),  .cin5(cin17),
		   .cout0(cout12),.cout1(cout13),.cout2(cout14),
		   .cout3(cout15),.cout4(cout16),.cout5(cout17),
		   .c(cout23), .s(s_int2));

   oh_csa62 csa62_03 (.in0(in27),      .in1(in28),      .in2(in29),
                   .in3(in30),      .in4(in31),      .in5(in32),
		   .cin0(cin18),  .cin1(cin19),  .cin2(cin20),
	 	   .cout0(cout18),.cout1(cout19),.cout2(cout20),
		   .c(cout24),.s(s_int3));

   oh_csa92 csa92_10 (.in0(in33),      .in1(s_int0),    .in2(s_int1),
		   .in3(s_int2),    .in4(s_int3),    .in5(cin21),
		   .in6(cin22),    .in7(cin23),    .in8(cin24),
		   .cin0(cin25),  .cin1(cin26),  .cin2(cin27),
		   .cin3(cin28),  .cin4(cin29),  .cin5(cin30),
		   .cout0(cout25),.cout1(cout26),.cout2(cout27),
		   .cout3(cout28),.cout4(cout29),.cout5(cout30),
		   .c(c), .s(s));


endmodule // oh_csa34to2


