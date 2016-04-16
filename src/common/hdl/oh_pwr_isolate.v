//#############################################################################
//# Function: Isolation buffer for multi supply domains                       #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT  (see LICENSE file in OH! repository)                       # 
//#############################################################################

module oh_pwr_isolate #(parameter DW   = 1, // width of data inputs
			parameter ASIC = 0  // use ASIC lib
			) 
   (
    input 	    vdd, // supply (set to 1 if valid)
    input 	    vss, // ground (set to 0 if valid)
    input 	    niso,// active low isolation signal
    input [DW-1:0]  in,  // input signal
    output [DW-1:0] out  // buffered output signal
    );


`ifdef TARGET_SIM   
   assign out[DW-1:0] = ((vdd===1'b1) && (vss===1'b0)) ? ({(DW){niso}} & in[DW-1:0]):
		                                         {(DW){1'bX}};
`else
   generate
      if(ASIC)	
	begin
	   asic_iso i_iso [DW-1:0] (.vdd(vdd),
				    .vss(vss),
				    .in(in[DW-1:0]),
				    .out(out[DW-1:0]));
	end
      else
	begin
	   assign out[DW-1:0] = {(DW){niso}} & in[DW-1:0];
	end
   endgenerate
`endif
   
endmodule // oh_buf
