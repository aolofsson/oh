/*
 This block receives the IO transaction and converts to a 104 bit packet. 
 */

module erx_io (/*AUTOARG*/
   // Outputs
   rx_clkin, rxo_wr_wait_p, rxo_wr_wait_n, rxo_rd_wait_p,
   rxo_rd_wait_n, rx_access, rx_burst, rx_packet,
   // Inputs
   erx_io_nreset, rx_lclk, rx_lclk_div4, idelay_value, load_taps,
   rxi_lclk_p, rxi_lclk_n, rxi_frame_p, rxi_frame_n, rxi_data_p,
   rxi_data_n, rx_wr_wait, rx_rd_wait
   );
   parameter IOSTD_ELINK = "LVDS_25";  
   parameter PW          = 104;
   parameter ETYPE       = 1;//0=parallella
                             //1=ephycard     
   
   //#########################
   //# reset, clocks
   //#########################
   input       erx_io_nreset;               // high sped reset
   input       rx_lclk;                     // fast I/O clock
   input       rx_lclk_div4;                // slow clock
   output      rx_clkin;                    // clock output for pll

   //#########################
   //# idelays
   //#########################
   input [44:0] idelay_value;
   input 	load_taps;

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
   wire [15:0]   rx_word_iddr;
   wire  	 rx_frame_iddr;
 
   
   //############
   //# REGS
   //############
   reg 		 valid_packet;
   reg [15:0] 	 rx_word_sync;
   reg [111:0] 	 rx_sample; 
   reg [6:0] 	 rx_pointer;
   reg 		 access;  
   reg 		 burst;
   reg [PW-1:0]  rx_packet_lclk;
   reg 		 rx_access;
   reg [PW-1:0]  rx_packet;
   reg 		 rx_burst;
   wire [8:0] 	 rxi_delay_in;
   wire [8:0] 	 rxi_delay_out;
   reg 		 burst_detect;   
   reg [3:0] 	 valid;

   //#########################################
   //# Pins inverted for 64-core board
   //#########################################        
`ifdef TARGET_E64
   assign invert_pins=1'b1;
`else
   assign invert_pins=1'b0;
`endif
   
   //#######################################
   //#Register DDR inputs for better timing
   //#######################################
   reg 		 rx_frame;
   reg [15:0] 	 rx_word;
   
   always @ (posedge rx_lclk)
     begin
	rx_frame      <= rx_frame_iddr;
	rx_word[15:0] <= rx_word_iddr[15:0];	
     end
   
   //#####################
   //#CREATE 112 BIT PACKET 
   //#####################
   
   //write Pointer   
   always @ (posedge rx_lclk or negedge erx_io_nreset)
     if(!erx_io_nreset)
       rx_pointer[6:0] <= 7'b0000001;   
     else if (rx_pointer[6] & rx_frame_iddr)
       rx_pointer[6:0] <= 7'b0001000; //anticipate burst
     else if (rx_pointer[6])
       rx_pointer[6:0] <= 7'b0000001; //prepare for new frame    
     else if(rx_frame)
       rx_pointer[6:0] <= {rx_pointer[5:0],1'b0};//middle of frame
      
   //convert to 112 bit packet
   always @ (posedge rx_lclk)
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
     end // if (rx_frame)
   
   //#####################  
   //#DATA VALID SIGNAL 
   //####################
   always @ (posedge rx_lclk)
	access       <= rx_pointer[6];
 
   always @ (posedge rx_lclk or negedge erx_io_nreset)
     if(!erx_io_nreset)
       burst_detect <= 1'b0;   
     else if(access & rx_frame)
       burst_detect <= 1'b1;
     else if(~rx_frame)
       burst_detect <= 1'b0;
      
   //###################################
   //#SAMPLE AND HOLD DATA
   //###################################

   //(..and shuffle data for 104 bit packet)
   //seems redundant??? for burst??
   always @ (posedge rx_lclk or negedge erx_io_nreset)
     if(~erx_io_nreset)
       burst         <= 1'b0;   
     else if (access)
       burst       <= burst_detect;
   

   always @ (posedge rx_lclk)
     if(access)   
       begin
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
   //use shift register for speed
   //TODO: simplify
   
   always @ (posedge rx_lclk)
     if(!erx_io_nreset)
       valid[3:0] <=4'b0000;   
     else if(access)
       valid[3:0] <=4'b1111;   
     else
       valid[3:0] <={valid[2:0],1'b0};

   assign access_wide = valid[3];

   //access
   always @ (posedge rx_lclk_div4)
     begin
	rx_access <= access_wide;
     end

   //packet
   always @ (posedge rx_lclk_div4)
     if(access_wide)
       rx_packet[PW-1:0] <= rx_packet_lclk[PW-1:0];

   //burst
   always @ (posedge rx_lclk_div4)
     if(!erx_io_nreset)
       rx_burst          <= 1'b0;
     else if(access_wide)
       rx_burst          <= burst;
   
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

//TODO: Will this work?
`ifdef TARGET_E64
   IBUFDS #(.DIFF_TERM  ("TRUE"),.IOSTANDARD (IOSTD_ELINK))
   ibuf_lclk (.I     (rxi_lclk_n),
	      .IB    (rxi_lclk_p),
	      .O     (rx_clkin)
	      );
`else
   IBUFDS #(.DIFF_TERM  ("TRUE"),.IOSTANDARD (IOSTD_ELINK))
   ibuf_lclk (.I     (rxi_lclk_p),
	      .IB    (rxi_lclk_n),
	      .O     (rx_clkin)
	      );
`endif
   
 
   generate
      if(ETYPE==1)
	begin	   
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

	   assign rxo_wr_wait_n = 1'b0;
	   assign rxo_rd_wait_n = 1'b0;	   
	end      
      else if(ETYPE==0)
	begin
	   OBUFDS #(.IOSTANDARD(IOSTD_ELINK),.SLEW("SLOW")) 
	   obufds_wrwait (
			  .O(rxo_wr_wait_p),
			  .OB(rxo_wr_wait_n),
			  .I(rx_wr_wait ^ invert_pins)
			  );
	   
	   OBUFDS  #(.IOSTANDARD(IOSTD_ELINK),.SLEW("SLOW")) 
	   obufds_rdwait  (.O(rxo_rd_wait_p),
			   .OB(rxo_rd_wait_n),
			   .I(rx_rd_wait ^ invert_pins)
			   );
	end
   endgenerate
   
   //###################################
   //#RX CLOCK for IDDR
   //###################################      
   wire rx_lclk_iddr;   
   BUFIO i_bufio0 (.I(rx_clkin), .O(rx_lclk_iddr));//for iddr
      
   //###################################
   //#IDELAY CIRCUIT
   //###################################

   assign  rxi_delay_in[8:0] ={rxi_frame,rxi_data[7:0]};
   
   genvar        j;
   generate for(j=0; j<9; j=j+1)
     begin : gen_idelay
`define IDELAYCTRL_WONT_SYNTHESIZE
`ifdef IDELAYCTRL_WONT_SYNTHESIZE
	IDELAYE3 #(.DELAY_SRC("IDATAIN"),
		   .DELAY_TYPE("VAR_LOAD"),
		   .DELAY_VALUE(9'b0),
		   .REFCLK_FREQUENCY(200.0),
		   .DELAY_FORMAT("COUNT"), // Ultrascale w/ COUNT can remove IDELAYCTRL (but then not stable over temp / voltage variations)
		   .SIM_DEVICE("ULTRASCALE_PLUS_ES2"))

	idelay_inst (.CNTVALUEOUT(),             // monitoring value       
		     .DATAOUT(rxi_delay_out[j]), // delayed data
		     .CLK(rx_lclk_div4),         // variable tap delay clock
		     .CE(1'b0),                  // inc/dec tap value
		     .CNTVALUEIN({4'b0, idelay_value[(j+1)*5-1:j*5]}), //variable tap (BROKEN!!! for Ultrascale, 9 bits / counter
		     .DATAIN(1'b0),              // data from FPGA
		     .IDATAIN(rxi_delay_in[j]),  // data from ibuf
		     .INC(1'b0),                 // increment tap
		     .LOAD(load_taps),           // load new
		     .EN_VTC(~load_taps),        // Enables IDELAYCTRL
		     .RST(1'b0)                  //
		   );
`else
	(* IODELAY_GROUP = "IDELAY_GROUP" *) // Group name for IDELAYCTRL
	IDELAYE3 #(.DELAY_SRC("IDATAIN"),
		   .DELAY_TYPE("VAR_LOAD"),
		   .DELAY_VALUE(9'b0),
		   .REFCLK_FREQUENCY(200.0),
		   .DELAY_FORMAT("TIME"), // Ultrascale w/ COUNT can remove IDELAYCTRL (but then not stable over temp / voltage variations)
		   .SIM_DEVICE("ULTRASCALE_PLUS_ES2"))

	idelay_inst (.CNTVALUEOUT(),             // monitoring value       
		     .DATAOUT(rxi_delay_out[j]), // delayed data
		     .CLK(rx_lclk_div4),         // variable tap delay clock
		     .CE(1'b0),                  // inc/dec tap value
		     .CNTVALUEIN({4'b0, idelay_value[(j+1)*5-1:j*5]}), //variable tap (BROKEN!!! for Ultrascale, 9 bits / counter
		     .DATAIN(1'b0),              // data from FPGA
		     .IDATAIN(rxi_delay_in[j]),  // data from ibuf
		     .INC(1'b0),                 // increment tap
		     .LOAD(load_taps),           // load new
		     .EN_VTC(~load_taps),        // Enables IDELAYCTRL
		     .RST(1'b0)                  //
		   );
`endif
     end // block: gen_idelay
   endgenerate
   
   //#############################
   //# IDDR SAMPLERS
   //#############################  
 
   //DATA
   genvar        i;
   generate for(i=0; i<8; i=i+1)
     begin : gen_iddr           
	// Ultrascale doesn't have .SRTYPE("SYNC")
	IDDRE1 #(.DDR_CLK_EDGE  ("SAME_EDGE_PIPELINED"))
	iddr_data (
		   .Q1 (rx_word_iddr[i]),
		   .Q2 (rx_word_iddr[i+8]),
		   .C  (rx_lclk_iddr),//rx_lclk_iddr
		   .CB  (~rx_lclk_iddr),
		   .D  (rxi_delay_out[i] ^ invert_pins),
		   .R  (1'b0)
		   );
     end
     endgenerate

   //FRAME
   IDDRE1 #(.DDR_CLK_EDGE  ("SAME_EDGE_PIPELINED"))
	// Ultrascale doesn't have .SRTYPE("SYNC")
	iddr_frame (
		   .Q1 (rx_frame_iddr),
		   .Q2 (),    
		   .C  (rx_lclk_iddr),//TODO: will this work?
		   .CB  (~rx_lclk_iddr),
		   .D  (rxi_delay_out[8] ^ invert_pins),
		   .R  (1'b0)
		   );
   
endmodule // erx_io
// Local Variables:
// verilog-library-directories:("." "../../emesh/hdl" "../../common/hdl")
// End:

