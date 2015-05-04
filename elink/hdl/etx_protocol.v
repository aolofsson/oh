module etx_protocol (/*AUTOARG*/
   // Outputs
   etx_rd_wait, etx_wr_wait, etx_wait, etx_io_wait, tx_frame_par,
   tx_data_par,
   // Inputs
   reset, clk, testmode, etx_access, etx_packet, tx_enable, tp_enable,
   gpio_enable, gpio_data, chipid, tx_rd_wait, tx_wr_wait
   );

   parameter PW = 104;
   parameter AW = 32;   
   parameter DW = 32;
   parameter ID = 12'h000;
   
   //Clock/reset
   input 	  reset;
   input          clk;

   //Puts transmit in testmode
   input 	  testmode;

   //System side
   input          etx_access;
   input [PW-1:0] etx_packet;  

   //Pushback signals
   output         etx_rd_wait;
   output         etx_wr_wait;
   output         etx_wait;     //for pipeline
   output         etx_io_wait;  //for arbiter

   //Enble transmit
   input 	  tx_enable;  //transmit enable
   input 	  tp_enable;  //testmode enable
   input 	  gpio_enable;//gpio enable
   input [8:0]    gpio_data;  //gpio mode data
   input [11:0]   chipid;     //chip id
   
   //Interface to IO
   output [7:0]   tx_frame_par;
   output [63:0]  tx_data_par;
   input          tx_rd_wait;  // The wait signals are passed through
   input          tx_wr_wait;  // to the emesh interfaces

   //###################################################################
   //# Local regs & wires
   //###################################################################
   reg           etx_sample;   //hold for second cycle
   reg [7:0]     tx_frame_par;
   reg [127:0]   tx_data_reg;  //sample transaction on one clock cycle
   reg 		 rd_wait_sync;
   reg 		 wr_wait_sync;

   wire 	 etx_write;
   wire [1:0] 	 etx_datamode;
   wire [3:0]	 etx_ctrlmode;
   wire [AW-1:0] etx_dstaddr;
   wire [DW-1:0] etx_data;
   wire [AW-1:0] etx_srcaddr;
   wire [PW-1:0] etx_packet_mux;
   reg [PW-1:0]  testpacket;
   
   //Testmode logic
   always @( posedge clk or posedge reset ) 
     if(reset)
       testpacket[PW-1:0] <= 'd0;
     else if(testmode)
       if(~testpacket[1])//initiate write 
	 testpacket[PW-1:0]<={32'h55555555,//src
                              32'h55555555,//data
                              chipid[11:0],20'b0,//dst
                              4'b0,2'b10,2'b11};//32bit write
       else //initiate read
	 testpacket[PW-1:0]<={ID,12'hF03,`ERX_RR,2'b0,//src
                              32'haaaaaaaa,//dummy data
                              chipid[11:0],20'b0,//read from address
                              4'b0,2'b10,2'b01};//32bit read

   assign etx_packet_mux[PW-1:0] = testmode ? testpacket[PW-1:0] :
                                              etx_packet[PW-1:0];
   
   //Access always on in test mode (assumes no other traffic)
   assign etx_access_mux = testmode | etx_access;
   
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
		     .packet_in		(etx_packet_mux[PW-1:0])
		     );

   //Transmit packet enable
   assign etx_enable =  (testmode | tx_enable) & ~(etx_dstaddr[31:20]==ID) ;
  
   // TODO: Bursts
   always @( posedge clk or posedge reset ) 
     begin
	if(reset) 
	  begin	     
             etx_sample         <= 1'b1;
             tx_frame_par[7:0]  <= 8'd0;
             tx_data_reg[127:0] <= 'd0;	     
	  end 
	else 
	  begin
             if( etx_enable & etx_access & etx_sample ) //first cycle
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
	     else if(etx_enable & ~etx_sample ) //second cycle (1)
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

   synchronizer #(.DW(1)) rd_sync (// Outputs
				   .out		(etx_rd_wait),
				   // Inputs
				   .in		(tx_rd_wait),
				   .clk		(clk),
				   .reset	(reset)
				   );
   
   synchronizer #(.DW(1)) wr_sync (// Outputs
				   .out		(etx_wr_wait),
				   // Inputs
				   .in		(tx_wr_wait),
				   .clk		(clk),
				   .reset	(reset)
				   );

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
