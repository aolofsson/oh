//#############################################################################
//# Function: Carry Save Adder (4:2)                                          #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_csa42
  #(parameter N    = 1,        // number of sync stages
    parameter SYN  = "TRUE",   // synthesizable (or not)
    parameter TYPE = "DEFAULT" // scell type/size
    )
   ( input [N-1:0]  in0,  // input
     input [N-1:0]  in1,  // input
     input [N-1:0]  in2,  // input
     input [N-1:0]  in3,  // input
     input 	    cin,  // intra stage carry in
     output 	    cout, // intra stage carry out (2x sum)
     output [N-1:0] s,    // sum
     output [N-1:0] c     // carry (=2x sum)
     );

   generate
      if(SYN == "TRUE") begin

	 wire [N-1:0]     sum_int;
	 wire [N:0] 	  carry_int;

	 //Edges
	 assign carry_int[0] = cin;
	 assign cout         = carry_int[N];

	 //Full Adders
	 oh_csa32 #(.N(N))
	 fa0 (//inputs
	      .in0(in0[N-1:0]),
	      .in1(in1[N-1:0]),
	      .in2(in2[N-1:0]),
	      //outputs
	      .c(carry_int[N:1]),
	      .s(sum_int[N-1:0]));

	 oh_csa32 #(.N(N))
	 fa1 (//inputs
	      .in0(in3[N-1:0]),
	      .in1(sum_int[N-1:0]),
	      .in2(carry_int[N-1:0]),
	      //outputs
	      .c(c[N-1:0]),
	      .s(s[N-1:0]));
      end
      else begin

	 wire [N-1:0] carry_out;
	 wire [N-1:0] carry_in;

	 assign carry_in[N-1:0] = {carry_out[N-1:1],cin};

	 for (i=1;i<N;i=i+1) begin
	    asic_csa42 #(.TYPE(TYPE))
	    asic_csa42(// Outputs
		       .cout	(carry_out[i]),
		       .s	(s[i]),
		       .c	(c[i]),
		       // Inputs
		       .in0	(in0[i]),
		       .in1	(in1[i]),
		       .in2	(in2[i]),
		       .in3	(in3[i]),
		       .cin	({carry_in[i]}));
	 end

	 assign cout = carry[N-1];

      end
   endgenerate
endmodule // oh_csa42
