module etx_io (/*AUTOARG*/
   // Outputs
   txo_lclk_p, txo_lclk_n, txo_frame_p, txo_frame_n, txo_data_p,
   txo_data_n, tx_io_ack, tx_wr_wait, tx_rd_wait,
   // Inputs
   nreset, tx_lclk_io, tx_lclk90, txi_wr_wait_p, txi_wr_wait_n,
   txi_rd_wait_p, txi_rd_wait_n, tx_packet, tx_access, tx_burst
   );
   
   parameter IOSTD_ELINK = "LVDS_25";
   parameter PW          = 104;
   parameter ETYPE       = 0; // 0 = parallella
                              // 1 = ephycard     
   //###########
   //# reset, clocks
   //##########
   input        nreset;              //sync reset for io  
   input 	tx_lclk_io;	     //fast ODDR
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
   input [PW-1:0] tx_packet;
   input          tx_access;
   input          tx_burst;
   output 	  tx_io_ack;   
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
   reg [PW-1:0]   tx_packet_reg;
   reg [63:0] 	  tx_double;
   reg [2:0] 	  tx_state_reg;
   reg [2:0] 	  tx_state;
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
   reg 		  tx_io_ack;
   
   //#############################
   //# Transmit state machine
   //#############################  
  
`define IDLE    3'b000
`define CYCLE1  3'b001
`define CYCLE2  3'b010
`define CYCLE3  3'b011
`define CYCLE4  3'b100
`define CYCLE5  3'b101
`define CYCLE6  3'b110
`define CYCLE7  3'b111
     
always @ (posedge tx_lclk_io)
  if(!nreset)
    tx_state[2:0] <= `IDLE;
  else
    case (tx_state[2:0])
      `IDLE   : tx_state[2:0] <= tx_access ? `CYCLE1 : `IDLE;
      `CYCLE1 : tx_state[2:0] <= `CYCLE2;
      `CYCLE2 : tx_state[2:0] <= `CYCLE3;
      `CYCLE3 : tx_state[2:0] <= `CYCLE4;
      `CYCLE4 : tx_state[2:0] <= `CYCLE5;
      `CYCLE5 : tx_state[2:0] <= `CYCLE6;
      `CYCLE6 : tx_state[2:0] <= `CYCLE7;
      `CYCLE7 : tx_state[2:0] <= tx_burst ? `CYCLE4 : `IDLE;	
    endcase // case (tx_state)   
   
   assign tx_new_frame = (tx_state[2:0]==`CYCLE1);

 
   //Creating wide acknowledge on cycle 4
   always @ (posedge tx_lclk_io)
     if(!nreset)
       tx_io_ack <= 1'b0;
     else if ((tx_state[2:0] ==`CYCLE4))
       tx_io_ack <= 1'b1;   
     else if (tx_state[2:0]==`IDLE)
       tx_io_ack <= 1'b0;
  
   //Create frame signal for output
   always @ (posedge tx_lclk_io)
     begin
	tx_state_reg[2:0]     <= tx_state[2:0];
	tx_frame              <= |(tx_state_reg[2:0]);
     end

   //#############################
   //# 2 CYCLE PACKET PIPELINE
   //#############################  
   always @ (posedge tx_lclk_io)
     if (tx_access)
       tx_packet_reg[PW-1:0] <= tx_packet[PW-1:0];

    packet2emesh p2e (
		      .write_out	(write),
		      .datamode_out	(datamode[1:0]),
		      .ctrlmode_out	(ctrlmode[3:0]),
		      .dstaddr_out	(dstaddr[31:0]),
		      .data_out		(data[31:0]),
		      .srcaddr_out	(srcaddr[31:0]),
		      .packet_in	(tx_packet_reg[PW-1:0]));
 

   /*
    * The following format is used by the Epiphany multicore ASIC.
    * Don't change it if you want to communicate with Epiphany.
    * 
    */

   always @ (posedge tx_lclk_io)
     if (tx_new_frame)
       tx_double[63:0] <= {16'b0,//16
			   ~write,7'b0,ctrlmode[3:0],//12
			   dstaddr[31:0],datamode[1:0],write,tx_access};//36
     else if(tx_state[2:0]==`CYCLE4)
       tx_double[63:0] <= {data[31:0],srcaddr[31:0]};
  
   //#############################
   //# SELECTING DATA FOR TRANSMIT
   //#############################  
   
   always @ (posedge tx_lclk_io)
     case(tx_state_reg[2:0])
       //Cycle1
       3'b001: tx_data16[15:0]  <= tx_double[47:32];       
       //Cycle2
       3'b010: tx_data16[15:0]  <= tx_double[31:16];       
       //Cycle3
       3'b011: tx_data16[15:0]  <= tx_double[15:0];       
       //Cycle4				      
       3'b100: tx_data16[15:0]  <= tx_double[63:48];       
       //Cycle5
       3'b101: tx_data16[15:0]  <= tx_double[47:32];       
       //Cycle6
       3'b110: tx_data16[15:0]  <= tx_double[31:16];       
       //Cycle7
       3'b111: tx_data16[15:0]  <= tx_double[15:0];       
       default  tx_data16[15:0] <= 16'b0;
     endcase // case (tx_state[2:0])
                       
   //#############################
   //# CLOCK DRIVERS
   //#############################  
   //BUFIO i_lclk    (.I(tx_lclk_io), .O(tx_lclk_ddr));
   BUFIO i_lclk90  (.I(tx_lclk90), .O(tx_lclk90_ddr));

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
		   .C  (tx_lclk_io),
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
	      .C  (tx_lclk_io),
	      .CE (1'b1),
	      .D1 (tx_frame),
	      .D2 (tx_frame),
	      .R  (1'b0), //reset
	      .S  (1'b0)
	      );
   
   //LCLK
   ODDR #(.DDR_CLK_EDGE  ("SAME_EDGE"))
   oddr_lclk (
	      .Q  (txo_lclk90),
	      .C  (tx_lclk90_ddr),
	      .CE (1'b1),
	      .D1 (1'b1),
	      .D2 (1'b0),
	      .R  (1'b0),//should be no reason to reset clock, static input
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

   generate
      if(ETYPE==1)
	begin
	   assign tx_wr_wait = txi_wr_wait_p;
	end
      else if (ETYPE==0)
	begin
	   IBUFDS
	     #(.DIFF_TERM  ("TRUE"),     // Differential termination
	       .IOSTANDARD (IOSTD_ELINK))
	   ibufds_wrwait
	     (.I     (txi_wr_wait_p),
	      .IB    (txi_wr_wait_n),
	      .O     (tx_wr_wait));	 
	end
   endgenerate
      
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

