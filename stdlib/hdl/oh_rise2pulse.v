//#############################################################################
//# Function: Converts a rising edge to a single cycle pulse                  #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_rise2pulse #(parameter N = 1) // data width

   (  input           clk,     // clock
      input 	      nreset, // async active low reset
      input [N-1:0]  in, // edge input
      output [N-1:0] out     // one cycle pulse
      );

   reg [N-1:0]    in_reg;

   always @ (posedge clk or negedge nreset)
     if(!nreset)
       in_reg[N-1:0]  <= 'b0 ;
     else
       in_reg[N-1:0]  <= in[N-1:0] ;

   assign out[N-1:0]  = in[N-1:0] & ~in_reg[N-1:0] ;

endmodule // oh_rise2pulse
