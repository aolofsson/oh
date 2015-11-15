module etx_io (/*AUTOARG*/
   // Outputs
   txo_lclk_p, txo_lclk_n, txo_frame_p, txo_frame_n, txo_data_p,
   txo_data_n, tx_wr_wait, tx_rd_wait,
   // Inputs
   nreset, tx_lclk_io, tx_lclk_div4, tx_lclk90, txi_wr_wait_p,
   txi_wr_wait_n, txi_rd_wait_p, txi_rd_wait_n, tx_packet, tx_access,
   tx_burst
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
   input [PW-1:0] tx_packet;//lclkdiv4 domain
   input          tx_access;
   input          tx_burst;
   output 	  tx_wr_wait;
   output 	  tx_rd_wait;
   
   //############
   //# REGS
   //############
   reg [7:0] 	  tx_pointer;   
   reg [15:0] 	  tx_data16;
   reg		  tx_frame;
   reg [2:0] 	  tx_state_reg;
   reg [PW-1:0]   tx_packet_reg;
   reg [63:0] 	  tx_double;
   reg [2:0] 	  tx_state;   
   reg 		  tx_access_reg;
   
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
  
   wire 	  tx_new_frame;
   wire 	  tx_lclk90_ddr;
   wire 	  tx_wr_wait_async;
   wire 	  tx_rd_wait_async;
   wire 	  firstedge;
   
`define IDLE    3'b000
`define CYCLE1  3'b001
`define CYCLE2  3'b010
`define CYCLE3  3'b011
`define CYCLE4  3'b100
`define CYCLE5  3'b101
`define CYCLE6  3'b110
`define CYCLE7  3'b111

   //#########################################
   //# Sample incoming packet with fast clock
   //#########################################  

   //Find the aligned edge
   edgealign edgealign (
			// Outputs
			.firstedge	(firstedge),
			// Inputs
			.fastclk	(tx_lclk_io),
			.slowclk	(tx_lclk_div4)
			);
      
   //Sample on aligned edge
   always @ (posedge tx_lclk_io)
     if(firstedge)
       begin
	  tx_access_reg    <= tx_access & ~tx_wait;
       end

   //Pushback on wait
   always @ (posedge tx_lclk_io)
     if(firstedge & ~tx_wait)
       tx_packet_reg[PW-1:0] <= tx_packet[PW-1:0];	 

   //#########################################
   //# Transmit state machine
   //#########################################     

   //decode incoming packet
   packet2emesh p2e_reg (
			  .write_out	(write),
			  .datamode_out	(datamode[1:0]),
			  .ctrlmode_out	(ctrlmode[3:0]),
			  .dstaddr_out	(dstaddr[31:0]),
			  .data_out	(data[31:0]),
			  .srcaddr_out	(srcaddr[31:0]),
			  .packet_in	(tx_packet_reg[PW-1:0]));
    

   assign tx_new_frame = (tx_state[2:0]==`CYCLE1);
        
   always @ (posedge tx_lclk_io)
     if(!nreset)
       tx_state[2:0] <= `IDLE;
     else
       case (tx_state[2:0])
	 `IDLE   : tx_state[2:0] <=  tx_access_reg ? `CYCLE1 : `IDLE;
	 `CYCLE1 : tx_state[2:0] <= `CYCLE2;
	 `CYCLE2 : tx_state[2:0] <= `CYCLE3;
	 `CYCLE3 : tx_state[2:0] <= `CYCLE4;	 
	 `CYCLE4 : tx_state[2:0] <= `CYCLE5;
	 `CYCLE5 : tx_state[2:0] <= `CYCLE6;
	 `CYCLE6 : tx_state[2:0] <= `CYCLE7;
	 `CYCLE7 : tx_state[2:0] <= tx_burst  & ~tx_wait  ? `CYCLE4 : 
				                            `IDLE;	
       endcase // case (tx_state)   

   //#############################
   //# THE ELINK BYTE FORMAT
   //#############################  
    always @ (posedge tx_lclk_io)
      case(tx_state[2:0])
	`CYCLE1 : tx_data16[15:0]  <= {~write,7'b0,ctrlmode[3:0],dstaddr[31:28]};
	`CYCLE2 : tx_data16[15:0]  <= dstaddr[27:12];
	`CYCLE3 : tx_data16[15:0]  <= {dstaddr[11:0],datamode[1:0],write,tx_access};
	`CYCLE4 : tx_data16[15:0]  <= data[31:16];       
	`CYCLE5 : tx_data16[15:0]  <= data[15:0];       
	`CYCLE6 : tx_data16[15:0]  <= srcaddr[31:16];       
	`CYCLE7 : tx_data16[15:0]  <= srcaddr[15:0];       
	default  tx_data16[15:0] <= 16'b0;
      endcase // case (tx_state[2:0])
 	           
   //Create frame signal
   always @ (posedge tx_lclk_io)
     tx_frame   <= (|tx_state[2:0]); 
      
   //##############################################
   //# Wait signal synchronization
   //##############################################

   //Stopping pipeline is urgent so synchronization
   //must be done on fast clock
   
   dsync sync_rd (
		// Outputs
		.dout			(tx_rd_wait),
		// Inputs
		.clk			(tx_lclk_io),
		.din			(tx_rd_wait_async));
   
   dsync sync_wr (
		// Outputs
		.dout			(tx_wr_wait),
		// Inputs
		.clk			(tx_lclk_io),
		.din			(tx_wr_wait_async));

   assign tx_wait =  tx_rd_wait | tx_wr_wait; 

   
   //#############################
   //# IO DRIVER STUFF
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
	      .C  (tx_lclk90),
	      .CE (1'b1),
	      .D1 (1'b1),
	      .D2 (1'b0),
	      .R  (1'b0),//should be no reason to reset clock, static input
	      .S  (1'b0)
	      );
		  
  
   //Buffer drivers
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
`ifdef TODO
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

