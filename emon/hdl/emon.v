/*
  Copyright (C) 2013 Adapteva, Inc.
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
/*
 ########################################################################
 EPIPHANY ELINK TRAFFIC MONITOR
 ########################################################################
 */
`define E_REG_SYSMONCFG   20'hf036c
`define E_REG_SYSRXMON0   20'hf0370
`define E_REG_SYSRXMON1   20'hf0374
`define E_REG_SYSRXMON2   20'hf0378
`define E_REG_SYSTXMON0   20'hf037c
`define E_REG_SYSTXMON1   20'hf0380
`define E_REG_SYSTXMON2   20'hf0384

module emon (/*AUTOARG*/
   // Outputs
   mi_data_out, emon_zero_flag,
   // Inputs
   clk, reset, mi_access, mi_write, mi_addr, mi_data_in,
   erx_rdfifo_access, erx_rdfifo_wait, erx_wrfifo_access,
   erx_wrfifo_wait, erx_wbfifo_access, erx_wbfifo_wait,
   etx_rdfifo_access, etx_rdfifo_wait, etx_wrfifo_access,
   etx_wrfifo_wait, etx_wbfifo_access, etx_wbfifo_wait
   );

   parameter DW   = 32;//datawidth
   parameter MONS = 6; //monitors   
   /*****************************/
   /*SIMPLE MEMORY INTERFACE    */
   /*****************************/
   input               clk;   
   input               reset;
   input               mi_access;
   input               mi_write;
   input  [19:0]       mi_addr;
   input  [DW-1:0]     mi_data_in;
   output [DW-1:0]     mi_data_out;

   /*****************************/
   /*ELINK DATAPATH INPUTS      */
   /*****************************/   

   //Receive path
   input 	     erx_rdfifo_access;
   input 	     erx_rdfifo_wait;
   input 	     erx_wrfifo_access;
   input 	     erx_wrfifo_wait;
   input 	     erx_wbfifo_access;
   input 	     erx_wbfifo_wait;   
   //Transmit path
   input 	     etx_rdfifo_access;
   input 	     etx_rdfifo_wait;
   input 	     etx_wrfifo_access;
   input 	     etx_wrfifo_wait;
   input 	     etx_wbfifo_access;
   input 	     etx_wbfifo_wait;

   /*****************************/
   /*ZERO FLAG                  */
   /*****************************/   
   output [5:0]      emon_zero_flag;
   
   //wires
   wire 	     emon_read;
   wire [5:0]        emon_access;
   wire [5:0] 	     emon_write;
   wire 	     emon_cfg_match;
   wire 	     emon_cfg_write;

   reg [DW-1:0]      emon_reg_mux;
   wire [15:0] 	     emon_vector;
   
   //regs
   wire[DW-1:0]      emon_reg[5:0];
   reg [DW-1:0]      mi_data_out;
   reg [DW-1:0]      emon_cfg_reg;
   
   /*****************************/
   /*ADDRESS DECODE LOGIC       */
   /*****************************/
   //read   
   assign emon_read         = mi_access & ~mi_write;   

   //access signals   
   assign emon_cfg_match    = mi_addr[19:0]==`E_REG_SYSMONCFG;
   assign emon_access[0]    = mi_addr[19:0]==`E_REG_SYSRXMON0;
   assign emon_access[1]    = mi_addr[19:0]==`E_REG_SYSRXMON1;
   assign emon_access[2]    = mi_addr[19:0]==`E_REG_SYSRXMON2;
   assign emon_access[3]    = mi_addr[19:0]==`E_REG_SYSTXMON0;
   assign emon_access[4]    = mi_addr[19:0]==`E_REG_SYSTXMON1;
   assign emon_access[5]    = mi_addr[19:0]==`E_REG_SYSTXMON2;
   
   //write signals
   assign emon_write[0]     =  emon_access[0]  & mi_write & mi_access;   
   assign emon_write[1]     =  emon_access[1]  & mi_write & mi_access;   
   assign emon_write[2]     =  emon_access[2]  & mi_write & mi_access;   
   assign emon_write[3]     =  emon_access[3]  & mi_write & mi_access;   
   assign emon_write[4]     =  emon_access[4]  & mi_write & mi_access;   
   assign emon_write[5]     =  emon_access[5]  & mi_write & mi_access;   
   assign emon_cfg_write    =  emon_cfg_match  & mi_write & mi_access;   
   
   /*****************************/
   /*CONFIG REGISTER            */
   /*****************************/
   //6 monitor circuits
   //4 bits configuration per monitor
   always @ (posedge clk)
     if(reset)
       emon_cfg_reg[DW-1:0]<={(DW){1'b0}};   
     else if(emon_cfg_write)
       emon_cfg_reg[DW-1:0] <= mi_data_in[DW-1:0];
   /*****************************/
   /*MONITOR VECTOR             */
   /*****************************/
   assign emon_vector[15:0] = {1'b0,
			       1'b0,
			       etx_wbfifo_wait,
			       etx_wbfifo_access,
			       etx_wrfifo_wait,
			       etx_wrfifo_access,
			       etx_rdfifo_wait,
			       etx_rdfifo_access,
			       erx_wbfifo_wait,
			       erx_wbfifo_access,
			       erx_wrfifo_wait,
			       erx_wrfifo_access,
			       erx_rdfifo_wait,
			       erx_rdfifo_access,
			       1'b1,
			       1'b0};


   /*****************************/
   /*COUNTERS                   */
   /*****************************/
   genvar 	     i;
   generate
      for (i=0;i<MONS;i=i+1) begin : gen_mon
	 emon_counter emon_counter(//outputs
				   .emon_reg		(emon_reg[i]),
				   .emon_zero_flag	(emon_zero_flag[i]),
				   // Inputs
				   .clk		        (clk),
				   .reset		(reset),
				   .emon_vector	        (emon_vector[15:0]),
				   .emon_sel		(emon_cfg_reg[4*i+3:4*i]),
				   .reg_write		(emon_write[i]),
				   .reg_data		(mi_data_in[DW-1:0]));
      end      
   endgenerate		   
				  
   
   /*****************************/
   /*READBACK MUX               */
   /*****************************/
   integer j;
   always @*
     begin
	emon_reg_mux[DW-1:0]  = {(DW){1'b0}};
	for(j=0;j<MONS;j=j+1)
	  emon_reg_mux[DW-1:0] = emon_reg_mux[DW-1:0] | ({(DW){emon_access[j]}} & emon_reg[j]);
     end
   
   //Pipelineing readback
   always @ (posedge clk)
     if(emon_read)
       mi_data_out[DW-1:0] <= emon_reg_mux[DW-1:0];			  


endmodule // emon


