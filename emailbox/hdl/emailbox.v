/*
 ###########################################################################
 # Function: A mailbox FIFO with a FIFO empty/full flags that can be used as   
 #           interrupts. Status of the FIFO can be polled.
 #
 #           E_MAILBOXLO    = lower 32 bits of FIFO entry
 #           E_MAILBOXHI    = upper 32 bits of FIFO entry
 #
 # Notes:    System takes care of not overflowing the FIFO
 #           Reading the E_MAILBOXHI causes rd pointer to update to next entry
 #           E_MAILBOXLO/E_MAILBOXHI must be consecutive addresses for write.
 #           The "embox_not_empty" will stay high as long as there are messages
 #
 # How to use: 1.) Connect "embox_not_empty" to interrupt input line
 #             2.) Write an ISR to respond to interrupt line that:
 #                 -reads E_MAILBOXLO, then
 #                 -reads E_MAILBOXHI, then
 #                 -finishes ISR
 ###########################################################################
 */

module emailbox (/*AUTOARG*/
   // Outputs
   mi_dout, mailbox_full, mailbox_not_empty,
   // Inputs
   reset, wr_clk, rd_clk, emesh_access, emesh_packet, mi_en, mi_we,
   mi_addr, mi_din
   );

   parameter DW     = 32;      //data width of fifo
   parameter AW     = 32;      //data width of fifo
   parameter PW     = 104;     //packet size
   parameter RFAW   = 6;       //address bus width
   parameter GROUP  = 4'h0;    //address map group
   parameter ID     = 12'h000; //link id

   /*****************************/
   /*RESET                      */
   /*****************************/
   input           reset;       //asynchronous reset
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
   reg [63:0]     mi_dout;

   /*****************************/
   /*WIRES                      */
   /*****************************/
   wire 	   mailbox_read;
   wire 	   mi_rd;
   wire [2*DW-1:0] mailbox_fifo_data;
   wire 	   mailbox_empty; 
   wire 	   mailbox_pop;
   wire [31:0] 	   emesh_addr;
   wire [63:0] 	   emesh_din;
   wire 	   emesh__write;
   
   /*****************************/
   /*WRITE TO FIFO              */
   /*****************************/  

   assign emesh_addr[31:0]  = emesh_packet[39:8];

   assign emesh_din[63:0]   = emesh_packet[103:40];
  
   assign emesh_write       = emesh_access &
			      emesh_packet[1] &
			      (emesh_addr[31:20]==ID) & 
			      (emesh_addr[10:8]==3'h3) & 
                              (emesh_addr[RFAW+1:2]==`E_MAILBOXLO); 
   
   /*****************************/
   /*READ BACK DATA             */
   /*****************************/  

   assign mi_rd =  mi_en & ~mi_we;
   
   assign mailbox_pop  = mi_rd & (mi_addr[RFAW+1:2]==`E_MAILBOXHI); //fifo read

   always @ (posedge rd_clk)
     if(mi_rd)
       case(mi_addr[RFAW+1:2])	 
	 `E_MAILBOXLO:   mi_dout[63:0] <= mailbox_fifo_data[63:0];	 
	 `E_MAILBOXHI:   mi_dout[63:0] <= {mailbox_fifo_data[2*DW-1:DW],mailbox_fifo_data[2*DW-1:DW]};	 
	 default:        mi_dout[63:0] <= 64'd0;
       endcase // case (mi_addr[RFAW-1:2])
     else
       mi_dout[63:0] <= 64'd0;

   /*****************************/
   /*FIFO (64bit wide)          */
   /*****************************/

   assign mailbox_not_empty         = ~mailbox_empty;

   //BUG! This fifo is currently hard coded to 32 entries
   //Should be parametrized to up to 4096 entries
   fifo_async #(.DW(64), .AW(5)) fifo(// Outputs
			     .dout      (mailbox_fifo_data[2*DW-1:0]),
			     .empty     (mailbox_empty),
			     .full      (mailbox_full),
     			     .prog_full (),
			     //Read Port
			     .rd_en    (mailbox_pop), 
			     .rd_clk   (rd_clk),  
			     //Write Port 
			     .din      (emesh_din[63:0]),
			     .wr_en    (emesh_write),
			     .wr_clk   (wr_clk),  			     
			     .reset    (reset)      
			     ); 
   
endmodule // emailbox

/*
  Copyright (C) 2014 Adapteva, Inc.
  Contributed by Andreas Olofsson <andreas@adapteva.com>
 
   This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.This program is distributed in the hope 
  that it will be useful,but WITHOUT ANY WARRANTY; without even the implied 
  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details. You should have received a copy 
  of the GNU General Public License along with this program (see the file 
  COPYING).  If not, see <http://www.gnu.org/licenses/>.
*/
