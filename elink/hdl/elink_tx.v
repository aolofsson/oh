/*
  Copyright (C) 2014 Adapteva, Inc.
 
  Contributed by Andreas Olofsson <andreas@adapteva.com>
  Contributed by Fred Huettig <fred@adapteva.com>

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

module elink_tx(/*AUTOARG*/
   // Outputs
   txo_lclk_p, txo_lclk_n, txo_frame_p, txo_frame_n, txo_data_p,
   txo_data_n, etx_rdfifo_access, etx_rdfifo_wait, etx_wrfifo_access,
   etx_wrfifo_wait, etx_wbfifo_access, etx_wbfifo_wait,
   // Inputs
   reset, clk, ecfg_coreid, txi_wr_wait_p, txi_wr_wait_n,
   txi_rd_wait_p, txi_rd_wait_n, ecfg_tx_enable, ecfg_tx_mmu_mode,
   ecfg_tx_gpio_mode, ecfg_tx_ctrl_mode, ecfg_tx_clkdiv,
   ecfg_tx_dataout
   );

   //Global signals
   input        reset;           //reset (hw+sw reset)
   input        clk;             //clock input for what?
   input [11:0] ecfg_coreid;     //coordinate, used for srcaddr for example
   
   //IO side interface
   output       txo_lclk_p;       //high speed clock (up to 500MHz)
   output       txo_lclk_n;
   output       txo_frame_p;      //frame signal to indicate start/stop
   output       txo_frame_n;
   output [7:0] txo_data_p;       //transmit data (dual data rate)
   output [7:0] txo_data_n;          
   input 	txi_wr_wait_p;    //incoming pushback on write transactions
   input 	txi_wr_wait_n;    
   input 	txi_rd_wait_p;    //incoming pushback on read transactions
   input 	txi_rd_wait_n;    
   
   //control signals
   input        ecfg_tx_enable;     //enable signal for TX  
   input        ecfg_tx_mmu_mode;   //enables MMU on transnmit path  
   input        ecfg_tx_gpio_mode;  //forces TX outputs to constants
   input [3:0]  ecfg_tx_ctrl_mode;  //value for emesh ctrlmode tag
   input [3:0]  ecfg_tx_clkdiv;     //transmit clock divider
   input [8:0] 	ecfg_tx_dataout;    //data for data[7:0] and frame in GPIO mode 

   //Monitor output signals
   output	etx_rdfifo_access;  //read request from slave
   output	etx_rdfifo_wait;     
   output	etx_wrfifo_access;  //write request from slave
   output 	etx_wrfifo_wait;
   output	etx_wbfifo_access;  //writeback from master
   output	etx_wbfifo_wait;
     
endmodule // elink_tx



