/*
 ########################################################################
 ELINK CONFIGURATION INTERFACE
 ########################################################################
 
 */

module ecfg_if (/*AUTOARG*/
   // Outputs
   rxrr_access, rxrr_packet, mi_clk, mi_en, mi_we, mi_addr, mi_din,
   // Inputs
   txwr_clk, txwr_access, txwr_packet, txrd_access, txrd_packet,
   rxrr_clk, mi_ba_cfg_dout, mi_rx_cfg_dout, mi_rx_edma_dout,
   mi_rx_emmu_dout, mi_rx_mailbox_dout, mi_tx_cfg_dout,
   mi_tx_emmu_dout
   );

   parameter [11:0]  ELINKID             = 12'h800;
   parameter DW     = 32;
   parameter AW     = 32;
   parameter PW     = 104;
   
   /******************************/
   /*Host Write Interface        */
   /******************************/  
   input 	   txwr_clk;        //write clock used as mi_clk
   input 	   txwr_access;
   input [PW-1:0]  txwr_packet;

   /******************************/
   /*Host Write Interface        */
   /******************************/
   input 	   txrd_access;
   input [PW-1:0]  txrd_packet;

   /******************************/
   /*Host Readback Interface     */
   /******************************/
   input 	   rxrr_clk;   
   output 	   rxrr_access;
   output [PW-1:0] rxrr_packet;
   
   /******************************/
   /*Register Interface          */
   /******************************/
   output 	   mi_clk;
   output 	   mi_en;         
   output 	   mi_we; 
   output [19:0]   mi_addr;
   output [31:0]   mi_din;

   /******************************/
   /*Readback Data               */
   /******************************/

   //base
   input [31:0]   mi_ba_cfg_dout;
   //rx
   input [DW-1:0] mi_rx_cfg_dout;   
   input [DW-1:0] mi_rx_edma_dout;
   input [DW-1:0] mi_rx_emmu_dout;
   input [DW-1:0] mi_rx_mailbox_dout;
   //tx
   input [DW-1:0] mi_tx_cfg_dout;
   input [DW-1:0] mi_tx_emmu_dout;
   
   //wires

   wire [DW-1:0]	txwr_data;	
   wire [AW-1:0]	txwr_dstaddr;
   wire [AW-1:0]	txwr_srcaddr;
   wire [AW-1:0]	txrd_dstaddr;
   wire [AW-1:0]	txrd_srcaddr;

   

   wire 		mi_wr;
   wire 		mi_rd;
   
   //splicing packets
   packet2emesh p2e_wr(.access_out	(),
		       .write_out	(),
		       .datamode_out	(),
		       .ctrlmode_out	(),
		       .dstaddr_out	(txwr_dstaddr[AW-1:0]),
		       .data_out	(txwr_data[DW-1:0]),
		       .srcaddr_out	(),
		       .packet_in	(txwr_packet[PW-1:0])
		    );

   packet2emesh p2e_rd(.access_out	(),
		       .write_out	(),
		       .datamode_out	(),
		       .ctrlmode_out	(),
		       .dstaddr_out	(txrd_dstaddr[AW-1:0]),
		       .data_out	(),
		       .srcaddr_out	(txrd_srcaddr[AW-1:0]),
		       .packet_in	(txrd_packet[PW-1:0])
		    );
   
       
   //pass through clock
   //TODO: gate?
   assign mi_clk = txwr_clk;
   
   //Register file access (from slave)
   assign mi_wr = txwr_access & (txwr_dstaddr[31:20]==ELINKID);   
   assign mi_rd = txrd_access & (txrd_dstaddr[31:20]==ELINKID);
   
   //Only 32 bit writes supported
   assign mi_we         =  mi_wr;   
   assign mi_en         =  mi_wr | mi_rd;

   //Read/write address
   assign mi_addr[19:0] =  mi_we ? txwr_dstaddr[19:0] :
			           txrd_dstaddr[19:0];
    
   //Data
   assign mi_din[31:0]  = txwr_data[31:0];

   //TODO: Do readback later....     
endmodule // ecfg_base
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:


/*
  Copyright (C) 2013 Adapteva, Inc.
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
