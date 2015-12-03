//CSA9:2 Compressor
module oh_csa92 (/*AUTOARG*/
   // Outputs
   s, c, cout0, cout1, cout2, cout3, cout4, cout5,
   // Inputs
   in0, in1, in2, in3, in4, in5, in6, in7, in8, cin0, cin1, cin2,
   cin3, cin4, cin5
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

   input cin0;
   input cin1;
   input cin2;
   input cin3;
   input cin4;
   input cin5;

   output s;
   output c;
   output cout0;
   output cout1;
   output cout2;
   output cout3;
   output cout4;
   output cout5;

   wire   s_int0;
   wire   s_int1;
   wire   s_int2;

   oh_csa32 csa32_0 (.in0(in0),.in1(in1),.in2(in2),.c(cout0),.s(s_int0));
   oh_csa32 csa32_1 (.in0(in3),.in1(in4),.in2(in5),.c(cout1),.s(s_int1));
   oh_csa32 csa32_2 (.in0(in6),.in1(in7),.in2(in8),.c(cout2),.s(s_int2));

   oh_csa62 csa62 (.in0(s_int0),   .in1(s_int1),   .in2(s_int2),
                   .in3(cin0),    .in4(cin1),    .in5(cin2),
		   .cin0(cin3),  .cin1(cin4),  .cin2(cin5),
		   .cout0(cout3),.cout1(cout4),.cout2(cout5),
		   .c(c),.s(s));

endmodule // oh_csa92

