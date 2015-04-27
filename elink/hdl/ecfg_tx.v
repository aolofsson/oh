/*
 ########################################################################
 ELINK CONFIGURATION REGISTER FILE
 ########################################################################
 
 */
module ecfg_tx (/*AUTOARG*/
   // Outputs
   mi_dout, ecfg_tx_enable, ecfg_tx_mmu_enable, ecfg_tx_gpio_enable,
   ecfg_tx_tp_enable, ecfg_tx_ctrlmode, ecfg_tx_ctrlmode_bp,
   ecfg_tx_remap_enable, ecfg_dataout, ecfg_access, ecfg_packet,
   // Inputs
   reset, mi_clk, mi_en, mi_we, mi_addr, mi_din, ecfg_tx_debug
   );

   /******************************/
   /*Compile Time Parameters     */
   /******************************/
   parameter PW              = 104;   
   parameter RFAW            = 4;
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
   output 	   ecfg_tx_enable;       // enable signal for TX  
   output 	   ecfg_tx_mmu_enable;   // enables MMU on transmit path  
   output 	   ecfg_tx_gpio_enable;  // forces TX output pins to constants
   output          ecfg_tx_tp_enable;    // enables 1/0 pattern on transmit  
   output [3:0]    ecfg_tx_ctrlmode;     // value for emesh ctrlmode tag
   output          ecfg_tx_ctrlmode_bp;  // bypass value for emesh ctrlmode tag
   output 	   ecfg_tx_remap_enable; // enable address remapping
   output [8:0]    ecfg_dataout;         // data for elink outputs
   input [15:0]    ecfg_tx_debug;        // etx debug signals
   output          ecfg_access;          // direct test access  
   output [PW-1:0] ecfg_packet;          //packet for direct test access
	   
   /*------------------------CODE BODY---------------------------------------*/
   
   //registers

   reg [10:0] 	   ecfg_tx_config_reg;
   reg [8:0] 	   ecfg_tx_gpio_reg;
   reg [15:0] 	   ecfg_tx_status_reg;
   reg [8:0] 	   ecfg_tx_test_reg;
   reg [31:0] 	   ecfg_tx_data_reg;
   reg [31:0] 	   ecfg_tx_dstaddr_reg;
   reg [31:0] 	   ecfg_tx_srcaddr_reg;
   reg [31:0] 	   mi_dout;
   reg 		   ecfg_access;
   
   //wires
   wire 	ecfg_read;
   wire 	ecfg_write;
   wire 	ecfg_tx_config_write;
   wire 	ecfg_tx_gpio_write;
   wire 	ecfg_tx_test_write;
   wire 	ecfg_tx_addr_write;
   wire 	ecfg_tx_data_write;
   wire 	loop_mode;
   
   /*****************************/
   /*ADDRESS DECODE LOGIC       */
   /*****************************/

   //read/write decode
   assign ecfg_write  = mi_en &  mi_we & (mi_addr[19:16]==GROUP);
   assign ecfg_read   = mi_en & ~mi_we & (mi_addr[19:16]==GROUP);   

   //Config write enables
   assign ecfg_tx_config_write  = ecfg_write & (mi_addr[RFAW+1:2]==`ELTXCFG);
   assign ecfg_tx_status_write  = ecfg_write & (mi_addr[RFAW+1:2]==`ELTXSTATUS);
   assign ecfg_tx_gpio_write    = ecfg_write & (mi_addr[RFAW+1:2]==`ELTXGPIO);
   assign ecfg_tx_test_write    = ecfg_write & (mi_addr[RFAW+1:2]==`ELTXTEST);
   assign ecfg_tx_dstaddr_write = ecfg_write & (mi_addr[RFAW+1:2]==`ELTXDSTADDR);
   assign ecfg_tx_data_write    = ecfg_write & (mi_addr[RFAW+1:2]==`ELTXDATA);
   assign ecfg_tx_srcaddr_write = ecfg_write & (mi_addr[RFAW+1:2]==`ELTXSRCADDR);
     
   //###########################
   //# TX CONFIG
   //###########################
   always @ (posedge mi_clk)
     if(reset)
       ecfg_tx_config_reg[10:0] <= 11'b0;
     else if (ecfg_tx_config_write)
       ecfg_tx_config_reg[10:0] <= mi_din[10:0];

   assign ecfg_tx_enable          = ecfg_tx_config_reg[0];
   assign ecfg_tx_mmu_enable      = ecfg_tx_config_reg[1];   
   assign ecfg_tx_remap_enable    = ecfg_tx_config_reg[3:2]==2'b01;
   assign ecfg_tx_ctrlmode[3:0]   = ecfg_tx_config_reg[7:4];
   assign ecfg_tx_ctrlmode_bp     = ecfg_tx_config_reg[8];
   assign ecfg_tx_gpio_enable     = (ecfg_tx_config_reg[10:9]==2'b01);
   assign ecfg_tx_tp_enable       = (ecfg_tx_config_reg[10:9]==2'b10);//test pattern
   //###########################1
   //# STATUS REGISTER
   //###########################
   
   always @ (posedge mi_clk)
     if(reset)
       ecfg_tx_status_reg[15:0] <= 'd0;
     else if(ecfg_tx_status_write)
       ecfg_tx_status_reg[15:0] <= mi_din[15:0];
     else
       begin
	  ecfg_tx_status_reg[2:0]  <= ecfg_tx_status_reg[2:0] | ecfg_tx_debug[2:0];
	  ecfg_tx_status_reg[15:3] <= ecfg_tx_debug[15:3];
       end

   //###########################
   //# GPIO DATA
   //###########################
   always @ (posedge mi_clk)
     if(reset)
       ecfg_tx_gpio_reg[8:0] <= 'd0;   
     else if (ecfg_tx_gpio_write)
       ecfg_tx_gpio_reg[8:0] <= mi_din[8:0];

   assign ecfg_dataout[8:0] = ecfg_tx_gpio_reg[8:0];

   //###########################
   //# TEST REGISTER
   //###########################
   //0   = active/not active
   //1   = write
   //3:2 = datamode
   //7:4 = ctrlmode
   //8   = continuous-loop mode

   always @ (posedge mi_clk)
     if(reset)
       ecfg_tx_test_reg[8:0] <= 'd0;   
     else if (ecfg_tx_test_write)
       ecfg_tx_test_reg[8:0] <= mi_din[8:0];

   assign loop_mode = ecfg_tx_test_reg[8];
   
   //###########################
   //# DSTADDR REGISTER
   //###########################
   always @ (posedge mi_clk)
     if(reset)
       ecfg_tx_dstaddr_reg[31:0] <= 'd0;   
     else if (ecfg_tx_dstaddr_write)
       ecfg_tx_dstaddr_reg[31:0] <= mi_din[31:0];

   //###########################
   //# DATA REGISTER
   //###########################
   always @ (posedge mi_clk)
     if(reset)
       ecfg_tx_data_reg[31:0] <= 'd0;   
     else if (ecfg_tx_data_write)
       ecfg_tx_data_reg[31:0] <= mi_din[31:0];

   //###########################
   //# SRCADDR REGISTER
   //###########################
   always @ (posedge mi_clk)
     if(reset)
       ecfg_tx_srcaddr_reg[31:0] <= 'd0;   
     else if (ecfg_tx_srcaddr_write)
       ecfg_tx_srcaddr_reg[31:0] <= mi_din[31:0];
   
   
   //###########################
   //# CREATING TEST PACKET
   //###########################
   assign ecfg_packet[PW-1:0]={ecfg_tx_srcaddr_reg[31:0],
			       ecfg_tx_data_reg[31:0],
			       ecfg_tx_srcaddr_reg[31:0],
			       ecfg_tx_dstaddr_reg[31:0],
			       ecfg_tx_test_reg[7:0]
			       };
   
   always @ (posedge mi_clk or posedge reset)
     if(reset)
       ecfg_access <= 0;
     else if(ecfg_tx_test_write & mi_din[0])
       ecfg_access <= 1;
     else if(loop_mode)
       ecfg_access <= 1;
     else
       ecfg_access <= 0;
             
   //###############################
   //# DATA READBACK MUX
   //###############################

   //Pipelineing readback
   always @ (posedge mi_clk)
     if(ecfg_read)
       case(mi_addr[RFAW+1:2])
         `ELTXCFG:    mi_dout[31:0] <= {21'b0, ecfg_tx_config_reg[10:0]};
         `ELTXGPIO:   mi_dout[31:0] <= {23'b0, ecfg_tx_gpio_reg[8:0]};
	 `ELTXSTATUS: mi_dout[31:0] <= {16'b0, ecfg_tx_status_reg[15:0]};
         default:     mi_dout[31:0] <= 32'd0;
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
