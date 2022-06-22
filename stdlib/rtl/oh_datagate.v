//#############################################################################
//# Function: Low power data gate                                             #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################
//

module oh_datagate
  #(parameter N    = 2,        // number of sync stages
    parameter SYN  = "TRUE",   // synthesizable (or not)
    parameter TYPE = "DEFAULT" // scell type/size
    )
   (
    input 	   clk, // clock
    input 	   en, // data valid
    input [N-1:0]  in, // data input
    output [N-1:0] out // data output
    );

   generate
      if(SYN == "TRUE") begin

	 reg [N-1:0] 	   enable_pipe;
	 wire 		   enable;

	 always @ (posedge clk)
	   enable_pipe[N-1:0] <= {enable_pipe[N-2:0], en};

	 //Mask to 0 if no valid for last N cycles
	 assign enable = en | (|enable_pipe[N-1:0]);

	 assign out[N-1:0] = {(N){enable}} & in[N-1:0];
      end // if (SYN == "TRUE")
      else begin
	 genvar i;
	 for (i=1;i<N;i=i+1) begin
	    asic_datagate  #(.TYPE(TYPE))
	    asic_datagate (// Outputs
			   .out	(out[N-1:0]),
			   // Inputs
			   .clk	(clk),
			   .en	(en),
			   .in	(in[N-1:0]));

	 end
      end
   endgenerate
endmodule
