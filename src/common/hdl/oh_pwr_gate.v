//#############################################################################
//# Function: Power supply header switch                                      #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_pwr_gate (
    input  npower, // active low power on
    input  vdd, // input supply
    output vddg     // gated output supply
    );

   localparam ASIC = `CFG_ASIC;  // use asic library

`ifdef TARGET_SIM
   assign vddg = ((vdd===1'b1) && (npower===1'b0)) ? 1'b1 : 1'bX; 		  
`else
   generate
      if(ASIC)	
	begin : asic
	   asic_pwr_header i_header (.npower(npower),
				     .vdd(vdd),
				     .vddg(vddg));
	end
   endgenerate   
`endif
   
endmodule // oh_pwr_gate
