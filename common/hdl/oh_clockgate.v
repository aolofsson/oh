//#############################################################################
//# Function: Low power clock gate circuit                                    #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_clockgate
  #(parameter SYN  = "TRUE",    // synthesizable
    parameter TYPE = "DEFAULT"  // implementation type
    )
(
 input 	clk, // clock input
 input 	te,  // test enable
 input 	en,  // enable (from positive edge FF)
 output eclk // enabled clock output
 );

   generate
      if(SYN == "TRUE") begin

	 wire     en_sh;
	 wire     en_sl;

	 //Stable low/valid rising edge enable
	 assign   en_sl = en | te;

	 //Stable high enable signal
	 oh_lat0 lat0 (.out (en_sh),
		       .in  (en_sl),
		       .clk (clk));

	 assign eclk =  clk & en_sh;

      end
      else begin
	 asic_clockgate #(.TYPE(TYPE))
	 asic_clockgate (// Outputs
			 .eclk		(eclk),
			 // Inputs
			 .clk		(clk),
			 .te		(te),
			 .en		(en));
      end
   endgenerate
endmodule
