//#############################################################################
//# Function: Carry Save Adder (3:2)                                          #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_csa32
  #(parameter N    = 1,        // vector width
    parameter SYN  = "TRUE",   // synthesizable (or not)
    parameter TYPE = "DEFAULT" // scell type/size
    )
   ( input [N-1:0]  in0, // input
     input [N-1:0]  in1, // input
     input [N-1:0]  in2, // input
     output [N-1:0] s,   // sum
     output [N-1:0] c    // carry
     );

   generate
      if(SYN == "TRUE") begin
	 assign s[N-1:0] = in0[N-1:0] ^ in1[N-1:0] ^ in2[N-1:0];

	 assign c[N-1:0] = (in0[N-1:0] & in1[N-1:0]) |
			   (in1[N-1:0] & in2[N-1:0]) |
			   (in2[N-1:0] & in0[N-1:0] );
      end
      else begin
	 genvar 	     i;
	 for (i=0;i<N;i=i+1) begin
	    asic_csa32 #(.TYPE(TYPE))
	    asic_csa32  (.s(s[i]),
			 .c(c[i]),
			 .in2(in2[i]),
			 .in1(in1[i]),
			 .in0(in0[i]));
	 end
      end
   endgenerate
endmodule
