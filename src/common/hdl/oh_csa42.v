//#############################################################################
//# Function: Carry Save Adder (4:2)                                          #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_csa42 #( parameter DW    = 1 // data width
		   )
   ( input [DW-1:0]  in0, //input
     input [DW-1:0]  in1,//input
     input [DW-1:0]  in2,//input
     input [DW-1:0]  in3,//input
     input [DW-1:0]  cin,//carry in
     output [DW-1:0] s, //sum 
     output [DW-1:0] c, //carry
     output [DW-1:0] cout  //carry out
     );

   localparam ASIC = `CFG_ASIC;  // use asic library

   generate
      if(ASIC)	
	begin
	   asic_csa42 i_csa42[DW-1:0] (.s(s[DW-1:0]),
				       .cout(cout[DW-1:0]),
				       .c(c[DW-1:0]),
				       .cin(cin[DW-1:0]),
				       .in3(in3[DW-1:0]),
				       .in2(in2[DW-1:0]),
				       .in1(in1[DW-1:0]),
				       .in0(in0[DW-1:0]));
	end
      else
	begin
	   wire [DW-1:0]     s_int;
	   
	   assign s[DW-1:0]  = in0[DW-1:0] ^ 
			       in1[DW-1:0] ^ 
			       in2[DW-1:0] ^ 
			       in3[DW-1:0] ^ 
			       cin[DW-1:0];
	   
	   assign s_int[DW-1:0] = in1[DW-1:0] ^ 
				  in2[DW-1:0] ^ 
				  in3[DW-1:0];
	   
	   assign c[DW-1:0]     = (in0[DW-1:0] & s_int[DW-1:0]) | 
				  (in0[DW-1:0] & cin[DW-1:0])   | 
				  (s_int[DW-1:0] & cin[DW-1:0]);
	   
	   assign cout[DW-1:0]  = (in1[DW-1:0] & in2[DW-1:0]) | 
				  (in1[DW-1:0] & in3[DW-1:0]) | 
				  (in2[DW-1:0] & in3[DW-1:0]);
	end // else: !if(ASIC)
   endgenerate
   
endmodule // oh_csa42


