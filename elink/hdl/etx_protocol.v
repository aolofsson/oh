`include "elink_regmap.v"

/*
 *
 * This module converts the packet interface to a 64bit wide format 
 * suitable for sending out to a parallel to serial shift register.
 * The frame signal is sent along together with the data making.
 * The goal is to minimize the amount of logic done on the high speed
 * domain.
 * 
 * 
 */ 

module etx_protocol (/*AUTOARG*/
   // Outputs
   etx_rd_wait, etx_wr_wait, tx_data_slow, tx_frame_slow,
   // Inputs
   nreset, clk, etx_access, etx_packet, tx_enable, gpio_data,
   gpio_enable, tx_rd_wait, tx_wr_wait
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

   //Enble transmit
   input 	  tx_enable;   //transmit enable
   input [8:0]    gpio_data;   //TODO
   input    	  gpio_enable; //TODO
   
   //Interface to IO
   output [63:0]  tx_data_slow;
   output [3:0]   tx_frame_slow;
   input          tx_rd_wait; 
   input 	  tx_wr_wait; 

   //###################################################################
   //# Local regs & wires
   //###################################################################
   reg [2:0] 	  tx_state;   
   reg [PW-1:0]   tx_packet; 
   wire 	  etx_write;
   wire [1:0] 	  etx_datamode;
   wire [3:0] 	  etx_ctrlmode;
   wire [AW-1:0]  etx_dstaddr;
   wire [DW-1:0]  etx_data;
   wire 	  tx_write;
   wire [1:0] 	  tx_datamode;
   wire [3:0] 	  tx_ctrlmode;
   wire [AW-1:0]  tx_dstaddr;
   wire [DW-1:0]  tx_data;
   wire [AW-1:0]  tx_srcaddr;   
   wire 	  burst_match;
   wire 	  burst_type_match;
   wire [31:0] 	  burst_addr;
   wire 	  burst_addr_match;
   wire 	  burst_in;
   wire 	  adjust;
   wire 	  current_match;
   wire 	  next_match;
   wire 	  tx_burst_in;

   
   
   //##############################################################
   //# Packet Pipeline
   //##############################################################
   packet2emesh p2m0 (
		      .write_out	(etx_write),
		      .datamode_out	(etx_datamode[1:0]),
		      .ctrlmode_out	(etx_ctrlmode[3:0]),
		      .dstaddr_out	(etx_dstaddr[31:0]),
		      .data_out		(),
		      .srcaddr_out	(),
		      .packet_in	(etx_packet[PW-1:0]));//input
   
   //Hold transaction while waiting
   always @ (posedge clk)
     if(~etx_wait)
       tx_packet[PW-1:0] <= etx_packet[PW-1:0];
  
   //the IO pipeline flushes out
   packet2emesh p2m1 (
		     .write_out		(tx_write),
		     .datamode_out	(tx_datamode[1:0]),
		     .ctrlmode_out	(tx_ctrlmode[3:0]),
		     .dstaddr_out	(tx_dstaddr[31:0]),
		     .data_out		(tx_data[31:0]),
		     .srcaddr_out	(tx_srcaddr[31:0]),
		     .packet_in		(tx_packet[PW-1:0]));//input


   //#############################
   //# Burst Detection
   //#############################

   assign burst_addr_match  = ((tx_dstaddr[31:0]+32'h8) == etx_dstaddr[31:0]);

   assign current_match     = tx_access & 
			       tx_write &
		              (tx_datamode[1:0]==2'b11) &		       
			      (tx_ctrlmode[3:0]==4'b0000);

   assign next_match       =  etx_access &
			      etx_write &
		              (etx_datamode[1:0]==2'b11) &		       
			      (etx_ctrlmode[3:0]==4'b0000);
     
   assign tx_burst        =  ~tx_wait         &
		   	      current_match    &
			      next_match       &
			      burst_addr_match;
   
   reg 		  tx_burst_reg;   
   always @ (posedge clk)
     tx_burst_reg <=tx_burst;

   //############################################################
   //# TRANSMIT STATE MACHINE
   //#############################################################
   assign etx_valid = tx_enable & etx_access & ~tx_wait;
   
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
	 `TX_IDLE:  tx_state[2:0] <= etx_valid ? `TX_START : `TX_IDLE;
	 `TX_START: tx_state[2:0] <= `TX_ACK;
	 `TX_ACK:   tx_state[2:0] <= tx_burst  ? `TX_BURST :
				      etx_valid ? `TX_START :
                                      `TX_IDLE;
 	 `TX_BURST: tx_state[2:0] <= tx_burst  ? `TX_BURST : `TX_IDLE;	   
       endcase // case (tx_state[2:0])
   
   assign tx_ack_wait = (tx_state[1:0]==`TX_START);
   assign tx_access   = (tx_state[1:0]==`TX_START);
			
   //#######################################
   //# Wait propagation circuit backwards
   //########################################	  
   wire [63:0] 	  tx_cycle1;
   wire [63:0] 	  tx_cycle2;
   

   assign tx_frame_slow[3:0] = (tx_state[1:0]==`TX_START) ? 4'b0111 :
			       (tx_state[1:0]!=`TX_IDLE)  ? 4'b1111 :
			                                    4'b0000;
   
   assign tx_cycle1[63:0]    = {tx_dstaddr[11:0],tx_datamode[1:0],tx_write,tx_access, //47:32
			        tx_dstaddr[27:12],                                    //31:16
			        ~tx_write,5'b0,tx_burst_reg,1'b0,                     //8-15
			        tx_ctrlmode[3:0],tx_dstaddr[31:28],                   //0-7
			        16'b0 				                      //garbage
			        };
   
   assign tx_cycle2[63:0]   = {tx_srcaddr[15:0],                                      //48-63
			       tx_srcaddr[31:16],                                     //32-47
			       tx_data[15:0],                                         //16-31
			       tx_data[31:16]			                      //0-15
			       };
			       
   assign tx_data_slow[63:0]  = (tx_state[2:0]==`TX_START) ? tx_cycle1[63:0] : 
				                             tx_cycle2[63:0];
 
   
   //#######################################
   //# Wait propagation circuit backwards
   //########################################	      
   //immediate wait for state machine
   assign tx_wait     = tx_wr_wait  | tx_rd_wait;

   //used to detect rising edge of wait signal
   reg 	     tx_wait_reg;   
   always @ (posedge clk)
     tx_wait_reg <=tx_wait;

   //simplify??
//   assign adjust     =  //sage to sample new value on acknowledge
//			((tx_state[1:0]==`TX_ACK) & tx_wait);
   
			//don't wait if there is nothing to wait for
//		        ((tx_state[1:0]==`TX_IDLE) & tx_wait & ~tx_wait_reg);

   //wait for data
   assign etx_wr_wait = (tx_wr_wait | tx_ack_wait );// & ~adjust ;//& ~adjust
   assign etx_rd_wait = (tx_rd_wait | tx_ack_wait );// & ~adjust  ;//& ~adjust
   assign etx_wait    = etx_wr_wait | etx_rd_wait;   

           
endmodule // etx_protocol
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:

