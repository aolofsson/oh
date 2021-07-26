//#############################################################################
//# Function: Carry Save Adder (9:2)                                          #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_csa92
  #(parameter N    = 1,        // number of sync stages
    parameter SYN  = "TRUE",   // synthesizable (or not)
    parameter TYPE = "DEFAULT" // scell type/size
    )
   ( input [N-1:0]  in0, //input
     input [N-1:0]  in1,//input
     input [N-1:0]  in2,//input
     input [N-1:0]  in3,//input
     input [N-1:0]  in4,//input
     input [N-1:0]  in5,//input
     input [N-1:0]  in6,//input
     input [N-1:0]  in7,//input
     input [N-1:0]  in8,//input
     input [N-1:0]  cin0,//carry in
     input [N-1:0]  cin1,//carry in
     input [N-1:0]  cin2,//carry in
     input [N-1:0]  cin3,//carry in
     input [N-1:0]  cin4,//carry in
     input [N-1:0]  cin5,//carry in
     output [N-1:0] s, //sum
     output [N-1:0] c, //carry
     output [N-1:0] cout0, //carry out
     output [N-1:0] cout1, //carry out
     output [N-1:0] cout2, //carry out
     output [N-1:0] cout3, //carry out
     output [N-1:0] cout4, //carry out
     output [N-1:0] cout5  //carry out
     );


   wire [N-1:0]     s_int0;
   wire [N-1:0]     s_int1;
   wire [N-1:0]     s_int2;

   oh_csa32 #(.N(N),
	      .TYPE(TYPE),
	      .SYN(SYN))
   csa32_0 (.in0(in0[N-1:0]),
	    .in1(in1[N-1:0]),
	    .in2(in2[N-1:0]),
	    .c(cout0[N-1:0]),
	    .s(s_int0[N-1:0]));

   oh_csa32 #(.N(N),
	      .TYPE(TYPE),
	      .SYN(SYN))
   csa32_1 (.in0(in3[N-1:0]),
	    .in1(in4[N-1:0]),
	    .in2(in5[N-1:0]),
	    .c(cout1[N-1:0]),
	    .s(s_int1[N-1:0]));

   oh_csa32 #(.N(N),
	      .TYPE(TYPE),
	      .SYN(SYN))
   csa32_2 (.in0(in6[N-1:0]),
	    .in1(in7[N-1:0]),
	    .in2(in8[N-1:0]),
	    .c(cout2[N-1:0]),
	    .s(s_int2[N-1:0]));

   oh_csa62 #(.N(N),
	      .TYPE(TYPE),
	      .SYN(SYN))
   csa62 (.in0(s_int0[N-1:0]),
	  .in1(s_int1[N-1:0]),
	  .in2(s_int2[N-1:0]),
	  .in3(cin0[N-1:0]),
	  .in4(cin1[N-1:0]),
	  .in5(cin2[N-1:0]),
	  .cin0(cin3[N-1:0]),
	  .cin1(cin4[N-1:0]),
	  .cin2(cin5[N-1:0]),
	  .cout0(cout3[N-1:0]),
	  .cout1(cout4[N-1:0]),
	  .cout2(cout5[N-1:0]),
	  .c(c[N-1:0]),
	  .s(s[N-1:0]));

endmodule // oh_csa92
