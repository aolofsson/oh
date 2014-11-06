`define REG_ESYSRESET    6'h00
`define REG_ESYSCFGTX    6'h01
`define REG_ESYSCFGRX    6'h02
`define REG_ESYSCFGCLK   6'h03
`define REG_ESYSCOREID   6'h04
`define REG_ESYSVERSION  6'h05
`define REG_ESYSDATAIN   6'h06
`define REG_ESYSDATAOUT  6'h07
`define REG_ESYSRXMON0   6'h08
`define REG_ESYSRXMON1   6'h09
`define REG_ESYSRXMON2   6'h0A
`define REG_ESYSTXMON0   6'h0B
`define REG_ESYSTXMON1   6'h0C
`define REG_ESYSTXMON2   6'h0D
`define REG_ESYSTXMO2    6'h0E
`define REG_ESYSIRQSRC   6'h0F
`define REG_ESYSIRQDATA  6'h10
`define EVERSION         32'h00000000

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
 [0]              0  - elink in reset 
                  1  - elink NOT in reset
-------------------------------------------------------------
 ESYSCFGTX        ***Elink transmitter configuration***
 [0]              0  - link TX disable
                  1  - link TX enable
 [1]              0  - normal pass through transaction mode
                  1  - mmu mode
 [3:2]            00 - normal mode
                  01 - gpio mode
                  10 - reserved
                  11 - reserved
 [7:4]           Transmit control mode for eMesh
 [9:8]            00 - No division, full speed
                  01 - Divide by 2
                  10 - Reserved
                  11 - Reserved
  -------------------------------------------------------------
 ESYSCFGRX       ***Elink receiver configuration***
 [0]              0  - link RX disable
                  1  - link RX enable
 [1]              0  - normal transaction mode
                  1  - mmu mode
 [3:2]            00 - normal mode
                  01 - GPIO mode (drive rd wait pins from registers)
                  10 - loopback mode (loops TX-->RX)
                  11 - reserved
 [4]              0  - set monitor to count traffic
                  1  - set monitor to count congestion    
  -------------------------------------------------------------
 ESYSCFGCLK       ***Epiphany clock frequency setting*** 
 [3:0]            Output divider
                  0000 - CLock turned off
                  0001 - CLKIN/64
                  0010 - CLKIN/32
                  0011 - CLKIN/16
                  0100 - CLKIN/8
                  0101 - CLKIN/4
                  0110 - CLKIN/2
                  0111 - CLKIN/1
                  1XXX - RESERVED
 [7:4]            PLL settings (TBD)
 -------------------------------------------------------------
 ESYSCOREID       ***CORE ID***
 [5:0]            Column ID-->default at powerup/reset             
 [11:6]           Row ID  
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
 [8]            tx_fram
 [9]            rx_wait_rd
 [10]           rx_wait_wr
 -------------------------------------------------------------
 ESYSRXMON0     ***Counts RX master write transactions***
-------------------------------------------------------------
 ESYSRXMON1     ***Counts RX master read transactions***
-------------------------------------------------------------
 ESYSRXMON2     ***Counts RX slave read response transactions*** 
-------------------------------------------------------------
 ESYSTXMON0     ***Counts TX slave write transactions*** 
-------------------------------------------------------------
 ESYSTXMON1     ***Counts TX slave read transactions*** 
-------------------------------------------------------------
 ESYSTXMON2     ***Counts TX master read response transactions*** 
-------------------------------------------------------------
 ESYSIRQSRC     ***Current IRQ FIFO entry (12 bits)
                Read of entry will increment FIFO read pointer
-------------------------------------------------------------
 ESYSIRQDATA    ***Data associated with current IRQ FIFO entry
                32 bits (should be read before src)
-------------------------------------------------------------
 
 ########################################################################
 */
module esys_regs (/*AUTOARG*/
   // Outputs
   data_out, esys_tx_enable, esys_tx_mmu_mode, esys_tx_gpio_mode,
   esys_tx_ctrl_mode, esys_tx_clkdiv, esys_rx_enable,
   esys_rx_mmu_mode, esys_rx_gpio_mode, esys_rx_loopback_mode,
   esys_cclk_div, esys_coreid, esys_dataout, esys_irqsrc_read,
   // Inputs
   param_coreid, clk, hw_reset, access, write, addr, data_in,
   erx_irq_fifo_src, erx_irq_fifo_data, erx_rdfifo_access,
   erx_rdfifo_wait, erx_wrfifo_access, erx_wrfifo_wait,
   erx_wbfifo_access, erx_wbfifo_wait, etx_rdfifo_access,
   etx_rdfifo_wait, etx_wrfifo_access, etx_wrfifo_wait,
   etx_wbfifo_access, etx_wbfifo_wait
   );
   //Register file parameters

/*
 #####################################################################
 COMPILE TIME PARAMETERS 
 ######################################################################
 */
parameter EMONW  = 32;  //elink monitor register width
parameter EMAW  = 12;   //mmu table address width
parameter EDW    = 32;  //Epiphany native data width
parameter EAW    = 32;  //Epiphany native address width
parameter EIDW   = 12;  //Elink ID (row,column coordinate)
parameter RFAW   = 5;   //Number of registers=2^RFAW


   /*****************************/
   /*STATIC CONFIG SIGNALS      */
   /*****************************/
   input [EIDW-1:0] param_coreid;
   
   /*****************************/
   /*SIMPLE MEMORY INTERFACE    */
   /*****************************/
   input              clk;   
   input              hw_reset;
   input              access;
   input              write;
   input  [RFAW-1:0]  addr;
   input  [31:0]      data_in;
   output [31:0]      data_out;

   /*****************************/
   /*ELINK DATAPATH INPUTS      */
   /*****************************/
   input [11:0]      erx_irq_fifo_src;
   input [11:0]      erx_irq_fifo_data;
   input 	     erx_rdfifo_access;
   input 	     erx_rdfifo_wait;
   input 	     erx_wrfifo_access;
   input 	     erx_wrfifo_wait;
   input 	     erx_wbfifo_access;
   input 	     erx_wbfifo_wait;   
   input 	     etx_rdfifo_access;
   input 	     etx_rdfifo_wait;
   input 	     etx_wrfifo_access;
   input 	     etx_wrfifo_wait;
   input 	     etx_wbfifo_access;
   input 	     etx_wbfifo_wait;
  
   /*****************************/
   /*ESYS CONTROL OUTPUTS       */
   /*****************************/
   //tx
   output 	     esys_tx_enable;      //enable signal for TX  
   output 	     esys_tx_mmu_mode;    //enables MMU on transnmit path  
   output 	     esys_tx_gpio_mode;   //forces TX output pins to constants
   output [3:0]	     esys_tx_ctrl_mode;   //value for emesh ctrlmode tag
   output [3:0]      esys_tx_clkdiv;      //transmit clock divider

   //rx
   output 	     esys_rx_enable;         //enable signal for rx  
   output 	     esys_rx_mmu_mode;       //enables MMU on rx path  
   output 	     esys_rx_gpio_mode;      //forces rx wait pins to constants
   output 	     esys_rx_loopback_mode;  //loops back tx to rx receiver (after serdes)

   //cclk
   output [3:0]      esys_cclk_div;          //cclk divider setting
   output [3:0]      esys_cclk_pllcfg;       //pll configuration

   //coreid
   output [11:0]     esys_coreid;            //core-id of fpga elink

   //gpio
   output [11:0]     esys_dataout;          //data for elink outputs {rd_wait,wr_wait,frame,data[7:0}

   //irq
   output 	     esys_irqsrc_read;      //increments the irq fifo pointer

   /*------------------------BODY CODE---------------------------------------*/
   
   //registers
   reg [9:0] 	esys_cfgtx_reg;
   reg [4:0] 	esys_cfgrx_reg;
   reg [7:0] 	esys_cfgclk_reg;
   reg [11:0] 	esys_coreid_reg;
   wire [31:0] 	esys_version_reg; //fixed read only constant
   reg 		esys_reset_reg;
   reg [11:0] 	esys_datain_reg;
   reg [11:0] 	esys_dataout_reg;
   wire [11:0] 	esys_irqsrc_reg;
   wire [31:0]  esys_irqdata_reg;
   reg [31:0] 	data_out;
   
   //wires
   wire 	esys_read;
   wire 	esys_write;
   wire 	esys_reset_match;
   wire 	esys_cfgtx_match;
   wire 	esys_cfgrx_match;
   wire 	esys_cfgclk_match;
   wire 	esys_coreid_match;
   wire 	esys_version_match;
   wire 	esys_datain_match;
   wire 	esys_dataout_match;
   wire 	esys_rxmon0_match;
   wire 	esys_rxmon1_match;
   wire 	esys_rxmon2_match;
   wire 	esys_txmon0_match;
   wire 	esys_txmon1_match;
   wire 	esys_txmon2_match;
   wire 	esys_irqsrc_match;
   wire 	esys_irqdata_match;
   wire 	esys_regmux;
   wire [31:0] 	esys_reg_mux;
   
   /*****************************/
   /*ADDRESS DECODE LOGIC       */
   /*****************************/

   //read/write decode
   assign esys_write      = access & write;
   assign esys_read       = access & ~write;   

   //address match signals
   assign esys_reset_match     = addr[RFAW-1:0]==`REG_ESYSRESET;
   assign esys_cfgtx_match     = addr[RFAW-1:0]==`REG_ESYSCFGTX;
   assign esys_cfgrx_match     = addr[RFAW-1:0]==`REG_ESYSCFGRX;
   assign esys_cfgclk_match    = addr[RFAW-1:0]==`REG_ESYSCFGCLK;
   assign esys_coreid_match    = addr[RFAW-1:0]==`REG_ESYSCOREID;
   assign esys_version_match   = addr[RFAW-1:0]==`REG_ESYSVERSION;
   assign esys_datain_match    = addr[RFAW-1:0]==`REG_ESYSDATAIN;
   assign esys_dataout_match   = addr[RFAW-1:0]==`REG_ESYSDATAOUT;
   assign esys_rxmon0_match    = addr[RFAW-1:0]==`REG_ESYSRXMON0;
   assign esys_rxmon1_match    = addr[RFAW-1:0]==`REG_ESYSRXMON1;
   assign esys_rxmon2_match    = addr[RFAW-1:0]==`REG_ESYSRXMON2;
   assign esys_txmon0_match    = addr[RFAW-1:0]==`REG_ESYSTXMON0;
   assign esys_txmon1_match    = addr[RFAW-1:0]==`REG_ESYSTXMON1;
   assign esys_txmon2_match    = addr[RFAW-1:0]==`REG_ESYSTXMON2;
   assign esys_irqsrc_match    = addr[RFAW-1:0]==`REG_ESYSIRQSRC;
   assign esys_irqdata_match   = addr[RFAW-1:0]==`REG_ESYSIRQDATA;

   //Write enables
   assign esys_reset_write     = esys_reset_match   & esys_write;
   assign esys_cfgtx_write     = esys_cfgtx_match   & esys_write;
   assign esys_cfgrx_write     = esys_cfgrx_match   & esys_write;
   assign esys_cfgclk_write    = esys_cfgclk_match  & esys_write;
   assign esys_coreid_write    = esys_coreid_match  & esys_write;
   assign esys_version_write   = esys_version_match & esys_write;
   assign esys_datain_write    = esys_datain_match  & esys_write;
   assign esys_dataout_write   = esys_dataout_match & esys_write;
   assign esys_rxmon0_write    = esys_rxmon0_match  & esys_write;
   assign esys_rxmon1_write    = esys_rxmon1_match  & esys_write;
   assign esys_rxmon2_write    = esys_rxmon2_match  & esys_write;
   assign esys_txmon0_write    = esys_rxmon0_match  & esys_write;
   assign esys_txmon1_write    = esys_rxmon1_match  & esys_write;
   assign esys_txmon2_write    = esys_rxmon2_match  & esys_write;
   assign esys_irqsrc_write    = esys_irqsrc_match  & esys_write;
   assign esys_irqdata_write   = esys_irqdata_match & esys_write;
   
   //###########################
   //# ESYSCFGTX
   //###########################
   always @ (posedge clk)
     if(hw_reset)
       esys_cfgtx_reg[9:0] <= 10'b0;
     else if (esys_cfgtx_write)
       esys_cfgtx_reg[9:0] <= data_in[9:0];

   assign esys_tx_enable        = esys_cfgtx_reg[0];
   assign esys_tx_mmu_mode      = esys_cfgtx_reg[1];   
   assign esys_tx_gpio_mode     = esys_cfgtx_reg[3:2]==2'b01;
   assign esys_tx_ctrl_mode[3:0] = esys_cfgtx_reg[7:4];
   assign esys_tx_clkdiv[3:0]   = esys_cfgtx_reg[11:8];

   //###########################
   //# ESYSCFGRX
   //###########################
   always @ (posedge clk)
     if(hw_reset)
       esys_cfgrx_reg[4:0] <= 5'b0;
     else if (esys_cfgrx_write)
       esys_cfgrx_reg[4:0] <= data_in[4:0];

   assign esys_rx_enable        = esys_cfgrx_reg[0];
   assign esys_tx_mmu_mode      = esys_cfgrx_reg[1];   
   assign esys_rx_gpio_mode     = esys_cfgrx_reg[3:2]==2'b01;
   assign esys_rx_loopback_mode = esys_cfgrx_reg[3:2]==2'b10;
   assign esys_rx_monitor_mode  = esys_cfgrx_reg[4];

   //###########################
   //# ESYSCFGCLK
   //###########################
    always @ (posedge clk)
     if(hw_reset)
       esys_cfgclk_reg[7:0] <= 8'b0;
     else if (esys_cfgclk_write)
       esys_cfgclk_reg[7:0] <= data_in[7:0];

   assign esys_cclk_div[3:0]       = esys_cfgclk_reg[3:0];
   assign esys_cclk_pllcfg[3:0]    = esys_cfgclk_reg[7:4];

   //###########################
   //# ESYSCOREID
   //###########################
   always @ (posedge clk)
     if(hw_reset)
       esys_coreid_reg[EIDW-1:0] <= param_coreid[EIDW-1:0];
     else if (esys_coreid_write)
       esys_coreid_reg[EIDW-1:0] <= data_in[EIDW-1:0];   
   
   assign esys_coreid[EIDW-1:0] = esys_coreid_reg[EIDW-1:0];

   //###########################
   //# ESYSVERSION
   //###########################
   assign esys_version_reg[31:0] = `EVERSION;

   //###########################
   //# ESYSDATAIN
   //###########################
   always @ (posedge clk)
     if(hw_reset)
       esys_datain_reg[11:0] <= 12'b0;   
     else if (esys_datain_write)
       esys_datain_reg[11:0] <= data_in[11:0];  
     else
       esys_datain_reg[11:0] <= data_in[11:0];  

   //###########################
   //# ESYSDATAOUT
   //###########################
   always @ (posedge clk)
     if(hw_reset)
       esys_dataout_reg[11:0] <= 12'b0;   
     else if (esys_dataout_write)
       esys_dataout_reg[11:0] <= data_in[11:0];  

   assign esys_dataout[11:0] = esys_dataout_reg[11:0];
   
   //###########################
   //# ESYSRXMON0
   //###########################
`ifdef USE_ESYS_MONITORS
   //create module
   //instantiate monitors, similar to timers
   //inputs
`endif   

   //###########################
   //# ESYSIRQSRC
   //###########################
   assign esys_irqsrc_read      = esys_irqsrc_match & access;
   assign esys_irqsrc_reg[11:0] = erx_irq_fifo_src[11:0];

   //###########################
   //# ESYSIRQDATA
   //###########################   
   assign esys_irqdata_reg[31:0] = erx_irq_fifo_data[31:0];
   
   //###########################
   //# ESYSRESET
   //###########################
    always @ (posedge clk)
      if(hw_reset)
	esys_reset_reg <= 1'b0;   
      else if (esys_reset_write)
	esys_reset_reg <= data_in[0];  

   assign esys_reset = esys_reset_reg;
   
   //###############################
   //# DATA READBACK MUX
   //###############################

   assign esys_reg_mux[31:0] =   ({(32){esys_cfgtx_match}}   & {18'b0,esys_cfgtx_reg[11:0]})  |
				 ({(32){esys_cfgrx_match}}   & {18'b0,esys_cfgrx_reg[11:0]})  |
				 ({(32){esys_cfgclk_match}}  & {24'b0,esys_cfgclk_reg[7:0]})  |
				 ({(32){esys_coreid_match}}  & {18'b0,esys_coreid_reg[11:0]}) |
				 ({(32){esys_irqsrc_match}}  & {18'b0,esys_irqsrc_reg[11:0]}) |
				 ({(32){esys_version_match}} & esys_version_reg[31:0])        |
				 ({(32){esys_datain_match}}  & esys_datain_reg[31:0])         |
				 ({(32){esys_dataout_match}} & esys_dataout_reg[31:0])        |
				 ({(32){esys_rxmon0_match}}  & esys_rxmon0_reg[31:0])         |
				 ({(32){esys_rxmon1_match}}  & esys_rxmon1_reg[31:0])         |
				 ({(32){esys_rxmon2_match}}  & esys_rxmon2_reg[31:0])         |
				 ({(32){esys_txmon0_match}}  & esys_txmon0_reg[31:0])         |
				 ({(32){esys_txmon1_match}}  & esys_txmon1_reg[31:0])         |
				 ({(32){esys_txmon2_match}}  & esys_txmon2_reg[31:0])         |
				 ({(32){esys_irqdata_match}} & esys_irqdata_reg[31:0]);
      
   //Pipelineing readback
   always @ (posedge clk)
     if(access)
       data_out[31:0] <= esys_reg_mux[31:0];
   
endmodule // para_config

