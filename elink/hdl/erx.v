module erx (/*AUTOARG*/
   // Outputs
   rx_lclk_pll, rxo_wr_wait_p, rxo_wr_wait_n, rxo_rd_wait_p,
   rxo_rd_wait_n, rxwr_access, rxwr_packet, rxrd_access, rxrd_packet,
   rxrr_access, rxrr_packet, erx_cfg_wait, timeout, mailbox_full,
   mailbox_not_empty,
   // Inputs
   erx_reset, sys_reset, sys_clk, rx_lclk, rx_lclk_div4, rx_ref_clk,
   rxi_lclk_p, rxi_lclk_n, rxi_frame_p, rxi_frame_n, rxi_data_p,
   rxi_data_n, rxwr_wait, rxrd_wait, rxrr_wait, erx_cfg_access,
   erx_cfg_packet
   );

   parameter AW      = 32;
   parameter DW      = 32;
   parameter PW      = 104;
   parameter RFAW    = 6;
   parameter ID      = 12'h800;
   parameter IOSTD_ELINK="LVDS_25";

   //Synched resets
   input          erx_reset;                   // reset for core logic
   input          sys_reset;                   // reset for fifos 

   //Clocks
   input 	  sys_clk;	               // system clock for rx fifos
   input 	  rx_lclk;	               // fast clock for io
   input 	  rx_lclk_div4;		       // slow clock for rest of logic
   input 	  rx_ref_clk;                  // idelay reference clock   
   output 	  rx_lclk_pll;                 // clock output for pll
   
   //FROM IO Pins
   input 	  rxi_lclk_p,   rxi_lclk_n;     // rx clock input
   input 	  rxi_frame_p,  rxi_frame_n;    // rx frame signal
   input [7:0] 	  rxi_data_p,   rxi_data_n;     // rx data
   output 	  rxo_wr_wait_p,rxo_wr_wait_n;  // rx write pushback output
   output 	  rxo_rd_wait_p,rxo_rd_wait_n;  // rx read pushback output

   //Master write
   output 	   rxwr_access;		
   output [PW-1:0] rxwr_packet;
   input 	   rxwr_wait;

   //Master read request
   output 	   rxrd_access;		
   output [PW-1:0] rxrd_packet;
   input 	   rxrd_wait;

   //Slave read response
   output 	   rxrr_access;		
   output [PW-1:0] rxrr_packet;
   input 	   rxrr_wait;
  
   //Configuration Interface (from ETX)
   input 	   erx_cfg_access;
   input [PW-1:0]  erx_cfg_packet;
   output 	   erx_cfg_wait;
   
   //Readback timeout (synchronized to sys_c
   output 	   timeout;
   output 	   mailbox_full;
   output 	   mailbox_not_empty;
   
   /*AUTOOUTPUT*/
   /*AUTOINPUT*/

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			rx_access;		// From erx_io of erx_io.v
   wire			rx_burst;		// From erx_io of erx_io.v
   wire [PW-1:0]	rx_packet;		// From erx_io of erx_io.v
   wire			rx_rd_wait;		// From erx_core of erx_core.v
   wire			rx_wr_wait;		// From erx_core of erx_core.v
   wire			rxrd_fifo_access;	// From erx_core of erx_core.v
   wire [PW-1:0]	rxrd_fifo_packet;	// From erx_core of erx_core.v
   wire			rxrd_fifo_wait;		// From erx_fifo of erx_fifo.v
   wire			rxrr_fifo_access;	// From erx_core of erx_core.v
   wire [PW-1:0]	rxrr_fifo_packet;	// From erx_core of erx_core.v
   wire			rxrr_fifo_wait;		// From erx_fifo of erx_fifo.v
   wire			rxwr_fifo_access;	// From erx_core of erx_core.v
   wire [PW-1:0]	rxwr_fifo_packet;	// From erx_core of erx_core.v
   wire			rxwr_fifo_wait;		// From erx_fifo of erx_fifo.v
   // End of automatics

   /***********************************************************/
   /*RECEIVER  I/O LOGIC                                      */
   /***********************************************************/
   defparam erx_io.IOSTD_ELINK=IOSTD_ELINK;
   erx_io erx_io (.reset		(erx_reset),
		  /*AUTOINST*/
		  // Outputs
		  .rx_lclk_pll		(rx_lclk_pll),
		  .rxo_wr_wait_p	(rxo_wr_wait_p),
		  .rxo_wr_wait_n	(rxo_wr_wait_n),
		  .rxo_rd_wait_p	(rxo_rd_wait_p),
		  .rxo_rd_wait_n	(rxo_rd_wait_n),
		  .rx_access		(rx_access),
		  .rx_burst		(rx_burst),
		  .rx_packet		(rx_packet[PW-1:0]),
		  // Inputs
		  .rx_lclk		(rx_lclk),
		  .rx_lclk_div4		(rx_lclk_div4),
		  .rx_ref_clk		(rx_ref_clk),
		  .rxi_lclk_p		(rxi_lclk_p),
		  .rxi_lclk_n		(rxi_lclk_n),
		  .rxi_frame_p		(rxi_frame_p),
		  .rxi_frame_n		(rxi_frame_n),
		  .rxi_data_p		(rxi_data_p[7:0]),
		  .rxi_data_n		(rxi_data_n[7:0]),
		  .rx_wr_wait		(rx_wr_wait),
		  .rx_rd_wait		(rx_rd_wait));
   
   /**************************************************************/
   /*ELINK CORE LOGIC                                            */
   /**************************************************************/
   /*erx_core   AUTO_TEMPLATE ( .rx_packet	(rx_packet[PW-1:0]),
		                .rx_access	(rx_access),
                                .erx_cfg_access	(erx_cfg_access),
		                .erx_cfg_packet	(erx_cfg_packet[PW-1:0]),
                                .erx_cfg_wait	(erx_cfg_wait),
                                .rx_rd_wait	(rx_rd_wait),
		                .rx_wr_wait	(rx_wr_wait),
    			       .\(.*\)_packet   (\1_fifo_packet[PW-1:0]),
    			       .\(.*\)_access   (\1_fifo_access),
       			       .\(.*\)_wait     (\1_fifo_wait),
    );
    */
   
   defparam erx_core.ID=ID;   
   erx_core erx_core ( .clk		(rx_lclk_div4),
		       .reset           (erx_reset),
		      /*AUTOINST*/
		      // Outputs
		      .rx_rd_wait	(rx_rd_wait),		 // Templated
		      .rx_wr_wait	(rx_wr_wait),		 // Templated
		      .rxrd_access	(rxrd_fifo_access),	 // Templated
		      .rxrd_packet	(rxrd_fifo_packet[PW-1:0]), // Templated
		      .rxrr_access	(rxrr_fifo_access),	 // Templated
		      .rxrr_packet	(rxrr_fifo_packet[PW-1:0]), // Templated
		      .rxwr_access	(rxwr_fifo_access),	 // Templated
		      .rxwr_packet	(rxwr_fifo_packet[PW-1:0]), // Templated
		      .erx_cfg_wait	(erx_cfg_wait),		 // Templated
		      .mailbox_full	(mailbox_full),
		      .mailbox_not_empty(mailbox_not_empty),
		      // Inputs
		      .rx_packet	(rx_packet[PW-1:0]),	 // Templated
		      .rx_access	(rx_access),		 // Templated
		      .rx_burst		(rx_burst),
		      .rxrd_wait	(rxrd_fifo_wait),	 // Templated
		      .rxrr_wait	(rxrr_fifo_wait),	 // Templated
		      .rxwr_wait	(rxwr_fifo_wait),	 // Templated
		      .erx_cfg_access	(erx_cfg_access),	 // Templated
		      .erx_cfg_packet	(erx_cfg_packet[PW-1:0])); // Templated

   /************************************************************/
   /*FIFOs                                                     */
   /************************************************************/      
   erx_fifo erx_fifo   (
		/*AUTOINST*/
			// Outputs
			.rxwr_access	(rxwr_access),
			.rxwr_packet	(rxwr_packet[PW-1:0]),
			.rxrd_access	(rxrd_access),
			.rxrd_packet	(rxrd_packet[PW-1:0]),
			.rxrr_access	(rxrr_access),
			.rxrr_packet	(rxrr_packet[PW-1:0]),
			.rxrd_fifo_wait	(rxrd_fifo_wait),
			.rxrr_fifo_wait	(rxrr_fifo_wait),
			.rxwr_fifo_wait	(rxwr_fifo_wait),
			// Inputs
			.erx_reset	(erx_reset),
			.sys_reset	(sys_reset),
			.rx_lclk_div4	(rx_lclk_div4),
			.sys_clk	(sys_clk),
			.rxwr_wait	(rxwr_wait),
			.rxrd_wait	(rxrd_wait),
			.rxrr_wait	(rxrr_wait),
			.rxrd_fifo_access(rxrd_fifo_access),
			.rxrd_fifo_packet(rxrd_fifo_packet[PW-1:0]),
			.rxrr_fifo_access(rxrr_fifo_access),
			.rxrr_fifo_packet(rxrr_fifo_packet[PW-1:0]),
			.rxwr_fifo_access(rxwr_fifo_access),
			.rxwr_fifo_packet(rxwr_fifo_packet[PW-1:0]));
   
endmodule // erx
// Local Variables:
// verilog-library-directories:(".")
// End:

/*
 Copyright (C) 2014 Adapteva, Inc.
  
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

