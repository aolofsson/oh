/*
 ########################################################################
 ELINK CONFIGURATION INTERFACE
 ########################################################################
 
 */

module ecfg_if (/*AUTOARG*/
   // Outputs
   txwr_wait, txrd_wait, mi_en, mi_we, mi_addr, mi_din,
   // Inputs
   sys_clk, reset, txwr_access, txwr_packet, txrd_access, txrd_packet,
   rxwr_access, rxwr_packet, mi_el_dout, mi_rx_dout, mi_tx_dout,
   mi_mailbox_dout
   );

   parameter ID     = 12'h800;
   parameter DW     = 32;
   parameter AW     = 32;
   parameter PW     = 104;
   

   /********************************/
   /*One clock domain              */
   /********************************/  
   input           sys_clk;
   input           reset;

   /********************************/
   /*Transmit Write Interface      */
   /********************************/  
   input 	   txwr_access;
   input [PW-1:0]  txwr_packet;
   output 	   txwr_wait;
   /********************************/
   /*Transmit Side Read Interface */
   /********************************/
   input 	   txrd_access;
   input [PW-1:0]  txrd_packet;
   output 	   txrd_wait;

   /********************************/
   /*Receiver Write Interface      */
   /********************************/  
   input 	   rxwr_access;
   input [PW-1:0]  rxwr_packet;
  
   /********************************/
   /*Register Interface            */
   /********************************/
   output 	   mi_en;         
   output 	   mi_we; 
   output [19:0]   mi_addr;
   output [63:0]   mi_din;

   /******************************/
   /*Readback Data               */
   /******************************/
   input [31:0]    mi_el_dout;
   input [DW-1:0]  mi_rx_dout;   
   input [DW-1:0]  mi_tx_dout;
   input [DW-1:0]  mi_mailbox_dout;
   
   //wires
   wire [63:0] 	   txwr_data;
   wire [63:0] 	   rxwr_data;
   
   wire [AW-1:0]   txwr_dstaddr;
   wire [AW-1:0]   txwr_srcaddr;
   
   wire [AW-1:0]   txrd_dstaddr;
   wire [AW-1:0]   txrd_srcaddr;
   
   wire [AW-1:0]   rxwr_dstaddr;
   wire [AW-1:0]   rxwr_srcaddr;
   
   wire 	   mi_wr;
   wire 	   mi_rd;
   reg [63:0] 	   rx_mi_data_reg;
   reg [31:0] 	   rx_mi_addr_reg;
   reg 		   rx_mi_wait;

   
   //splicing packets
   packet2emesh p2e_txwr(.access_out	(),
		       .write_out	(),
		       .datamode_out	(),
		       .ctrlmode_out	(),
		       .dstaddr_out	(txwr_dstaddr[AW-1:0]),
		       .data_out	(txwr_data[31:0]),
		       .srcaddr_out	(txwr_data[63:32]),
		       .packet_in	(txwr_packet[PW-1:0])
		    );

   packet2emesh p2e_txrd(.access_out	(),
		       .write_out	(),
		       .datamode_out	(),
		       .ctrlmode_out	(),
		       .dstaddr_out	(txrd_dstaddr[AW-1:0]),
		       .data_out	(),
		       .srcaddr_out	(txrd_srcaddr[AW-1:0]),
		       .packet_in	(txrd_packet[PW-1:0])
		    );

   packet2emesh p2e_rxwr(.access_out	(),
		       .write_out	(),
		       .datamode_out	(),
		       .ctrlmode_out	(),
		       .dstaddr_out	(rxwr_dstaddr[AW-1:0]),
		       .data_out	(rxwr_data[31:0]),
		       .srcaddr_out	(rxwr_data[63:32]),
		       .packet_in	(rxwr_packet[PW-1:0])
		    );
            
   assign tx_wr = txwr_access & (txwr_dstaddr[31:20]==ID); 
   assign tx_rd = txrd_access & (txrd_dstaddr[31:20]==ID);
   assign rx_wr = rxwr_access & (rxwr_dstaddr[31:20]==ID); 
     
   assign mi_wr = tx_wr | rx_wr;
   assign mi_rd = tx_rd; //no access from receiver
    
   //DODO: 64 bit writes?
   assign mi_we         =  mi_wr;   
   assign mi_en         =  mi_wr | mi_rd;

   //Read/write address
   assign mi_addr[19:0] =  rx_wr ? rxwr_dstaddr[19:0] :
			   tx_rd ? txrd_dstaddr[19:0] :
			           txwr_dstaddr[19:0];
   
   //Data (prepare for it)
   assign mi_din[63:0]  =  rx_wr ? {rxwr_srcaddr[31:0],rxwr_data[31:0]} :
                                   {txwr_srcaddr[31:0],txwr_data[31:0]};

   //Interface clock (gate?)
   assign mi_clk = sys_clk;
   
   //Wait signals
   assign txwr_wait = tx_wr & rx_wr;
   assign txrd_wait = tx_rd & (tx_wr | rx_wr);

   
   //TODO: Do readback later....   
//   
endmodule // ecfg_if
// Local Variables:
// verilog-library-directories:("." "../../common/hdl" "../../memory/hdl")
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
