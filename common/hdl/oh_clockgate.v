//#############################################################################
//# Function: Low power clock gate circuit                                    #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_clockgate (
     input  clk, // clock input 
     input  te, // test enable enable   
     input  en, // enable (from positive edge FF)
     output eclk // enabled clock output
     );

   localparam ASIC = `CFG_ASIC;  // use ASIC lib

   generate
      if(ASIC)	     
	begin : asic
	   asic_icg icg (.en(en),
			 .te(te),
			 .clk(clk),
			 .eclk(eclk));
	end
      else
	begin : generic
	   wire    en_sh;
	   wire    en_sl;
	   //Stable low/valid rising edge enable
	   assign   en_sl = en | te;
	   //Stable high enable signal
	   oh_lat0 lat0 (.out (en_sh),
			 .in  (en_sl),
			 .clk (clk));
	   
	   assign eclk =  clk & en_sh;
	end 
   endgenerate
        
endmodule // oh_clockgate


