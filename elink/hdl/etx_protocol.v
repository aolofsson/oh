`include "elink_regmap.v"

module etx_protocol (/*AUTOARG*/
   // Outputs
   etx_rd_wait, etx_wr_wait, tx_packet, tx_access, tx_burst,
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
   output [PW-1:0] tx_packet;
   output          tx_access;
   output          tx_burst;
   input           tx_rd_wait;  // The wait signals are passed through
   input           tx_wr_wait;  // to the emesh interfaces

   //###################################################################
   //# Local regs & wires
   //###################################################################
   reg [PW-1:0]  tx_packet; 
   wire 	 etx_write;
   wire [1:0] 	 etx_datamode;
   wire [3:0]	 etx_ctrlmode;
   wire [AW-1:0] etx_dstaddr;
   wire [DW-1:0] etx_data;
   wire 	 tx_write;
   wire [1:0] 	 tx_datamode;
   wire [3:0]	 tx_ctrlmode;
   wire [AW-1:0] tx_dstaddr;   
   wire 	 burst_match;
   wire 	 burst_type_match;
   wire [31:0] 	 burst_addr;
   wire 	 burst_addr_match;
   wire 	 burst_in;

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
   //This transaction should be flushed out on wait????
   reg 	 tx_access_reg;  
   always @ (posedge clk)
     if(!nreset)
       begin
	  tx_access_reg <= 'b0;
	  tx_packet[PW-1:0] <= 'b0;	  
       end
     else if(~(etx_wr_wait | etx_rd_wait))
       begin
	  tx_packet[PW-1:0] <= etx_packet[PW-1:0];
	  tx_access_reg     <= tx_enable & etx_access;
       end
  
   //Clear out the access while in wait state
   //the IO pipeline flushes out
   assign tx_access = tx_access_reg  &
//		      ~burst_negedge &
		      ~(tx_wr_wait | tx_rd_wait);

   //#################################
   //# Checking for transaction "done"
   //#################################
   //if burst, you get immediate "ack"
   //otherwise you get ack in one cycle  
   reg 		 done;
   wire 	 tx_io_wait;

   always @ (posedge clk or negedge nreset)
     if(!nreset)
       done <= 1'b0;                 
     else
       done <= tx_access & ~done;
  
   assign tx_io_wait = tx_access & ~done & ~tx_burst;//tx_burst_reg

   assign adjust     = tx_io_wait_reg & (tx_rd_wait | tx_wr_wait);
  		      
   //#############################
   //# Burst Detection
   //#############################

   packet2emesh p2m1 (
		     .write_out		(tx_write),
		     .datamode_out	(tx_datamode[1:0]),
		     .ctrlmode_out	(tx_ctrlmode[3:0]),
		     .dstaddr_out	(tx_dstaddr[31:0]),
		     .data_out		(),
		     .srcaddr_out	(),
		     .packet_in		(tx_packet[PW-1:0]));//input
   
   assign burst_addr_match  = ((tx_dstaddr[31:0]+32'h8) == etx_dstaddr[31:0]);

   assign current_match     = tx_access & 
			       tx_write &
		              (tx_datamode[1:0]==2'b11) &		       
			      (tx_ctrlmode[3:0]==4'b0000);

   assign next_match       =  etx_access &
			      etx_write &
		              (etx_datamode[1:0]==2'b11) &		       
			      (etx_ctrlmode[3:0]==4'b0000);
     
   assign tx_burst_in =  current_match    &
			 next_match       &
			 burst_addr_match;

   reg tx_wr_wait_reg;
   reg tx_rd_wait_reg;   
   reg tx_io_wait_reg; 
   reg tx_burst_reg;
   //reg tx_burst;   
   //sample to align up witth tx_access   
   always @ (posedge clk) 
     begin
	tx_burst_reg      <= tx_burst_in & tx_access_reg;
	tx_rd_wait_reg    <= tx_rd_wait;
	tx_wr_wait_reg    <= tx_wr_wait;
	tx_io_wait_reg    <= tx_io_wait;
     end

   assign tx_burst  = tx_burst_reg & 
		      tx_burst_in & 
		       ~(tx_wr_wait | tx_rd_wait);
     
   assign burst_negedge = ~tx_burst_in &
			  tx_burst_reg;
   
   //#############################
   //# Wait propagation circuit
   //#############################	      
   assign etx_wr_wait = (tx_wr_wait | tx_io_wait | burst_negedge) & ~adjust;
   assign etx_rd_wait = (tx_rd_wait | tx_io_wait | burst_negedge) & ~adjust;
  
endmodule // etx_protocol
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:

