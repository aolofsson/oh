module etx_io (/*AUTOARG*/
   // Outputs
   txo_lclk_p, txo_lclk_n, txo_frame_p, txo_frame_n, txo_data_p,
   txo_data_n, tx_io_wait, tx_wr_wait, tx_rd_wait,
   // Inputs
   ioreset, tx_lclk, tx_lclk90, tx_lclk_div4, txi_wr_wait_p,
   txi_wr_wait_n, txi_rd_wait_p, txi_rd_wait_n, tx_packet, tx_access,
   tx_burst
   );

   parameter IOSTD_ELINK = "LVDS_25";
   parameter PW   = 104;
   
   //###########
   //# reset, clocks
   //##########
   input        ioreset;             //reset for io  
   input 	tx_lclk;	     // fast clock for io
   input 	tx_lclk90;           // fast 90deg shifted lclk   
   input 	tx_lclk_div4;	     // slow clock for rest of logic   
   
   //###########
   //# eLink pins
   //###########
   output 	txo_lclk_p,   txo_lclk_n;     // tx clock output
   output 	txo_frame_p, txo_frame_n;     // tx frame signal
   output [7:0] txo_data_p, txo_data_n;       // tx data (dual data rate)
   input 	txi_wr_wait_p,txi_wr_wait_n;  // tx write pushback
   input 	txi_rd_wait_p, txi_rd_wait_n; // tx read pushback

   //#############
   //# Fabric interface
   //#############
   input [PW-1:0] tx_packet;
   input          tx_access;
   input          tx_burst;
   output 	  tx_io_wait;   
   output 	  tx_wr_wait;
   output 	  tx_rd_wait;
   
   //############
   //# REGS
   //############
   reg [7:0] 	  tx_pointer;   
   reg [15:0] 	  tx_data16;
   reg [7:0] 	  tx_data;
   reg 		  tx_access_reg;
   reg 		  tx_frame;
   reg 		  tx_io_wait_reg;

   //############
   //# WIRES
   //############
   wire 	  new_tran;
   wire 	  access;
   wire 	  write;
   wire [1:0] 	  datamode;   
   wire [3:0]	  ctrlmode;
   wire [31:0] 	  dstaddr;
   wire [31:0] 	  data;
   wire [31:0] 	  srcaddr;
   
   //#############################
   //# Disassemble packet (for clarity)
   //#############################  
   packet2emesh p2e (
		     // Outputs
		     .access_out	(access),
		     .write_out		(write),
		     .datamode_out	(datamode[1:0]),
		     .ctrlmode_out	(ctrlmode[3:0]),
		     .dstaddr_out	(dstaddr[31:0]),
		     .data_out		(data[31:0]),
		     .srcaddr_out	(srcaddr[31:0]),
		     // Inputs
		     .packet_in		(tx_packet[PW-1:0]));
   
   
   //#############################
   //# Transaction state machine
   //#############################  
   always @ (posedge tx_lclk)
     if (~tx_access)
       tx_pointer[7:0] <= 8'b00000001; //new transaction
     else if (tx_pointer[6] & tx_burst)
       tx_pointer[7:0] <= 8'b00001000; //burst
     else
       tx_pointer[7:0] <= {tx_pointer[6:0],tx_pointer[7]};

   //#############################
   //# Frame Signal
   //#############################  
   //TODO: cleanup
   assign tx_io_wait = tx_access & ~tx_burst & ~tx_io_wait_reg;
      
   always @ (posedge tx_lclk_div4 or posedge ioreset)
     if(ioreset)
       tx_io_wait_reg <= 1'b0;
     else	 
       tx_io_wait_reg <= tx_io_wait;
   
   //#############################
   //# Frame Signal
   //#############################  
   always @ (posedge tx_lclk or posedge ioreset)
     if(ioreset)
       tx_frame <= 1'b0;   
     else if(tx_pointer[0] & tx_access)
       tx_frame <= 1'b1;
     else if(tx_pointer[7] & ~tx_burst)
       tx_frame <= 1'b0;
   
   //#############################
   //# SELECTING DATA PER CYCLE
   //#############################  
   //optimize later...
   always @ (negedge tx_lclk)
     case(tx_pointer[6:0])
       //Cycle0
       7'b0000001: tx_data16[15:0] <= {ctrlmode[3:0],dstaddr[31:28],~write,7'b0};
       //Cycle1
       7'b0000010: tx_data16[15:0] <= {dstaddr[19:12],dstaddr[27:20]};
       //Cycle2
       7'b0000100: tx_data16[15:0] <= {dstaddr[3:0],datamode[1:0],write,access,
				        dstaddr[11:4]};       
       //Cycle3
       7'b0001000: tx_data16[15:0] <= {data[23:16],data[31:24]};
       //Cycle4				      
       7'b0010000: tx_data16[15:0] <= {data[7:0],data[15:8]};            
       //Cycle5
       7'b0100000: tx_data16[15:0] <= {srcaddr[23:16],srcaddr[31:24]};
       //Cycle6
       7'b1000000: tx_data16[15:0] <= {srcaddr[7:0],srcaddr[15:8]};
       default  tx_data16[15:0]    <= 16'b0;
     endcase // case (tx_pointer[7:0])
             
   //#############################
   //# DATA (DDR)
   //#############################  
   always @ (negedge tx_lclk)
     tx_data[7:0] <= tx_data16[15:8];

   always @ (posedge tx_lclk)
     tx_data[7:0] <= tx_data16[7:0];
		  
   //##############################
   //# OUTPUT BUFFERS
   //##############################

   OBUFDS obufds_data[7:0] (
			     .O   (txo_data_p[7:0]),
			     .OB  (txo_data_n[7:0]),
			     .I   (tx_data)
			     );
   
   OBUFDS obufds_frame ( .O   (txo_frame_p),
			 .OB  (txo_frame_n),
			 .I   (tx_frame)
			 );

   OBUFDS obufds_lclk ( .O   (txo_lclk_p),
			.OB  (txo_lclk_n),
			.I   (tx_lclk90)
			);
   
   //################################
   //# Wait Input Buffers
   //################################
   
   IBUFDS
     #(.DIFF_TERM  ("TRUE"),     // Differential termination
       .IOSTANDARD (IOSTD_ELINK))
   ibufds_wrwait
     (.I     (txi_wr_wait_p),
      .IB    (txi_wr_wait_n),
      .O     (tx_wr_wait));
  
//TODO: Come up with cleaner defines for this
//Parallella and other platforms...   
`ifdef TODO
  IBUFDS
     #(.DIFF_TERM  ("TRUE"),     // Differential termination
       .IOSTANDARD (IOSTD_ELINK))
   ibufds_rdwait
     (.I     (txi_rd_wait_p),
      .IB    (txi_rd_wait_n),
      .O     (tx_rd_wait));
`else
   //On Parallella this signal comes in single-ended
   assign tx_rd_wait = txi_rd_wait_p;
`endif


   
endmodule // etx_io
// Local Variables:
// verilog-library-directories:("." "../../emesh/hdl")
// End:


/*
  Copyright (C) 2014 Adapteva, Inc.
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
