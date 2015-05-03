/*
 ########################################################################
 RESET AND CLOCK CONFIG
 ######################################################################## 
 */

module ecfg_clocks (/*AUTOARG*/
   // Outputs
   txwr_wait, soft_reset, ecfg_clk_settings,
   // Inputs
   txwr_access, txwr_packet, clk, hard_reset
   );

   
   parameter RFAW  = 6;     // 32 registers for now
   parameter PW    = 104;   // 32 registers for now
   parameter ID    = 12'h000;
   
   /******************************/
   /*REGISTER ACCESS             */
   /******************************/
   input 	  txwr_access;
   input [PW-1:0] txwr_packet;
   output 	  txwr_wait;

   /******************************/
   /*Clock/reset                 */
   /******************************/
   input 	  clk;   
   input 	  hard_reset;       // ecfg registers reset only by "hard reset"

   /******************************/
   /*Outputs                     */
   /******************************/
   output 	 soft_reset;       // soft reset output driven by register
   output [15:0] ecfg_clk_settings;    // clock settings (for pll)
   
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


   wire 	mi_en;
   wire [31:0] 	mi_addr;
   wire [31:0] 	mi_din;

   packet2emesh pe2 (
		     // Outputs
		     .access_out	(),
		     .write_out		(mi_we),
		     .datamode_out	(),
		     .ctrlmode_out	(),
		     .dstaddr_out	(mi_addr[31:0]),
		     .data_out		(mi_din[31:0]),
		     .srcaddr_out	(),
		     // Inputs
		     .packet_in		(txwr_packet[PW-1:0])
		     );   
         
   /*****************************/
   /*ADDRESS DECODE LOGIC       */
   /*****************************/
   
   assign mi_en = txwr_access & 
		  (mi_addr[31:20]==ID) &
		  (mi_addr[10:8]==3'h2);
   

   //read/write decode
   assign ecfg_write  = mi_en &  mi_we;
   assign ecfg_read   = mi_en & ~mi_we;   

   //Config write enables
   assign ecfg_reset_write    = ecfg_write & (mi_addr[RFAW+1:2]==`E_RESET);
   assign ecfg_clk_write      = ecfg_write & (mi_addr[RFAW+1:2]==`E_CLK);
  
   
   //###########################
   //# RESET
   //###########################
    always @ (posedge clk or posedge hard_reset)
      if(hard_reset)
	ecfg_reset_reg <= 1'b0;   
      else if (ecfg_reset_write)
	ecfg_reset_reg <= mi_din[0];  

   assign soft_reset    = ecfg_reset_reg;
     
   //###########################
   //# CCLK/LCLK (PLL)
   //###########################
    always @ (posedge clk or posedge hard_reset)
     if(hard_reset)
       ecfg_clk_reg[15:0] <= 'd0;   
     else if (ecfg_clk_write)
       ecfg_clk_reg[15:0] <= mi_din[15:0];

   assign ecfg_clk_settings[15:0] = ecfg_clk_reg[15:0];
    
endmodule // ecfg_base
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:

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
