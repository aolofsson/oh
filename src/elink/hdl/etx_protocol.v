//#####################################################################
//# This module converts the packet interface to a 64bit wide format 
//# suitable for sending out to a parallel to serial shift register.
//# The frame signal is sent along together with the data making.
//# The goal is to minimize the amount of logic done on the high speed
//#  domain.
//#####################################################################
module etx_protocol (/*AUTOARG*/
   // Outputs
   etx_rd_wait, etx_wr_wait, etx_wait, tx_burst, tx_access,
   tx_data_slow, tx_frame_slow,
   // Inputs
   nreset, clk, etx_access, etx_packet, tx_enable, burst_enable,
   gpio_data, gpio_enable, ctrlmode_bypass, ctrlmode, tx_rd_wait,
   tx_wr_wait
   );

   parameter PW = 104;
   parameter AW = 32;   
   parameter DW = 32;
   parameter ID = 12'h000;
   
   //Clock/reset
   input 	  nreset;
   input          clk;

   //System side
   input          etx_access;
   input [PW-1:0] etx_packet;  

   //Pushback signals
   output         etx_rd_wait;
   output         etx_wr_wait;
   output 	  etx_wait;
   
   //Config interface
   input 	  tx_enable;    //transmit enable
   input    	  burst_enable; //Enables bursting
   input [8:0]    gpio_data;    //TODO
   input    	  gpio_enable;  //TODO
   output 	  tx_burst;     //for TXSTATUS
   output 	  tx_access;    //for TXMON

   //ctrlmode for rd/wr transactions
   input 	   ctrlmode_bypass;
   input [3:0] 	   ctrlmode;

   //Interface to IO
   output [63:0]  tx_data_slow;
   output [3:0]   tx_frame_slow;
   input          tx_rd_wait; 
   input 	  tx_wr_wait; 

   //################################################################
   //# Local regs & wires
   //################################################################
   reg [2:0] 	  tx_state;   
   reg [PW-1:0]   tx_packet; 
   reg 		  tx_burst_reg;   
 
   wire [1:0] 	  etx_datamode;
   wire [4:0] 	  etx_ctrlmode;
   wire [AW-1:0]  etx_dstaddr;
   wire [DW-1:0]  etx_data;
   wire [1:0] 	  tx_datamode;
   wire [4:0] 	  tx_ctrlmode;
   wire [AW-1:0]  tx_dstaddr;
   wire [DW-1:0]  tx_data;
   wire [AW-1:0]  tx_srcaddr;   
   wire [3:0] 	  ctrlmode_mux;

   //##############################################################
   //# Packet Pipeline
   //##############################################################
   packet2emesh #(.AW(AW))
   p2m0 (
	 .write_in	(etx_write),
	 .datamode_in	(etx_datamode[1:0]),
	 .ctrlmode_in	(etx_ctrlmode[4:0]),
	 .dstaddr_in	(etx_dstaddr[31:0]),
	 .data_in	(),
	 .srcaddr_in	(),
	 .packet_in	(etx_packet[PW-1:0]));//input
   
   //ctrlmode bypass
   assign ctrlmode_mux[3:0] = ctrlmode_bypass ?  ctrlmode[3:0] : 
				                 etx_ctrlmode[3:0];

   //Hold transaction while waiting
   always @ (posedge clk)
     if(~etx_wait)
       tx_packet[PW-1:0] <= {etx_packet[PW-1:8],   
			     1'b0,			     
			     ctrlmode_mux[3:0], 
			     etx_packet[2:0]};
  
   //the IO pipeline flushes out
   packet2emesh #(.AW(AW))
   p2m1 (
	 .write_in	(tx_write),
	 .datamode_in	(tx_datamode[1:0]),
	 .ctrlmode_in	(tx_ctrlmode[4:0]),
	 .dstaddr_in	(tx_dstaddr[31:0]),
	 .data_in	(tx_data[31:0]),
	 .srcaddr_in	(tx_srcaddr[31:0]),
	 .packet_in	(tx_packet[PW-1:0]));//input
   

   //#############################
   //# Burst Detection
   //#############################

   assign burst_addr_match  = ((tx_dstaddr[31:0]+32'h8) == etx_dstaddr[31:0]);

   assign current_match     = tx_access & 
			      tx_write &
		              (tx_datamode[1:0]==2'b11) &		       
			      (tx_ctrlmode[3:0]==4'b0000);

   assign next_match       =  etx_access & //BUG: should be valid? 
			      etx_write &
		              (etx_datamode[1:0]==2'b11) &		       
			      (etx_ctrlmode[3:0]==4'b0000);
     
   assign tx_burst        =   burst_enable     &
                              ~tx_wait         &
		   	      current_match    &
			      next_match       &
			      burst_addr_match;
   
 
   always @ (posedge clk)
     tx_burst_reg <=tx_burst;

   //############################################################
   //# TRANSMIT STATE MACHINE
   //#############################################################
   assign etx_valid = tx_enable  & 
		      etx_access & 
		      ~tx_wait;
   
`define TX_IDLE  3'b000
`define TX_START 3'b001
`define TX_ACK   3'b010
`define TX_BURST 3'b011
`define TX_WAIT  3'b100

   always @ (posedge clk)
     if(!nreset)
       tx_state[2:0] <= `TX_IDLE;
     else
       case (tx_state[2:0])
	 `TX_IDLE:  tx_state[2:0] <= etx_valid ? `TX_START : 
				                 `TX_IDLE;
	 `TX_START: tx_state[2:0] <= `TX_ACK;
	 `TX_ACK:   tx_state[2:0] <= tx_burst  ? `TX_BURST :
				     etx_valid ? `TX_START :
                                                 `TX_IDLE;
 	 `TX_BURST: tx_state[2:0] <= tx_burst  ? `TX_BURST : 
				                 `TX_IDLE;	   
       endcase // case (tx_state[2:0])
   
   assign tx_ack_wait = (tx_state[2:0]==`TX_START);
   assign tx_access   = (tx_state[2:0]==`TX_START) |
			(tx_state[2:0]==`TX_BURST);
   

   //#######################################
   //# Wait propagation circuit backwards
   //########################################	  
   wire [63:0] 	  tx_cycle1;
   wire [63:0] 	  tx_cycle2;
   
   assign tx_frame_slow[3:0] = (tx_state[1:0]==`TX_START) ? 4'b0111 :
			       (tx_state[1:0]!=`TX_IDLE)  ? 4'b1111 :
			                                    4'b0000;
   
   assign tx_cycle1[63:0] = {tx_dstaddr[11:0],tx_datamode[1:0],tx_write,tx_access, //47:32
			     tx_dstaddr[27:12],                                    //31:16
			    ~tx_write,5'b0,tx_burst_reg,1'b0,                      //8-15
			     tx_ctrlmode[3:0],tx_dstaddr[31:28],                   //0-7
			     16'b0 				                   //garbage
			    };
   
   assign tx_cycle2[63:0]   = {tx_srcaddr[15:0],                                   //48-63
			       tx_srcaddr[31:16],                                  //32-47
			       tx_data[15:0],                                      //16-31
			       tx_data[31:16]			                   //0-15
			       };
			       
   assign tx_data_slow[63:0]  = (tx_state[2:0]==`TX_START) ? tx_cycle1[63:0] : 
				                             tx_cycle2[63:0];
 
   
   //#######################################
   //# Wait propagation circuit backwards
   //########################################	      
   //immediate wait for state machine
   assign tx_wait     = tx_wr_wait  | tx_rd_wait;

   //wait for data
   assign etx_wr_wait = (tx_wr_wait | tx_ack_wait );
   assign etx_rd_wait = (tx_rd_wait | tx_ack_wait );
   assign etx_wait    = etx_wr_wait | etx_rd_wait;   
           
endmodule // etx_protocol
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:

