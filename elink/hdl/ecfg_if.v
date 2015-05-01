/*
 ########################################################################
 
 ########################################################################
 */

module ecfg_if (/*AUTOARG*/
   // Outputs
   wait_out, mi_mmu_en, mi_dma_en, mi_cfg_en, mi_we, mi_addr, mi_din,
   access_out, packet_out,
   // Inputs
   clk, reset, access_in, packet_in, mi_dout0, mi_dout1, mi_dout2,
   mi_dout3, wait_in
   );

   parameter RX     = 0;     //0,1
   parameter PW     = 104;
   parameter AW     = 32;
   parameter DW     = 32;
   parameter ID     = 12'h810;
   
   /********************************/
   /*Clocks/reset                  */
   /********************************/  
   input             clk;  
   input             reset;

   /********************************/
   /*Incoming Packet               */
   /********************************/  
   input 	     access_in;
   input [PW-1:0]    packet_in;
   output 	     wait_out;     //outgoing wait
  
   /********************************/
   /* Register Interface           */
   /********************************/
   output 	 mi_mmu_en;     
   output 	 mi_dma_en;
   output 	 mi_cfg_en;      
   output        mi_we;  
   output [14:0] mi_addr;
   output [63:0] mi_din;   
   input [63:0]  mi_dout0;
   input [63:0]  mi_dout1;
   input [63:0]  mi_dout2;
   input [63:0]  mi_dout3;


   /********************************/
   /* Outgoing Packet              */
   /********************************/
   output 	     access_out;
   output [PW-1:0]   packet_out;
   input 	     wait_in;       //incoming wait 
   
   //wires
   wire [31:0] 	 dstaddr;
   wire [31:0] 	 data;   
   wire [31:0]   srcaddr;
   wire [1:0] 	 datamode;
   wire [3:0] 	 ctrlmode;
   wire [63:0] 	 mi_dout_mux;
   wire 	 mi_rd;
   wire 	 access_forward;
   
   //regs;
   reg 		 access_out;   
   reg [31:0] 	 dstaddr_out;
   reg [31:0] 	 data_out;   
   reg [31:0] 	 srcaddr_out;
   reg [1:0] 	 datamode_out;
   reg [3:0] 	 ctrlmode_out;
   reg 		 write_out;
   
   //splicing packet
   packet2emesh p2e (.access_out   (),
		     .write_out	   (write),
		     .datamode_out (datamode[1:0]),
		     .ctrlmode_out (ctrlmode[3:0]),
		     .dstaddr_out  (dstaddr[31:0]),
		     .data_out	   (data[31:0]),
		     .srcaddr_out  (srcaddr[31:0]),
		     .packet_in	   (packet_in[PW-1:0])
		    );

   //ENABLE SIGNALS
   assign mi_match   = access_in & (dstaddr[31:20]==ID);
   
   //signal to carry transaction from ETX to ERX block through fifo_cdc
   assign mi_rx_en = mi_match &
                     (
		      ((dstaddr[19:16]==4'hF) & (dstaddr[10:8]==3'h3))  |           //RX-CFG
		      ((dstaddr[19:16]==4'hF) & (dstaddr[10:8]==3'h5) & dstaddr[5]) | //RX-DMA
		      ((dstaddr[19:16]==4'hE) & dstaddr[15])                          //RX-EMMU

		     );

   //config select (group 2 and 3)
   assign mi_cfg_en = mi_match & 
		      (dstaddr[19:16]==4'hF) &
		      (dstaddr[10:8]=={2'b01,RX});
   

   //dma select (group 5)
   assign mi_dma_en = mi_match &
		      (dstaddr[19:16]==4'hF) & 
		      (dstaddr[10:8]==3'h5)  & 
		      (dstaddr[5]==RX);
   

   //mmu select
   assign mi_mmu_en = mi_match & 
		      (dstaddr[19:16]==4'hE) &
		      (dstaddr[15]==RX);


   //read/write indicator
   assign mi_rd = ~write & (mi_mmu_en | mi_cfg_en | mi_dma_en);   
   assign mi_we = write  & (mi_mmu_en | mi_cfg_en | mi_dma_en); 
   
   //ADDR
   assign mi_addr[14:0] = dstaddr[14:0];
   
   //DIN
   assign mi_din[63:0]  = {srcaddr[31:0], data[31:0]};
   
   //READBACK MUX (inputs should be zero if not used)
   assign mi_dout_mux[63:0] = mi_dout0[63:0] |
			      mi_dout1[63:0] |
			      mi_dout2[63:0] |
			      mi_dout3[63:0];
     

   //Access out packet
  
   assign access_forwad = (mi_rx_en | mi_rd) & ~wait_in;

   always @ (posedge  clk)
     access_out   <= access_forward;
   
   always @ (posedge clk)
     if(access_forward)
       begin
	  write_out         <= mi_rx_en & write;
	  datamode_out[1:0] <= datamode[1:0];
	  ctrlmode_out[3:0] <= ctrlmode[3:0];
	  dstaddr_out[31:0] <= mi_rx_en ? dstaddr[31:0] : srcaddr[31:0];
	  data_out[31:0]    <= mi_rx_en ? data[31:0]    : mi_dout_mux[31:0];
	  srcaddr_out[31:0] <= mi_rx_en ? srcaddr[31:0] : mi_dout_mux[63:32];
       end

   //Create packet
   emesh2packet e2p (.packet_out	(packet_out[PW-1:0]),
		     .access_in		(access_out),
		     .write_in		(write_out),
		     .datamode_in	(datamode_out[1:0]),
		     .ctrlmode_in	(ctrlmode_out[3:0]),
		     .dstaddr_in	(dstaddr_out[AW-1:0]),
		     .data_in		(data_out[DW-1:0]),
		     .srcaddr_in	(srcaddr_out[AW-1:0])
		     );
   
   
endmodule // ecfg_if
/*
  Copyright (C) 2015 Adapteva, Inc.
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
