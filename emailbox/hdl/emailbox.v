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
   reset, clk, mi_en, mi_we, mi_addr, mi_din
   );

   parameter DW    = 32;    //data width of fifo
   parameter RFAW  = 5;     //address bus width
   parameter FAW   = 4;     //fifo entries==2^FAW
   parameter GROUP = 4'h0;  //address map group 

   /*****************************/
   /*CLOCK AND RESET            */
   /*****************************/
   input           reset;       //synchronous  reset
   input 	   clk;

   /*****************************/
   /*SIMPLE MEMORY INTERFACE    */
   /*****************************/
   input 	   mi_en;
   input  	   mi_we;      
   input [19:0]    mi_addr;
   input [DW-1:0]  mi_din;
   output [DW-1:0] mi_dout;   
   
   /*****************************/
   /*MAILBOX OUTPUTS            */
   /*****************************/
   output 	   mailbox_full;
   output 	   mailbox_not_empty;   
   
   /*****************************/
   /*REGISTERS                  */
   /*****************************/
   reg [DW-1:0]    mi_dout;
   reg [DW-1:0]    mailbox_data_reg;
   reg 		   mi_data_sel;
   /*****************************/
   /*WIRES                      */
   /*****************************/
   wire 	   mailbox_read;
   wire 	   mailbox_write;
   wire 	   mailbox_lo_write;
   wire 	   mailbox_push_fifo;
   wire 	   mailbox_pop_fifo;
   wire [2*DW-1:0] mailbox_fifo_data;
   wire 	   mailbox_empty;

   
   /*****************************/
   /*DECODE LOGIC               */
   /*****************************/
     
   //fifo read/write logic
   assign mailbox_write       = mi_en & mi_we;
   assign mailbox_read        = mi_en & ~mi_we;

   //Register write enables
   assign  mailbox_lo_write    = mailbox_write & (mi_addr[RFAW+1:2]==`EMAILBOXLO); //write to shadow
   assign  mailbox_push_fifo   = mailbox_write & (mi_addr[RFAW+1:2]==`EMAILBOXHI); //initiates FIFO write
   
   //read logic   
   assign mailbox_pop_fifo     = mailbox_read & (mi_addr[RFAW+1:2]==`EMAILBOXHI); //fifo read      

   /*****************************/
   /*WRITE ACTION               */
   /*****************************/

   //shadow register for writing lower word (32 bit bus)
   always @ (posedge clk)
     if(mailbox_lo_write)
       mailbox_data_reg[DW-1:0] <=mi_din[DW-1:0];
   
   /*****************************/
   /*READ BACK DATA             */
   /*****************************/

   always @ (posedge clk)
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
   fifo_sync #(.DW(64)) mbox(// Outputs
			     .rd_data  (mailbox_fifo_data[2*DW-1:0]),
			     .rd_empty (mailbox_empty),
			     .wr_full  (mailbox_full),
			     // Inputs
			     .rd_en    (mailbox_pop_fifo), 
			     .wr_data  ({mi_din[DW-1:0],mailbox_data_reg[DW-1:0]}),
			     .wr_en    (mailbox_push_fifo),
			     .clk      (clk),  
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
