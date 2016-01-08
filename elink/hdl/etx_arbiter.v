/*
 ########################################################################
 EPIPHANY eMesh Arbiter
 ########################################################################
 
 This block takes three FIFO inputs (write, read request, read response)
 and the DMA channel, arbitrates between the active channels, and forwards 
 the result to the transmit output pins.
 
 Arbitration Priority:
 1) host writes (highest)
 2) read requests from host
 3) read responses

 */

module etx_arbiter (/*AUTOARG*/
   // Outputs
   txwr_wait, txrd_wait, txrr_wait, etx_access, etx_rr, etx_packet,
   // Inputs
   clk, nreset, txwr_access, txwr_packet, txrd_access, txrd_packet,
   txrr_access, txrr_packet, etx_rd_wait, etx_wr_wait, etx_cfg_wait,
   ctrlmode_bypass, ctrlmode
   );

   parameter PW = 104;
   parameter ID = 0;
   
   //tx clock and reset
   input          clk;
   input          nreset;

   //Write Request (from slave)
   input 	   txwr_access;
   input [PW-1:0]  txwr_packet;
   output          txwr_wait;
   
   //Read Request (from slave)
   input 	   txrd_access;
   input [PW-1:0]  txrd_packet;
   output          txrd_wait;
   
   //Read Response (from master)
   input 	   txrr_access;
   input [PW-1:0]  txrr_packet;
   output          txrr_wait;

   //Wait signal inputs
   input           etx_rd_wait;
   input           etx_wr_wait;
   input 	   etx_cfg_wait;
   
   //ctrlmode for rd/wr transactions
   input 	   ctrlmode_bypass;
   input [3:0] 	   ctrlmode;
   
   //Transaction for IO protocol
   output          etx_access;
   output 	   etx_rr;      //bypass translation on read response
   output [PW-1:0] etx_packet;
    
   //regs
   reg 		   etx_access;
   reg [PW-1:0]    etx_packet;
   reg 		   etx_rr;     //bypass translation on read response
   
   //wires  
   wire [3:0] 	   txrd_ctrlmode;
   wire [3:0] 	   txwr_ctrlmode;
   wire 	   access_in;   
   wire [PW-1:0]   etx_packet_mux;
   wire 	   txrr_grant;
   wire 	   txrd_grant;
   wire 	   txwr_grant;  
   wire [PW-1:0]   txrd_splice_packet;
   wire [PW-1:0]   txwr_splice_packet;
   wire [PW-1:0]   etx_mux;

   //##########################################################################
   //# Insert special control mode in packet (UGLY)
   //##########################################################################
   assign txrd_ctrlmode[3:0] =  ctrlmode_bypass ?  ctrlmode[3:0] : 
				                   txrd_packet[6:3];
     
   assign txwr_ctrlmode[3:0] =  ctrlmode_bypass ?  ctrlmode[3:0] : 
				                   txwr_packet[6:3];

   assign txrd_splice_packet[PW-1:0] = {txrd_packet[PW-1:8],   
					1'b0,
					txrd_ctrlmode[3:0], 
					txrd_packet[2:0]};

   assign txwr_splice_packet[PW-1:0] = {txwr_packet[PW-1:8],   
					1'b0,
					txwr_ctrlmode[3:0], 
					txwr_packet[2:0]};
 
   //##########################################################################
   //# Arbiter
   //##########################################################################
   
   oh_arbiter_static #(.N(3)) arbiter (.grants({txrr_grant,	
						txrd_grant,
						txwr_grant //highest priority
						}),
				       .requests({txrr_access,	
						  txrd_access,
						  txwr_access
						  })	
				  );
   //Priority Mux
   assign etx_mux[PW-1:0] =({(PW){txwr_grant}} & txwr_splice_packet[PW-1:0]) |
			   ({(PW){txrd_grant}} & txrd_splice_packet[PW-1:0]) |
			   ({(PW){txrr_grant}} & txrr_packet[PW-1:0]);
 
   
   //######################################################################
   //Pushback (stall) Signals
   //######################################################################
   
   //Write waits on pin wr wait or cfg_wait
   assign txwr_wait = etx_wr_wait |
		      etx_rd_wait |
		      etx_cfg_wait;
   
   //Read response
   assign txrr_wait = etx_wr_wait  |
		      etx_rd_wait  |
		      etx_cfg_wait |
		      txwr_access;

   //Host read request (self throttling, one read at a time)
   assign txrd_wait = etx_rd_wait  |
		      etx_wr_wait  |
		      etx_cfg_wait |
		      txrr_access  |
		      txwr_access;
   
   //#####################################################################
   //# Pipeline stage (arbiter+mux takes time..)
   //#####################################################################
   assign access_in = (txwr_grant & ~txwr_wait) |
		      (txrd_grant & ~txrd_wait) |
		      (txrr_grant & ~txrr_wait);


   
   //access
    always @ (posedge clk)
      if (!nreset)
	begin
	   etx_access        <= 1'b0;   
	   etx_rr            <= 1'b0;	   
	end
      else if (~txwr_wait)
	begin
	   etx_access         <= access_in ;
	   etx_rr             <= txrr_grant & ~txrr_wait;
	end	   
   
   //packet
   always @ (posedge clk)
     if (!nreset)
       etx_packet[PW-1:0] <= 'b0;
     else if (access_in & ~txwr_wait)
       etx_packet[PW-1:0] <= etx_mux[PW-1:0];	 
   
endmodule // etx_arbiter
// Local Variables:
// verilog-library-directories:("." "../../emesh/hdl")
// End:


