//#############################################################################
//# Function: Dual data rate input buffer (2 cycle delay)                     #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_iddr #(parameter DW      = 1 // width of data inputs
		 )
   (
    input 		clk, // clock
    input 		ce, // clock enable, set to high to clock in data
    input [DW-1:0] 	din, // data input sampled on both edges of clock
    output reg [DW-1:0] q1, // iddr rising edge sampled data
    output reg [DW-1:0] q2   // iddr falling edge sampled data
    );
   
   //regs("sl"=stable low, "sh"=stable high)
   reg [DW-1:0]     q1_sl;
   reg [DW-1:0]     q2_sh;
   
   // rising edge sample
   always @ (posedge clk)
     if(ce)
       q1_sl[DW-1:0] <= din[DW-1:0];
   
   // falling edge sample
   always @ (negedge clk)
     q2_sh[DW-1:0] <= din[DW-1:0];
   
   // pipeline for alignment
   always @ (posedge clk)
     begin
	q1[DW-1:0] <= q1_sl[DW-1:0];
	q2[DW-1:0] <= q2_sh[DW-1:0];
     end
            
endmodule // oh_iddr


