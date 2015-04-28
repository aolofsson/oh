module etx_mux (/*AUTOARG*/
   // Outputs
   mi_dout,
   // Inputs
   sys_clk, reset, mi_en, mi_addr, mi_tx_emmu_dout, mi_tx_cfg_dout
   );

   parameter AW = 32;
   parameter DW = 32;
   
   //Needed for selecting data
   input 	   sys_clk;
   input 	   reset;   
   input 	   mi_en; 
   input [19:0]    mi_addr;
  
   input [DW-1:0] mi_tx_emmu_dout;
   input [DW-1:0] mi_tx_cfg_dout;
   
   output [DW-1:0] mi_dout;
   
endmodule // etx_mux

