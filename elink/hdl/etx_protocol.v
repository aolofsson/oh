`include "elink_regmap.v"

module etx_protocol (/*AUTOARG*/
   // Outputs
   etx_rd_wait, etx_wr_wait, tx_packet, tx_access, tx_burst,
   // Inputs
   nreset, clk, etx_access, etx_packet, tx_enable, gpio_data,
   gpio_enable, tx_io_ack, tx_rd_wait, tx_wr_wait
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
   output [PW-1:0] tx_packet;
   output          tx_access;
   output          tx_burst;
   input           tx_io_ack;   // acknowledge signal from IO (clears wait) 
   input           tx_rd_wait;  // The wait signals are passed through
   input           tx_wr_wait;  // to the emesh interfaces

   //###################################################################
   //# Local regs & wires
   //###################################################################
   reg 		 tx_burst;   
   reg           tx_access;
   reg [PW-1:0]  tx_packet; 
   reg 		 tx_io_wait;
   
   wire 	 etx_write;
   wire [1:0] 	 etx_datamode;
   wire [3:0]	 etx_ctrlmode;
   wire [AW-1:0] etx_dstaddr;
   wire [DW-1:0] etx_data;
   wire 	 last_write;
   wire [1:0] 	 last_datamode;
   wire [3:0]	 last_ctrlmode;
   wire [AW-1:0] last_dstaddr;   
   wire 	 burst_match;
   wire 	 burst_type_match;
   wire [31:0] 	 burst_addr;
   wire 	 burst_addr_match;
   wire 	 burst_in;
   
   //packet to emesh bundle
   packet2emesh p2m0 (
		      .write_out	(etx_write),
		      .datamode_out	(etx_datamode[1:0]),
		      .ctrlmode_out	(etx_ctrlmode[3:0]),
		      .dstaddr_out	(etx_dstaddr[31:0]),
		      .data_out		(),
		      .srcaddr_out	(),
		      .packet_in	(etx_packet[PW-1:0]));//input

   //Simple stall state machine
   //Gets set for one cycle whenever there is no burst
   //gets cleared by ack from io logic
   
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       tx_io_wait <= 1'b0;    
     else if (tx_io_ack)
       tx_io_wait <= 1'b0;
     else
       tx_io_wait <= tx_access & ~burst_in;        
     
   //Hold transaction while waiting
   //This transaction should be flushed out
   always @ (posedge clk)
     if(!nreset)
       begin
	  tx_packet[PW-1:0] <= 'b0;
	  tx_access         <= 1'b0;
       end     
     else if(~(etx_wr_wait | etx_rd_wait))
       begin
	  tx_packet[PW-1:0] <= etx_packet[PW-1:0];
	  tx_access         <= tx_enable & etx_access;	
       end
   
   //#############################
   //# Burst Detection
   //#############################
   always @ (posedge clk)
     if(!nreset)
       tx_burst <= 1'b0;   
     else       
       tx_burst          <= burst_in;

   packet2emesh p2m1 (
		     .write_out		(last_write),
		     .datamode_out	(last_datamode[1:0]),
		     .ctrlmode_out	(last_ctrlmode[3:0]),
		     .dstaddr_out	(last_dstaddr[31:0]),
		     .data_out		(),
		     .srcaddr_out	(),
		     .packet_in		(tx_packet[PW-1:0]));//input

   assign burst_addr[31:0]  = (last_dstaddr[31:0] + 32'h8);
   
   assign burst_addr_match  = (burst_addr[31:0] == etx_dstaddr[31:0]);

   assign burst_type_match  = {last_ctrlmode[3:0],last_datamode[1:0],last_write}
			       ==
		   	      {etx_ctrlmode[3:0],etx_datamode[1:0], etx_write};

   assign burst_in   =    etx_write                 & //write 
	       	         (etx_datamode[1:0]==2'b11) & //double only
		          burst_type_match          & //same types
		          burst_addr_match;            //inc by 8
   			      
   //Stall for all etx pipeline
   assign etx_wr_wait = tx_wr_wait  | tx_io_wait;
   assign etx_rd_wait = tx_rd_wait  | tx_io_wait;
        
endmodule // etx_protocol
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:

