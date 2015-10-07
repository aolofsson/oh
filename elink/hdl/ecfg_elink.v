/*
 ########################################################################
 MASTER ENABLE, CLOCKS, CHIP-ID
 ######################################################################## 
 */

`include "elink_regmap.v"

module ecfg_elink (/*AUTOARG*/
   // Outputs
   txwr_gated_access, elink_en, clk_config, e_chipid,
   // Inputs
   txwr_access, txwr_packet, clk, reset
   );

   parameter RFAW             = 6;     // 32 registers for now
   parameter PW               = 104;   // 32 registers for now
   parameter ID               = 12'h000;
   parameter DEFAULT_CHIPID   = 12'h808;
   
   /******************************/
   /*REGISTER ACCESS             */
   /******************************/
   input 	  txwr_access;
   input [PW-1:0] txwr_packet;

   /******************************/
   /*FILTERED WRITE FOR TX FIFO  */
   /******************************/
   output 	  txwr_gated_access;

   /******************************/
   /*Clock/reset                 */
   /******************************/
   input 	  clk;   
   input 	  reset;         // POR "hard reset"

   /******************************/
   /*Outputs                     */
   /******************************/
   output 	 elink_en;         // elink master enable
   output [15:0] clk_config;       // clock settings (for pll)
   output [11:0] e_chipid;         // chip-id for Epiphany   
   
   /*------------------------CODE BODY---------------------------------------*/
   
   //registers
   reg          ecfg_reset_reg;
   reg [15:0] 	ecfg_clk_reg;
   reg [11:0] 	ecfg_chipid_reg;
   reg [31:0] 	mi_dout;
   
   //wires
   wire 	ecfg_read;
   wire 	ecfg_write;
   wire 	ecfg_clk_write;
   wire 	ecfg_chipid_write;
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
   assign ecfg_chipid_write   = ecfg_write & (mi_addr[RFAW+1:2]==`E_CHIPID);
   
   /*****************************/
   /*FILTER ACCESS              */
   /*****************************/
   assign 	txwr_gated_access =  txwr_access & ~(ecfg_reset_write | 
						   ecfg_clk_write   |
                                                   ecfg_chipid_write);
   
   //###########################
   //# RESET REG (ASYNC)
   //###########################
    always @ (posedge clk or posedge reset)
      if(reset)
	ecfg_reset_reg <= 1'b0;         
      else if (ecfg_reset_write)
	ecfg_reset_reg <= mi_din[0];  

   assign elink_en    =~ecfg_reset_reg; //always on, TODO: fix!
     
   //###########################
   //# CCLK/LCLK (PLL)
   //###########################
   //TODO: implement!
    always @ (posedge clk)
     if(reset)
       ecfg_clk_reg[15:0] <= 16'h573;//all clocks on at lowest speed   
     else if (ecfg_clk_write)
       ecfg_clk_reg[15:0] <= mi_din[15:0];

   assign clk_config[15:0] = ecfg_clk_reg[15:0];

   //###########################
   //# CHIPID
   //###########################
   always @ (posedge clk)
     if(reset)
       ecfg_chipid_reg[11:0] <= DEFAULT_CHIPID;
     else if (ecfg_chipid_write)
       ecfg_chipid_reg[11:0] <= mi_din[11:0];   
   
   assign e_chipid[11:0]=ecfg_chipid_reg[5:2];   
    
endmodule // ecfg_elink

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
