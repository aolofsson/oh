/*
 ########################################################################
 ELINK CONFIGURATION REGISTER FILE
 ########################################################################
 
 */

module ecfg_rx (/*AUTOARG*/
   // Outputs
   mi_dout, ecfg_rx_enable, ecfg_rx_mmu_enable,
   // Inputs
   reset, mi_clk, mi_en, mi_we, mi_addr, mi_din, ecfg_rx_datain,
   ecfg_rx_debug
   );

   /******************************/
   /*Compile Time Parameters     */
   /******************************/
   parameter RFAW            = 5;         // 32 registers for now
   
   /******************************/
   /*HARDWARE RESET (EXTERNAL)   */
   /******************************/
   input 	reset;       // ecfg registers reset only by "hard reset"

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
   /*CONFIG SIGNALS             */
   /*****************************/
   //rx
   output 	 ecfg_rx_enable;       // enable signal for rx  
   output 	 ecfg_rx_mmu_enable;   // enables MMU on rx path  
   input [8:0] 	 ecfg_rx_datain;       // frame and data inputs        
   input [15:0]  ecfg_rx_debug;        // erx debug signals
   
   /*------------------------CODE BODY---------------------------------------*/
   
   //registers
   reg [4:0] 	ecfg_rx_reg;
   reg [8:0] 	ecfg_datain_reg;
   reg [8:0] 	ecfg_datain_sync;
   reg [2:0] 	ecfg_rx_debug_reg;
   reg [31:0] 	mi_dout;
   
   //wires
   wire 	ecfg_read;
   wire 	ecfg_write;
   wire 	ecfg_rx_write;
   
   /*****************************/
   /*ADDRESS DECODE LOGIC       */
   /*****************************/

   //read/write decode
   assign ecfg_write  = mi_en &  mi_we;
   assign ecfg_read   = mi_en & ~mi_we;   

   //Config write enables
   assign ecfg_rx_write       = ecfg_write & (mi_addr[RFAW+1:2]==`ELRX);
   

   //###########################
   //# RXCFG
   //###########################
   always @ (posedge mi_clk)
     if(reset)
       ecfg_rx_reg[4:0] <= 5'b0;
     else if (ecfg_rx_write)
       ecfg_rx_reg[4:0] <= mi_din[4:0];

   assign ecfg_rx_enable        = ecfg_rx_reg[0];
   assign ecfg_rx_mmu_enable    = ecfg_rx_reg[1];   
   
   //###########################
   //# DATAIN (synchronized)
   //###########################
   always @ (posedge mi_clk)
     begin
	ecfg_datain_sync[8:0] <= ecfg_rx_datain[8:0];
	ecfg_datain_reg[8:0]  <= ecfg_datain_sync[8:0];
     end
 
   //###########################1
   //# DEBUG
   //###########################
   
   always @ (posedge mi_clk)
     if(reset)
       ecfg_rx_debug_reg[2:0] <= 'd0;
     else
       ecfg_rx_debug_reg[2:0]  <=ecfg_rx_debug_reg[2:0] | ecfg_rx_debug[2:0];
   
   //###############################
   //# DATA READBACK MUX
   //###############################

   //Pipelineing readback
   always @ (posedge mi_clk)
     if(ecfg_read)
       case(mi_addr[RFAW+1:2])
         `ELRX:      mi_dout[31:0] <= {27'b0, ecfg_rx_reg[4:0]};
         `ELDATAIN:  mi_dout[31:0] <= {23'b0, ecfg_datain_reg[8:0]};
         default:    mi_dout[31:0] <= 32'd0;
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
