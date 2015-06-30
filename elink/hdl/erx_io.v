module erx_io (/*AUTOARG*/
   // Outputs
   rx_lclk_pll, rxo_wr_wait_p, rxo_wr_wait_n, rxo_rd_wait_p,
   rxo_rd_wait_n, rx_access, rx_burst, rx_packet,
   // Inputs
   reset, rx_lclk, rx_lclk_div4, rx_ref_clk, rxi_lclk_p, rxi_lclk_n,
   rxi_frame_p, rxi_frame_n, rxi_data_p, rxi_data_n, rx_wr_wait,
   rx_rd_wait
   );

   parameter IOSTD_ELINK = "LVDS_25";
   parameter PW = 104;

   //#########################
   //# reset, clocks
   //#########################
   input       reset;                       // reset
   input       rx_lclk;                     // fast I/O clock
   input       rx_lclk_div4;                // slow clock
   input       rx_ref_clk;                  // idelay reference clock   
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
   wire     rx_ref_clk_idlyctrl;

   //############
   //# REGS
   //############
   reg [7:0] 	 data_even_reg;   
   reg [7:0] 	 data_odd_reg;
   wire 	 rx_frame;
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
   
   //#####################
   //#CREATE 112 BIT PACKET 
   //#####################
   
   //write Pointer   
   always @ (posedge rx_lclk)
     if (~rx_frame)
       rx_pointer[6:0] <= 7'b0000001; //new frame
     else if (rx_pointer[6])
       rx_pointer[6:0] <= 7'b0001000; //anticipate burst
     else if(rx_frame)
       rx_pointer[6:0] <= {rx_pointer[5:0],1'b0};//middle of frame
      
   //convert to 112 bit packet
   always @ (posedge rx_lclk)
     if(rx_frame)   
       begin
	  if(rx_pointer[0])
	    rx_sample[15:0]    <= rx_word[15:0];
	  if(rx_pointer[1])
	    rx_sample[31:16]   <= rx_word[15:0];
	  if(rx_pointer[2])
	    rx_sample[47:32]   <= rx_word[15:0];
	  if(rx_pointer[3])
	    rx_sample[63:48]   <= rx_word[15:0];
	  if(rx_pointer[4])
	    rx_sample[79:64]   <= rx_word[15:0];
	  if(rx_pointer[5])
	    rx_sample[95:80]   <= rx_word[15:0];
	  if(rx_pointer[6])
	    rx_sample[111:96]  <= rx_word[15:0];	  
       end
   
   //#####################  
   //#DATA VALID SIGNAL 
   //####################
   always @ (posedge rx_lclk)
     begin     
	access       <= rx_pointer[6];
	valid_packet <= access;//data pipeline
     end
   
   reg burst_detect;   
   always @ (posedge rx_lclk)
     if(access & rx_frame)
       burst_detect <= 1'b1;
     else if(~rx_frame)
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
	  rx_packet_lclk[0]     <= rx_sample[40];
	  //write
	  rx_packet_lclk[1]     <= rx_sample[41];
	  //datamode
	  rx_packet_lclk[3:2]   <= rx_sample[43:42];
	  //ctrlmode
	  rx_packet_lclk[7:4]   <= rx_sample[15:12];
	  //dstaddr
	  rx_packet_lclk[39:8]  <= {rx_sample[11:8],
			             rx_sample[23:16],
			             rx_sample[31:24],
			             rx_sample[39:32],
			             rx_sample[47:44]};
	  //data
	  rx_packet_lclk[71:40] <= {rx_sample[55:48],
			              rx_sample[63:56],
			              rx_sample[71:64],
			              rx_sample[79:72]};	
	  //srcaddr
	  rx_packet_lclk[103:72]<= {rx_sample[87:80],
			              rx_sample[95:88],
			              rx_sample[103:96],
			              rx_sample[111:104]
				      };	
     end

   //###################################
   //#SYNCHRONIZE TO SLOW CLK
   //###################################
 
   //stretch access pulse to 4 cycles
   pulse_stretcher #(.DW(3)) ps0 (.out			(access_wide),
				 .in			(valid_packet),
				 .clk			(rx_lclk),
				 .reset			(reset)
				 );

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

   IBUFDS #(.DIFF_TERM  ("TRUE"),.IOSTANDARD (IOSTD_ELINK))
   ibuf_lclk (.I     (rxi_lclk_p),
	      .IB    (rxi_lclk_n),
	      .O     (rxi_lclk)
	      );
      
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

   //###################################
   //#RX CLOCK
   //###################################

   BUFG bufg_lclk (.I(rxi_lclk), .O(rx_lclk_pll));

   //###################################
   //#IDELAY CIRCUIT
   //###################################

   assign  rxi_delay_in[8:0] ={rxi_frame,rxi_data[7:0]};
   
   BUFG bufg_rx_ref_clk( .I(rx_ref_clk), .O(rx_ref_clk_idlyctrl));

   //Do these need parameters?
   IDELAYCTRL idelayctrl_inst (.RDY(),
			       .REFCLK(rx_ref_clk_idlyctrl),//200MHz clk (78ps tap delay)
			       .RST(1'b0)
			       );
   
   genvar        j;
   generate for(j=0; j<9; j=j+1)
     begin : gen_idelay	     
	IDELAYE2 #(.CINVCTRL_SEL("FALSE"),
		   .DELAY_SRC("IDATAIN"), 
		   .HIGH_PERFORMANCE_MODE("FALSE"),
		   .IDELAY_TYPE("FIXED"),
		   .IDELAY_VALUE(14),
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
   BUFIO bufio_lclk (.I(rxi_lclk), 
		     .O(rx_lclk_iddr));
   //DATA
   genvar        i;
   generate for(i=0; i<8; i=i+1)
     begin : gen_iddr
	IDDR #(.DDR_CLK_EDGE  ("SAME_EDGE_PIPELINED"))
	iddr_data (
		   .Q1 (rx_word[i]),
		   .Q2 (rx_word[i+8]),
		   .C  (rx_lclk_iddr),
		   .CE (1'b1),
		   .D  (rxi_delay_out[i]),
		   .R  (reset),
		   .S  (1'b0)
		   );
     end
     endgenerate

   //FRAME
   IDDR #(.DDR_CLK_EDGE  ("SAME_EDGE_PIPELINED"))
	iddr_frame (
		   .Q1 (),
		   .Q2 (rx_frame),    
		   .C  (rx_lclk_iddr),
		   .CE (1'b1),
		   .D  (rxi_delay_out[8]),
		   .R  (reset),
		   .S  (1'b0)
		   );	
   
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
