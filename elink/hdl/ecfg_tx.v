/*
 ########################################################################
 ELINK CONFIGURATION REGISTER FILE
 ########################################################################
 
 */

module ecfg_tx (/*AUTOARG*/
   // Outputs
   mi_dout, ecfg_tx_enable, ecfg_tx_mmu_enable, ecfg_tx_gpio_enable,
   ecfg_tx_tp_enable, ecfg_tx_ctrlmode, ecfg_tx_ctrlmode_bp,
   ecfg_dataout,
   // Inputs
   reset, mi_clk, mi_en, mi_we, mi_addr, mi_din, ecfg_tx_debug
   );

   /******************************/
   /*Compile Time Parameters     */
   /******************************/
   parameter RFAW            = 5;         // 32 registers for now
   parameter GROUP           = 4'h0;
   
   /******************************/
   /*HARDWARE RESET (EXTERNAL)   */
   /******************************/
   input 	reset;             // ecfg registers reset only by "hard reset"
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
   //tx
   output 	 ecfg_tx_enable;       // enable signal for TX  
   output 	 ecfg_tx_mmu_enable;   // enables MMU on transmit path  
   output 	 ecfg_tx_gpio_enable;  // forces TX output pins to constants
   output        ecfg_tx_tp_enable;    // enables 1/0 pattern on transmit  
   output [3:0]  ecfg_tx_ctrlmode;     // value for emesh ctrlmode tag
   output        ecfg_tx_ctrlmode_bp;  // bypass value for emesh ctrlmode tag
   output [8:0]  ecfg_dataout;         // data for elink outputs
   input [15:0]  ecfg_tx_debug;        // etx debug signals
   
   /*------------------------CODE BODY---------------------------------------*/
   
   //registers

   reg [8:0] 	ecfg_tx_reg;
   reg [8:0] 	ecfg_dataout_reg;
   reg [2:0] 	ecfg_tx_debug_reg;
   reg [31:0] 	mi_dout;
   
   //wires
   wire 	ecfg_read;
   wire 	ecfg_write;
   wire 	ecfg_tx_write;
   wire 	ecfg_dataout_write;
   
   /*****************************/
   /*ADDRESS DECODE LOGIC       */
   /*****************************/

   //read/write decode
   assign ecfg_write  = mi_en &  mi_we & (mi_addr[19:16]==GROUP);
   assign ecfg_read   = mi_en & ~mi_we & (mi_addr[19:16]==GROUP);   

   //Config write enables
   assign ecfg_tx_write       = ecfg_write & (mi_addr[RFAW+1:2]==`ELTX);
   assign ecfg_dataout_write  = ecfg_write & (mi_addr[RFAW+1:2]==`ELDATAOUT);
     
   //###########################
   //# TX
   //###########################
   always @ (posedge mi_clk)
     if(reset)
       ecfg_tx_reg[8:0] <= 9'b0;
     else if (ecfg_tx_write)
       ecfg_tx_reg[8:0] <= mi_din[8:0];

   assign ecfg_tx_enable          = ecfg_tx_reg[0];
   assign ecfg_tx_mmu_enable      = ecfg_tx_reg[1];   
   assign ecfg_tx_gpio_enable     = (ecfg_tx_reg[3:2]==2'b01);
   assign ecfg_tx_tp_enable       = (ecfg_tx_reg[3:2]==2'b10);//test clock pattern
   assign ecfg_tx_ctrlmode[3:0]   = ecfg_tx_reg[7:4];
   assign ecfg_tx_ctrlmode_bp     = ecfg_tx_reg[8];
   
   //###########################
   //# DATAOUT
   //###########################
   always @ (posedge mi_clk)
     if(reset)
       ecfg_dataout_reg[8:0] <= 'd0;   
     else if (ecfg_dataout_write)
       ecfg_dataout_reg[8:0] <= mi_din[8:0];

   assign ecfg_dataout[8:0] = ecfg_dataout_reg[8:0];

   //###########################1
   //# DEBUG
   //###########################
   
   always @ (posedge mi_clk)
     if(reset)
       ecfg_tx_debug_reg[2:0] <= 'd0;
     else
       ecfg_tx_debug_reg[2:0] <=ecfg_tx_debug_reg[2:0] | ecfg_tx_debug[2:0];

   //###############################
   //# DATA READBACK MUX
   //###############################

   //Pipelineing readback
   always @ (posedge mi_clk)
     if(ecfg_read)
       case(mi_addr[RFAW+1:2])
         `ELTX:      mi_dout[31:0] <= {23'b0, ecfg_tx_reg[8:0]};
         `ELDATAOUT: mi_dout[31:0] <= {23'b0, ecfg_dataout_reg[8:0]};
	 `ELDEBUG:   mi_dout[31:0] <= {16'b0,ecfg_tx_debug[15:3],ecfg_tx_debug_reg[2:0]};
         default:    mi_dout[31:0] <= 32'd0;
       endcase

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
