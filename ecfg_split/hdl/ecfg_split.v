
/*
  Copyright (C) 2014 Adapteva, Inc.
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

//########################################################################
//  EPIPHANY CONFIGURATION BUS SPLITTER
//########################################################################
 
/*
  NOTE:  This module is (hopefully) temporary, until Vivado gains the
 ability (or I learn how) to have a custom interface with multiple 
 slaves.  This issue has been raised with Xilinx.
 */

module ecfg_split(/*AUTOARG*/
   // Outputs
   slvcfg_datain, mcfg0_sw_reset, mcfg0_tx_enable, mcfg0_tx_mmu_mode,
   mcfg0_tx_gpio_mode, mcfg0_tx_ctrl_mode, mcfg0_tx_clkdiv,
   mcfg0_rx_enable, mcfg0_rx_mmu_mode, mcfg0_rx_gpio_mode,
   mcfg0_rx_loopback_mode, mcfg0_coreid, mcfg0_dataout,
   mcfg1_sw_reset, mcfg1_tx_enable, mcfg1_tx_mmu_mode,
   mcfg1_tx_gpio_mode, mcfg1_tx_ctrl_mode, mcfg1_tx_clkdiv,
   mcfg1_rx_enable, mcfg1_rx_mmu_mode, mcfg1_rx_gpio_mode,
   mcfg1_rx_loopback_mode, mcfg1_coreid, mcfg1_dataout,
   mcfg2_sw_reset, mcfg2_tx_enable, mcfg2_tx_mmu_mode,
   mcfg2_tx_gpio_mode, mcfg2_tx_ctrl_mode, mcfg2_tx_clkdiv,
   mcfg2_rx_enable, mcfg2_rx_mmu_mode, mcfg2_rx_gpio_mode,
   mcfg2_rx_loopback_mode, mcfg2_coreid, mcfg2_dataout,
   mcfg3_sw_reset, mcfg3_tx_enable, mcfg3_tx_mmu_mode,
   mcfg3_tx_gpio_mode, mcfg3_tx_ctrl_mode, mcfg3_tx_clkdiv,
   mcfg3_rx_enable, mcfg3_rx_mmu_mode, mcfg3_rx_gpio_mode,
   mcfg3_rx_loopback_mode, mcfg3_coreid, mcfg3_dataout,
   mcfg4_sw_reset, mcfg4_tx_enable, mcfg4_tx_mmu_mode,
   mcfg4_tx_gpio_mode, mcfg4_tx_ctrl_mode, mcfg4_tx_clkdiv,
   mcfg4_rx_enable, mcfg4_rx_mmu_mode, mcfg4_rx_gpio_mode,
   mcfg4_rx_loopback_mode, mcfg4_coreid, mcfg4_dataout,
   // Inputs
   slvcfg_sw_reset, slvcfg_tx_enable, slvcfg_tx_mmu_mode,
   slvcfg_tx_gpio_mode, slvcfg_tx_ctrl_mode, slvcfg_tx_clkdiv,
   slvcfg_rx_enable, slvcfg_rx_mmu_mode, slvcfg_rx_gpio_mode,
   slvcfg_rx_loopback_mode, slvcfg_coreid, slvcfg_dataout,
   mcfg0_datain, mcfg1_datain, mcfg2_datain, mcfg3_datain,
   mcfg4_datain
   );


   /*****************************/
   /* Slave (input) Port        */
   /*****************************/
   //RESET
   input         slvcfg_sw_reset;

   //tx
   input         slvcfg_tx_enable;         //enable signal for TX  
   input         slvcfg_tx_mmu_mode;       //enables MMU on transnmit path  
   input         slvcfg_tx_gpio_mode;      //forces TX input pins to constants
   input [3:0]   slvcfg_tx_ctrl_mode;      //value for emesh ctrlmode tag
   input [3:0]   slvcfg_tx_clkdiv;         //transmit clock divider
   
   //rx
   input         slvcfg_rx_enable;         //enable signal for rx  
   input         slvcfg_rx_mmu_mode;       //enables MMU on rx path  
   input         slvcfg_rx_gpio_mode;      //forces rx wait pins to constants
   input         slvcfg_rx_loopback_mode;  //loops back tx to rx receiver (after serdes)

   //coreid
   input [11:0]  slvcfg_coreid;            //core-id of fpga elink

   //gpio
   output [10:0] slvcfg_datain;          // data from elink inputs
   input [10:0]  slvcfg_dataout;           //data for elink outputs {rd_wait,wr_wait,frame,data[7:0]}
   
   /*************************************************/
   /* Master (output) Port #0                       */
   /*  NOTE: This is the only port that takes input */
   /*************************************************/
   //RESET
   output        mcfg0_sw_reset;

   //tx
   output        mcfg0_tx_enable;
   output        mcfg0_tx_mmu_mode;
   output        mcfg0_tx_gpio_mode;
   output [3:0]  mcfg0_tx_ctrl_mode;
   output [3:0]  mcfg0_tx_clkdiv;
   
   //rx
   output        mcfg0_rx_enable;
   output        mcfg0_rx_mmu_mode;
   output        mcfg0_rx_gpio_mode;
   output        mcfg0_rx_loopback_mode;

   //coreid
   output [11:0] mcfg0_coreid;

   //gpio
   input [10:0]  mcfg0_datain;
   output [10:0] mcfg0_dataout;

   /*****************************/
   /* Master (output) Port #1   */
   /*****************************/
   //RESET
   output        mcfg1_sw_reset;

   //tx
   output        mcfg1_tx_enable;
   output        mcfg1_tx_mmu_mode;
   output        mcfg1_tx_gpio_mode;
   output [3:0]  mcfg1_tx_ctrl_mode;
   output [3:0]  mcfg1_tx_clkdiv;
   
   //rx
   output        mcfg1_rx_enable;
   output        mcfg1_rx_mmu_mode;
   output        mcfg1_rx_gpio_mode;
   output        mcfg1_rx_loopback_mode;

   //coreid
   output [11:0] mcfg1_coreid;

   //gpio
   input [10:0]  mcfg1_datain;
   output [10:0] mcfg1_dataout;

   /*****************************/
   /* Master (output) Port #2   */
   /*****************************/
   //RESET
   output        mcfg2_sw_reset;

   //tx
   output        mcfg2_tx_enable;
   output        mcfg2_tx_mmu_mode;
   output        mcfg2_tx_gpio_mode;
   output [3:0]  mcfg2_tx_ctrl_mode;
   output [3:0]  mcfg2_tx_clkdiv;
   
   //rx
   output        mcfg2_rx_enable;
   output        mcfg2_rx_mmu_mode;
   output        mcfg2_rx_gpio_mode;
   output        mcfg2_rx_loopback_mode;

   //coreid
   output [11:0] mcfg2_coreid;

   //gpio
   input [10:0]  mcfg2_datain;
   output [10:0] mcfg2_dataout;

   /*****************************/
   /* Master (output) Port #3   */
   /*****************************/
   //RESET
   output        mcfg3_sw_reset;

   //tx
   output        mcfg3_tx_enable;
   output        mcfg3_tx_mmu_mode;
   output        mcfg3_tx_gpio_mode;
   output [3:0]  mcfg3_tx_ctrl_mode;
   output [3:0]  mcfg3_tx_clkdiv;
   
   //rx
   output        mcfg3_rx_enable;
   output        mcfg3_rx_mmu_mode;
   output        mcfg3_rx_gpio_mode;
   output        mcfg3_rx_loopback_mode;

   //coreid
   output [11:0] mcfg3_coreid;

   //gpio
   input [10:0]  mcfg3_datain;
   output [10:0] mcfg3_dataout;

   /*****************************/
   /* Master (output) Port #4   */
   /*****************************/
   //RESET
   output        mcfg4_sw_reset;

   //tx
   output        mcfg4_tx_enable;
   output        mcfg4_tx_mmu_mode;
   output        mcfg4_tx_gpio_mode;
   output [3:0]  mcfg4_tx_ctrl_mode;
   output [3:0]  mcfg4_tx_clkdiv;
   
   //rx
   output        mcfg4_rx_enable;
   output        mcfg4_rx_mmu_mode;
   output        mcfg4_rx_gpio_mode;
   output        mcfg4_rx_loopback_mode;

   //coreid
   output [11:0] mcfg4_coreid;

   //gpio
   input [10:0]  mcfg4_datain;
   output [10:0] mcfg4_dataout;

   /*******************************/
   /* Copy port0 input to master  */
   /*******************************/

   assign slvcfg_datain = mcfg0_datain;
   
   /*******************************/
   /* Split inputs to all outputs */
   /*******************************/

   assign mcfg0_sw_reset = slvcfg_sw_reset;
   assign mcfg0_tx_enable = slvcfg_tx_enable;
   assign mcfg0_tx_mmu_mode = slvcfg_tx_mmu_mode;
   assign mcfg0_tx_gpio_mode = slvcfg_tx_gpio_mode;
   assign mcfg0_tx_ctrl_mode = slvcfg_tx_ctrl_mode;
   assign mcfg0_tx_clkdiv = slvcfg_tx_clkdiv;
   assign mcfg0_rx_enable = slvcfg_rx_enable;
   assign mcfg0_rx_mmu_mode = slvcfg_rx_mmu_mode;
   assign mcfg0_rx_gpio_mode = slvcfg_rx_gpio_mode;
   assign mcfg0_rx_loopback_mode = slvcfg_rx_loopback_mode;
   assign mcfg0_coreid = slvcfg_coreid;
   assign mcfg0_dataout = slvcfg_dataout;
   
   assign mcfg1_sw_reset = slvcfg_sw_reset;
   assign mcfg1_tx_enable = slvcfg_tx_enable;
   assign mcfg1_tx_mmu_mode = slvcfg_tx_mmu_mode;
   assign mcfg1_tx_gpio_mode = slvcfg_tx_gpio_mode;
   assign mcfg1_tx_ctrl_mode = slvcfg_tx_ctrl_mode;
   assign mcfg1_tx_clkdiv = slvcfg_tx_clkdiv;
   assign mcfg1_rx_enable = slvcfg_rx_enable;
   assign mcfg1_rx_mmu_mode = slvcfg_rx_mmu_mode;
   assign mcfg1_rx_gpio_mode = slvcfg_rx_gpio_mode;
   assign mcfg1_rx_loopback_mode = slvcfg_rx_loopback_mode;
   assign mcfg1_coreid = slvcfg_coreid;
   assign mcfg1_dataout = slvcfg_dataout;
   
   assign mcfg2_sw_reset = slvcfg_sw_reset;
   assign mcfg2_tx_enable = slvcfg_tx_enable;
   assign mcfg2_tx_mmu_mode = slvcfg_tx_mmu_mode;
   assign mcfg2_tx_gpio_mode = slvcfg_tx_gpio_mode;
   assign mcfg2_tx_ctrl_mode = slvcfg_tx_ctrl_mode;
   assign mcfg2_tx_clkdiv = slvcfg_tx_clkdiv;
   assign mcfg2_rx_enable = slvcfg_rx_enable;
   assign mcfg2_rx_mmu_mode = slvcfg_rx_mmu_mode;
   assign mcfg2_rx_gpio_mode = slvcfg_rx_gpio_mode;
   assign mcfg2_rx_loopback_mode = slvcfg_rx_loopback_mode;
   assign mcfg2_coreid = slvcfg_coreid;
   assign mcfg2_dataout = slvcfg_dataout;
   
   assign mcfg3_sw_reset = slvcfg_sw_reset;
   assign mcfg3_tx_enable = slvcfg_tx_enable;
   assign mcfg3_tx_mmu_mode = slvcfg_tx_mmu_mode;
   assign mcfg3_tx_gpio_mode = slvcfg_tx_gpio_mode;
   assign mcfg3_tx_ctrl_mode = slvcfg_tx_ctrl_mode;
   assign mcfg3_tx_clkdiv = slvcfg_tx_clkdiv;
   assign mcfg3_rx_enable = slvcfg_rx_enable;
   assign mcfg3_rx_mmu_mode = slvcfg_rx_mmu_mode;
   assign mcfg3_rx_gpio_mode = slvcfg_rx_gpio_mode;
   assign mcfg3_rx_loopback_mode = slvcfg_rx_loopback_mode;
   assign mcfg3_coreid = slvcfg_coreid;
   assign mcfg3_dataout = slvcfg_dataout;
   
   assign mcfg4_sw_reset = slvcfg_sw_reset;
   assign mcfg4_tx_enable = slvcfg_tx_enable;
   assign mcfg4_tx_mmu_mode = slvcfg_tx_mmu_mode;
   assign mcfg4_tx_gpio_mode = slvcfg_tx_gpio_mode;
   assign mcfg4_tx_ctrl_mode = slvcfg_tx_ctrl_mode;
   assign mcfg4_tx_clkdiv = slvcfg_tx_clkdiv;
   assign mcfg4_rx_enable = slvcfg_rx_enable;
   assign mcfg4_rx_mmu_mode = slvcfg_rx_mmu_mode;
   assign mcfg4_rx_gpio_mode = slvcfg_rx_gpio_mode;
   assign mcfg4_rx_loopback_mode = slvcfg_rx_loopback_mode;
   assign mcfg4_coreid = slvcfg_coreid;
   assign mcfg4_dataout = slvcfg_dataout;
   
endmodule // ecfg_split
