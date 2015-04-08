/*
 Copyright (C) 2015 Adapteva, Inc.
 Contributed by Andreas Olofsson <andreas@adapteva.com>
 
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
 Generic asynchronous FIFO
 
 Caution:  There is no protection against overflow or underflow,
           driving logic should avoid wen on full or ren on empty.
 ########################################################################
 */

module fifo_async(/*AUTOARG*/
   // Outputs
   wr_full, wr_progfull, rd_data, rd_empty,
   // Inputs
   reset, wr_clk, wr_en, wr_data, rd_clk, rd_en
   );

   parameter AW = 5;   //fifo address width   
   parameter DW = 16;  //fifo data width
   
   //Reset
   input 	   reset;

   //Write side interface
   input 	   wr_clk;      //write side clock
   input 	   wr_en;       //write enable
   input [DW-1:0]  wr_data;     //write data
   output 	   wr_full;     //fifo full
   output 	   wr_progfull; //programmable full level
   
   //Read side interface
   input 	   rd_clk;      //read side clock
   input 	   rd_en;       //read enable
   output [DW-1:0] rd_data;     //read data
   output 	   rd_empty;    //fifo empty
   

   //Dummy for now...
   assign rd_data     = 103'b0;
   assign rd_empty    = 1'b0;
   assign wr_full     = 1'b0;
   assign wr_progfull = 1'b0;

   //TODO:instatiate the right fifo
   //distributed RAM
   //32 x 103
   //async reset signal, assert high, full asserted on 16
   
   
endmodule // fifo_async




