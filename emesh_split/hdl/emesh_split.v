/*
  File: emesh_split.v
 
  This file is part of the Parallella Project.

  Copyright (C) 2014 Adapteva, Inc.
  Contributed by Fred Huettig <fred@adapteva.com>

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program (see the file COPYING).  If not, see
  <http://www.gnu.org/licenses/>.
*/

/*
 ########################################################################
 EPIPHANY eMesh Splitter
 ########################################################################
 
 This block takes one eMesh input (104-bit transactions) and
 copies it to two outputs.  The wait signals are taken only from the 
 first slave port.
 
 This block will hopefully be removed once I figure out how to get
 Vivado to allow multiple slaves on one interface!
 */

module emesh_split (/*AUTOARG*/
   // Outputs
   ems_rd_wait, ems_wr_wait, emm0_access, emm0_write, emm0_datamode,
   emm0_ctrlmode, emm0_dstaddr, emm0_srcaddr, emm0_data, emm1_access,
   emm1_write, emm1_datamode, emm1_ctrlmode, emm1_dstaddr,
   emm1_srcaddr, emm1_data,
   // Inputs
   ems_access, ems_write, ems_datamode, ems_ctrlmode, ems_dstaddr,
   ems_srcaddr, ems_data, emm0_rd_wait, emm0_wr_wait
   );

   // Slave port
   input         ems_access;
   input         ems_write;
   input [1:0]   ems_datamode;
   input [3:0]   ems_ctrlmode;
   input [31:0]  ems_dstaddr;
   input [31:0]  ems_srcaddr;
   input [31:0]  ems_data;
   output        ems_rd_wait;
   output        ems_wr_wait;

   // Master port #0 (with wait inputs)
   output        emm0_access;
   output        emm0_write;
   output [1:0]  emm0_datamode;
   output [3:0]  emm0_ctrlmode;
   output [31:0] emm0_dstaddr;
   output [31:0] emm0_srcaddr;
   output [31:0] emm0_data;
   input         emm0_rd_wait;
   input         emm0_wr_wait;
   
   // Master port #1 (NO wait inputs)
   output        emm1_access;
   output        emm1_write;
   output [1:0]  emm1_datamode;
   output [3:0]  emm1_ctrlmode;
   output [31:0] emm1_dstaddr;
   output [31:0] emm1_srcaddr;
   output [31:0] emm1_data;
   
   //############
   //# Duplicate all slave->master signals
   //############
   wire        emm0_access   = ems_access;    
   wire        emm0_write    = ems_write;    
   wire [1:0]  emm0_datamode = ems_datamode; 
   wire [3:0]  emm0_ctrlmode = ems_ctrlmode; 
   wire [31:0] emm0_dstaddr  = ems_dstaddr;  
   wire [31:0] emm0_srcaddr  = ems_srcaddr;  
   wire [31:0] emm0_data     = ems_data;
   
   // Master port #1 (NO wait inputs)
   wire        emm1_access   = ems_access;  
   wire        emm1_write    = ems_write;   
   wire [1:0]  emm1_datamode = ems_datamode;
   wire [3:0]  emm1_ctrlmode = ems_ctrlmode;
   wire [31:0] emm1_dstaddr  = ems_dstaddr; 
   wire [31:0] emm1_srcaddr  = ems_srcaddr; 
   wire [31:0] emm1_data     = ems_data;    
      
   //#############################
   //# Wait signal passthroughs, port 0 only
   //#############################
   wire          ems_rd_wait = emm0_rd_wait;
   wire          ems_wr_wait = emm0_wr_wait;
   
endmodule // emesh_split


