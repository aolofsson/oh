//#############################################################################
//# Function: Low power clock gate circuit                                    #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_clockgate (
     input  clk, // clock input 
     input  te, // test enable   
     input  en, // enable (from positive edge FF)
     output eclk // enabled clock output
     );

`ifdef CFG_ASIC
   asic_icg icg (.en(en),
		 .te(te),
		 .clk(clk),
		 .eclk(eclk));
`else
   wire     en_sh;
   wire     en_sl;
   //Stable low/valid rising edge enable
   assign   en_sl = en | te;
   //Stable high enable signal
   oh_lat0 lat0 (.out (en_sh),
		 .in  (en_sl),
		 .clk (clk));
   
   assign eclk =  clk & en_sh;
`endif // !`ifdef CFG_ASIC
        
endmodule // oh_clockgate


