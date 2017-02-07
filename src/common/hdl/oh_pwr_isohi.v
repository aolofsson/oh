//#############################################################################
//# Function: Isolation buffer (HIGH) for multi supply domains                #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT  (see LICENSE file in OH! repository)                       # 
//#############################################################################

module oh_pwr_isohi #(parameter DW   = 1        // width of data inputs
		      ) 
   (
    input 	    iso,// active low isolation signal
    input [DW-1:0]  in, // input signal
    output [DW-1:0] out // out = iso | in
    );

   localparam ASIC = `CFG_ASIC;  // use ASIC lib

   generate
      if(ASIC)	
	begin : asic
	   asic_iso_hi iiso [DW-1:0] (.iso(iso),
				      .in(in[DW-1:0]),
				      .out(out[DW-1:0]));
	end
      else
	begin : gen
	   assign out[DW-1:0] = {(DW){iso}} | in[DW-1:0];
	end
   endgenerate   

endmodule // oh_buf
