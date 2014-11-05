/*
  File: axi_elink_if.v
 
  This file is part of the Parallella FPGA Reference Design.

  Copyright (C) 2013 Adapteva, Inc.
  Contributed by Roman Trogan <support@adapteva.com>

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program (see the file COPYING).  If not, see
  <http://www.gnu.org/licenses/>.
*/
module axi_elink_if (/*AUTOARG*/
   // Outputs
   reset_chip, reset_fpga, emaxi_access_outb, emaxi_write_outb,
   emaxi_datamode_outb, emaxi_ctrlmode_outb, emaxi_dstaddr_outb,
   emaxi_srcaddr_outb, emaxi_data_outb, emaxi_wr_wait_outb,
   esaxi_access_outb, esaxi_write_outb, esaxi_datamode_outb,
   esaxi_ctrlmode_outb, esaxi_dstaddr_outb, esaxi_srcaddr_outb,
   esaxi_data_outb, esaxi_wr_wait_outb, esaxi_rd_wait_outb,
   elink_access_outb, elink_write_outb, elink_datamode_outb,
   elink_ctrlmode_outb, elink_dstaddr_outb, elink_srcaddr_outb,
   elink_data_outb, elink_wr_wait_outb, elink_rd_wait_outb,
   elink_disable, elink_cclk_enb, elink_clk_div,
   // Inputs
   eclk, aclk, reset, emaxi_access_inb, emaxi_write_inb,
   emaxi_datamode_inb, emaxi_ctrlmode_inb, emaxi_dstaddr_inb,
   emaxi_srcaddr_inb, emaxi_data_inb, emaxi_wr_wait_inb,
   emaxi_rd_wait_inb, esaxi_access_inb, esaxi_write_inb,
   esaxi_datamode_inb, esaxi_ctrlmode_inb, esaxi_dstaddr_inb,
   esaxi_srcaddr_inb, esaxi_data_inb, esaxi_wr_wait_inb,
   esaxi_rd_wait_inb, elink_access_inb, elink_write_inb,
   elink_datamode_inb, elink_ctrlmode_inb, elink_dstaddr_inb,
   elink_srcaddr_inb, elink_data_inb, elink_wr_wait_inb,
   elink_rd_wait_inb
   );

   //#########
   //# Inputs
   //#########

   input         eclk;
   input         aclk;
   input 	 reset;     

   //##############################
   //# From axi_master
   //##############################
   input 	 emaxi_access_inb;
   input 	 emaxi_write_inb;
   input [1:0] 	 emaxi_datamode_inb;
   input [3:0] 	 emaxi_ctrlmode_inb;
   input [31:0]  emaxi_dstaddr_inb;
   input [31:0]  emaxi_srcaddr_inb;
   input [31:0]  emaxi_data_inb;  
   input 	 emaxi_wr_wait_inb;  
   input 	 emaxi_rd_wait_inb; 
   
   //##############################
   //# From axi_slave
   //##############################
   input 	 esaxi_access_inb;
   input 	 esaxi_write_inb;
   input [1:0] 	 esaxi_datamode_inb;
   input [3:0] 	 esaxi_ctrlmode_inb;
   input [31:0]  esaxi_dstaddr_inb;
   input [31:0]  esaxi_srcaddr_inb;
   input [31:0]  esaxi_data_inb;  
   input 	 esaxi_wr_wait_inb;  
   input 	 esaxi_rd_wait_inb; 

   //##############################
   //# From elink
   //##############################
   input 	 elink_access_inb;
   input 	 elink_write_inb;
   input [1:0] 	 elink_datamode_inb;
   input [3:0] 	 elink_ctrlmode_inb;
   input [31:0]  elink_dstaddr_inb;
   input [31:0]  elink_srcaddr_inb;
   input [31:0]  elink_data_inb;  
   input 	 elink_wr_wait_inb;  
   input 	 elink_rd_wait_inb; 
   
   //##########
   //# Outputs
   //##########

   output 	 reset_chip;
   output 	 reset_fpga;

   //##############################
   //# To axi_master
   //##############################
   output 	 emaxi_access_outb;
   output 	 emaxi_write_outb;
   output [1:0]  emaxi_datamode_outb;
   output [3:0]  emaxi_ctrlmode_outb;
   output [31:0] emaxi_dstaddr_outb;
   output [31:0] emaxi_srcaddr_outb;
   output [31:0] emaxi_data_outb;   
   output 	 emaxi_wr_wait_outb; 

   //##############################
   //# To axi_slave
   //##############################
   output 	 esaxi_access_outb;
   output 	 esaxi_write_outb;
   output [1:0]  esaxi_datamode_outb;
   output [3:0]  esaxi_ctrlmode_outb;
   output [31:0] esaxi_dstaddr_outb;
   output [31:0] esaxi_srcaddr_outb;
   output [31:0] esaxi_data_outb;   
   output 	 esaxi_wr_wait_outb; 
   output 	 esaxi_rd_wait_outb; 
   
   //##############################
   //# To elink
   //##############################
   output 	 elink_access_outb;
   output 	 elink_write_outb;
   output [1:0]  elink_datamode_outb;
   output [3:0]  elink_ctrlmode_outb;
   output [31:0] elink_dstaddr_outb;
   output [31:0] elink_srcaddr_outb;
   output [31:0] elink_data_outb;   
   output 	 elink_wr_wait_outb; 
   output 	 elink_rd_wait_outb; 
   // controls
   output    elink_disable;
   output    elink_cclk_enb;
   output [1:0] elink_clk_div;

   /*AUTOINPUT*/
   /*AUTOWIRE*/

   //#########
   //# Regs
   //#########
   reg 		 esaxi_access_en;
   
   
   //#########
   //# Wires
   //#########
   wire 	 emaxi_sel;
   wire 	 route_to_slave;

   wire 	 axi_access_in;
   wire 	 axi_write_in;
   wire [1:0] 	 axi_datamode_in;
   wire [3:0] 	 axi_ctrlmode_in;
   wire [31:0] 	 axi_dstaddr_in;
   wire [31:0] 	 axi_srcaddr_in;
   wire [31:0] 	 axi_data_in;   
   wire 	 axi_wr_wait_in; 
   wire 	 axi_rd_wait_in; 

   wire 	 axi_access_out;
   wire 	 axi_write_out;
   wire [1:0] 	 axi_datamode_out;
   wire [3:0] 	 axi_ctrlmode_out;
   wire [31:0] 	 axi_dstaddr_out;
   wire [31:0] 	 axi_srcaddr_out;
   wire [31:0] 	 axi_data_out;   
   wire 	 axi_wr_wait_out; 
   wire 	 axi_rd_wait_out; 


   //###################################
   //# FPGACFG Instantiation
   //###################################

   /*fpgacfg AUTO_TEMPLATE (.elink_\(.*\)_in  (elink_\1_inb[]),
                            .elink_\(.*\)_out (elink_\1_outb[]),
                            .axi_\(.*\)_in    (axi_\1_in[]),
                            .axi_\(.*\)_out   (axi_\1_out[]),
                                 );
    */

   fpgacfg fpgacfg
     (/*AUTOINST*/
      // Outputs
      .reset_chip                       (reset_chip),
      .reset_fpga                       (reset_fpga),
      .elink_access_out                 (elink_access_outb),     // Templated
      .elink_write_out                  (elink_write_outb),      // Templated
      .elink_datamode_out               (elink_datamode_outb[1:0]), // Templated
      .elink_ctrlmode_out               (elink_ctrlmode_outb[3:0]), // Templated
      .elink_dstaddr_out                (elink_dstaddr_outb[31:0]), // Templated
      .elink_srcaddr_out                (elink_srcaddr_outb[31:0]), // Templated
      .elink_data_out                   (elink_data_outb[31:0]), // Templated
      .elink_wr_wait_out                (elink_wr_wait_outb),    // Templated
      .elink_rd_wait_out                (elink_rd_wait_outb),    // Templated
      .elink_disable                    (elink_disable),
      .elink_cclk_enb                   (elink_cclk_enb),
      .elink_clk_div                    (elink_clk_div[1:0]),
      .axi_access_out                   (axi_access_out),        // Templated
      .axi_write_out                    (axi_write_out),         // Templated
      .axi_datamode_out                 (axi_datamode_out[1:0]), // Templated
      .axi_ctrlmode_out                 (axi_ctrlmode_out[3:0]), // Templated
      .axi_dstaddr_out                  (axi_dstaddr_out[31:0]), // Templated
      .axi_srcaddr_out                  (axi_srcaddr_out[31:0]), // Templated
      .axi_data_out                     (axi_data_out[31:0]),    // Templated
      .axi_wr_wait_out                  (axi_wr_wait_out),       // Templated
      .axi_rd_wait_out                  (axi_rd_wait_out),       // Templated
      // Inputs
      .eclk                             (eclk),
      .aclk                             (aclk),
      .reset                            (reset),
      .elink_access_in                  (elink_access_inb),      // Templated
      .elink_write_in                   (elink_write_inb),       // Templated
      .elink_datamode_in                (elink_datamode_inb[1:0]), // Templated
      .elink_ctrlmode_in                (elink_ctrlmode_inb[3:0]), // Templated
      .elink_dstaddr_in                 (elink_dstaddr_inb[31:0]), // Templated
      .elink_srcaddr_in                 (elink_srcaddr_inb[31:0]), // Templated
      .elink_data_in                    (elink_data_inb[31:0]),  // Templated
      .elink_wr_wait_in                 (elink_wr_wait_inb),     // Templated
      .elink_rd_wait_in                 (elink_rd_wait_inb),     // Templated
      .axi_access_in                    (axi_access_in),         // Templated
      .axi_write_in                     (axi_write_in),          // Templated
      .axi_datamode_in                  (axi_datamode_in[1:0]),  // Templated
      .axi_ctrlmode_in                  (axi_ctrlmode_in[3:0]),  // Templated
      .axi_dstaddr_in                   (axi_dstaddr_in[31:0]),  // Templated
      .axi_srcaddr_in                   (axi_srcaddr_in[31:0]),  // Templated
      .axi_data_in                      (axi_data_in[31:0]),     // Templated
      .axi_wr_wait_in                   (axi_wr_wait_in),        // Templated
      .axi_rd_wait_in                   (axi_rd_wait_in));        // Templated
      
   //####################################
   //# Transactions from- AXI to- ELINK
   //####################################

   //# arbitration
   always @ (posedge eclk or posedge reset)
     if(reset)
       esaxi_access_en <= 1'b0;
     else
       esaxi_access_en <= ~esaxi_access_en;
   
   assign esaxi_wr_wait_outb = emaxi_access_inb & ~esaxi_access_en |
			       axi_wr_wait_out;
   assign esaxi_rd_wait_outb = emaxi_access_inb & ~esaxi_access_en |
			       axi_rd_wait_out;

   assign emaxi_wr_wait_outb = esaxi_access_inb & esaxi_access_en |
			       axi_wr_wait_out;

   assign emaxi_sel = emaxi_access_inb & ~emaxi_wr_wait_outb;

   //# selection mux
   assign axi_access_in        = emaxi_access_inb | esaxi_access_inb;
   assign axi_write_in         = emaxi_sel ? emaxi_write_inb : 
			                     esaxi_write_inb;
   assign axi_datamode_in[1:0] = emaxi_sel ? emaxi_datamode_inb[1:0]:
				             esaxi_datamode_inb[1:0];
   assign axi_ctrlmode_in[3:0] = emaxi_sel ? emaxi_ctrlmode_inb[3:0]:
				             esaxi_ctrlmode_inb[3:0];
   assign axi_dstaddr_in[31:0] = emaxi_sel ? emaxi_dstaddr_inb[31:0]:
				             esaxi_dstaddr_inb[31:0];
   assign axi_srcaddr_in[31:0] = emaxi_sel ? emaxi_srcaddr_inb[31:0]:
				             esaxi_srcaddr_inb[31:0];
   assign axi_data_in[31:0]    = emaxi_sel ? emaxi_data_inb[31:0]:
				             esaxi_data_inb[31:0];   
   
   //####################################
   //# Transactions from- ELINK to- AXI
   //####################################

   //# AXI Slave port has a predefined read source address of `AXI_COORD
   assign route_to_slave = (axi_dstaddr_out[31:20] == `AXI_COORD);

   assign esaxi_access_outb = axi_access_out &  route_to_slave;
   assign emaxi_access_outb = axi_access_out & ~route_to_slave;

   assign esaxi_write_outb         = axi_write_out;
   assign esaxi_datamode_outb[1:0] = axi_datamode_out[1:0];
   assign esaxi_ctrlmode_outb[3:0] = axi_ctrlmode_out[3:0];
   assign esaxi_dstaddr_outb[31:0] = axi_dstaddr_out[31:0];
   assign esaxi_srcaddr_outb[31:0] = axi_srcaddr_out[31:0];
   assign esaxi_data_outb[31:0]    = axi_data_out[31:0];   
   
   assign emaxi_write_outb         = axi_write_out;
   assign emaxi_datamode_outb[1:0] = axi_datamode_out[1:0];
   assign emaxi_ctrlmode_outb[3:0] = axi_ctrlmode_out[3:0];
   assign emaxi_dstaddr_outb[31:0] = axi_dstaddr_out[31:0];
   assign emaxi_srcaddr_outb[31:0] = axi_srcaddr_out[31:0];
   assign emaxi_data_outb[31:0]    = axi_data_out[31:0];   
   
   assign axi_wr_wait_in = route_to_slave & esaxi_wr_wait_inb |
			  ~route_to_slave & emaxi_wr_wait_inb;
   assign axi_rd_wait_in = route_to_slave & esaxi_rd_wait_inb |
			  ~route_to_slave & emaxi_rd_wait_inb;
   
endmodule // axi_elink_if

    // Local Variables:
    // verilog-library-directories:("." "../elink" "../parallella-I")
    // End:
