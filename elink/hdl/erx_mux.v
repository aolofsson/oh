module erx_mux (/*AUTOARG*/
   // Outputs
   mi_dout,
   // Inputs
   sys_clk, mi_addr, mi_rx_cfg_dout, mi_rx_edma_dout, mi_rx_emmu_dout
   );

   parameter DW = 32;
   parameter AW = 32;
   
   input 	   sys_clk;
   
   //Needed for selecting data
  
   input [19:0]    mi_addr;

   input [DW-1:0]  mi_rx_cfg_dout;
   input [DW-1:0]  mi_rx_edma_dout;
   input [DW-1:0]  mi_rx_emmu_dout;

   output [DW-1:0] mi_dout;

   
      
endmodule // erx_mux
