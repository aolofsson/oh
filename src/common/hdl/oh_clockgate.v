module oh_clockgate(/*AUTOARG*/
   // Outputs
   eclk,
   // Inputs
   nrst, clk, en, se
   );

   parameter DW=1;

   input  nrst;         // active low reset (synced to clk)   
   input  clk;          // clock input 
   input  se;           // scan enable   
   input  [DW-1:0] en;  // enable (from positive edge FF)
   output [DW-1:0] eclk;// enabled clock
     
`ifdef CFG_ASIC

`else

   wire [DW-1:0]   en_sh;
   wire [DW-1:0]   en_sl;

   //Turn on clock if in scan mode or if enabled
   assign   en_sl[DW-1:0] = en[DW-1:0]   | 
			    {(DW){se}}   |
			    {(DW){~nrst}}; 

   //making signal stable
   oh_lat0 #(.DW(1)) lat0 (.out_sh (en_sh[DW-1:0]),
                           .in_sl  (en_sl[DW-1:0]),
                           .clk    (clk)
			  );

   assign eclk[DW-1:0] =  {(DW){clk}} & en_sh[DW-1:0];
   
`endif
   
        
endmodule // clock_gater

