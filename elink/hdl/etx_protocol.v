//########################################################################
//# ELINK TX Protocol block
//########################################################################
//#
//# The etx_protocol block implements a transmitter for communicating with
//# the Epiphany receiver per the documentation seen below.
//#
//# The output transaction has an option of the bursting where data of 
//# the new transaction is sent without the address. In such a case the
//# address of the transaction will be determined in the receiver according 
//# to the address of the previous transaction.
//#
//#        ___     ___     ___     ___     ___     ___
//# lclk _|   |___|   |___|   |___|   |___|   |___|   |_
//#
//#              -------------------------------
//# frame ______/
//#              --- --- --- --- ---
//# data  XXXXXXX 0 X 1 X 2 X 3 X 4 X .....
//#              --- --- --- --- ---
//#
//#  Transaction structure:
//#  -------------------------
//#   byte0  -> 00000000
//#   byte1  -> ctrlmode[3:0],dstaddr[31:28]
//#   byte2  -> dstaddr[27:20]
//#   byte3  -> dstaddr[19:12]
//#   byte4  -> dstaddr[11:4]
//#   byte5  -> dstaddr[3:0],datamode[1:0],write,access
//#   byte6  -> data[31:24] (or srcaddr[31:24] if read transaction)
//#   byte7  -> data[23:16] (or srcaddr[23:16] if read transaction)
//#   byte8  -> data[15:8]  (or srcaddr[15:8]  if read transaction)
//#  *byte9  -> data[7:0]   (or srcaddr[7:0]   if read transaction)
//#   byte10 -> data[63:56]  
//#   byte11 -> data[55:48]  
//#   byte12 -> data[47:40]  
//#   byte13 -> data[39:32]  
//# **byte14 -> data[31:24]  
//#    ...
//#    ...
//#    ...
//#
//#  * byte9 is the last byte of 32 bit write or read transaction 
//#   
//# ** if 64 bit write transaction, data of byte14 is the first data byte of
//#    bursting transaction
//# 
//# -- The data is transmitted MSB first but in 32bits resolution. If we want
//#    to transmit 64 bits it will be [31:0] (msb first) and then [63:32] 
//#    (msb first)
//#
//# Wait indication to the transmitter (from Epiphany chip receiver):
//#
//# When one of the secondary fifos becomes full we send wait indication 
//# to the transmitter.
//# There is some uncertainty regarding how long it will take for the wait 
//# control to stop the transmitter (we have synchronization on the way, 
//# which may cause +/-1 cycle of uncertainty).
//# Our main fifo on the input port of the receiver is robust enough
//# (has enough entries) to receive all of the transactions sent during the
//# time of "wait traveling" without loosing any information.
//# But the uncertainty mentioned above forces us to start from empty fifo
//# every time after wait indication is raised in order to ensure that 
//# the number of available entries won't be reduced.
//#              
//#####################################################################
module etx_protocol (/*AUTOARG*/
   // Outputs
   etx_rd_wait, etx_wr_wait, etx_wait, etx_io_wait, tx_frame_par,
   tx_data_par,
   // Inputs
   etx_access, etx_packet, ecfg_tx_tp_enable, ecfg_dataout,
   ecfg_tx_enable, ecfg_tx_gpio_enable, ecfg_access, ecfg_packet,
   reset, tx_lclk_div4, tx_rd_wait, tx_wr_wait
   );

   parameter PW = 104;
   parameter AW = 32;   
   parameter DW = 32;
   
   //Bus side
   input          etx_access;
   input [PW-1:0] etx_packet;  
   output         etx_rd_wait;
   output         etx_wr_wait;
   output         etx_wait;     //for pipeline
   output         etx_io_wait;  //for arbiter

   //Enables transmit test pattern
   input 	  ecfg_tx_tp_enable;
   input [8:0]    ecfg_dataout;
   input 	  ecfg_tx_enable;
   input 	  ecfg_tx_gpio_enable;

   //Test Insertion
   input 	  ecfg_access;
   input [PW-1:0] ecfg_packet;
   
   // IO side (8 eLink bytes at a time)
   input 	  reset;
   input          tx_lclk_div4;// Parallel-rate clock from eClock block
   output [7:0]   tx_frame_par;
   output [63:0]  tx_data_par;
   input          tx_rd_wait;  // The wait signals are passed through
   input          tx_wr_wait;  // to the emesh interfaces

   //############
   //# Local regs & wires
   //############
   reg           etx_sample;   //hold for second cycle
   reg [7:0]     tx_frame_par;
   reg [127:0]   tx_data_reg;  //sample transaction on one clock cycle
   reg 		 rd_wait_sync;
   reg 		 wr_wait_sync;
   reg 		 etx_rd_wait;
   reg 		 etx_wr_wait;

   wire 	 etx_write;
   wire [1:0] 	 etx_datamode;
   wire [3:0]	 etx_ctrlmode;
   wire [AW-1:0] etx_dstaddr;
   wire [DW-1:0] etx_data;
   wire [AW-1:0] etx_srcaddr;
   wire 	 access_mux;
   wire 	 ecfg_access_sync;
   wire [PW-1:0] packet_mux;
	 
   //Synchronize access signal
   synchronizer #(.DW(1)) synchronizer(.out		(ecfg_access_sync),
				      .in		(ecfg_access),
				      .clk		(tx_lclk_div4),
				      .reset		(reset)
				      );

   assign access_mux = ecfg_access_sync | etx_access;


   assign packet_mux[PW-1:0] = ecfg_access_sync ? ecfg_packet[PW-1:0] :
	                                          etx_packet[PW-1:0];

   //packet to emesh bundle
   packet2emesh p2m (
		     // Outputs
		     .access_out	(),
		     .write_out		(etx_write),
		     .datamode_out	(etx_datamode[1:0]),
		     .ctrlmode_out	(etx_ctrlmode[3:0]),
		     .dstaddr_out	(etx_dstaddr[31:0]),
		     .data_out		(etx_data[31:0]),
		     .srcaddr_out	(etx_srcaddr[31:0]),
		     // Inputs
		     .packet_in		(packet_mux[PW-1:0]));

  
      
   // TODO: Bursts
   always @( posedge tx_lclk_div4 or posedge reset ) 
     begin
	if(reset) 
	  begin	     
             etx_sample         <= 1'b1;
             tx_frame_par[7:0]  <= 8'd0;
             tx_data_reg[127:0] <= 'd0;	     
	  end 
	else 
	  begin
             if( access_mux & etx_sample ) //first cycle
	       begin
		  etx_sample          <= 1'b0;
		  tx_frame_par[7:0]   <= 8'h3F;
		  tx_data_reg[127:0]  <= {etx_data[31:0], 
					 etx_srcaddr[31:0],
					 8'd0,  // Not used
					 8'd0,  //not used
					 ~etx_write, 7'd0, // B0-TODO: For bursts, add the inc bit
					 etx_ctrlmode[3:0], etx_dstaddr[31:28], // B1
					 etx_dstaddr[27:4],  // B2, B3, B4
					 etx_dstaddr[3:0], etx_datamode[1:0], etx_write, etx_access // B5
				   };
               end 
	     else if(~etx_sample ) //second cycle (1)
	       begin
		  etx_sample        <= 1'b1;
		  tx_frame_par[7:0] <= 8'hFF;
               end 
	     else 
	       begin
		  etx_sample          <= 1'b1;
		  tx_frame_par[7:0]   <= 'd0;
		  tx_data_reg[127:0]  <= 'd0;
               end
	  end // else: !if(reset)	
     end // always @ ( posedge txlclk_p or posedge reset )


   //After first sample, etx_sample-->0 use as indicator to sample in data.
   assign tx_data_par[63:0] = ~etx_sample ? tx_data_reg[63:0] : //first cycle
                                            tx_data_reg[127:64];//all others, 0 or upper
      
   //#############################
   //# Wait signals (async)
   //#############################

   always @ (posedge tx_lclk_div4) 
     begin
	rd_wait_sync <= tx_rd_wait;
	etx_rd_wait  <= rd_wait_sync;
	wr_wait_sync <= tx_wr_wait;
	etx_wr_wait  <= wr_wait_sync;
     end

   //#############################
   //# Pipeline stall
   //#############################

   assign etx_io_wait = ~etx_sample;

   assign etx_wait    = etx_io_wait |
			etx_rd_wait |
			etx_wr_wait;
      
   
endmodule // etx_protocol
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:

/*
  File: etx_protocol.v
 
  This file is part of the Parallella Project.

  Copyright (C) 2014 Adapteva, Inc.
  Contributed by Fred Huettig <fred@adapteva.com>

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program (see the file COPYING).  If not, see
  <http://www.gnu.org/licenses/>.
*/
