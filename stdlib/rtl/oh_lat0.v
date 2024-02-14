//#############################################################################
//# Function: Active Low Latch                                                #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_lat0
  #(parameter N    = 1,        // number of sync stages
    parameter SYN  = "TRUE",   // synthesizable (or not)
    parameter TYPE = "DEFAULT" // scell type/size
    )
   (input 	   clk, // clk
    input [N-1:0]  in,  // input data
    output [N-1:0] out  // output data
     );

   genvar i;

   generate
      if(SYN == "TRUE") begin
	 reg [N-1:0]      out_reg;
	 always @ (clk or in)
	   if (!clk)
	     out_reg[N-1:0] <= in[N-1:0];
	 assign out[N-1:0] = out_reg[N-1:0];
      end
      else begin
	 for (i=0;i<N;i=i+1) begin
	    asic_lat0 #(.TYPE(TYPE))
	    asic_lat0 (.clk(clk),
		       .in(in[i]),
		       .out(out[i]));
	 end
      end
   endgenerate

endmodule // oh_lat0
