//#############################################################################
//# Function: Rising Edge Sampled Register                                    #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_reg1 #(parameter DW = 1            // data width
		 ) 
   ( input           nreset, //async active low reset
     input 	     clk, // clk
     input 	     en, // write enable
     input [DW-1:0]  in, // input data
     output [DW-1:0] out  // output data (stable/latched when clk=1)
     );
   
   reg [DW-1:0]      out_reg;	   
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       out_reg[DW-1:0] <= 'b0;
     else if(en)	      
       out_reg[DW-1:0] <= in[DW-1:0];
   assign out[DW-1:0] = out_reg[DW-1:0];	   
   
endmodule // ohr_reg1





