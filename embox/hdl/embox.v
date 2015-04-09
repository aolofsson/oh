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
 #           EMBOX0    = lower 32 bits of FIFO entry
 #           EMBOX1    = upper 32 bits of FIFO entry
 #           EMBSTATUS = status of FIFO [0]=1-->fifo not empty
 #                                      [1]=1-->fifo full      
 #
 # Notes:    System takes care of not overflowing the FIFO
 #           Reading the REG_EMBOX1 causes rd pointer to update to next entry
 #           EMBOX0/EMBOX1 must be consecutive addresses for write.
 #
 ############################################################################
 */

//Register Definitions
`define EMBSTATUS      10'h019 //mailbox status
`define EMBOX0         10'h01A //mailbox entry0 (read/write)
`define EMBOX1         10'h01B //mailbox entry1 (read/write)

module embox (/*AUTOARG*/
   // Outputs
   mi_dout, embox_full, embox_not_empty,
   // Inputs
   reset, clk, mi_en, mi_we, mi_addr, mi_din
   );

   parameter DW   = 32;  //data width of fifo
   parameter RFAW = 13;  //address bus width
   parameter FAW  = 4;   //fifo entries==2^FAW

   /*****************************/
   /*CLOCK AND RESET            */
   /*****************************/
   input              reset;       //synchronous  reset
   input 	      clk;

   /*****************************/
   /*SIMPLE MEMORY INTERFACE    */
   /*****************************/
   input 	      mi_en;
   input [3:0]	      mi_we;      
   input [RFAW-1:0]   mi_addr;
   input [DW-1:0]     mi_din;
   output [DW-1:0]    mi_dout;   
   
   /*****************************/
   /*MAILBOX OUTPUTS            */
   /*****************************/
   output 	      embox_full;
   output 	      embox_not_empty;   

   /*****************************/
   /*REGISTERS                  */
   /*****************************/
   reg [DW-1:0]       mi_dout;
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
   wire               embox_empty;
   
   /*****************************/
   /*DECODE LOGIC               */
   /*****************************/
   
   //access decode
   assign embox_w0_access     = (mi_addr[RFAW-1:2]==`EMBOX0); //lower 32 bit word
   assign embox_w1_access     = (mi_addr[RFAW-1:2]==`EMBOX1); //upper 32 bit word

   //fifo read/write logic
   assign  embox_write       = mi_en &  mi_we[0];
   assign  embox_w0_write    = embox_w0_access & embox_write;
   assign  embox_w1_write    = embox_w1_access & embox_write;      //causes FIFO write

   //read logic
   assign embox_read         = mi_en & ~mi_we[0];
   assign embox_w1_read      = embox_w1_access & embox_read;       //causes FIFO read		      

   /*****************************/
   /*WRITE ACTION               */
   /*****************************/
   //hold lower data word until upper word arrives

   always @ (posedge clk)
     if(embox_w0_write)
       embox_data_reg[DW-1:0] <=mi_din[DW-1:0];
   
   /*****************************/
   /*READ BACK DATA             */
   /*****************************/

   always @ (posedge clk)
     if(embox_read)
       case(mi_addr[RFAW-1:2])	 
	 `EMBOX0:    mi_dout[DW-1:0] <= embox_fifo_data[DW-1:0];	 
	 `EMBOX1:    mi_dout[DW-1:0] <= embox_fifo_data[2*DW-1:DW];	 
	 `EMBSTATUS: mi_dout[DW-1:0] <= {{(DW-2){1'b0}},embox_full,embox_not_empty};
	 default:         mi_dout[DW-1:0] <= 32'd0;
       endcase // case (mi_addr[RFAW-1:2])
   
   
   /*****************************/
   /*FIFO (64-BIT)              */
   /*****************************/
   assign embox_not_empty         = ~embox_empty;

   fifo_sync #(.DW(64)) mbox(// Outputs
			     .rd_data  (embox_fifo_data[2*DW-1:0]),
			     .rd_empty (embox_empty),
			     .wr_full  (embox_full),
			     // Inputs
			     .rd_en    (embox_w1_read), 
			     .wr_data  ({mi_din[DW-1:0],embox_data_reg[DW-1:0]}),
			     .wr_en    (embox_w1_write),
			     .clk      (clk),  
			     .reset    (reset)      
			     ); 
   
endmodule // embox



