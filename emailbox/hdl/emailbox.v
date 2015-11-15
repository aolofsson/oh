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
   mi_dout, mailbox_full, mailbox_not_empty,
   // Inputs
   nreset, wr_clk, rd_clk, emesh_access, emesh_packet, mi_en, mi_we,
   mi_addr, mi_din
   );

   parameter DW     = 32;        //data width of fifo
   parameter AW     = 32;        //data width of fifo
   parameter PW     = 104;       //packet size
   parameter RFAW   = 6;         //address bus width
   parameter ID     = 12'h000;   //link id

   parameter WIDTH  = 104;
   parameter DEPTH  = 32;
   
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
   /*READ INTERFACE             */
   /*****************************/   
   input 	    mi_en;
   input  	    mi_we;      
   input [RFAW+1:0] mi_addr;
   input [63:0]     mi_din;  //assumes write interface is 64 bits
   output [63:0]    mi_dout;   
   
   /*****************************/
   /*MAILBOX OUTPUTS            */
   /*****************************/
   output 	   mailbox_full;
   output 	   mailbox_not_empty;   
   
   /*****************************/
   /*REGISTERS                  */
   /*****************************/
   reg 		   mi_rd_pipe;

   /*****************************/
   /*WIRES                      */
   /*****************************/
   wire [63:0]     mi_dout;
   wire 	    mailbox_read;
   wire 	    mi_rd;
   wire [WIDTH-1:0] mailbox_fifo_data;
   wire 	    mailbox_empty; 
   wire 	    mailbox_pop;
   wire [31:0] 	    emesh_addr;
   wire [63:0] 	    emesh_din;
   wire 	    emesh_write;
   
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
   
   wire emailbox_write  = emesh_access &
	                  emesh_write  &
	                  (emesh_addr[31:20]==ID) & 
			  (emesh_addr[19:16]==`EGROUP_MMR) & 
                          (emesh_addr[RFAW+1:2]==`E_MAILBOXLO); 
   
   /*****************************/
   /*READ BACK DATA             */
   /*****************************/  

   assign mi_rd =  mi_en & ~mi_we;
   
   always @ (posedge rd_clk or negedge nreset)
     if(!nreset)
       mi_rd_pipe <= 1'b0;   
     else
       mi_rd_pipe   <= mi_rd;
   
   wire emailbox_read = mi_rd & (mi_addr[RFAW+1:2]==`E_MAILBOXHI); //fifo read

   assign mi_dout[63:0] = {64{mi_rd_pipe}} & mailbox_fifo_data[63:0];

   /*****************************/
   /*FIFO (64bit wide)          */
   /*****************************/

   assign mailbox_not_empty         = ~mailbox_empty;

   defparam fifo.DW    = WIDTH;
   defparam fifo.DEPTH = DEPTH;
   //TODO: fix the width and depth
   fifo_async fifo(.rst       (~nreset),  
		    // Outputs
		   .dout      (mailbox_fifo_data[WIDTH-1:0]),
		   .empty     (mailbox_empty),
		   .full      (mailbox_full),
     		   .prog_full (),
		   .valid(),
		   //Read Port
		   .rd_en    (emailbox_read), 
		   .rd_clk   (rd_clk),  
		   //Write Port 
		   .din      ({40'b0,emesh_din[63:0]}),
		   .wr_en    (emailbox_write),
		   .wr_clk   (wr_clk)  			     
		   ); 
   
endmodule // emailbox

// Local Variables:
// verilog-library-directories:("." "../../emesh/hdl")
// End:
