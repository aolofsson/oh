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

`ifdef TARGET_SIM
   assign vddg = ((vdd===1'b1) && (npower===1'b0)) ? 1'b1 : 1'bX; 		  
`else
 `ifdef CFG_ASIC
   asic_pwr_header i_header (.npower(npower),
				     .vdd(vdd),
				     .vddg(vddg));
 `endif
`endif

   
endmodule // oh_pwr_gate
