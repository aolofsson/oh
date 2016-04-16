//#############################################################################
//# Function: Low power clock gate circuit                                    #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_clockgate #(parameter DW   = 1, // width of data
		      parameter ASIC = 0  // use ASIC lib
		      ) 
   ( 
     input 	     nrst, // active low sync reset (synced to input clk)   
     input 	     clk, // clock input 
     input 	     se, // scan enable   
     input [DW-1:0]  en, // enable (from positive edge FF)
     output [DW-1:0] eclk// enabled clock output
  );

	     
   wire [DW-1:0]   en_sh;
   wire [DW-1:0]   en_sl;

   //Turn on clock if in scan mode or if enabled
   assign   en_sl[DW-1:0] = en[DW-1:0]   | 
			    {(DW){se}}   |
			    {(DW){~nrst}}; 

   //making signal stable
   oh_lat0 #(.DW(1)) lat0 (.out (en_sh[DW-1:0]),
                           .in  (en_sl[DW-1:0]),
                           .clk (clk)
			  );

   assign eclk[DW-1:0] =  {(DW){clk}} & en_sh[DW-1:0];
   
        
endmodule // oh_clockgate


