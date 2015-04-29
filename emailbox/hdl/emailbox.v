/*
 ###########################################################################
 # Function: A mailbox FIFO with a FIFO empty/full flags that can be used as   
 #           interrupts. Status of the FIFO can be polled.
 #
 #           EMAILBOXLO    = lower 32 bits of FIFO entry
 #           EMAILBOXHI    = upper 32 bits of FIFO entry
 #           EMBSTATUS = status of FIFO [0]=1-->fifo not empty
 #                                      [1]=1-->fifo full      
 #
 # Notes:    System takes care of not overflowing the FIFO
 #           Reading the EMAILBOXHI causes rd pointer to update to next entry
 #           EMAILBOXLO/EMAILBOXHI must be consecutive addresses for write.
 #           The "embox_not_empty" will stay high as long as there are messages
 #
 # How to use: 1.) Connect "embox_not_empty" to interrupt input line
 #             2.) Write an ISR to respond to interrupt line that:
 #                 -reads EMAILBOXLO, then
 #                 -reads EMAILBOXHI, then
 #                 -finishes ISR
 ############################################################################
 */

module emailbox (/*AUTOARG*/
   // Outputs
   mi_dout, mailbox_full, mailbox_not_empty,
   // Inputs
   reset, sys_clk, mi_en, mi_we, mi_addr, mi_din
   );

   parameter DW     = 32;      //data width of fifo
   parameter AW     = 32;      //data width of fifo
   parameter PW     = 104;     //packet size
   parameter RFAW   = 5;       //address bus width
   parameter GROUP  = 4'h0;    //address map group
   parameter ID     = 12'h800; //link id

   /*****************************/
   /*RESET                      */
   /*****************************/
   input           reset;       //asynchronous reset
   input 	   sys_clk;   

   /*****************************/
   /*READ INTERFACE             */
   /*****************************/
   
   input 	   mi_en;
   input  	   mi_we;      
   input [19:0]    mi_addr;
   input [63:0]    mi_din;  //assumes write interface is 64 bits
   output [31:0]   mi_dout;   
   
   /*****************************/
   /*MAILBOX OUTPUTS            */
   /*****************************/
   output 	   mailbox_full;
   output 	   mailbox_not_empty;   
   
   /*****************************/
   /*REGISTERS                  */
   /*****************************/
   reg [DW-1:0]    mi_dout;

   /*****************************/
   /*WIRES                      */
   /*****************************/
   wire 	   mailbox_read;
   wire 	   mailbox_pop_fifo;
   wire [2*DW-1:0] mailbox_fifo_data;
   wire 	   mailbox_empty;
   wire 	   mailbox_write;
   
   /*****************************/
   /*WRITE PORT                */
   /*****************************/
   assign mailbox_write  = mi_en & mi_we & (mi_addr[RFAW+1:2]==`EMAILBOXLO);
   
   /*****************************/
   /*READ BACK DATA             */
   /*****************************/  

   assign mailbox_pop_fifo     = mi_en & 
				 ~mi_we &
				 mailbox_not_empty &
				 mailbox_read & (mi_addr[RFAW+1:2]==`EMAILBOXHI); //fifo read

   always @ (posedge sys_clk)
     if(mailbox_read)
       case(mi_addr[RFAW+1:2])	 
	 `EMAILBOXLO:   mi_dout[DW-1:0] <= mailbox_fifo_data[DW-1:0];	 
	 `EMAILBOXHI:   mi_dout[DW-1:0] <= mailbox_fifo_data[2*DW-1:DW];	 
	 default:    mi_dout[DW-1:0] <= 32'd0;
       endcase // case (mi_addr[RFAW-1:2])
   
   /*****************************/
   /*FIFO (64-BIT)              */
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
			     .rd_en    (mailbox_pop_fifo), 
			     .rd_clk   (sys_clk),  
			     //Write Port 
			     .din      (mi_din[63:0]),
			     .wr_en    (mailbox_write),
			     .wr_clk   (sys_clk),  			     
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
