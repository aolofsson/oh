//#############################################################################
//# Function: Dual data rate input buffer (2 cycle delay)                     #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_iddr
  #(parameter DW  = 2) // width of data inputs
   (
    input 		clk, // clock
    input 		ce0, // 1st cycle enable
    input 		ce1, // 2nd cycle enable
    input [DW/2-1:0] 	din, // data input sampled on both edges of clock
    output reg [DW-1:0] dout // iddr aligned
    );

   //regs("sl"=stable low, "sh"=stable high)
   reg [DW/2-1:0]     din_sl;
   reg [DW/2-1:0]     din_sh;
   reg 		      ce0_negedge;

   //########################
   // Pipeline valid for negedge
   //########################
   always @ (negedge clk)
     ce0_negedge <= ce0;

   //########################
   // Dual edge sampling
   //########################

   always @ (posedge clk)
     if(ce0)
       din_sl[DW/2-1:0] <= din[DW/2-1:0];
   always @ (negedge clk)
     if(ce0_negedge)
       din_sh[DW/2-1:0] <= din[DW/2-1:0];

   //########################
   // Aign pipeline
   //########################
   always @ (posedge clk)
     if(ce1)
       dout[DW-1:0] <= {din_sh[DW/2-1:0],
			din_sl[DW/2-1:0]};

endmodule // oh_iddr
