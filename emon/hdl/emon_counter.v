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
 A SIMPLE COUNTER
 ########################################################################
 */

module emon_counter (/*AUTOARG*/
   // Outputs
   emon_reg, emon_zero_flag,
   // Inputs
   clk, reset, emon_vector, emon_sel, reg_write, reg_data
   );

   /**************************************************************************/
   /*PARAMETERS                                                              */
   /**************************************************************************/
   parameter RFAW = 6;   
   parameter DW   = 32;   
      
   /**************************************************************************/
   /*BASIC INTERFACE                                                         */
   /**************************************************************************/
   input             clk;
   input             reset;
   /**************************************************************************/
   /*CONFIGURATION                                                           */
   /**************************************************************************/
   input [15:0]      emon_vector; //different events to count
   input [3:0]       emon_sel;    //mode selector
   /**************************************************************************/
   /*REGISTER WRITE INTERFACE                                                */
   /**************************************************************************/
   input	     reg_write;
   input  [DW-1:0]   reg_data;
       
   /*********************************************************************** */
   /*MONITOR OUTPUTS                                                        */
   /*************************************************************************/ 
   output [DW-1:0]   emon_reg;      //register value
   output            emon_zero_flag;//monitor is zero
   
   /*************************************************************************/
   /*REGISTERS                                                              */
   /*************************************************************************/    
   reg [DW-1:0]      emon_reg;
   reg 		     emon_input; 
     
   /*************************************************************************/
   /*INPUT MUX                                                              */
   /*************************************************************************/
   always @(posedge clk)
     emon_input <= emon_vector[emon_sel[3:0]];

   /*************************************************************************/
   /*COUNTER                                                                */
   /*************************************************************************/
   always @(posedge clk)
     if(reset)
       emon_reg[DW-1:0]   <= {(DW){1'b1}};    //initialize with max value
     else if(reg_write) 
       emon_reg[DW-1:0]   <= reg_data[DW-1:0];//writeable interface
     else
       emon_reg[DW-1:0]   <= emon_reg[DW-1:0] - {31'b0,emon_input};
      
   /************************************************************************ */
   /*OUTPUTS                                                                 */
   /**************************************************************************/

   //Detecting zero on counter
   assign emon_zero_flag   = ~(|emon_reg[DW-1:0]);

      
endmodule // ctimer


     



			