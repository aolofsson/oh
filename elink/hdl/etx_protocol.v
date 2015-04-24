/*
 ########################################################################
 EPIPHANY eLink TX Protocol block
 ########################################################################
 
 This block takes standard eMesh protocol (104-bit transactions) and
 encodes the bytes into 8-byte parallel outputs for the output 
 serializers.
 */

module etx_protocol (/*AUTOARG*/
   // Outputs
   etx_rd_wait, etx_wr_wait, etx_wait, tx_frame_par, tx_data_par,
   // Inputs
   etx_access, etx_packet, ecfg_tx_tp_enable, ecfg_dataout,
   ecfg_tx_enable, ecfg_tx_gpio_enable, reset, tx_lclk_div4,
   tx_rd_wait, tx_wr_wait
   );

   parameter PW = 104;
   parameter AW = 32;   
   parameter DW = 32;
   
   //Bus side
   input          etx_access;
   input [PW-1:0] etx_packet;  
   output         etx_rd_wait;
   output         etx_wr_wait;
   output         etx_wait;

   //Enables transmit test pattern
   input 	  ecfg_tx_tp_enable;
   input [8:0]    ecfg_dataout;
   input 	  ecfg_tx_enable;
   input 	  ecfg_tx_gpio_enable;
   
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
   reg           etx_cycle;    //Cycle 0 or 1
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
		     .packet_in		(etx_packet[PW-1:0]));
      
   // TODO: Bursts
   always @( posedge tx_lclk_div4 or posedge reset ) 
     begin
	if(reset) 
	  begin	     
             etx_cycle          <= 1'b0;
             tx_frame_par[7:0]  <= 8'd0;
             tx_data_reg[127:0] <= 'd0;	     
	  end 
	else 
	  begin
             if( etx_access & ~etx_cycle ) //first cycle (0)
	       begin
		  etx_cycle           <= 1'b1;
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
	     else if( etx_cycle ) //second cycle (1)
	       begin
		  etx_cycle  <= 1'b0;
		  tx_frame_par[7:0] <= 8'hFF;
               end 
	     else 
	       begin
		  etx_cycle           <= 1'b0;
		  tx_frame_par[7:0]   <= 8'h00;
		  tx_data_reg[127:0]  <= 64'd0;
               end
	  end // else: !if(reset)	
     end // always @ ( posedge txlclk_p or posedge reset )


   //First/second cycle select
   assign tx_data_par[63:0] = etx_cycle ? tx_data_reg[127:64]:
			                  tx_data_reg[63:0];
      
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

   assign etx_wait = etx_cycle   |
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
