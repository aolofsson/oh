//#############################################################################
//# Function: Rising Edge Sampled Register                                    #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_reg1 #(parameter DW = 1            // data width
		 ) 
   ( input           nreset, //async active low reset
     input 	     clk, // clk, latch when clk=0
     input [DW-1:0]  in, // input data
     output [DW-1:0] out  // output data (stable/latched when clk=1)
     );

   localparam ASIC = `CFG_ASIC;
   
   generate
      if(ASIC)
	begin : g0
	   asic_reg1 ireg [DW-1:0] (.nreset(nreset),
				    .clk(clk),
				    .in(in[DW-1:0]),
				    .out(out[DW-1:0]));
	end
      else
	begin
	   reg [DW-1:0] out_reg;	   
	   always @ (posedge clk or negedge nreset)
	     if(!nreset)
	       out_reg[DW-1:0] <= 'b0;
	     else	      
	       out_reg[DW-1:0] <= in[DW-1:0];
	   assign out[DW-1:0] = out_reg[DW-1:0];	   
	end // else: !if(ASIC)
   endgenerate
   
endmodule // ohr_reg1





