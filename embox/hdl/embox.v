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

/*###########################################################################
 # Function: A mailbox FIFO with a FIFO empty/full flags that can be used as   
 #           interrupts. Status of the FIFO can be polled.
 #
 #           REG_EMBOX0  = lower 32 bits of FIFO entry
 #           REG_EMBOX1  = upper 32 bits of FIFO entry
 #           REG_EMBPOLL = status of FIFO [0]=1-->fifo not empty
 #                                        [1]=1-->fifo full      
 #
 # Notes:    System takes care of not overflowing the FIFO
 #           Reading the REG_EMBOX1 causes rd pointer to update to next entry
 #           EMBOX0/EMBOX1 must be consecutive addresses for write.
 #
 ############################################################################
 */

//Register Definitions
`define E_REG_MBSTATUS      20'hf0360 //mailbox status
`define E_REG_MBOX0         20'hf0364 //mailbox entry0 (read/write)
`define E_REG_MBOX1         20'hf0368 //mailbox entry1 (read/write)

module embox (/*AUTOARG*/
   // Outputs
   mi_data_out, mi_data_sel, embox_full, embox_not_empty,
   // Inputs
   reset, clk, mi_access, mi_write, mi_addr, mi_data_in
   );

   parameter DW  = 32; //data width of 
   parameter RFW = 6;  //address bus width
   parameter FAW = 4;  //fifo entries==2^FAW

   /*****************************/
   /*SIMPLE MEMORY INTERFACE    */
   /*****************************/
   input              reset;       //synchronous  reset
   input              clk;   
   input              mi_access;
   input              mi_write;
   input  [19:0]      mi_addr;
   input  [DW-1:0]    mi_data_in;
   output [DW-1:0]    mi_data_out;
   output 	      mi_data_sel;

   /*****************************/
   /*MAILBOX OUTPUTS            */
   /*****************************/
   output 	      embox_full;
   output 	      embox_not_empty;   

   /*****************************/
   /*REGISTERS                  */
   /*****************************/
   reg [DW-1:0]       mi_data_out;
   reg [DW-1:0]       embox_data_reg;
   reg 		      mi_data_sel;
   /*****************************/
   /*WIRES                      */
   /*****************************/
   wire               embox_w0_access;
   wire               embox_w1_access;
   wire               embox_status_access;
   wire 	      embox_write;
   wire 	      embox_w0_write;
   wire 	      embox_w1_write;
   wire 	      embox_read;
   wire 	      embox_w0_read;
   wire 	      embox_w1_read;
   wire 	      embox_status_read;
   wire [DW-1:0]      embox_read_data;
   wire [2*DW-1:0]    embox_fifo_data;
   
   /*****************************/
   /*DECODE LOGIC               */
   /*****************************/
   
   //access decode
   assign embox_w0_access     = (mi_addr[19:0]==`E_REG_MBOX0); //lower 32 bit word
   assign embox_w1_access     = (mi_addr[19:0]==`E_REG_MBOX1); //upper 32 bit word
   assign embox_status_access = (mi_addr[19:0]==`E_REG_MBSTATUS);//polling fifo status

   assign embox_match         = embox_w0_access |
				embox_w1_access |
				embox_status_access;
   
   //write logic
   assign  embox_write       = mi_access &  mi_write;
   assign  embox_w0_write    = embox_w0_access & embox_write;
   assign  embox_w1_write    = embox_w1_access & embox_write; //causes FIFO write

   //read logic
   assign embox_read         = mi_access & ~mi_write;
   assign embox_w0_read      = embox_w0_access     & embox_read;
   assign embox_w1_read      = embox_w1_access     & embox_read;//causes FIFO read
   assign embox_status_read  = embox_status_access & embox_read;
			      
   /*****************************/
   /*WRITE ACTION               */
   /*****************************/
   //hold lower data word until upper word arrives

   always @ (posedge clk)
     if(embox_w0_write)
       embox_data_reg[DW-1:0] <=mi_data_in[DW-1:0];
   
   /*****************************/
   /*READ BACK DATA             */
   /*****************************/
   assign embox_not_empty         = ~embox_empty;

   assign embox_read_data[DW-1:0] = embox_status_read ? {{(DW-2){1'b0}},embox_full,embox_not_empty}  :
				    embox_w0_read     ? embox_fifo_data[DW-1:0]                             :
	                    	  	                embox_fifo_data[2*DW-1:DW];   
   always @ (posedge clk)
     if(embox_read)
       begin
	  mi_data_out[DW-1:0] <= embox_read_data[DW-1:0];
	  mi_data_sel         <= embox_match;
       end
   
   /*****************************/
   /*FIFO                       */
   /*****************************/
   fifo #(.DW(2*DW), .AW(FAW)) mbox_fifo(
                                       // Outputs
                                       .rd_data         (embox_fifo_data[2*DW-1:0]),
                                       .rd_fifo_empty   (embox_empty),
                                       .wr_fifo_full    (embox_full),
                                       // Inputs
                                       .reset           (reset),
                                       .wr_clk          (clk),
                                       .rd_clk          (clk), 
                                       .wr_write        (embox_w1_write), 
                                       .wr_data         ({mi_data_in[DW-1:0],embox_data_reg[DW-1:0]}), 
                                       .rd_read         (embox_w1_read)
				       ); 
endmodule // embox



