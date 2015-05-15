module etx_fifo(/*AUTOARG*/
   // Outputs
   txrd_wait, txwr_wait, txrr_wait, etx_cfg_access, etx_cfg_packet,
   txrd_fifo_access, txrd_fifo_packet, txrr_fifo_access,
   txrr_fifo_packet, txwr_fifo_access, txwr_fifo_packet,
   // Inputs
   etx_reset, sys_reset, sys_clk, tx_lclk_div4, txrd_access,
   txrd_packet, txwr_access, txwr_packet, txrr_access, txrr_packet,
   etx_cfg_wait, txrd_fifo_wait, txrr_fifo_wait, txwr_fifo_wait
   );

   parameter AW      = 32;
   parameter DW      = 32;
   parameter PW      = 104;
   parameter RFAW    = 6;
   parameter ID      = 12'h000;
   
   //Clocks,reset,config
   input          etx_reset;
   input          sys_reset;
   input 	  sys_clk;   
   input 	  tx_lclk_div4;	  // slow speed parallel clock
      
   //Read Request Channel Input
   input 	  txrd_access;
   input [PW-1:0] txrd_packet;
   output 	  txrd_wait;
   
   //Write Channel Input
   input 	  txwr_access;
   input [PW-1:0] txwr_packet;
   output 	  txwr_wait;
   
   //Read Response Channel Input
   input 	  txrr_access;
   input [PW-1:0] txrr_packet;
   output 	  txrr_wait;

   //Configuration Interface (for ERX)
   output 	   etx_cfg_access;
   output [PW-1:0] etx_cfg_packet;
   input 	   etx_cfg_wait;
   
   output 	   txrd_fifo_access;
   output [PW-1:0] txrd_fifo_packet;
   input 	   txrd_fifo_wait;
   
   output 	   txrr_fifo_access;
   output [PW-1:0] txrr_fifo_packet;
   input 	   txrr_fifo_wait;
   
   output 	   txwr_fifo_access;
   output [PW-1:0] txwr_fifo_packet;
   input 	   txwr_fifo_wait;


   
   /*AUTOOUTPUT*/
   /*AUTOINPUT*/
   /*AUTOWIRE*/

   
   /************************************************************/
   /*FIFOs                                                     */
   /************************************************************/
   //TODO: Minimize depth and width

   /*fifo_cdc  AUTO_TEMPLATE (
			       // Outputs
                               .access_out (@"(substring vl-cell-name  0 4)"_fifo_access),
			       .packet_out (@"(substring vl-cell-name  0 4)"_fifo_packet[PW-1:0]),
                               .wait_out   (@"(substring vl-cell-name  0 4)"_wait),
                               .wait_in   (@"(substring vl-cell-name  0 4)"_fifo_wait),
    			       .clk_out	   (tx_lclk_div4),
                               .clk_in	   (sys_clk),
                               .access_in  (@"(substring vl-cell-name  0 4)"_access),
                               .rd_en      (@"(substring vl-cell-name  0 4)"_fifo_read),
			       .reset_in   (sys_reset),
                               .reset_out  (etx_reset),
                               .packet_in  (@"(substring vl-cell-name  0 4)"_packet[PW-1:0]),
    );
    */

   //Write fifo (from slave)
   fifo_cdc #(.WIDTH(104), .DEPTH(16)) txwr_fifo(
			                  /*AUTOINST*/
						 // Outputs
						 .wait_out		(txwr_wait),	 // Templated
						 .access_out		(txwr_fifo_access), // Templated
						 .packet_out		(txwr_fifo_packet[PW-1:0]), // Templated
						 // Inputs
						 .clk_in		(sys_clk),	 // Templated
						 .reset_in		(sys_reset),	 // Templated
						 .access_in		(txwr_access),	 // Templated
						 .packet_in		(txwr_packet[PW-1:0]), // Templated
						 .clk_out		(tx_lclk_div4),	 // Templated
						 .reset_out		(etx_reset),	 // Templated
						 .wait_in		(txwr_fifo_wait)); // Templated
   
   //Read request fifo (from slave)
   fifo_cdc  #(.WIDTH(104), .DEPTH(16)) txrd_fifo(
				             /*AUTOINST*/
						  // Outputs
						  .wait_out		(txrd_wait),	 // Templated
						  .access_out		(txrd_fifo_access), // Templated
						  .packet_out		(txrd_fifo_packet[PW-1:0]), // Templated
						  // Inputs
						  .clk_in		(sys_clk),	 // Templated
						  .reset_in		(sys_reset),	 // Templated
						  .access_in		(txrd_access),	 // Templated
						  .packet_in		(txrd_packet[PW-1:0]), // Templated
						  .clk_out		(tx_lclk_div4),	 // Templated
						  .reset_out		(etx_reset),	 // Templated
						  .wait_in		(txrd_fifo_wait)); // Templated
   

  
   //Read response fifo (from master)
   fifo_cdc  #(.WIDTH(104), .DEPTH(5)) txrr_fifo(
					    
					     /*AUTOINST*/
						 // Outputs
						 .wait_out		(txrr_wait),	 // Templated
						 .access_out		(txrr_fifo_access), // Templated
						 .packet_out		(txrr_fifo_packet[PW-1:0]), // Templated
						 // Inputs
						 .clk_in		(sys_clk),	 // Templated
						 .reset_in		(sys_reset),	 // Templated
						 .access_in		(txrr_access),	 // Templated
						 .packet_in		(txrr_packet[PW-1:0]), // Templated
						 .clk_out		(tx_lclk_div4),	 // Templated
						 .reset_out		(etx_reset),	 // Templated
						 .wait_in		(txrr_fifo_wait)); // Templated
  

   
endmodule // elink
// Local Variables:
// verilog-library-directories:("." "../../emmu/hdl" "../../memory/hdl" "../../edma/hdl/")
// End:


/*
 Copyright (C) 2015 Adapteva, Inc.
 
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
