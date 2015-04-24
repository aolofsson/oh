module erx_mux (/*AUTOARG*/
   // Outputs
   mi_dout,
   // Inputs
   mi_clk, mi_en, mi_addr, mi_rx_cfg_dout, mi_rx_mailbox_dout,
   mi_rx_edma_dout, mi_rx_emmu_dout
   );

   parameter DW = 32;
   parameter AW = 32;
   
   //Needed for selecting data
   input 	   mi_clk;
   input 	   mi_en; 
   input [19:0]    mi_addr;

   input [DW-1:0]  mi_rx_cfg_dout;
   input [DW-1:0]  mi_rx_mailbox_dout;
   input [DW-1:0]  mi_rx_edma_dout;
   input [DW-1:0]  mi_rx_emmu_dout;

   output [DW-1:0] mi_dout;
   
endmodule // erx_mux
