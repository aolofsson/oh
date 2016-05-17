/*
 ########################################################################
 EPIPHANY eMesh Arbiter
 ########################################################################

 This block takes three FIFO inputs (write, read request, read response)
 and the DMA channel, arbitrates between the active channels (using round
 robin), and forwards the result to the transmit output pins.

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

   // ???: Add fifo_not_empty/valid signals instead off tx??_access?
   // oh_fifo_cdc deasserts access_out when wait_in is high.
   oh_arbiter_rr3 arbiter (.clk(clk),
			   .nreset(nreset),
			   .grants({txrd_grant,
				    txwr_grant,
				    txrr_grant
				    }),
			   .requests({txrd_access,
				      txwr_access,
				      txrr_access
				      })
			  );
   oh_mux3 #(.DW(PW))
   mux3(.out	(etx_mux[PW-1:0]),
	.in0	(txwr_packet[PW-1:0]),.sel0 (txwr_valid),
	.in1	(txrd_packet[PW-1:0]),.sel1 (txrd_valid),
	.in2	(txrr_packet[PW-1:0]),.sel2 (txrr_valid)
	);

   //######################################################################
   //Pushback (stall) Signals
   //######################################################################
   assign etx_all_wait = (etx_wait     & ~cfg_match) |
			 (etx_cfg_wait &  cfg_match);

   assign txrr_wait = etx_all_wait |       1'b0 | txwr_valid | txrd_valid;
   assign txwr_wait = etx_all_wait | txrr_valid |       1'b0 | txrd_valid;
   assign txrd_wait = etx_all_wait | txrr_valid | txwr_valid |       1'b0;

   //#####################################################################
   //# Pipeline stage (arbiter+mux takes time..)
   //#####################################################################

   assign txwr_valid = txwr_grant & txwr_access;
   assign txrd_valid = txrd_grant & txrd_access;
   assign txrr_valid = txrr_grant & txrr_access;

   assign access_in = txwr_valid | txrd_valid | txrr_valid;

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
       cfg_access  <= (txwr_valid | txrd_valid) & cfg_match;

   //packet
   always @ (posedge clk)
     if (access_in & ~etx_all_wait)
       etx_packet[PW-1:0] <= etx_mux[PW-1:0];	 
   
endmodule // etx_arbiter
// Local Variables:
// verilog-library-directories:("." "../../emesh/hdl" "../../common/hdl")
// End:


