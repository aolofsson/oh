//#############################################################################
//# Function: Rising Edge Sampled Register                                    #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_reg1
  #(parameter N    = 1,        // vector width
    parameter SYN  = "TRUE",   // synthesizable (or not)
    parameter TYPE = "DEFAULT" // scell type/size
    )
   ( input          nreset, //async active low reset
     input 	    clk,    // clk
     input 	    en,     // write enable
     input [N-1:0]  in,     // input data
     output [N-1:0] out     // output data (stable/latched when clk=1)
     );

   //TODO: Implement all classes of flip-flops
   generate
      if(SYN == "TRUE") begin
	 reg [N-1:0]      out_reg;
	 always @ (posedge clk or negedge nreset)
	   if(!nreset)
	     out_reg[N-1:0] <= 'b0;
	   else if(en)
	     out_reg[N-1:0] <= in[N-1:0];
	 assign out[N-1:0] = out_reg[N-1:0];
      end
      else begin
	 genvar 	     i;
	 for (i=0;i<N;i=i+1) begin
	    asic_reg1 #(.TYPE(TYPE))
	    asic_reg1  (// Outputs
			.out	(out[i]),
			// Inputs
			.nreset	(nreset),
			.clk	(clk),
			.en	(en),
			.in	(in[i]));
	 end
      end
   endgenerate
endmodule
