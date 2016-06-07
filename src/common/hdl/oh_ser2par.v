//#############################################################################
//# Purpose: Serial to Parallel Converter                                     #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_ser2par #(parameter PW = 64, // parallel packet width
		    parameter SW = 1   // serial packet width
		    )
   (
    input 	    clk, // sampling clock   
    input [SW-1:0]  din, // serial data
    output [PW-1:0] dout, // parallel data  
    input 	    lsbfirst, // lsb first order
    input 	    shift      // shift the shifter
    );
 
   parameter CW   = $clog2(PW/SW);  // serialization factor (for counter)
   
   reg [PW-1:0]    dout_reg;
   reg [CW-1:0]    count;
   wire [PW-1:0]   shiftdata;

   assign dout = dout_reg;

   always @ (posedge clk)
     if(shift & lsbfirst)
       dout_reg[PW-1:0] <= {din[SW-1:0],dout_reg[PW-1:SW]};
     else if(shift)
       dout_reg[PW-1:0] <= {dout_reg[PW-SW-1:0],din[SW-1:0]};
   
endmodule // oh_ser2par
