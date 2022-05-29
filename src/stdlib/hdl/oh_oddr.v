//#############################################################################
//# Function: Dual data rate output buffer                                    #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_oddr
  #(parameter N    =  1,       // vector width
    parameter SYN  = "TRUE",   // synthesizable (or not)
    parameter TYPE = "DEFAULT" // scell type/size
    )
   (
    input 	   clk, // clock input
    input [N-1:0]  in1, // negedge input
    input [N-1:0]  in2, // posedge input
    output [N-1:0] out  // ddr output
    );

   generate
      if(SYN == "TRUE") begin
	 //regs("sl"=stable low, "sh"=stable high)
	 reg [N-1:0]     in2_sh;

	 always @ (negedge clk)
	   in2_sh[N-1:0] <= in2[N-1:0];

	 assign out[N-1:0] = ~clk ? in1[N-1:0] : in2_sh[N-1:0];
      end
      else begin
	 for (i=0;i<N;i=i+1) begin
	    asic_oddr #(.TYPE(TYPE))
	    asic_oddr(// Outputs
		      .out		(out[N-1:0]),
		      // Inputs
		      .clk		(clk),
		      .in1		(in1[N-1:0]),
		      .in2		(in2[N-1:0]));
	 end
      end // else: !if(SYN == "TRUE")
   endgenerate

endmodule // oh_oddr
