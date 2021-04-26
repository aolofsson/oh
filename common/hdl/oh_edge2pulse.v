//#############################################################################
//# Function: Converts an edge to a single cycle pulse                        #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_edge2pulse #( parameter DW      = 1) // width of data inputs
   (
    input 	    clk, // clock  
    input 	    nreset, // async active low reset   
    input [DW-1:0]  in, // edge input
    output [DW-1:0] out     // one cycle pulse
    );
     
   reg [DW-1:0]    in_reg;   

   always @ (posedge clk or negedge nreset)
     if(!nreset)
       in_reg[DW-1:0]  <= 'b0 ;
     else
       in_reg[DW-1:0]  <= in[DW-1:0] ;
     
   assign out[DW-1:0]  = in_reg[DW-1:0]  ^ in[DW-1:0] ;
   
endmodule // oh_edge2pulse
