module etx_protocol (/*AUTOARG*/
   // Outputs
   etx_rd_wait, etx_wr_wait, tx_frame_par, tx_data_par,
   // Inputs
   reset, clk, etx_access, etx_packet, tx_enable, gpio_data,
   gpio_enable, tx_rd_wait, tx_wr_wait
   );

   parameter PW = 104;
   parameter AW = 32;   
   parameter DW = 32;
   parameter ID = 12'h000;
   
   //Clock/reset
   input 	  reset;
   input          clk;

   //System side
   input          etx_access;
   input [PW-1:0] etx_packet;  

   //Pushback signals
   output         etx_rd_wait;
   output         etx_wr_wait;

   //Enble transmit
   input 	  tx_enable;   //transmit enable
   input [8:0]    gpio_data;   //TODO
   input    	  gpio_enable; //TODO
   
   //Interface to IO
   output [7:0]   tx_frame_par;
   output [63:0]  tx_data_par;
   input          tx_rd_wait;  // The wait signals are passed through
   input          tx_wr_wait;  // to the emesh interfaces

   //###################################################################
   //# Local regs & wires
   //###################################################################
   reg [7:0]     tx_frame_par;
   reg [127:0] 	 tx_data_reg; 
   wire		 tx_rd_wait_sync;
   wire 	 tx_wr_wait_sync;

   wire 	 etx_write;
   wire [1:0] 	 etx_datamode;
   wire [3:0]	 etx_ctrlmode;
   wire [AW-1:0] etx_dstaddr;
   wire [DW-1:0] etx_data;
   wire [AW-1:0] etx_srcaddr;
   reg [PW-1:0]  testpacket;
   wire 	 etx_valid;
   reg           etx_io_wait;
   
   
   
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
		     .packet_in		(etx_packet[PW-1:0])
		     );

   //Transmit packet enable
   //Only set valid if not wait 
   assign etx_valid = (tx_enable & etx_access & ~(etx_dstaddr[31:20]==ID)) &
		       ((etx_write & ~tx_wr_wait_sync) | 
			 (~etx_write & ~tx_rd_wait_sync)
			 );
   
   //One cycle hold for every transaction
   always @( posedge clk or posedge reset )
     if(reset)
       etx_io_wait <= 1'b0;
     else
       etx_io_wait <= etx_valid & ~etx_io_wait;
   
   // TODO: Bursts
   always @( posedge clk or posedge reset ) 
     begin
	if(reset) 
	  begin	     
             tx_frame_par[7:0] <= 8'd0;
             tx_data_reg[127:0] <= 'd0;	     
	  end 
	else 
	  begin
             if( etx_valid & ~etx_io_wait ) //first cycle
	       begin
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
	     else if(etx_io_wait ) //second cycle (1), completes transaction
	       begin
		  tx_frame_par[7:0] <= 8'hFF;
               end 
	     else 
	       begin
		  tx_frame_par[7:0]  <= 'd0;
		  tx_data_reg[127:0] <= 'd0;
               end
	  end // else: !if(reset)	
     end // always @ ( posedge txlclk_p or posedge reset )

   assign tx_data_par[63:0] = (tx_frame_par[0] & etx_io_wait)  ? tx_data_reg[63:0] :
			      (tx_frame_par[0] & ~etx_io_wait) ? tx_data_reg[127:64] :
			                                         64'b0;
           
   //#############################
   //# Wait signals (async)
   //#############################

   synchronizer #(.DW(1)) rd_sync (// Outputs
				   .out		(tx_rd_wait_sync),
				   // Inputs
				   .in		(tx_rd_wait),
				   .clk		(clk),
				   .reset	(reset)
				   );
   
   synchronizer #(.DW(1)) wr_sync (// Outputs
				   .out		(tx_wr_wait_sync),
				   // Inputs
				   .in		(tx_wr_wait),
				   .clk		(clk),
				   .reset	(reset)
				   );

   //Stall for all etx pipeline
   assign etx_wr_wait = tx_wr_wait_sync | etx_io_wait;
   assign etx_rd_wait = tx_rd_wait_sync | etx_io_wait;
        
endmodule // etx_protocol
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:

/*
  File: etx_protocol.v
 
  This file is part of the Parallella Project.

  Copyright (C) 2014 Adapteva, Inc.
 Contributed by Fred Huettig <fred@adapteva.com>
 Contributed by Andreas Olofsson <andreas@adapteva.com>

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
