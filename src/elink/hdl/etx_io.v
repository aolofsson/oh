module etx_io (/*AUTOARG*/
   // Outputs
   txo_lclk_p, txo_lclk_n, txo_frame_p, txo_frame_n, txo_data_p,
   txo_data_n, tx_wr_wait, tx_rd_wait,
   // Inputs
   tx_lclk_io, tx_lclk_div4, tx_lclk90, txi_wr_wait_p, txi_wr_wait_n,
   txi_rd_wait_p, txi_rd_wait_n, tx_data_slow, tx_frame_slow
   );
   
   parameter IOSTD_ELINK = "LVDS_25";
   parameter PW          = 104;
   parameter ETYPE       = 0; // 0 = parallella
                              // 1 = ephycard     
   //###########
   //# reset, clocks
   //##########
   input 	tx_lclk_io;	     //fast ODDR
   input 	tx_lclk_div4;	     //slow clock
   input 	tx_lclk90;           //fast 90deg shifted lclk   
   
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
   input [63:0]   tx_data_slow;    //data for burst or transaction
   input  [3:0]   tx_frame_slow;   //framing signal
   output 	  tx_wr_wait;
   output 	  tx_rd_wait;
   
   //############
   //# REGS
   //############
   reg [63:0] 	  tx_data;
   reg [3:0] 	  tx_frame;
   wire [15:0] 	  tx_data16;
   wire  	  tx_frame16;
   reg 		  tx_wr_wait_sync;
   reg 		  tx_rd_wait_sync; 
   reg 		  tx_wr_wait_reg;
   reg 		  tx_rd_wait_reg;
   reg 		  tx_wr_wait_reg2;
   reg 		  tx_rd_wait_reg2;
   //############
   //# WIRES
   //############
   wire [15:0] 	  tx_data_mux;   
   wire 	  txo_frame_ddr;
   wire 	  txo_lclk90;   
   wire 	  tx_wr_wait_async;
   wire 	  tx_rd_wait_async;
   wire [7:0] 	  txo_data_ddr;
   wire 	  invert_pins;
   
   //#########################################
   //# Pins inverted for 64-core board
   //#########################################        
`ifdef TARGET_E64
   assign invert_pins=1'b1;
`else
   assign invert_pins=1'b0;
`endif
   //#########################################
   //# Synchronizatsion to fast domain
   //#########################################        

   //Find the aligned edge
   oh_edgealign edgealign0 (.firstedge	(firstedge),
  			    .fastclk	(tx_lclk_io),
			    .slowclk	(tx_lclk_div4)
			   );

   //Data shift registers
   always @ (posedge tx_lclk_io)
     if(firstedge) //"load"
       begin
	  tx_data[63:0]   <= tx_data_slow[63:0]; //changes every 4 cycles
	  tx_frame[3:0]   <= tx_frame_slow[3:0];	
       end
     else //"shift"
       begin
	  tx_data[63:0]   <= {16'b0,tx_data[63:16]};
	  tx_frame[3:0]   <= {tx_frame[2:0],1'b0};	  
       end

   assign tx_data16[15:0] = tx_data[15:0];   
   assign tx_frame16      = tx_frame[3];

   //##############################################
   //# Wait signal synchronization
   //############################################## 
   always @ (negedge tx_lclk_io)
     begin
	tx_wr_wait_sync <= tx_wr_wait_async ^ invert_pins;
	tx_rd_wait_sync <= tx_rd_wait_async ^ invert_pins;
     end

   //Looks like legacy elink puts out short wait pulses.
   //Let's make sure they don't sneak through
 
   always @ (posedge tx_lclk_div4)
     begin
	tx_wr_wait_reg  <= tx_wr_wait_sync; 
	tx_wr_wait_reg2 <= tx_wr_wait_reg;
	tx_rd_wait_reg  <= tx_rd_wait_sync;
	tx_rd_wait_reg2 <= tx_rd_wait_reg;	
     end
   assign tx_wr_wait = tx_wr_wait_reg | tx_wr_wait_reg2;
   assign tx_rd_wait = tx_rd_wait_reg | tx_rd_wait_reg2;
             
   //############################################
   //# IO DRIVER STUFF
   //############################################  

   //DATA
   genvar        i;
   generate for(i=0; i<8; i=i+1)
     begin : gen_oddr
	ODDRE1
	oddr_data (
		   .Q  (txo_data_ddr[i]),
		   .C  (tx_lclk_io),
		   .D1 (tx_data16[i+8] ^ invert_pins),
		   .D2 (tx_data16[i] ^ invert_pins)
		   );
     end
     endgenerate

   //FRAME
   ODDRE1
   oddr_frame (
	      .Q  (txo_frame_ddr),
	      .C  (tx_lclk_io),
	      .D1 (tx_frame16 ^ invert_pins),
	      .D2 (tx_frame16 ^ invert_pins)
	      );
   
   //LCLK
   ODDRE1
   oddr_lclk (
	      .Q  (txo_lclk90),
	      .C  (tx_lclk90),
	      .D1 (1'b1 ^ invert_pins),
	      .D2 (1'b0 ^ invert_pins)
	      );
		    
   //Buffer drivers
   OBUFDS obufds_data[7:0] (
			     .O   (txo_data_p[7:0]),
			     .OB  (txo_data_n[7:0]),
			     .I   (txo_data_ddr[7:0])
			     );
   
   OBUFDS obufds_frame ( .O   (txo_frame_p),
			 .OB  (txo_frame_n),
			 .I   (txo_frame_ddr)
			 );

   OBUFDS obufds_lclk ( .O   (txo_lclk_p),
			.OB  (txo_lclk_n),
			.I   (txo_lclk90)
			);
   //Wait inputs
   generate
      if(ETYPE==1)
	begin
	   assign tx_wr_wait_async = txi_wr_wait_p;
	end
      else if (ETYPE==0)
	begin
	   IBUFDS
	     #(.DIFF_TERM  ("TRUE"),     // Differential termination
	       .IOSTANDARD (IOSTD_ELINK))
	   ibufds_wrwait
	     (.I     (txi_wr_wait_p),
	      .IB    (txi_wr_wait_n),
	      .O     (tx_wr_wait_async));	 
	end
   endgenerate
      
//TODO: Come up with cleaner defines for this
`define ZYNQMP
`ifdef ZYNQMP
  IBUFDS
     #(.DIFF_TERM  ("TRUE"),     // Differential termination
       .IOSTANDARD (IOSTD_ELINK))
      ibufds_rdwait
     (.I     (txi_rd_wait_p),
      .IB    (txi_rd_wait_n),
      .O     (tx_rd_wait_async));
`else
   //On Parallella this signal comes in single-ended
   assign tx_rd_wait_async = txi_rd_wait_p;
`endif
   
endmodule // etx_io
// Local Variables:
// verilog-library-directories:("." "../../emesh/hdl" "../../common/hdl")
// End:

