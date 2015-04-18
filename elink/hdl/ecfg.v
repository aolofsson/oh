/*
 ########################################################################
 ELINK CONFIGURATION REGISTER FILE
 ########################################################################
 
 */

module ecfg (/*AUTOARG*/
   // Outputs
   soft_reset, mi_dout, ecfg_tx_enable, ecfg_tx_mmu_enable,
   ecfg_tx_gpio_enable, ecfg_tx_ctrlmode, ecfg_timeout_enable,
   ecfg_rx_enable, ecfg_rx_mmu_enable, ecfg_rx_gpio_enable,
   ecfg_clk_settings, ecfg_coreid, ecfg_dataout, embox_not_empty,
   embox_full,
   // Inputs
   hard_reset, mi_clk, mi_en, mi_we, mi_addr, mi_din, ecfg_rx_datain,
   ecfg_tx_datain, ecfg_tx_debug, ecfg_rx_debug
   );

   /******************************/
   /*Compile Time Parameters     */
   /******************************/
   parameter RFAW            = 5;         // 32 registers for now
   parameter DEFAULT_COREID  = 12'h808;   // reset value for ecfg_coreid
   parameter DEFAULT_VERSION = 16'h0000;  // reset value for version
   parameter DEFAULT_CLKDIV  = 4'd7;
   
   /******************************/
   /*HARDWARE RESET (EXTERNAL)   */
   /******************************/
   input 	hard_reset;       // ecfg registers reset only by "hard reset"
   output 	soft_reset;       // soft reset output driven by register

   /*****************************/
   /*SIMPLE MEMORY INTERFACE    */
   /*****************************/    
   input 	 mi_clk;
   input 	 mi_en;         
   input 	 mi_we;            // single we, must write 32 bit words
   input [19:0]  mi_addr;          // complete physical address (no shifting!)
   input [31:0]  mi_din;
   output [31:0] mi_dout;   
   
   /*****************************/
   /*ELINK CONTROL SIGNALS      */
   /*****************************/
   //reset

   //tx
   output 	 ecfg_tx_enable;       // enable signal for TX  
   output 	 ecfg_tx_mmu_enable;   // enables MMU on transmit path  
   output 	 ecfg_tx_gpio_enable;  // forces TX output pins to constants
   output [3:0]  ecfg_tx_ctrlmode;     // value for emesh ctrlmode tag
   output 	 ecfg_timeout_enable;  // enables axi slave timeout circuit
   
   //rx
   output 	 ecfg_rx_enable;       // enable signal for rx  
   output 	 ecfg_rx_mmu_enable;   // enables MMU on rx path  
   output 	 ecfg_rx_gpio_enable;  // forces rx wait pins to constants
   
   //clocks
   output [15:0] ecfg_clk_settings;    // clock settings
   
   //coreid
   output [11:0] ecfg_coreid;          // core-id of fpga elink

   //gpio
   input [8:0] 	 ecfg_rx_datain;       // frame and data
   input [1:0] 	 ecfg_tx_datain;       // wait signals
   output [10:0] ecfg_dataout;         // data for elink outputs

   //debug
   output 	 embox_not_empty;      // not-empty interrupt
   output 	 embox_full;           // full debug signal 
   input [15:0]  ecfg_tx_debug;        // etx debug signals
   input [15:0]  ecfg_rx_debug;        // etx debug signals
   
   /*------------------------CODE BODY---------------------------------------*/
   
   //registers
   reg          ecfg_reset_reg;
   reg [8:0] 	ecfg_tx_reg;
   reg [4:0] 	ecfg_rx_reg;
   reg [15:0] 	ecfg_clk_reg;
   reg [11:0] 	ecfg_coreid_reg;
   reg [15:0] 	ecfg_version_reg;
   reg [10:0] 	ecfg_datain_reg;
   reg [10:0] 	ecfg_dataout_reg;
   reg [7:0] 	ecfg_debug_reg;
   reg [31:0] 	mi_dout;
   
   //wires
   wire 	ecfg_read;
   wire 	ecfg_write;
   wire         ecfg_match;
   wire 	ecfg_regmux;
   wire [31:0] 	ecfg_reg_mux;
   wire 	ecfg_tx_write;
   wire 	ecfg_rx_write;
   wire 	ecfg_clk_write;
   wire 	ecfg_coreid_write;
   wire 	ecfg_version_write;
   wire 	ecfg_dataout_write;
   wire 	ecfg_reset_write;
   wire [31:0] 	ecfg_debug_vector;
   
   /*****************************/
   /*ADDRESS DECODE LOGIC       */
   /*****************************/

   //read/write decode
   assign ecfg_write  = mi_en &  mi_we;
   assign ecfg_read   = mi_en & ~mi_we;   

   //Config write enables
   assign ecfg_reset_write    = ecfg_write & (mi_addr[RFAW+1:2]==`ESYSRESET);
   assign ecfg_tx_write    = ecfg_write & (mi_addr[RFAW+1:2]==`ESYSTX);
   assign ecfg_rx_write    = ecfg_write & (mi_addr[RFAW+1:2]==`ESYSRX);
   assign ecfg_clk_write   = ecfg_write & (mi_addr[RFAW+1:2]==`ESYSCLK);
   assign ecfg_coreid_write   = ecfg_write & (mi_addr[RFAW+1:2]==`ESYSCOREID);
   assign ecfg_dataout_write  = ecfg_write & (mi_addr[RFAW+1:2]==`ESYSDATAOUT);

   //###########################
   //# ESYSRESET
   //###########################
    always @ (posedge mi_clk)
      if(hard_reset)
	ecfg_reset_reg <= 1'b0;   
      else if (ecfg_reset_write)
	ecfg_reset_reg <= mi_din[0];  

   assign soft_reset    = ecfg_reset_reg;

   //###########################
   //# ESYSTX
   //###########################
   always @ (posedge mi_clk)
     if(hard_reset)
       ecfg_tx_reg[8:0] <= 9'b0;
     else if (ecfg_tx_write)
       ecfg_tx_reg[8:0] <= mi_din[8:0];

   assign ecfg_tx_enable          = ecfg_tx_reg[0];
   assign ecfg_tx_mmu_enable      = ecfg_tx_reg[1];   
   assign ecfg_tx_gpio_enable     = (ecfg_tx_reg[3:2]==2'b01);
   assign ecfg_tx_ctrlmode[3:0]   = ecfg_tx_reg[7:4];
   assign ecfg_timeout_enable     = ecfg_tx_reg[8];
   
   //###########################
   //# ESYSRX
   //###########################
   always @ (posedge mi_clk)
     if(hard_reset)
       ecfg_rx_reg[4:0] <= 5'b0;
     else if (ecfg_rx_write)
       ecfg_rx_reg[4:0] <= mi_din[4:0];

   assign ecfg_rx_enable        = ecfg_rx_reg[0];
   assign ecfg_rx_mmu_enable    = ecfg_rx_reg[1];   
   assign ecfg_rx_gpio_enable   = ecfg_rx_reg[3:2]==2'b01;

   //###########################
   //# ESYSCLK
   //###########################
    always @ (posedge mi_clk)
     if(hard_reset)
       ecfg_clk_reg[15:0] <= {8'b0,DEFAULT_CLKDIV,DEFAULT_CLKDIV};
     else if (ecfg_clk_write)
       ecfg_clk_reg[15:0] <= mi_din[15:0];

   assign ecfg_clk_settings[15:0] = ecfg_clk_reg[15:0];
   
   //assign ecfg_cclk_en             = ~(ecfg_clk_reg[3:0]==4'b0000);   
   //assign ecfg_cclk_div[3:0]       = ecfg_clk_reg[3:0];
   //assign ecfg_cclk_pllcfg[3:0]    = ecfg_clk_reg[7:4];
   //assign ecfg_cclk_bypass         = ecfg_clk_reg[8];

   //###########################
   //# ESYSCOREID
   //###########################
   always @ (posedge mi_clk)
     if(hard_reset)
       ecfg_coreid_reg[11:0] <= DEFAULT_COREID;
     else if (ecfg_coreid_write)
       ecfg_coreid_reg[11:0] <= mi_din[11:0];   
   
   assign ecfg_coreid[11:0] = ecfg_coreid_reg[11:0];

   //###########################
   //# ESYSVERSION
   //###########################
   always @ (posedge mi_clk)
     if(hard_reset)
       ecfg_version_reg[15:0] <= DEFAULT_VERSION;
     else if (ecfg_version_write)
       ecfg_version_reg[15:0] <= mi_din[15:0];   
   
   //###########################
   //# ESYSDATAIN
   //###########################
   always @ (posedge mi_clk)
     ecfg_datain_reg[10:0] <= {ecfg_rx_datain[1:0], ecfg_rx_datain[8:0]};
   
   //###########################
   //# ESYSDATAOUT
   //###########################
   always @ (posedge mi_clk)
     if(hard_reset)
       ecfg_dataout_reg[10:0] <= 11'd0;   
     else if (ecfg_dataout_write)
       ecfg_dataout_reg[10:0] <= mi_din[10:0];

   assign ecfg_dataout[10:0] = ecfg_dataout_reg[10:0];

   //###########################
   //# ESYSDEBUG
   //###########################
   assign ecfg_debug_vector[31:0]= {embox_not_empty,
				    ecfg_rx_debug[14:3],
				    ecfg_tx_debug[14:3],
				    ecfg_rx_debug[2:0],
				    ecfg_tx_debug[2:0],
				    embox_full
				    };
   
   always @ (posedge mi_clk)
     if(hard_reset)
       ecfg_debug_reg[7:0] <= 8'd0;
     else
       ecfg_debug_reg[7:0] <=ecfg_debug_reg[7:0] | ecfg_debug_vector[7:0];

   //###############################
   //# DATA READBACK MUX
   //###############################

   //Pipelineing readback
   always @ (posedge mi_clk)
     if(ecfg_read)
       case(mi_addr[RFAW+1:2])
         `ESYSRESET:   mi_dout[31:0] <= {31'b0, ecfg_reset_reg};
         `ESYSTX:      mi_dout[31:0] <= {23'b0, ecfg_tx_reg[8:0]};
         `ESYSRX:      mi_dout[31:0] <= {27'b0, ecfg_rx_reg[4:0]};
         `ESYSCLK:     mi_dout[31:0] <= {24'b0, ecfg_clk_reg[7:0]};
         `ESYSCOREID:  mi_dout[31:0] <= {20'b0, ecfg_coreid_reg[11:0]};
         `ESYSVERSION: mi_dout[31:0] <= {16'b0, ecfg_version_reg[15:0]};
         `ESYSDATAIN:  mi_dout[31:0] <= {21'b0, ecfg_datain_reg[10:0]};
         `ESYSDATAOUT: mi_dout[31:0] <= {21'b0, ecfg_dataout_reg[10:0]};
	 `ESYSDEBUG:   mi_dout[31:0] <= {ecfg_debug_vector[31:8],ecfg_debug_reg[7:0]};
         default:      mi_dout[31:0] <= 32'd0;
       endcase

endmodule // ecfg

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
