//#############################################################################
//# Function: Dual data rate output buffer                                    #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_oddr #(parameter DW  = 1) // width of data inputs
   (
    input 	    clk, // clock input
    input [DW-1:0]  din1, // data input1
    input [DW-1:0]  din2, // data input2
    output [DW-1:0] out   // ddr output
    );
   
   //regs("sl"=stable low, "sh"=stable high)
   reg [DW-1:0]     din2_sh;
   
   always @ (negedge clk)
     din2_sh[DW-1:0] <= din2[DW-1:0];
   
   assign out[DW-1:0] = ~clk ? din1[DW-1:0] : 
	                       din2_sh[DW-1:0];
      
endmodule // oh_oddr


