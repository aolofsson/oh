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
   reg           tx_access;
   reg [PW-1:0]  tx_packet; 
   reg 		 tx_io_wait;
   
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

   //Creates a one cycle wait whenever there is no burst
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       tx_io_wait <= 1'b0;            
     else if (tx_rd_wait | tx_wr_wait)
       tx_io_wait <= 1'b0;            
     else
       tx_io_wait <= etx_access & ~tx_io_wait & ~tx_burst;//~tx_burst_reg
   
   //Hold transaction while waiting
   //This transaction should be flushed out on wait????
   always @ (posedge clk)
     if(!nreset)
       begin
	  tx_packet[PW-1:0] <= 'b0;
	  tx_access     <= 1'b0;
       end     
     else if(~(etx_wr_wait | etx_rd_wait))
       begin
	  tx_packet[PW-1:0] <= etx_packet[PW-1:0];
	  tx_access         <= tx_enable & etx_access;
       end
   
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

   reg [31:0] dstaddr_incr;
   reg [1:0]  datamode_old;
   reg [3:0]  ctrlmode_old;
   reg        write_old;
   reg 	      access_old;
   

/*   always @ (posedge clk)
     if (~(etx_wr_wait | etx_rd_wait))
     begin
	dstaddr_incr[31:0] <= tx_dstaddr[31:0] + 32'h8;
	write_old          <= tx_write;
	datamode_old[1:0]  <= tx_datamode[1:0];
	access_old         <= tx_access;
	ctrlmode_old[3:0]  <= tx_ctrlmode[3:0];	
     end     
*/
   
   assign burst_addr_match  = ((tx_dstaddr[31:0]+32'h8) == etx_dstaddr[31:0]);

   assign current_match     = tx_access &
			      tx_write &
		              (tx_datamode[1:0]==2'b11) &		       
			      (tx_ctrlmode[3:0]==4'b0000);

   assign next_match       =  etx_access &
			      etx_write &
		              (etx_datamode[1:0]==2'b11) &		       
			      (etx_ctrlmode[3:0]==4'b0000);
     
   assign tx_burst_in =  ~tx_wr_wait      &
			 current_match    &
			 next_match       &
			 burst_addr_match;

   reg tx_wr_wait_reg;
   reg tx_rd_wait_reg;   
   reg tx_io_wait_reg; 
   reg tx_burst_reg;
   reg tx_burst;   
   //sample to align up witth tx_access   
   always @ (posedge clk) 
     begin
	tx_burst          <= tx_burst_in;
	tx_burst_reg      <= tx_burst;
	tx_rd_wait_reg    <= tx_rd_wait;
	tx_wr_wait_reg    <= tx_wr_wait;
	tx_io_wait_reg    <= tx_io_wait;
     end
        
   assign special_sample = tx_io_wait_reg                   & 
		           (tx_wr_wait     | tx_rd_wait)    &
   			   ~(tx_wr_wait_reg | tx_rd_wait_reg) 
			    ;

   //#############################
   //# Wait propagation circuit
   //#############################	      
   assign etx_wr_wait = (tx_wr_wait  | tx_io_wait) & ~special_sample;
   assign etx_rd_wait = (tx_rd_wait  | tx_io_wait) & ~special_sample;
  
endmodule // etx_protocol
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:

