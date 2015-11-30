module oh_clockgate(/*AUTOARG*/
   // Outputs
   eclk,
   // Inputs
   nrst, clk, en, se
   );

   input  nrst;//active low reset   
   input  clk; //clock input 
   input  en;  //enable
   input  se;  //scan enable   
   output eclk;//enabled clock
     
`ifdef CFG_ASIC

`else
   wire   en_sh;
   wire   en_sl;

   //Turn on clock if in scan mode or if enabled
   assign   en_sl = en | se | ~nrst;

   //making signal stable
   oh_lat0 #(.DW(1)) lat0 (.out_sh (en_sh),
                           .in_sl  (en_sl),
                           .clk    (clk)
			  );

   assign eclk =  clk & en_sh;
   
`endif
   
        
endmodule // clock_gater

