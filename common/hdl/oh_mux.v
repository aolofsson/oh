//#############################################################################
//# Function: One hot N:1 MUX                                                 #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_mux
  #(parameter N   = 32,        // vector width
    parameter M   = 2,         // number of vectors
    parameter SYN  = "TRUE",    // synthesizable (or not)
    parameter TYPE = "DEFAULT"  // implementation type
    )
   (
    input [M-1:0]   sel, // select vector
    input [M*N-1:0] in,  // concatenated input {..,in1[N-1:0],in0[N-1:0]
    output [N-1:0]  out  // output
    );

   generate
      if(SYN == "TRUE") begin
	 reg [N-1:0]     mux;
	 integer 	 i;
	 always @*
	   begin
	      mux[N-1:0] = 'b0;
	      for(i=0;i<M;i=i+1)
		mux[N-1:0] = mux[N-1:0] | {(N){sel[i]}} & in[((i+1)*N-1)-:N];
	   end
	 assign out[N-1:0] = mux[N-1];
      end
      else begin
	 //TODO: implement
	 asic_mux #(.TYPE(TYPE),
		    .N(N))
	 asic_mux(.out	(out),
		  .sel  (sel[N-1:0]),
		  .in	(in[N-1:0]));
      end
   endgenerate
endmodule
