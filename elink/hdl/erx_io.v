\/*
 This block receives the IO transaction and converts to a 104 bit packet. 
 */
`include "elink_constants.v"
module erx_io (/*AUTOARG*/
   // Outputs
   rx_lclk_pll, rxo_wr_wait_p, rxo_wr_wait_n, rxo_rd_wait_p,
   rxo_rd_wait_n, rx_access, rx_burst, rx_packet,
   // Inputs
   reset, rx_lclk, rx_lclk_div4, rxi_lclk_p, rxi_lclk_n, rxi_frame_p,
   rxi_frame_n, rxi_data_p, rxi_data_n, rx_wr_wait, rx_rd_wait
   );

   parameter IOSTD_ELINK = "LVDS_25";
   parameter PW = 104;

   // Can we do this in a better way?
   //parameter [8:0] RX_TAP_DELAY [8:0];
   
   reg [3:0] RX_TAP_DELAY[8:0];
   initial
     begin
	RX_TAP_DELAY[0]=4'd15;
	RX_TAP_DELAY[1]=4'd15;
	RX_TAP_DELAY[2]=4'd15;
	RX_TAP_DELAY[3]=4'd15;
	RX_TAP_DELAY[4]=4'd14;
	RX_TAP_DELAY[5]=4'd15;
	RX_TAP_DELAY[6]=4'd14;
	RX_TAP_DELAY[7]=4'd15;
	RX_TAP_DELAY[8]=4'd14;
     end

   //#########################
   //# reset, clocks
   //#########################
   input       reset;                       // reset
   input       rx_lclk;                     // fast I/O clock
   input       rx_lclk_div4;                // slow clock
   output      rx_lclk_pll;                 // clock output for pll
   
   //##########################
   //# elink pins
   //##########################
   input       rxi_lclk_p,   rxi_lclk_n;    // rx clock input
   input       rxi_frame_p,  rxi_frame_n;   // rx frame signal
   input [7:0] rxi_data_p,   rxi_data_n;    // rx data
   output      rxo_wr_wait_p,rxo_wr_wait_n; // rx write pushback output
   output      rxo_rd_wait_p,rxo_rd_wait_n; // rx read pushback output
  
   //##########################
   //# erx logic interface
   //##########################
   output 	   rx_access;
   output 	   rx_burst;
   output [PW-1:0] rx_packet;
   input           rx_wr_wait;
   input           rx_rd_wait;

   //############
   //# WIRES
   //############
   wire [7:0]    rxi_data;
   wire          rxi_frame;
   wire 	 rxi_lclk;
   wire 	 access_wide;
   reg 		 valid_packet;
   wire [15:0]   rx_word;
   reg [15:0] 	 rx_word_sync;
   
   //############
   //# REGS
   //############
   reg [7:0] 	 data_even_reg;   
   reg [7:0] 	 data_odd_reg;
   wire [1:0] 	 rx_frame;
   reg [1:0] 	 rx_frame_sync;
   wire  	 rx_frame_old;
   reg [111:0]   rx_sample; 
   reg [6:0] 	 rx_pointer;
   reg 		 access;  
   reg 		 burst;
   reg [PW-1:0]  rx_packet_lclk;
   reg 		 rx_access;
   reg [PW-1:0]  rx_packet;
   reg 		 rx_burst;
   wire 	 rx_lclk_iddr;
   wire [8:0] 	 rxi_delay_in;
   wire [8:0] 	 rxi_delay_out;
   reg 		 reset_sync;
   
   //Reset sync
   always @ (posedge rx_lclk)
     reset_sync <= reset;
   
   //#####################
   //#CREATE 112 BIT PACKET 
   //#####################
   //TODO: clean up!
   //write Pointer   
   always @ (posedge rx_lclk)
     if (~rx_frame_sync[1]) begin
	rx_pointer <= 3'b0; //new frame
	access <= 1'b0;
     end
     else if (rx_pointer != 3'd6 && (rx_frame_sync != 2'b00))
       begin
	rx_pointer <= rx_pointer + 1; //anticipate burst
	access <= 1'b0;
     end
     else begin
	rx_pointer <= 3'd3;//middle of frame
	access <= 1'b1;
     end

   
   // shift register for rx_word
   always @ (posedge rx_lclk)
     case (rx_frame_sync[1:0])
       2'b01 : begin
	  rx_sample[111:8] <= rx_sample[103:0];
	  rx_sample[7:0] <= rx_word_sync[7:0];
       end
       2'b10 : begin
	  rx_sample[111:8] <= rx_sample[103:0];
	  rx_sample[7:0] <= rx_word_sync[15:8];
       end
       2'b11 : begin
	  rx_sample[111:16] <= rx_sample[95:0];
	  rx_sample[15:0] <= rx_word_sync[15:0];
       end
       default :
	 rx_sample <= rx_sample;
     endcase // case (rx_frame_sync[1:0])
   
   
   //#####################  
   //#DATA VALID SIGNAL 
   //####################
 
   always @ (posedge rx_lclk)
     begin     
	valid_packet <= access;//data pipeline
     end
   
   reg burst_detect;   
   always @ (posedge rx_lclk)
     if(access & rx_frame_sync[1])
       burst_detect <= 1'b1;
     else if(~rx_frame_sync)
       burst_detect <= 1'b0;
   
   //###################################
   //#SAMPLE AND HOLD DATA
   //###################################

   //(..and shuffle data for 104 bit packet)
   always @ (posedge rx_lclk)
     if(access)   
       begin
	  //pipelin burst (delay by one frame)
	  burst                 <= burst_detect;	  
	  
	  //access
	  rx_packet_lclk[0]     <= rx_sample[64];
	  
	  //write
	  rx_packet_lclk[1]     <= rx_sample[65];
	  
	  //datamode
	  rx_packet_lclk[3:2]   <= rx_sample[67:66];
	  
	  //ctrlmode
	  rx_packet_lclk[7:4]   <= rx_sample[103:100];
	  
	  //dstaddr
	  rx_packet_lclk[39:8]  <= rx_sample[99:68];
	  
	  //data
	  rx_packet_lclk[71:40] <= rx_sample[63:32];
	  
	  //srcaddr
	  rx_packet_lclk[103:72]<= rx_sample[31:0];
       end

   //###################################
   //#SYNCHRONIZE TO SLOW CLK
   //###################################
 
   //stretch access pulse to 4 cycles
   pulse_stretcher #(.DW(3)) 
   ps0 (
	.out(access_wide),
	.in(valid_packet),
	.clk(rx_lclk),
	.reset(reset_sync));

   
   always @ (posedge rx_lclk_div4)
     rx_access <= access_wide;
   
   always @ (posedge rx_lclk_div4)
     if(access_wide)
       begin
	  rx_packet[PW-1:0] <= rx_packet_lclk[PW-1:0];
	  rx_burst          <= burst;	  
       end


   //################################
   //# I/O Buffers Instantiation
   //################################

   IBUFDS  #(.DIFF_TERM  ("TRUE"),.IOSTANDARD (IOSTD_ELINK))
   ibuf_data[7:0] 
     (.I     (rxi_data_p[7:0]),
      .IB    (rxi_data_n[7:0]),
      .O     (rxi_data[7:0]));
   
   IBUFDS #(.DIFF_TERM  ("TRUE"), .IOSTANDARD (IOSTD_ELINK))
   ibuf_frame
     (.I     (rxi_frame_p),
      .IB    (rxi_frame_n),
      .O     (rxi_frame));


   IBUFGDS #(.DIFF_TERM  ("TRUE"),.IOSTANDARD (IOSTD_ELINK))
   ibuf_lclk (.I     (rxi_lclk_p),
	      .IB    (rxi_lclk_n),
	      .O     (rxi_lclk)
	      );
	      


`ifdef EPHYCARD
    OBUFT #(.IOSTANDARD("LVCMOS18"), .SLEW("SLOW"))
    obuft_wrwait (
		    .O(rxo_wr_wait_p),
		    .T(rx_wr_wait),
		    .I(1'b0)
		    );
		    
	OBUFT #(.IOSTANDARD("LVCMOS18"), .SLEW("SLOW"))
    obuft_rdwait (
             .O(rxo_rd_wait_p),
             .T(rx_rd_wait),
             .I(1'b0)
              );

`else
      
   OBUFDS #(.IOSTANDARD(IOSTD_ELINK),.SLEW("SLOW")) 
   obufds_wrwait (
		    .O(rxo_wr_wait_p),
		    .OB(rxo_wr_wait_n),
		    .I(rx_wr_wait)
		    );
   
   OBUFDS  #(.IOSTANDARD(IOSTD_ELINK),.SLEW("SLOW")) 
   obufds_rdwait  (.O(rxo_rd_wait_p),
		   .OB(rxo_rd_wait_n),
		   .I(rx_rd_wait)
		   );
`endif
   //###################################
   //#RX CLOCK
   //###################################

   BUFG rxi_lclk_bufg_i(.I(rxi_lclk), .O(rx_lclk_pll));  //for rest of io
   BUFIO rx_lclk_bufio_i(.I(rxi_lclk), .O(rx_lclk_iddr));//for iddr

   //###################################
   //#IDELAY CIRCUIT
   //###################################

   assign  rxi_delay_in[8:0] ={rxi_frame,rxi_data[7:0]};
   
   genvar        j;
   generate for(j=0; j<9; j=j+1)
     begin : gen_idelay
	(* IODELAY_GROUP = "IDELAY_GROUP" *) // Group name for IDELAYCTRL
	
	IDELAYE2 #(.CINVCTRL_SEL("FALSE"),
		   .DELAY_SRC("IDATAIN"), 
		   .HIGH_PERFORMANCE_MODE("FALSE"),
		   .IDELAY_TYPE("FIXED"),
		   .IDELAY_VALUE(0), //(RX_TAP_DELAY[j]
		   .PIPE_SEL("FALSE"),
		   .REFCLK_FREQUENCY(200.0),
		   .SIGNAL_PATTERN("DATA"))
	idelay_inst (.CNTVALUEOUT(),                   
		     .DATAOUT(rxi_delay_out[j]),
		     .C(1'b0),
		     .CE(1'b0),
		     .CINVCTRL(1'b0),
		     .CNTVALUEIN(5'b0),
		     .DATAIN(1'b0),
		     .IDATAIN(rxi_delay_in[j]),
		     .INC(1'b0),
		     .LD(1'b0),
		     .LDPIPEEN(1'b0),
		     .REGRST(1'b0)
		     );
     end // block: gen_idelay
   endgenerate

   
   //#############################
   //# IDDR SAMPLERS
   //#############################  
 
   //DATA
   genvar        i;
   generate for(i=0; i<8; i=i+1)
     begin : gen_iddr
	IDDR #(.DDR_CLK_EDGE  ("SAME_EDGE"), .SRTYPE("ASYNC"))
	iddr_data (
		   .Q1 (rx_word[i]),
		   .Q2 (rx_word[i+8]),
		   .C  (rx_lclk_iddr),
		   .CE (1'b1),
		   .D  (rxi_delay_out[i]),
		   .R  (reset_sync),
		   .S  (1'b0)
		   );
     end
     endgenerate

   //FRAME
   IDDR #(.DDR_CLK_EDGE  ("SAME_EDGE"), .SRTYPE("ASYNC"))
	iddr_frame (
		   .Q1 (rx_frame[0]),
		   .Q2 (rx_frame[1]),    
		   .C  (rx_lclk_iddr),
		   .CE (1'b1),
		   .D  (rxi_delay_out[8]),
		   .R  (reset_sync),
		   .S  (1'b0)
		   );

   //Pipe stage
   always @ (posedge rx_lclk)
     rx_frame_sync <= rx_frame;

   //Pipe stage
   always @ (posedge rx_lclk)
     rx_word_sync <= rx_word;
   
   
endmodule // erx_io
// Local Variables:
// verilog-library-directories:("." "../../emesh/hdl" "../../common/hdl")
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
