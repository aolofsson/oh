`include "elink_regmap.vh"
module erx_arbiter (/*AUTOARG*/
   // Outputs
   rx_rd_wait, rx_wr_wait, edma_wait, ecfg_wait, rxwr_access,
   rxwr_packet, rxrd_access, rxrd_packet, rxrr_access, rxrr_packet,
   // Inputs
   erx_access, erx_packet, mailbox_wait, edma_access, edma_packet,
   ecfg_access, ecfg_packet, rxwr_wait, rxrd_wait, rxrr_wait
   );

   parameter AW   = 32;
   parameter DW   = 32;
   parameter PW   = 104;
   parameter ID   = 12'h800; //link id
   parameter RFAW = 6;
   
   //Incoming packet (writes)  
   input           erx_access; //from MMU
   input [PW-1:0]  erx_packet;
   output          rx_rd_wait; //for IO
   output          rx_wr_wait; //for IO

   //Pushback from mailbox
   input 	   mailbox_wait;
   
   //From DMA
   input           edma_access;
   input [PW-1:0]  edma_packet;
   output 	   edma_wait;

   //From ETX
   input           ecfg_access;
   input [PW-1:0]  ecfg_packet;
   output 	   ecfg_wait;

   //To Master Write FIFO
   output 	   rxwr_access;
   output [PW-1:0] rxwr_packet;   
   input           rxwr_wait;
   
   //To Master Read FIFO
   output 	   rxrd_access;
   output [PW-1:0] rxrd_packet;   
   input           rxrd_wait;
   
   //To Slave Read Response FIFO
   output 	   rxrr_access;
   output [PW-1:0] rxrr_packet;   
   input           rxrr_wait;

   //####################################
   //Splicing pakets
   //####################################
   wire 	   erx_write;
   wire [AW-1:0]   erx_dstaddr;
   wire 	   erx_read;
   
   packet2emesh #(.AW(AW))
   p2e (// Outputs
	.write_in	(erx_write),
	.datamode_in	(),
	.ctrlmode_in	(),
	.data_in	(),
	.dstaddr_in	(erx_dstaddr[AW-1:0]),
	.srcaddr_in	(),
	// Inputs
	.packet_in	(erx_packet[PW-1:0]));
   
   //#######################################################
   //Read response path (from IO or elink register readback)
   //#######################################################
     
   assign rxrr_access   =  ecfg_access |
			   (erx_access & 
			   (erx_dstaddr[31:20]==ID) &
			    erx_dstaddr[19:16]==`EGROUP_RR);
   
   assign rxrr_packet[PW-1:0] = ecfg_access ? ecfg_packet[PW-1:0] :	    
                                              erx_packet[PW-1:0];

   //####################################
   //Write Path (from IO through MMU)
   //####################################

   assign rxwr_access         = erx_access   & 
				erx_write    &
				~(erx_dstaddr[31:20]==ID);
   
   assign rxwr_packet[PW-1:0] = erx_packet[PW-1:0];
         
   //########################################
   //Read Request Path (from IO through MMU) 
   //########################################

   assign erx_read            = erx_access & ~erx_write;
   
   assign rxrd_access         = erx_read | edma_access;
   
   assign rxrd_packet[PW-1:0] = erx_read ? erx_packet[PW-1:0] : 
				            edma_packet[PW-1:0];
   
   //####################################
   //Wait Signals
   //####################################   
   assign ecfg_wait     = rxrr_wait;

   assign edma_wait     = rxrd_wait | erx_read;
   
   assign rx_rd_wait    = rxrd_wait;

   assign rx_wr_wait    = ecfg_access  |
			  mailbox_wait |
			  rxwr_wait    | 
			  rxrr_wait;
   
endmodule // erx_arbiter

// Local Variables:
// verilog-library-directories:("." "../../common/hdl" "../../emesh/hdl")
// End:


