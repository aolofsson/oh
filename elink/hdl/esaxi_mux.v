module esaxi_mux (/*AUTOARG*/
   // Outputs
   emrr_mux_data, emrr_mux_empty, emrr_rd_en, mi_clk, mi_rx_emmu_sel,
   mi_tx_emmu_sel, mi_ecfg_sel, mi_embox_sel, mi_we, mi_addr, mi_din,
   // Inputs
   clk, emwr_data, emwr_dstaddr, emwr_access, emrq_data, emrq_access,
   emrr_mux_rd_en, emrr_data, emrr_empty, mi_ecfg_dout,
   mi_tx_emmu_dout, mi_rx_emmu_dout, mi_embox_dout
   );

   parameter ELINKID  = 0;    //ID of link
   parameter DW       = 32;

   //Input clock
   input 	  clk;

   //Write from slave
   input [31:0]   emwr_data;
   input [31:0]   emwr_dstaddr;
   input 	  emwr_access;   

   //Read from slave
   input [31:0]   emrq_data;
   input [31:0]   emwr_dstaddr;
   input 	  emrq_access;   
 
   //Read response
   output [31:0]  emrr_mux_data;   
   input 	  emrr_mux_rd_en;   
   output 	  emrr_mux_empty;
      
   //FIFO side (read response)
   input [31:0]   emrr_data;   
   output 	  emrr_rd_en;   
   input 	  emrr_empty;

   //Register Interface 
   output         mi_clk;
   output 	  mi_rx_emmu_sel;
   output 	  mi_tx_emmu_sel;
   output 	  mi_ecfg_sel;
   output 	  mi_embox_sel;
   output         mi_we;   
   output [19:0]  mi_addr;   
   output [31:0]  mi_din;   

   //Readback data to mux
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
   
   //Register file access (from slave)
   assign mi_wr = emwr_access & (emwr_dstaddr[31:20]==ELINKID);   
   assign mi_rd = emrq_access & (emrq_dstaddr[31:20]==ELINKID);
      
   //Only 32 bit writes supported
   assign mi_we         =  mi_wr;   
   assign mi_en         =  mi_wr | mi_rd;

   //Read/write address
   assign mi_addr[19:0] =  mi_we ? emwr_dstaddr[19:0] :
			           emrq_dstaddr[19:0];
   		
   //Block select
   assign mi_ecfg_sel     = mi_en & (mi_addr[19:16]==EGROUP_MMR);
   assign mi_rx_emmu_sel  = mi_en & (mi_addr[19:16]==EGROUP_RXMMU);
   assign mi_tx_emmu_sel  = mi_en & (mi_addr[19:16]==EGROUP_TXMMU);
   assign mi_embox_sel    = mi_en & (mi_addr[19:16]==EGROUP_EMBOX);
   				  
   //Data
   assign mi_din[31:0] = emwr_data[31:0];
	 
   //Readback
   always@ (posedge clk)
     begin
	mi_ecfg_reg    <= mi_ecfg_sel;
	mi_rx_emmu_reg <= mi_rx_emmu_sel;	
	mi_tx_emmu_reg <= mi_tx_emmu_sel;
	mi_embox_reg   <= mi_embox_sel;
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

   //Read Response
   assign   emrr_mux_data[31:0]       = mi_rd_reg ? mi_dout[31:0] :
				                    emrr_data[31:0];

   assign   emrr_mux_rd_en            = emrr_rd_en & ~mi_rd_reg;   

   assign   emrr_mux_empty            = emrr_empty & ~mi_rd_reg;

   
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
