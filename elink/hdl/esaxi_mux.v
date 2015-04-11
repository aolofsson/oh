module esaxi_mux (/*AUTOARG*/
   // Outputs
   emwr_full, emwr_prog_full, emrq_full, emrq_prog_full, emrr_rd_data,
   emrr_empty, esaxi_emwr_wr_data, esaxi_emwr_wr_en,
   esaxi_emrq_wr_data, esaxi_emrq_wr_en, esaxi_emrr_rd_en, mi_clk,
   mi_rx_emmu_en, mi_tx_emmu_en, mi_ecfg_en, mi_embox_en, mi_we,
   mi_addr, mi_din,
   // Inputs
   clk, emwr_wr_data, emwr_wr_en, emrq_wr_data, emrq_wr_en,
   emrr_rd_en, esaxi_emwr_full, esaxi_emwr_prog_full, esaxi_emrq_full,
   esaxi_emrq_prog_full, esaxi_emrr_rd_data, esaxi_emrr_empty,
   mi_ecfg_dout, mi_tx_emmu_dout, mi_rx_emmu_dout, mi_embox_dout
   );

   parameter ELINKID  = 0;    //ID of link
   parameter DW       = 32;

   //Input clock
   input 	  clk;

   //AXI Side
   input [102:0]  emwr_wr_data;
   input 	  emwr_wr_en;   
   output 	  emwr_full;
   output 	  emwr_prog_full;

   input [102:0]  emrq_wr_data;   
   input 	  emrq_wr_en;   
   output 	  emrq_full;   
   output 	  emrq_prog_full;

   output [31:0]  emrr_rd_data;   
   input 	  emrr_rd_en;   
   output 	  emrr_empty;
   
   //FIFO side
   output [102:0] esaxi_emwr_wr_data;
   output 	  esaxi_emwr_wr_en;   
   input 	  esaxi_emwr_full;
   input 	  esaxi_emwr_prog_full;
   
   output [102:0] esaxi_emrq_wr_data;   
   output 	  esaxi_emrq_wr_en;   
   input 	  esaxi_emrq_full;   
   input 	  esaxi_emrq_prog_full;

   input [31:0]   esaxi_emrr_rd_data;   
   output 	  esaxi_emrr_rd_en;   
   input 	  esaxi_emrr_empty;

   //Register Interface 
   output         mi_clk;
   output 	  mi_rx_emmu_en;
   output 	  mi_tx_emmu_en;
   output 	  mi_ecfg_en;
   output 	  mi_embox_en;
   output         mi_we;   
   output [19:0]  mi_addr;   
   output [31:0]  mi_din;   
   input [DW-1:0] mi_ecfg_dout;
   input [DW-1:0] mi_tx_emmu_dout;
   input [DW-1:0] mi_rx_emmu_dout;
   input [DW-1:0] mi_embox_dout;

   //Wire declarations
   wire 	  mi_wr;
   wire 	  mi_rd;
   wire 	  mi_we;
   wire 	  mi_en;
   wire [31:0] 	  mi_dout;
   wire 	  mi_sel;

   //Regs
   reg 	  mi_rx_emmu_reg;
   reg 	  mi_tx_emmu_reg;
   reg 	  mi_ecfg_reg;
   reg 	  mi_embox_reg;
   reg 	  mi_rd_reg;
	  
   /*******************************/
   /*SIMPLE MEMORY-LIKE INTERFACE */
   /*******************************/  
   assign mi_clk = clk;
   
   //Register file access
   assign mi_wr = emwr_wr_en & (emwr_wr_data[95:64]==ELINKID);   
   assign mi_rd = emrq_wr_en & (emrq_wr_data[95:64]==ELINKID);
      
   //Only 32 bit writes supported
   assign mi_we         =  mi_wr;   
   assign mi_en         =  mi_wr | mi_rd;

   //Read/write address
   assign mi_addr[19:0] =  mi_wr ? emwr_wr_data[83:64] :
			           emrq_wr_data[83:64];
   		
   //Block selects
   assign mi_ecfg_en   = mi_en & (mi_addr[19:16]==EGROUP_MMR);
   assign mi_rx_mmu_en = mi_en & (mi_addr[19:16]==EGROUP_RXMMU);
   assign mi_tx_mmu_en = mi_en & (mi_addr[19:16]==EGROUP_TXMMU);
   assign mi_embox_en  = mi_en & (mi_addr[19:16]==EGROUP_EMBOX);
   				  
   //Data
   assign mi_din[31:0] = emwr_wr_data[31:0];
	 
   //Readback
   always@ (posedge clk)
     begin
	mi_ecfg_reg    <= mi_ecfg_en;
	mi_rx_emmu_reg <= mi_rx_emmu_en;	
	mi_tx_emmu_reg <= mi_tx_emmu_en;
	mi_embox_reg   <= mi_embox_en;
	mi_rd_reg      <= mi_rd;
     end

   //Data mux
   assign mi_dout[31:0] = mi_ecfg_reg    ? mi_ecfg_dout[31:0]    :
			  mi_rx_emmu_reg ? mi_rx_emmu_dout[31:0] :
			  mi_tx_emmu_reg ? mi_tx_emmu_dout[31:0] :
			                   mi_embox_dout[31:0];
   /********************************/
   /*INTERFACE TO AXI SLAVE        */
   /********************************/  

   //Write Request
   assign  esaxi_emwr_wr_data[102:0] = emwr_wr_data[102:0] ;
   assign  esaxi_emwr_wr_en          = emwr_wr_en & ~mi_wr;   
   assign  emwr_full                 = esaxi_emwr_full;
   assign  emwr_prog_full            = esaxi_emwr_prog_full ;

   //Read Request
   assign   esaxi_emrq_wr_data[102:0] = emrq_wr_data[102:0];
   assign   esaxi_emrq_wr_en          = emrq_wr_en & ~mi_rd;      
   assign   emrq_full                 = esaxi_emrq_full;  
   assign   emrq_prog_full            = esaxi_emrq_prog_full ;

   //Read Response
   assign   emrr_rd_data[31:0]       = mi_rd_reg ? mi_dout[31:0] :
				                   esaxi_emrr_rd_data[31:0];
   assign   esaxi_emrr_rd_en          = emrr_rd_en & ~mi_rd_reg;   
   assign   emrr_empty                = esaxi_emrr_empty & ~mi_rd_reg;

   
endmodule // esaxi_mux

/*
  Copyright (C) 2014 Adapteva, Inc.
  Contributed by Andreas Olofsson <andreas@adapteva.com>
 
   This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.This program is distributed in the hope 
  that it will be useful,but WITHOUT ANY WARRANTY; without even the implied 
  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details. You should have received a copy 
  of the GNU General Public License along with this program (see the file 
  COPYING).  If not, see <http://www.gnu.org/licenses/>.
*/
