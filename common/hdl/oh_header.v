//#############################################################################
//# Function: Power supply header switch                                      #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_header
  #(parameter SYN   = "TRUE",   // true=synthesizable
    parameter TYPE  = "DEFAULT" // scell type/size
    )
   (
    input  npower, // active low power on
    input  vdd, // input supply
    output vddg     // gated output supply
    );

   generate
      if(SYN == "TRUE")	begin
      end
      else begin
	 asic_header #(.TYPE(TYPE))
	 asic_header (.npower(npower),
		      .vdd(vdd),
		      .vddg(vddg));
      end
   endgenerate

endmodule // oh_pwr_gate
