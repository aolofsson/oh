/*
 ###########################################################################
 # Function: A mailbox FIFO with a FIFO empty/full flags that can be used as   
 #           interrupts.
 #
 #           E_MAILBOXLO    = lower 32 bits of FIFO entry
 #           E_MAILBOXHI    = upper 32 bits of FIFO entry
 #
 # Notes:    1.) System should take care of not overflowing the FIFO
 #           2.) Reading the E_MAILBOXHI causes a fifo rd pointer update
 #           3.) The "embox_not_empty" is a "level" interrupt signal.
 #
 # How to use: 1.) Connect "embox_not_empty" to interrupt input line
 #             2.) Write an ISR to respond to interrupt line::
 #                 -reads E_MAILBOXLO, then
 #                 -reads E_MAILBOXHI, then
 #                 -finishes ISR
 #
 ###########################################################################
 */
`include "emailbox_regmap.v" // is there a better way?
module emailbox (/*AUTOARG*/
   // Outputs
   mi_dout, mailbox_irq,
   // Inputs
   nreset, wr_clk, rd_clk, emesh_access, emesh_packet, mi_en, mi_we,
   mi_addr, mailbox_irq_en
   );

   parameter DW     = 32;        //data width of fifo
   parameter AW     = 32;        //data width of fifo
   parameter PW     = 104;       //packet size
   parameter RFAW   = 6;         //address bus width
   parameter ID     = 12'h000;   //link id

   parameter MW     = 104;       //fifo memory width
   parameter DEPTH  = 32;        //fifo depth
   
   /*****************************/
   /*RESET                      */
   /*****************************/
   input           nreset;      //asynchronous active low reset
   input 	   wr_clk;      //write clock
   input 	   rd_clk;      //read clock
   
   /*****************************/
   /*WRITE INTERFACE            */
   /*****************************/
   input 	   emesh_access;
   input [PW-1:0]  emesh_packet;
   
   /*****************************/
   /*32 BIT READ INTERFACE      */
   /*****************************/   
   input 	    mi_en;
   input  	    mi_we;      
   input [RFAW+1:0] mi_addr;
   output [63:0]    mi_dout;   
   
   /*****************************/
   /*MAILBOX CONTROl            */
   /*****************************/
   input 	    mailbox_irq_en; 	    
   output 	    mailbox_irq;   
   
   /*****************************/
   /*REGISTERS                  */
   /*****************************/
   reg 		  mi_rd_reg;   
   reg [RFAW+1:2] mi_addr_reg;
   reg 		  read_hi;
   reg 		  read_status;
   
   /*****************************/
   /*WIRES                      */
   /*****************************/
   wire 	    mi_rd;  
   wire [31:0] 	    emesh_addr;
   wire [63:0] 	    emesh_din;
   wire 	    emesh_write;
   wire 	    mailbox_read;
   wire 	    mailbox_write;
   wire [MW-1:0]    mailbox_data;
   wire 	    mailbox_empty; 
   /*****************************/
   /*WRITE TO FIFO              */
   /*****************************/  
   packet2emesh pe2 (// Outputs
		     .write_out		(emesh_write),
		     .datamode_out	(),
		     .ctrlmode_out	(),
		     .data_out		(emesh_din[31:0]),
		     .dstaddr_out	(emesh_addr[31:0]),
		     .srcaddr_out	(emesh_din[63:32]),
		     // Inputs
		     .packet_in		(emesh_packet[PW-1:0]));
   
   assign mailbox_write  = emesh_access &
	                  emesh_write  &
	                  (emesh_addr[31:20]==ID) & 
			  (emesh_addr[19:16]==`EGROUP_MMR) & 
                          (emesh_addr[RFAW+1:2]==`E_MAILBOXLO); 
   
   /*****************************/
   /*READ BACK DATA (32BIT)     */
   /*****************************/  

   assign mi_rd         = mi_en & ~mi_we;   
   assign mailbox_read  = mi_rd & (mi_addr[RFAW+1:2]==`E_MAILBOXLO); //fifo read

   always @ (posedge rd_clk)
     begin
	read_hi     <= mi_rd & (mi_addr[RFAW+1:2]==`E_MAILBOXHI);
	read_status <= mi_rd & (mi_addr[RFAW+1:2]==`E_MAILBOXSTAT);
     end
   assign mi_dout[31:0]  = read_status ? {30'b0,mailbox_full, mailbox_not_empty} :
			   read_hi     ? mailbox_data[63:32]                     : 
			                 mailbox_data[31:0];
   assign mi_dout[63:32] = mailbox_data[63:32];
   
   /*****************************/
   /*FIFO (64bit wide)          */
   /*****************************/
   defparam fifo.DW    = MW;
   defparam fifo.DEPTH = DEPTH;
   //TODO: fix the width and depth
   fifo_async fifo(.rst       (~nreset),  
		    // Outputs
		   .dout      (mailbox_data[MW-1:0]),
		   .empty     (mailbox_empty),
		   .full      (mailbox_full),
     		   .prog_full (),
		   .valid     (dout_valid),
		   //Read Port
		   .rd_en    (mailbox_read), 
		   .rd_clk   (rd_clk),  
		   //Write Port 
		   .din      ({40'b0,emesh_din[63:0]}),
		   .wr_en    (mailbox_write),
		   .wr_clk   (wr_clk)  			     
		   ); 


   /*****************************/
   /*FIFO (64bit wide)          */
   /*****************************/
   assign mailbox_not_empty         = ~mailbox_empty;
   assign mailbox_irq = mailbox_irq_en & ( mailbox_not_empty | mailbox_full);
   
   
endmodule // emailbox

// Local Variables:
// verilog-library-directories:("." "../../emesh/hdl")
// End:
