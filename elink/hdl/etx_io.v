module etx_io (/*AUTOARG*/
   // Outputs
   txo_lclk_p, txo_lclk_n, txo_frame_p, txo_frame_n, txo_data_p,
   txo_data_n, tx_io_wait, tx_wr_wait, tx_rd_wait,
   // Inputs
   reset, tx_lclk, tx_lclk90, tx_lclk_div4, txi_wr_wait_p,
   txi_wr_wait_n, txi_rd_wait_p, txi_rd_wait_n, tx_packet, tx_access,
   tx_burst
   );

   parameter IOSTD_ELINK = "LVDS_25";
   parameter PW   = 104;
   
   //###########
   //# reset, clocks
   //##########
   input        reset;             //reset for io  
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
   wire [7:0] 	  txo_data;
   wire 	  txo_frame;   
   wire 	  txo_lclk90;
   
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
      
   always @ (posedge tx_lclk_div4 or posedge reset)
     if(reset)
       tx_io_wait_reg <= 1'b0;
     else	 
       tx_io_wait_reg <= tx_io_wait;
   
   //#############################
   //# Frame Signal
   //#############################  
   
   always @ (posedge tx_lclk or posedge reset)
     if(reset)
       tx_frame <= 1'b0;   
     else if(tx_pointer[0] & tx_access)
       tx_frame <= 1'b1;
     else if(tx_pointer[7] & ~tx_burst)
       tx_frame <= 1'b0;
   
   //#############################
   //# SELECTING DATA PER CYCLE
   //#############################  
   always @ (posedge tx_lclk)
     case({tx_access,tx_pointer[6:0]})
       //Cycle0
       8'b10000001: tx_data16[15:0] <= {~write,7'b0,ctrlmode[3:0],dstaddr[31:28]};
       //Cycle1
       8'b10000010: tx_data16[15:0] <= {dstaddr[27:20],dstaddr[19:12]};
       //Cycle2
       8'b10000100: tx_data16[15:0] <= {dstaddr[11:4],
					dstaddr[3:0],datamode[1:0],write,access
				        };       
       //Cycle3
       8'b10001000: tx_data16[15:0] <= {data[31:24],data[23:16]};
       //Cycle4				      
       8'b10010000: tx_data16[15:0] <= {data[15:8],data[7:0]};            
       //Cycle5
       8'b10100000: tx_data16[15:0] <= {srcaddr[31:24],srcaddr[23:16]};
       //Cycle6
       8'b11000000: tx_data16[15:0] <= {srcaddr[15:8],srcaddr[7:0]};
       default  tx_data16[15:0]    <= 16'b0;
     endcase // case (tx_pointer[7:0])
             
   //#############################
   //# ODDR DRIVERS
   //#############################  

   //DATA
   genvar        i;
   generate for(i=0; i<8; i=i+1)
     begin : gen_oddr
	ODDR #(.DDR_CLK_EDGE  ("SAME_EDGE"))
	oddr_data (
		   .Q  (txo_data[i]),
		   .C  (tx_lclk),
		   .CE (1'b1),
		   .D1 (tx_data16[i+8]),
		   .D2 (tx_data16[i]),
		   .R  (1'b0),
		   .S  (1'b0)
		   );
     end
     endgenerate

   //FRAME
   ODDR #(.DDR_CLK_EDGE  ("SAME_EDGE"))
   oddr_frame (
	      .Q  (txo_frame),
	      .C  (tx_lclk),
	      .CE (1'b1),
	      .D1 (tx_frame),
	      .D2 (tx_frame),
	      .R  (reset), //TODO: should this be buffered?
	      .S  (1'b0)
	      );
   
   //LCLK
   ODDR #(.DDR_CLK_EDGE  ("SAME_EDGE"))
   oddr_lclk (
	      .Q  (txo_lclk90),
	      .C  (tx_lclk90),
	      .CE (1'b1),
	      .D1 (1'b1),
	      .D2 (1'b0),
	      .R  (reset),//make TX clock quiet during reset
	      .S  (1'b0)
	      );
		  
   //##############################
   //# OUTPUT BUFFERS
   //##############################

   OBUFDS obufds_data[7:0] (
			     .O   (txo_data_p[7:0]),
			     .OB  (txo_data_n[7:0]),
			     .I   (txo_data[7:0])
			     );
   
   OBUFDS obufds_frame ( .O   (txo_frame_p),
			 .OB  (txo_frame_n),
			 .I   (txo_frame)
			 );

   OBUFDS obufds_lclk ( .O   (txo_lclk_p),
			.OB  (txo_lclk_n),
			.I   (txo_lclk90)
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
  Contributed by Gunnar Hillerstrom
 
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
