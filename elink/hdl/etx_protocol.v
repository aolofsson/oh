`include "elink_regmap.v"

module etx_protocol (/*AUTOARG*/
   // Outputs
   etx_rd_wait, etx_wr_wait, tx_packet, tx_access, tx_burst,
   // Inputs
   reset, clk, etx_access, etx_packet, tx_enable, gpio_data,
   gpio_enable, tx_io_wait, tx_rd_wait, tx_wr_wait
   );

   parameter PW = 104;
   parameter AW = 32;   
   parameter DW = 32;
   parameter ID = 12'h000;
   
   //Clock/reset
   input 	  reset;
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
   input           tx_io_wait;  
   input           tx_rd_wait;  // The wait signals are passed through
   input           tx_wr_wait;  // to the emesh interfaces

   //###################################################################
   //# Local regs & wires
   //###################################################################
   reg 		   tx_burst;
   
   reg           tx_access;
   reg [PW-1:0]  tx_packet; 
   wire		 tx_rd_wait_sync;
   wire 	 tx_wr_wait_sync;
   wire 	 etx_write;
   wire [1:0] 	 etx_datamode;
   wire [3:0]	 etx_ctrlmode;
   wire [AW-1:0] etx_dstaddr;
   wire [DW-1:0] etx_data;
   wire 	 last_write;
   wire [1:0] 	 last_datamode;
   wire [3:0]	 last_ctrlmode;
   wire [AW-1:0] last_dstaddr;   
   wire 	 etx_valid;
   reg           etx_io_wait;
   wire 	 burst_match;
   wire 	 burst_type_match;
   wire [31:0] 	 burst_addr;
   wire 	 burst_addr_match;
    
   //packet to emesh bundle
   packet2emesh p2m0 (
		      .write_out	(etx_write),
		      .datamode_out	(etx_datamode[1:0]),
		      .ctrlmode_out	(etx_ctrlmode[3:0]),
		      .dstaddr_out	(etx_dstaddr[31:0]),
		      .data_out		(),
		      .srcaddr_out	(),
		      .packet_in	(etx_packet[PW-1:0]));//input

   //Only set valid if not wait and 
   assign etx_valid = (tx_enable & 
		       etx_access & 
		       ~((etx_dstaddr[31:20]==ID) & (etx_dstaddr[19:16]!=`EGROUP_RR)) &
		      ((etx_write & ~tx_wr_wait_sync) | (~etx_write & ~tx_rd_wait_sync))
		       );
   

   reg 		 tx_io_wait_reg;
   
   //Pipeline the io wait to improve timing
   always @ (posedge clk)
     tx_io_wait_reg <= tx_io_wait;

   //Prepare transaction / with burst
   always @ (posedge clk)
     if(reset)
       begin
	  tx_packet[PW-1:0] <= 'b0;
	  tx_access         <= 1'b0;
       end
   else if(~tx_io_wait)
     begin
	tx_packet[PW-1:0] <= etx_packet[PW-1:0];
	tx_access         <= etx_valid;
       end

   
   always @ (posedge clk)
     if(reset)
       tx_burst <= 1'b0;   
     else       
       tx_burst          <= (etx_write                 & //write 
	       	            (etx_datamode[1:0]==2'b11) & //double only
			    burst_type_match           & //same types
			    burst_addr_match);           //inc by 8
   
   //#############################
   //# Burst Detection
   //#############################

   packet2emesh p2m1 (
		     .write_out		(last_write),
		      .datamode_out	(last_datamode[1:0]),
		     .ctrlmode_out	(last_ctrlmode[3:0]),
		     .dstaddr_out	(last_dstaddr[31:0]),
		     .data_out		(),
		     .srcaddr_out	(),
		     .packet_in		(tx_packet[PW-1:0]));//input

   assign burst_addr[31:0]  = (last_dstaddr[31:0] + 4'd8);
   
   assign burst_addr_match  = (burst_addr[31:0] == etx_dstaddr[31:0]);

   assign burst_type_match  = {last_ctrlmode[3:0],last_datamode[1:0],last_write}
			       ==
		   	      {etx_ctrlmode[3:0],etx_datamode[1:0], etx_write};
   			      

   //#############################
   //# Wait signals (async)
   //#############################

   synchronizer #(.DW(1)) rd_sync (// Outputs
				   .out		(tx_rd_wait_sync),
				   // Inputs
				   .in		(tx_rd_wait),
				   .clk		(clk),
				   .reset	(reset)
				   );
   
   synchronizer #(.DW(1)) wr_sync (// Outputs
				   .out		(tx_wr_wait_sync),
				   // Inputs
				   .in		(tx_wr_wait),
				   .clk		(clk),
				   .reset	(reset)
				   );

   //Stall for all etx pipeline
   assign etx_wr_wait = tx_wr_wait_sync | tx_io_wait;
   assign etx_rd_wait = tx_rd_wait_sync | tx_io_wait;
        
endmodule // etx_protocol
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:

