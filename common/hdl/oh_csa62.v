//CSA6:2 Compressor
module oh_csa62 (/*AUTOARG*/
   // Outputs
   s, c, cout0, cout1, cout2,
   // Inputs
   in0, in1, in2, in3, in4, in5, cin0, cin1, cin2
   );

   input in0;
   input in1;
   input in2;
   input in3;
   input in4;
   input in5;
   input cin0;
   input cin1;
   input cin2;

   output s;
   output c;
   output cout0;
   output cout1;
   output cout2;

   wire   s_int0;
   wire   s_int1;

   oh_csa32 csa32_0 (.in0(in0),.in1(in1),.in2(in2),.c(cout0),.s(s_int0));
   oh_csa32 csa32_1 (.in0(in3),.in1(in4),.in2(in5),.c(cout1),.s(s_int1));

   oh_csa42 csa42 (.in0(s_int0),.in1(s_int1),.in2(cin0),.in3(cin1),.cin(cin2),
                .cout(cout2),.c(c),.s(s));

endmodule // oh_csa62

