//#############################################################################
//# Function: Dual data rate input buffer (2 cycle delay)                     #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_iddr
  #(parameter N    = 1,        // vector width
    parameter SYN  = "TRUE",   // synthesizable (or not)
    parameter TYPE = "DEFAULT" // scell type/size
    )
   (
    input 		 clk, // clock
    input 		 en0, // 1st cycle enable
    input 		 en1, // 2nd cycle enable
    input [N-1:0] 	 in, // data input sampled on both edges of clock
    output reg [2*N-1:0] out // iddr aligned
    );

   generate
      if(SYN == "TRUE") begin

	 //regs("sl"=stable low, "sh"=stable high)
	 reg [N-1:0]     in_sl;
	 reg [N-1:0] 	 in_sh;
	 reg 		 en0_negedge;

	 //########################
	 // Pipeline valid for negedge
	 //########################
	 always @ (negedge clk)
	   en0_negedge <= en0;

	 //########################
	 // Dual edge sampling
	 //########################

	 always @ (posedge clk)
	   if(en0)
	     in_sl[N-1:0] <= in[N-1:0];
	 always @ (negedge clk)
	   if(en0_negedge)
	     in_sh[N-1:0] <= in[N-1:0];

	 //########################
	 // Aign pipeline
	 //########################
	 always @ (posedge clk)
	   if(en1)
	     out[2*N-1:0] <= {in_sh[N-1:0],
			      in_sl[N-1:0]};

      end
      else begin
	 for (i=0;i<N;i=i+1) begin
	    asic_iddr #(.TYPE(TYPE))
	    asic_iddr(// Outputs
		      .out	(out[2*N-1:0]),
		      // Inputs
		      .clk	(clk),
		      .en0	(en0),
		      .en1	(en1),
		      .in	(in[N-1:0]));
	 end
      end
   endgenerate

endmodule // oh_iddr
