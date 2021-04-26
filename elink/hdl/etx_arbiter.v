/*
 ########################################################################
 EPIPHANY eMesh Arbiter
 ########################################################################
 
 This block takes three FIFO inputs (write, read request, read response)
 and the DMA channel, arbitrates between the active channels, and forwards 
 the result to the transmit output pins.
 
 Arbitration Priority:
 1) read responses (highest)
 2) host writes
 3) read requests from host (lowest)
 */

module etx_arbiter (/*AUTOARG*/
   // Outputs
   txwr_wait, txrd_wait, txrr_wait, etx_access, cfg_access,
   etx_packet,
   // Inputs
   clk, nreset, txwr_access, txwr_packet, txrd_access, txrd_packet,
   txrr_access, txrr_packet, etx_wait, etx_cfg_wait
   );

   parameter AW = 32;   
   parameter PW = 2*AW+40;
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
   input 	   etx_wait;   
   input 	   etx_cfg_wait;
   
   //Outgoing transaction
   output          etx_access;      //for IO
   output 	   cfg_access;      //for RX/RX configuration
   output [PW-1:0] etx_packet;
    
   //regs
   reg 		   etx_access;
   reg [PW-1:0]    etx_packet;
   reg 		   cfg_access;  //config access
   reg [PW-1:0]    cfg_packet;  //config packet
   
   //wires  
   wire [3:0] 	   txrd_ctrlmode;
   wire [3:0] 	   txwr_ctrlmode;
   wire 	   access_in;   
   wire [PW-1:0]   etx_packet_mux;
   wire 	   txrr_grant;
   wire 	   txrd_grant;
   wire 	   txwr_grant;  
   wire [PW-1:0]   etx_mux;
   wire [31:0] 	   dstaddr_mux;
   
   //########################################################################
   //# Arbiter
   //########################################################################
   //TODO: change to round robin!!! (live lock hazard)
   
   oh_arbiter #(.N(3)) arbiter (.grants({txrd_grant,
					 txwr_grant, //highest priority
					 txrr_grant	
					 }),
				.requests({txrd_access,
					   txwr_access,
					   txrr_access	
					   })
				);
   oh_mux3 #(.DW(PW))
   mux3(.out	(etx_mux[PW-1:0]),
	.in0	(txwr_packet[PW-1:0]),.sel0 (txwr_grant),
	.in1	(txrd_packet[PW-1:0]),.sel1 (txrd_grant),
	.in2	(txrr_packet[PW-1:0]),.sel2 (txrr_grant)
	);

   //######################################################################
   //Pushback (stall) Signals
   //######################################################################
   assign etx_all_wait = (etx_wait     & ~cfg_match) |
			 (etx_cfg_wait &  cfg_match);
      
   //Read response
   assign txrr_wait = etx_all_wait;

   //Write waits on pin wr wait or cfg_wait
   assign txwr_wait = etx_all_wait |
		      txrr_access;

   //Host read request (self throttling, one read at a time)
   assign txrd_wait = etx_all_wait |
		      txrr_access  |
		      txwr_access;
   
   //#####################################################################
   //# Pipeline stage (arbiter+mux takes time..)
   //#####################################################################
   assign access_in = txwr_grant |
		      txrd_grant |
		      txrr_grant;

/*   assign access_in = (txwr_grant & ~txwr_wait) |
		      (txrd_grant & ~txrd_wait) |
		      (txrr_grant & ~txrr_wait);

  */ 
   
   packet2emesh #(.AW(AW))
   p2e (.write_in	(),
	.datamode_in	(),
	.ctrlmode_in	(),
	.dstaddr_in	(dstaddr_mux[31:0]),
	.srcaddr_in	(),
	.data_in	(),
	.packet_in	(etx_mux[PW-1:0]));
   
   assign cfg_match = (dstaddr_mux[31:20]==ID);

   //access decode
    always @ (posedge clk)
      if (!nreset)
	etx_access    <= 1'b0;   
      else if (~etx_wait)
	//for loopback, send cfg to RX (mostly for mailbox)
	etx_access   <= access_in & ~cfg_match;

   //config access
   always @ (posedge clk)
     if (!nreset)
       cfg_access  <= 1'b0;	   
     else if (~etx_cfg_wait)
       cfg_access  <= (txwr_grant | txrd_grant) & cfg_match;

   //packet
   always @ (posedge clk)
     if (access_in & ~etx_all_wait)
       etx_packet[PW-1:0] <= etx_mux[PW-1:0];	 
   
endmodule // etx_arbiter
// Local Variables:
// verilog-library-directories:("." "../../emesh/hdl" "../../common/hdl")
// End:


