//#############################################################################
//# Function: Isolation (low) buffer for multi supply domains                 #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT  (see LICENSE file in OH! repository)                       #
//#############################################################################

module oh_isobuflo
  #(parameter N     = 1,        // width of data inputs
    parameter SYN   = "TRUE",   // true=synthesizable
    parameter TYPE  = "DEFAULT" // scell type/size
    )
   (
    input 	   iso,// active low isolation signal
    input [N-1:0]  in, // input signal
    output [N-1:0] out  // out = ~iso & in
    );

   generate
      if(SYN == "TRUE")	begin
	 assign out[N-1:0] = {(N){~iso}} | in[N-1:0];
      end
      else begin
	 genvar 	     i;
	 for (i=0;i<N;i=i+1) begin
	    asic_isobuflo #(.TYPE(TYPE))
	    asic_isobuflo (.iso(iso),
			   .in(in[i]),
			   .out(out[i]));
	 end
      end
   endgenerate

endmodule
