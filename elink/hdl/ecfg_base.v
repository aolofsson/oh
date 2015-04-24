/*
 ########################################################################
 ELINK CONFIGURATION REGISTER FILE
 ########################################################################
 
 */

module ecfg_base (/*AUTOARG*/
   // Outputs
   soft_reset, mi_dout, ecfg_clk_settings, colid, rowid,
   // Inputs
   hard_reset, mi_clk, mi_en, mi_we, mi_addr, mi_din
   );

   /******************************/
   /*Compile Time Parameters     */
   /******************************/
   parameter RFAW            = 5;         // 32 registers for now
   parameter DEFAULT_COREID  = 12'h808;   // reset value for ecfg_coreid
   parameter DEFAULT_VERSION = 16'h0000;  // reset value for version
   parameter DEFAULT_CLKDIV  = 4'd7;
   parameter GROUP           = 4'h0;
   

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
   //clocks
   output [15:0] ecfg_clk_settings;    // clock settings
   
   //coreid
   output [3:0]  colid;
   output [3:0]  rowid;
     
   /*------------------------CODE BODY---------------------------------------*/
   
   //registers
   reg          ecfg_reset_reg;
   reg [15:0] 	ecfg_clk_reg;
   reg [11:0] 	ecfg_coreid_reg;
   reg [15:0] 	ecfg_version_reg;
   reg [31:0] 	mi_dout;
   
   //wires
   wire 	ecfg_read;
   wire 	ecfg_write;
   wire 	ecfg_clk_write;
   wire 	ecfg_coreid_write;
   wire 	ecfg_version_write;
   wire 	ecfg_reset_write;
   
   /*****************************/
   /*ADDRESS DECODE LOGIC       */
   /*****************************/

   //read/write decode
   assign ecfg_write  = mi_en &  mi_we & (mi_addr[19:16]==GROUP);
   assign ecfg_read   = mi_en & ~mi_we & (mi_addr[19:16]==GROUP);   

   //Config write enables
   assign ecfg_reset_write    = ecfg_write & (mi_addr[RFAW+1:2]==`ELRESET);
   assign ecfg_clk_write      = ecfg_write & (mi_addr[RFAW+1:2]==`ELCLK);
   assign ecfg_coreid_write   = ecfg_write & (mi_addr[RFAW+1:2]==`ELCOREID);
   assign ecfg_version_write  = ecfg_write & (mi_addr[RFAW+1:2]==`ELVERSION);
   
   //###########################
   //# RESET
   //###########################
    always @ (posedge mi_clk)
      if(hard_reset)
	ecfg_reset_reg <= 1'b0;   
      else if (ecfg_reset_write)
	ecfg_reset_reg <= mi_din[0];  

   assign soft_reset    = ecfg_reset_reg;
     
   //###########################
   //# CCLK/LCLK (PLL)
   //###########################
    always @ (posedge mi_clk)
     if(hard_reset)
       ecfg_clk_reg[15:0] <= 'd0;   
     else if (ecfg_clk_write)
       ecfg_clk_reg[15:0] <= mi_din[15:0];

   assign ecfg_clk_settings[15:0] = ecfg_clk_reg[15:0];
    
   //###########################
   //# COREID
   //###########################
   always @ (posedge mi_clk)
     if(hard_reset)
       ecfg_coreid_reg[11:0] <= DEFAULT_COREID;
     else if (ecfg_coreid_write)
       ecfg_coreid_reg[11:0] <= mi_din[11:0];   
   
   assign colid[3:0]=ecfg_coreid_reg[5:2];   
   assign rowid[3:0]=ecfg_coreid_reg[11:8];
   
  
   //###########################
   //# VERSION
   //###########################
   always @ (posedge mi_clk)
     if(hard_reset)
       ecfg_version_reg[15:0] <= DEFAULT_VERSION;
     else if (ecfg_version_write)
       ecfg_version_reg[15:0] <= mi_din[15:0];   
   
   //###############################
   //# DATA READBACK MUX
   //###############################

   //Pipelineing readback
   always @ (posedge mi_clk)
     if(ecfg_read)
       case(mi_addr[RFAW+1:2])
         `ELRESET:   mi_dout[31:0] <= {31'b0, ecfg_reset_reg};
         `ELCLK:     mi_dout[31:0] <= {24'b0, ecfg_clk_reg[7:0]};
         `ELCOREID:  mi_dout[31:0] <= {20'b0, ecfg_coreid_reg[11:0]};
         `ELVERSION: mi_dout[31:0] <= {16'b0, ecfg_version_reg[15:0]};
         default:    mi_dout[31:0] <= 32'd0;
       endcase

endmodule // ecfg_base

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
