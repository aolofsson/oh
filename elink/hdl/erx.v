module erx (/*AUTOARG*/
   // Outputs
   rx_lclk_div4, rxo_wr_wait_p, rxo_wr_wait_n, rxo_rd_wait_p,
   rxo_rd_wait_n, rxwr_access, rxwr_packet, rxrd_access, rxrd_packet,
   rxrr_access, rxrr_packet, erx_cfg_wait, timeout, mailbox_full,
   mailbox_not_empty,
   // Inputs
   reset, sys_clk, rxi_lclk_p, rxi_lclk_n, rxi_frame_p, rxi_frame_n,
   rxi_data_p, rxi_data_n, rxwr_wait, rxrd_wait, rxrr_wait,
   erx_cfg_access, erx_cfg_packet
   );

   parameter AW      = 32;
   parameter DW      = 32;
   parameter PW      = 104;
   parameter RFAW    = 6;
   parameter ID      = 12'h800;

   //reset & clock
   input          reset;
   input 	  sys_clk;	    //system input clock for fifos
   output         rx_lclk_div4;    //for synchronization outside erx
   
   //FROM IO Pins
   input 	  rxi_lclk_p,  rxi_lclk_n;     //link rx clock input
   input 	  rxi_frame_p,  rxi_frame_n;   //link rx frame signal
   input [7:0] 	  rxi_data_p,   rxi_data_n;    //link rx data
   output 	  rxo_wr_wait_p,rxo_wr_wait_n; //link rx write pushback output
   output 	  rxo_rd_wait_p,rxo_rd_wait_n; //link rx read pushback output

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
   wire [63:0]		rx_data_par;		// From erx_io of erx_io.v
   wire [7:0]		rx_frame_par;		// From erx_io of erx_io.v
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

   //regs
   wire [15:0] 	rx_status;
   wire 	rxwr_fifo_full;
   wire 	rxrr_fifo_full;
   wire 	rxrd_fifo_full;
   wire 	rxrd_empty;
   wire 	rxwr_empty;
   wire 	rxrr_empty;
   wire [103:0] edma_packet;		// From edma of edma.v, ...
   
   /***********************************************************/
   /*RECEIVER  I/O LOGIC                                      */
   /***********************************************************/
   erx_io erx_io (
		    /*AUTOINST*/
		  // Outputs
		  .rxo_wr_wait_p	(rxo_wr_wait_p),
		  .rxo_wr_wait_n	(rxo_wr_wait_n),
		  .rxo_rd_wait_p	(rxo_rd_wait_p),
		  .rxo_rd_wait_n	(rxo_rd_wait_n),
		  .rx_lclk_div4		(rx_lclk_div4),
		  .rx_frame_par		(rx_frame_par[7:0]),
		  .rx_data_par		(rx_data_par[63:0]),
		  // Inputs
		  .reset		(reset),
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
   /*erx_core   AUTO_TEMPLATE ( 
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
   
   erx_core erx_core ( .clk		(rx_lclk_div4),
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
		      .reset		(reset),
		      .rx_data_par	(rx_data_par[63:0]),
		      .rx_frame_par	(rx_frame_par[7:0]),
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
			.reset		(reset),
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
// verilog-library-directories:("." "../../emmu/hdl" "../../edma/hdl" "../../memory/hdl" "../../emailbox/hdl")
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

