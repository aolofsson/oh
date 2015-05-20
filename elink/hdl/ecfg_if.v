/*
 ########################################################################
 
 ########################################################################
 */

module ecfg_if (/*AUTOARG*/
   // Outputs
   mi_mmu_en, mi_dma_en, mi_cfg_en, mi_we, mi_addr, mi_din,
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
   wire 	 rxsel;
   wire 	 mi_en;
   
   //regs;
   reg 		 access_out;   
   reg [31:0] 	 dstaddr_reg;
   reg [31:0] 	 srcaddr_reg;
   reg [1:0] 	 datamode_reg;
   reg [3:0] 	 ctrlmode_reg;
   reg 		 write_reg;
   reg 		 readback_reg;   
   reg [31:0] 	 data_reg;
   wire [31:0] 	 data_out;
   
   //parameter didn't seem to work
   assign 	 rxsel = RX;   

   //splicing packet
   packet2emesh p2e (.access_out   (),
		     .write_out	   (write),
		     .datamode_out (datamode[1:0] ),
		     .ctrlmode_out (ctrlmode[3:0]),
		     .dstaddr_out  (dstaddr[31:0]),
		     .data_out	   (data[31:0]),
		     .srcaddr_out  (srcaddr[31:0]),
		     .packet_in	   (packet_in[PW-1:0])
		    );

   //ENABLE SIGNALS
   assign mi_match   = access_in & (dstaddr[31:20]==ID);
    
   //config select (group 2 and 3)
   assign mi_cfg_en = mi_match & 
		      (dstaddr[19:16]==4'hF) &
		      (dstaddr[10:8]=={2'b01,rxsel});
   

   //dma select (group 5)
   assign mi_dma_en = mi_match &
		      (dstaddr[19:16]==4'hF) & 
		      (dstaddr[10:8]==3'h5)  & 
		      (dstaddr[5]==rxsel);
   

   //mmu select
   assign mi_mmu_en = mi_match & 
		      (dstaddr[19:16]==4'hE) &
		      (dstaddr[15]==rxsel);


   //read/write indicator
   assign mi_en = (mi_mmu_en | mi_cfg_en | mi_dma_en);   
   assign mi_rd = ~write & mi_en;   
   assign mi_we = write  & mi_en;
   
   //signal to carry transaction from ETX to ERX block through fifo_cdc
   assign mi_rx_en = mi_match & 
		     ((dstaddr[19:16]==4'hE) | (dstaddr[19:16]==4'hF)) &  
		     ~mi_en;
      
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
   assign access_forward = (mi_rx_en | mi_rd);

   always @ (posedge  clk)
     if(reset)
       access_out   <= 1'b0;
     else if(~wait_in)
       access_out   <= access_forward;
   
   always @ (posedge clk)
     if(~wait_in)
       begin
	  readback_reg      <= mi_rd;
	  write_reg         <= (mi_rx_en & write) | mi_rd;	  
	  datamode_reg[1:0] <= datamode[1:0];
	  ctrlmode_reg[3:0] <= ctrlmode[3:0];
	  dstaddr_reg[31:0] <= mi_rx_en ? dstaddr[31:0] : srcaddr[31:0];
	  data_reg[31:0]    <= data[31:0];	  
	  srcaddr_reg[31:0] <= mi_rx_en ? srcaddr[31:0] : mi_dout_mux[63:32];
       end
   
   assign data_out[31:0] = readback_reg ? mi_dout_mux[31:0] : data_reg[31:0];
   
   //Create packet
   emesh2packet e2p (.packet_out	(packet_out[PW-1:0]),
		     .access_in		(1'b1),
		     .write_in		(write_reg),
		     .datamode_in        (datamode_reg[1:0]),
		     .ctrlmode_in   	(ctrlmode_reg[3:0]),
		     .dstaddr_in   	(dstaddr_reg[AW-1:0]),
		     .data_in		(data_out[31:0]),
		     .srcaddr_in        (srcaddr_reg[AW-1:0])
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
