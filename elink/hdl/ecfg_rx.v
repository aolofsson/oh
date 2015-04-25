/*
 ########################################################################
 ELINK CONFIGURATION REGISTER FILE
 ########################################################################
 
 */

module ecfg_rx (/*AUTOARG*/
   // Outputs
   mi_dout, rx_enable, mmu_enable, remap_mode, remap_base,
   remap_pattern, remap_sel,
   // Inputs
   reset, mi_clk, mi_en, mi_we, mi_addr, mi_din, gpio_datain,
   debug_vector
   );

   /******************************/
   /*Compile Time Parameters     */
   /******************************/
   parameter RFAW            = 5;         // 32 registers for now
   parameter GROUP           = 4'h0;
   
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
   output 	 rx_enable;    // enable signal for rx  
   output 	 mmu_enable;   // enables MMU on rx path  
   input [8:0] 	 gpio_datain;  // frame and data inputs        
   input [15:0]  debug_vector; // erx debug signals
   output [1:0]  remap_mode;   //remap mode 
   output [31:0] remap_base;   //base for dynamic remap 
   output [11:0] remap_pattern;//patter for static remap
   output [11:0] remap_sel;    //selects for static remap 
   
   /*------------------------CODE BODY---------------------------------------*/
   
   //registers
   reg [31:0] 	ecfg_rx_reg;
   reg [31:0] 	ecfg_base_reg;
   reg [8:0] 	ecfg_datain_reg;
   reg [8:0] 	ecfg_datain_sync;
   reg [2:0] 	ecfg_rx_debug_reg;
   reg [31:0] 	mi_dout;
   
   //wires
   wire 	ecfg_read;
   wire 	ecfg_write;
   wire 	ecfg_rx_write;
   wire  	ecfg_base_write;
   wire  	ecfg_remap_write;
   
   /*****************************/
   /*ADDRESS DECODE LOGIC       */
   /*****************************/

   //read/write decode
   assign ecfg_write  = mi_en &  mi_we & (mi_addr[19:15]=={GROUP,1'b0});
   assign ecfg_read   = mi_en & ~mi_we & (mi_addr[19:15]=={GROUP,1'b0});   

   //Config write enables
   assign ecfg_rx_write      = ecfg_write & (mi_addr[RFAW+1:2]==`ELRXCFG);
   assign ecfg_base_write    = ecfg_write & (mi_addr[RFAW+1:2]==`ELRXBASE);
   
   //###########################
   //# RXCFG
   //###########################
   always @ (posedge mi_clk)
     if(reset)
       ecfg_rx_reg[31:0] <= 'b0;
     else if (ecfg_rx_write)
       ecfg_rx_reg[31:0] <= mi_din[31:0];

   assign rx_enable           = ecfg_rx_reg[0];
   assign mmu_enable          = ecfg_rx_reg[1];
   assign remap_mode[1:0]     = ecfg_rx_reg[3:2];
   assign remap_sel[11:0]     = ecfg_rx_reg[15:4];
   assign remap_pattern[11:0] = ecfg_rx_reg[27:16];
   
   //###########################
   //# DATAIN (synchronized)
   //###########################
   always @ (posedge mi_clk)
     begin
	ecfg_datain_sync[8:0] <= gpio_datain[8:0];
	ecfg_datain_reg[8:0]  <= ecfg_datain_sync[8:0];
     end
 
   //###########################1
   //# DEBUG
   //###########################
   
   always @ (posedge mi_clk)
     if(reset)
       ecfg_rx_debug_reg[2:0] <= 'd0;
     else
       ecfg_rx_debug_reg[2:0]  <=ecfg_rx_debug_reg[2:0] | debug_vector[2:0];

   //###########################1
   //# DYNAMIC REMAP BASE
   //###########################
   always @ (posedge mi_clk)
     if(reset)
       ecfg_base_reg[31:0] <='d0;
     else if (ecfg_base_write)
       ecfg_base_reg[31:0] <=mi_din[31:0];

   assign remap_base[31:0] = ecfg_base_reg[31:0];
   
   //###############################
   //# DATA READBACK MUX
   //###############################

   //Pipelineing readback
   always @ (posedge mi_clk)
     if(ecfg_read)
       case(mi_addr[RFAW+1:2])
         `ELRXCFG:   mi_dout[31:0] <= {ecfg_rx_reg[31:0]};
         `ELRXDIN:   mi_dout[31:0] <= {23'b0, ecfg_datain_reg[8:0]};
	 `ELRXBASE:  mi_dout[31:0] <= {ecfg_base_reg[31:0]};
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
