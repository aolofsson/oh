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

module elink_rx(/*AUTOARG*/
   // Outputs
   rxo_wr_wait_p, rxo_wr_wait_n, rxo_rd_wait_p, rxo_rd_wait_n,
   erx_rdfifo_access, erx_rdfifo_wait, erx_wrfifo_access,
   erx_wrfifo_wait, erx_wbfifo_access, erx_wbfifo_wait,
   // Inputs
   reset, clk, ecfg_coreid, rxi_lclk_p, rxi_lclk_n, rxi_frame_p,
   rxi_frame_n, rxi_data_p, rxi_data_n, ecfg_rx_enable,
   ecfg_rx_gpio_mode, ecfg_rx_loopback_mode, ecfg_rx_mmu_mode,
   ecfg_rx_dataout
   );
   //Global signals
   input        reset;           //reset (hw+sw reset)
   input        clk;             //clock input for what?
   input [11:0] ecfg_coreid;     //coordinate, used for srcaddr for example
   
   //Receiver
   input        rxi_lclk_p;      //high speed clock (up to 500MHz)
   input        rxi_lclk_n;
   input        rxi_frame_p;     //frame signal to indicate start/stop
   input        rxi_frame_n;
   input [7:0]  rxi_data_p;      //receive data (dual data rate)
   input [7:0]  rxi_data_n;
   output       rxo_wr_wait_p;   //outgoing pushback on write transactions
   output       rxo_wr_wait_n;   //
   output       rxo_rd_wait_p;   //outgoing pushback on read transactions
   output       rxo_rd_wait_n;   //

   //Control signals
   input        ecfg_rx_enable;          //enable receiver 
   input        ecfg_rx_gpio_mode;       //forces rx wait pins to constants
   input        ecfg_rx_loopback_mode;   //loopback tx-->rx
   input        ecfg_rx_mmu_mode;        //enable the mmu block 
   input [1:0] 	ecfg_rx_dataout;         //data for wr_wait and rd_wait in GPIO mode
   
   //Monitor output signals
   output      erx_rdfifo_access;       //read request on axi master
   output      erx_rdfifo_wait;          
   output      erx_wrfifo_access;       //write on axi master
   output      erx_wrfifo_wait;
   output      erx_wbfifo_access;       //writeback to axi slave
   output      erx_wbfifo_wait;         
   
   
endmodule // elink_transmit

