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
 EPIPHANY CONFIGURATION REGISTER
 ########################################################################
-------------------------------------------------------------
 ESYSRESET        ***Elink reset***
 [0]              0  - elink active 
                  1  - elink in reset
-------------------------------------------------------------
 ESYSCFGTX        ***Elink transmitter configuration***
 [0]              0  - link TX disable
                  1  - link TX enable
 [1]              0  - normal pass through transaction mode
                  1  - mmu mode
 [3:2]            00 - normal mode
                  01 - drive mode
                  10 - reserved
                  11 - reserved
 [7:4]            Transmit control mode for eMesh
 [11:8]           0000 - No division, full speed
                  0001 - Divide by 2
                  Others - Reserved
  -------------------------------------------------------------
 ESYSCFGRX       ***Elink receiver configuration***
 [0]              0  - link RX disable
                  1  - link RX enable
 [1]              0  - normal transaction mode
                  1  - mmu mode
 [3:2]            00 - normal mode
                  01 - sample mode (drive rd wait pins from registers)
                  10 - loopback mode (loops TX-->RX)
                  11 - reserved
 [4]              0  - set monitor to count traffic
                  1  - set monitor to count congestion    
  -------------------------------------------------------------
 ESYSCFGCLK       ***Epiphany clock frequency setting*** 
 [3:0]            Output divider
                  0000 - Clock turned off
                  0001 - CLKIN/64
                  0010 - CLKIN/32
                  0011 - CLKIN/16
                  0100 - CLKIN/8
                  0101 - CLKIN/4
                  0110 - CLKIN/2
                  0111 - CLKIN/1 (full speed)
                  1XXX - RESERVED
 [7:4]            PLL settings (TBD)
 -------------------------------------------------------------
 ESYSCOREID     ***CORE ID***
 [5:0]           Column ID-->default at powerup/reset             
 [11:6]          Row ID  
 -------------------------------------------------------------
 ESYSVERSION    ***Version number (read only)***
 [7:0]           Revision #, incremented in each change (match git?)
 [15:8]          Type (features included in FPGA load, same board)
 [23:16]         Board platform #
 [31:24]         Generation # (needed??)
 -------------------------------------------------------------
 ESYSDATAIN     ***Data on elink input pins
 [7:0]          rx_data[7:0]         
 [8]            tx_frame
 [9]            tx_wait_rd
 [10]           tx_wait_wr
 -------------------------------------------------------------
 ESYSDATAOUT    ***Data on eLink output pins
 [7:0]          tx_data[7:0]         
 [8]            tx_frame
 [9]            rx_wait_rd
 [10]           rx_wait_wr
 -------------------------------------------------------------
 ESYSDEBUG      ***Various debug signals from elink
 [31:0]          (design specific, generic inferface for now)
                 included: 
                 -all wait signals, (4)
                 -fifo fulls, 
                 -fifo emptys
                 -axi access, ready signals for master/slave
                 -frame signals (in and out) 
 -------------------------------------------------------------
 ########################################################################
 */

// These are WORD addresses (bits 11:2)
`define ESYSRESET    10'h010
`define ESYSCFGTX    10'h011
`define ESYSCFGRX    10'h012
`define ESYSCFGCLK   10'h013
`define ESYSCOREID   10'h014
`define ESYSVERSION  10'h015
`define ESYSDATAIN   10'h016
`define ESYSDATAOUT  10'h017
`define ESYSDEBUG    10'h018

module ecfg (/*AUTOARG*/
   // Outputs
   mi_dout, ecfg_reset, ecfg_resetb, ecfg_tx_enable, ecfg_tx_mmu_mode,
   ecfg_tx_gpio_mode, ecfg_tx_ctrl_mode, ecfg_tx_clkdiv,
   ecfg_rx_enable, ecfg_rx_mmu_mode, ecfg_rx_gpio_mode, ecfg_cclk_en,
   ecfg_cclk_div, ecfg_cclk_pllcfg, ecfg_coreid, ecfg_dataout,
   // Inputs
   hw_reset, mi_clk, mi_en, mi_we, mi_addr, mi_din, ecfg_datain,
   ecfg_debug
   );

   /******************************/
   /*Compile Time Parameters     */
   /******************************/
   parameter EVERSION        = 32'h00_00_00_00;  // FPGA gen:plat:type:rev
   parameter IDW             = 12;               // Elink ID (row,column coordinate)
   parameter RFAW            = 13;               // Register file address width
   parameter DEFAULT_COREID  = 12'h808;          // Reset value for ecfg_coreid

   /******************************/
   /*HARDWARE RESET (POR/BUTTON) */
   /******************************/
   input 	     hw_reset;

   /*****************************/
   /*SIMPLE MEMORY INTERFACE    */
   /*****************************/  
   input             mi_clk;
   input 	     mi_en;
   input [3:0] 	     mi_we;             //Single we, must write full words!
   input  [RFAW-1:0] mi_addr;
   input [31:0]      mi_din;
   output [31:0]     mi_dout;   
   
   
   /*****************************/
   /*ELINK CONTROL SIGNALS      */
   /*****************************/
   //RESET
   output 	    ecfg_reset;        //reset for all elink logic 
   output           ecfg_resetb;       //reset for epiphany chip
   
   //tx
   output 	    ecfg_tx_enable;    //enable signal for TX  
   output 	    ecfg_tx_mmu_mode;  //enables MMU on transmit path  
   output 	    ecfg_tx_gpio_mode; //forces TX output pins to constants
   output [3:0]     ecfg_tx_ctrl_mode; //value for emesh ctrlmode tag
   output [3:0]     ecfg_tx_clkdiv;    //transmit clock divider
   
   //rx
   output 	    ecfg_rx_enable;    //enable signal for rx  
   output 	    ecfg_rx_mmu_mode;  //enables MMU on rx path  
   output 	    ecfg_rx_gpio_mode; //forces rx wait pins to constants
   

   //cclk
   output 	     ecfg_cclk_en;     //cclk enable   
   output [3:0]      ecfg_cclk_div;    //cclk divider setting
   output [3:0]      ecfg_cclk_pllcfg; //pll configuration

   //coreid
   output [11:0]     ecfg_coreid;      //core-id of fpga elink

   //gpio
   input [10:0]      ecfg_datain;      //data from elink inputs
   output [10:0]     ecfg_dataout;     //data for elink outputs

   //debug
   input [31:0]      ecfg_debug;      //various signals for debugging the elink hardware
   
   
   /*------------------------BODY CODE---------------------------------------*/
   
   //registers
   reg [11:0] 	ecfg_cfgtx_reg;
   reg [4:0] 	ecfg_cfgrx_reg;
   reg [7:0] 	ecfg_cfgclk_reg;
   reg [11:0] 	ecfg_coreid_reg;
   reg          ecfg_reset_reg;
   reg [10:0] 	ecfg_datain_reg;
   reg [10:0] 	ecfg_dataout_reg;
   reg [31:0] 	mi_dout;
   
   //wires
   wire 	ecfg_read;
   wire 	ecfg_write;
   wire         ecfg_match;
   wire 	ecfg_regmux;
   wire [31:0] 	ecfg_reg_mux;
   wire 	ecfg_cfgtx_write;
   wire 	ecfg_cfgrx_write;
   wire 	ecfg_cfgclk_write;
   wire 	ecfg_coreid_write;
   wire 	ecfg_dataout_write;
   wire 	ecfg_rx_monitor_mode;
   wire 	ecfg_reset_write;
   
   /*****************************/
   /*ADDRESS DECODE LOGIC       */
   /*****************************/

   //read/write decode
   assign ecfg_write      = mi_en & mi_we[0];
   assign ecfg_read       = mi_en & ~mi_we[0];   

   //Write enables
   assign ecfg_reset_write     = ecfg_write & (mi_addr[RFAW-1:2]==`ESYSRESET);
   assign ecfg_cfgtx_write     = ecfg_write & (mi_addr[RFAW-1:2]==`ESYSCFGTX);
   assign ecfg_cfgrx_write     = ecfg_write & (mi_addr[RFAW-1:2]==`ESYSCFGRX);
   assign ecfg_cfgclk_write    = ecfg_write & (mi_addr[RFAW-1:2]==`ESYSCFGCLK);
   assign ecfg_coreid_write    = ecfg_write & (mi_addr[RFAW-1:2]==`ESYSCOREID);
   assign ecfg_dataout_write   = ecfg_write & (mi_addr[RFAW-1:2]==`ESYSDATAOUT);

   //###########################
   //# ESYSCFGTX
   //###########################
   always @ (posedge mi_clk)
     if(hw_reset)
       ecfg_cfgtx_reg[11:0] <= 12'b0;
     else if (ecfg_cfgtx_write)
       ecfg_cfgtx_reg[11:0] <= mi_din[11:0];

   assign ecfg_tx_enable         = ecfg_cfgtx_reg[0];
   assign ecfg_tx_mmu_mode       = ecfg_cfgtx_reg[1];   
   assign ecfg_tx_gpio_mode      = ecfg_cfgtx_reg[3:2]==2'b01;
   assign ecfg_tx_ctrl_mode[3:0] = ecfg_cfgtx_reg[7:4];
   assign ecfg_tx_clkdiv[3:0]    = ecfg_cfgtx_reg[11:8];

   //###########################
   //# ESYSCFGRX
   //###########################
   always @ (posedge mi_clk)
     if(hw_reset)
       ecfg_cfgrx_reg[4:0] <= 5'b0;
     else if (ecfg_cfgrx_write)
       ecfg_cfgrx_reg[4:0] <= mi_din[4:0];

   assign ecfg_rx_enable        = ecfg_cfgrx_reg[0];
   assign ecfg_rx_mmu_mode      = ecfg_cfgrx_reg[1];   
   assign ecfg_rx_gpio_mode     = ecfg_cfgrx_reg[3:2]==2'b01;
   assign ecfg_rx_monitor_mode  = ecfg_cfgrx_reg[4];

   //###########################
   //# ESYSCFGCLK
   //###########################
    always @ (posedge mi_clk)
     if(hw_reset)
       ecfg_cfgclk_reg[7:0] <= 8'b0;
     else if (ecfg_cfgclk_write)
       ecfg_cfgclk_reg[7:0] <= mi_din[7:0];

   assign ecfg_cclk_en             = ~(ecfg_cfgclk_reg[3:0]==4'b0000);   
   assign ecfg_cclk_div[3:0]       = ecfg_cfgclk_reg[3:0];
   assign ecfg_cclk_pllcfg[3:0]    = ecfg_cfgclk_reg[7:4];

   //###########################
   //# ESYSCOREID
   //###########################
   always @ (posedge mi_clk)
     if(hw_reset)
       ecfg_coreid_reg[IDW-1:0] <= DEFAULT_COREID;
     else if (ecfg_coreid_write)
       ecfg_coreid_reg[IDW-1:0] <= mi_din[IDW-1:0];   
   
   assign ecfg_coreid[IDW-1:0] = ecfg_coreid_reg[IDW-1:0];

   //###########################
   //# ESYSDATAIN
   //###########################
   always @ (posedge mi_clk)
     ecfg_datain_reg[10:0] <= ecfg_datain[10:0];
   
   //###########################
   //# ESYSDATAOUT
   //###########################
   always @ (posedge mi_clk)
     if(hw_reset)
       ecfg_dataout_reg[10:0] <= 11'd0;   
     else if (ecfg_dataout_write)
       ecfg_dataout_reg[10:0] <= mi_din[10:0];

   assign ecfg_dataout[10:0] = ecfg_dataout_reg[10:0];
   
   //###########################
   //# ESYSRESET
   //###########################
    always @ (posedge mi_clk)
      if(hw_reset)
	ecfg_reset_reg <= 1'b0;   
      else if (ecfg_reset_write)
	ecfg_reset_reg <= mi_din[0];  

   assign ecfg_reset    = ecfg_reset_reg | hw_reset;
   assign ecfg_resetb   = ~ecfg_reset;
   
   //###############################
   //# DATA READBACK MUX
   //###############################

   //Pipelineing readback
   always @ (posedge mi_clk)
     if(ecfg_read)
       case(mi_addr[RFAW-1:2])
         `ESYSRESET:    mi_dout[31:0] <= {31'b0, ecfg_reset_reg};
         `ESYSCFGTX:    mi_dout[31:0] <= {20'b0, ecfg_cfgtx_reg[11:0]};
         `ESYSCFGRX:    mi_dout[31:0] <= {27'b0, ecfg_cfgrx_reg[4:0]};
         `ESYSCFGCLK:   mi_dout[31:0] <= {24'b0, ecfg_cfgclk_reg[7:0]};
         `ESYSCOREID:   mi_dout[31:0] <= {{(32-IDW){1'b0}}, ecfg_coreid_reg[IDW-1:0]};
         `ESYSVERSION:  mi_dout[31:0] <= EVERSION;
         `ESYSDATAIN:   mi_dout[31:0] <= {21'b0, ecfg_datain_reg[10:0]};
         `ESYSDATAOUT:  mi_dout[31:0] <= {21'b0, ecfg_dataout_reg[10:0]};
	 `ESYSDEBUG:    mi_dout[31:0] <= ecfg_debug[31:0];
         default:       mi_dout[31:0] <= 32'd0;
       endcase

endmodule // ecfg


