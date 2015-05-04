/*
 ########################################################################
 ELINK TX CONFIGURATION REGISTER FILE
 ######################################################################## 
 */
module ecfg_tx (/*AUTOARG*/
   // Outputs
   mi_dout, tx_enable, mmu_enable, gpio_enable, tp_enable,
   remap_enable, gpio_data, ctrlmode, ctrlmode_bypass, chipid,
   // Inputs
   reset, clk, mi_en, mi_we, mi_addr, mi_din, tx_status
   );

   /******************************/
   /*Compile Time Parameters     */
   /******************************/
   parameter PW               = 104;   
   parameter RFAW             = 6;
   parameter DEFAULT_CHIPID   = 12'h808;
   parameter DEFAULT_VERSION  = 16'h0000;

   /******************************/
   /*HARDWARE RESET (EXTERNAL)   */
   /******************************/
   input 	 reset;             
   input 	 clk;

   /*****************************/
   /*SIMPLE MEMORY INTERFACE    */
   /*****************************/    
   input 	     mi_en;         
   input 	     mi_we;            
   input [RFAW+1:0]  mi_addr;       // complete address (no shifting!)
   input [31:0]      mi_din;        // (lower 2 bits not used)
   output [31:0]     mi_dout;   
   
   /*****************************/
   /*ELINK CONTROL SIGNALS      */
   /*****************************/
   //tx (static configs)
   output 	   tx_enable;      // enable signal for TX  
   output 	   mmu_enable;     // enables MMU on transmit path  
   output 	   gpio_enable;    // forces TX output pins to constants
   output          tp_enable;      // enables 1/0 pattern on transmit     
   output 	   remap_enable;   // enable address remapping
   input [15:0]    tx_status;      // etx status signals
   
   //sampled by tx_lclk (test)
   output [8:0]    gpio_data;      // data for elink outputs (static)   

   //dynamic (control timing by use mode)
   output [3:0]    ctrlmode;        // value for emesh ctrlmode tag
   output          ctrlmode_bypass; // selects ctrlmode

   //to drive epiphany id pins
   output [11:0]   chipid;
   
   
   //registers
   reg [11:0] 	   ecfg_chipid_reg;
   reg [15:0] 	   ecfg_version_reg;
   reg [10:0] 	   ecfg_tx_config_reg;
   reg [8:0] 	   ecfg_tx_gpio_reg;
   reg [2:0] 	   ecfg_tx_status_reg;
   reg [31:0] 	   mi_dout;
   reg 		   ecfg_access;
   
   //wires
   wire 	   ecfg_read;
   wire 	   ecfg_write;
   wire 	   ecfg_tx_config_write;
   wire 	   ecfg_tx_gpio_write;
   wire 	   ecfg_tx_test_write;
   wire 	   ecfg_tx_addr_write;
   wire 	   ecfg_tx_data_write;
   wire 	   loop_mode;
   
   /*****************************/
   /*ADDRESS DECODE LOGIC       */
   /*****************************/

   //read/write decode
   assign ecfg_write  = mi_en &  mi_we;
   assign ecfg_read   = mi_en & ~mi_we;   

   //Config write enables 
   assign ecfg_chipid_write    = ecfg_write & (mi_addr[RFAW+1:2]==`E_CHIPID);
   assign ecfg_version_write   = ecfg_write & (mi_addr[RFAW+1:2]==`E_VERSION);
   assign ecfg_tx_config_write = ecfg_write & (mi_addr[RFAW+1:2]==`ETX_CFG);
   assign ecfg_tx_status_write = ecfg_write & (mi_addr[RFAW+1:2]==`ETX_STATUS);
   assign ecfg_tx_gpio_write   = ecfg_write & (mi_addr[RFAW+1:2]==`ETX_GPIO);
  
   //###########################
   //# TX CONFIG
   //###########################
   always @ (posedge clk)
     if(reset)
       ecfg_tx_config_reg[10:0] <= 11'b0;
     else if (ecfg_tx_config_write)
       ecfg_tx_config_reg[10:0] <= mi_din[10:0];

   assign tx_enable       = 1'b1;//TODO: fix! ecfg_tx_config_reg[0];
   assign mmu_enable      = ecfg_tx_config_reg[1];   
   assign remap_enable    = ecfg_tx_config_reg[3:2]==2'b01;
   assign ctrlmode[3:0]   = ecfg_tx_config_reg[7:4];
   assign ctrlmode_bypass = ecfg_tx_config_reg[8];
   assign gpio_enable     = (ecfg_tx_config_reg[10:9]==2'b01);
   assign tp_enable       = (ecfg_tx_config_reg[10:9]==2'b10);

   //###########################
   //# STATUS REGISTER
   //###########################   
   always @ (posedge clk)
     if(reset)
       ecfg_tx_status_reg[2:0] <= 'd0;
     else
       begin
	  ecfg_tx_status_reg[2:0]<= ecfg_tx_status_reg[2:0] | tx_status[2:0];
       end

   //###########################
   //# GPIO DATA
   //###########################
   always @ (posedge clk)
     if(reset)
       ecfg_tx_gpio_reg[8:0] <= 'd0;   
     else if (ecfg_tx_gpio_write)
       ecfg_tx_gpio_reg[8:0] <= mi_din[8:0];

   assign gpio_data[8:0] = ecfg_tx_gpio_reg[8:0];

   //###########################
   //# CHIPID
   //###########################
   always @ (posedge clk)
     if(reset)
       ecfg_chipid_reg[11:0] <= DEFAULT_CHIPID;
     else if (ecfg_chipid_write)
       ecfg_chipid_reg[11:0] <= mi_din[11:0];   
   
   assign chipid[11:0]=ecfg_chipid_reg[5:2];   
   
   //###########################
   //# VERSION
   //###########################
   always @ (posedge clk)
     if(reset)
       ecfg_version_reg[15:0] <= DEFAULT_VERSION;
     else if (ecfg_version_write)
       ecfg_version_reg[15:0] <= mi_din[15:0];       

   //###############################
   //# DATA READBACK MUX
   //###############################
   //Pipelineing readback
   always @ (posedge clk)
     if(ecfg_read)
       case(mi_addr[RFAW+1:2])
         `ETX_CFG:    mi_dout[31:0] <= {21'b0, ecfg_tx_config_reg[10:0]};
         `ETX_GPIO:   mi_dout[31:0] <= {23'b0, ecfg_tx_gpio_reg[8:0]};
	 `ETX_STATUS: mi_dout[31:0] <= {16'b0, tx_status[15:3],ecfg_tx_status_reg[2:0]};
	 `E_CHIPID:   mi_dout[31:0] <= {20'b0, ecfg_chipid_reg[11:0]};
         `E_VERSION:  mi_dout[31:0] <= {16'b0, ecfg_version_reg[15:0]};
         default:     mi_dout[31:0] <= 32'd0;
       endcase // case (mi_addr[RFAW+1:2])
     else
       mi_dout[31:0] <= 32'd0;

endmodule // ecfg_tx


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
