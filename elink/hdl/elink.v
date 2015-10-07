module elink(/*AUTOARG*/
   // Outputs
   rx_lclk_pll, rxo_wr_wait_p, rxo_wr_wait_n, rxo_rd_wait_p,
   rxo_rd_wait_n, txo_lclk_p, txo_lclk_n, txo_frame_p, txo_frame_n,
   txo_data_p, txo_data_n, e_chipid, elink_en, mailbox_not_empty,
   mailbox_full, timeout, rxwr_access, rxwr_packet, rxrd_access,
   rxrd_packet, rxrr_access, rxrr_packet, txwr_wait, txrd_wait,
   txrr_wait,
   // Inputs
   por_reset, reset, sys_clk, tx_lclk, tx_lclk90, tx_lclk_div4,
   rx_lclk, rx_lclk_div4, rxi_lclk_p, rxi_lclk_n, rxi_frame_p,
   rxi_frame_n, rxi_data_p, rxi_data_n, txi_wr_wait_p, txi_wr_wait_n,
   txi_rd_wait_p, txi_rd_wait_n, rxwr_wait, rxrd_wait, rxrr_wait,
   txwr_access, txwr_packet, txrd_access, txrd_packet, txrr_access,
   txrr_packet
   );
   
   parameter AW          = 32;       //native address width
   parameter DW          = 32;       //native data width
   parameter PW          = 104;      //packet width   
   parameter ID          = 12'h810;  //epiphany ID for elink (ie addr[31:20])
   parameter IOSTD_ELINK = "LVDS_25";
   parameter ETYPE       = 1;
   
   /****************************/
   /*CLOCK AND RESET           */
   /****************************/
   input        por_reset;     // por reset for elink en
   input        reset;         // hardware reset
   input 	sys_clk;       // a single system clock for master/slave FIFOs
   input 	tx_lclk;       // fast tx clock for IO
   input 	tx_lclk90;     // fast 90deg shifted lclk   
   input 	tx_lclk_div4;  // slow tx clock for core logic
   input 	rx_lclk;       // rx input clock tweaked by pll for IO
   input 	rx_lclk_div4;  // slow clock for rx logic 
   output 	rx_lclk_pll;   // rx_lclk pass through input for pll

   /********************************/
   /*ELINK RECEIVER                */
   /********************************/          
   input 	rxi_lclk_p,   rxi_lclk_n;    // rx clock input
   input        rxi_frame_p,  rxi_frame_n;   // rx frame signal
   input [7:0] 	rxi_data_p,   rxi_data_n;    // rx data
   output       rxo_wr_wait_p,rxo_wr_wait_n; // rx write pushback output
   output       rxo_rd_wait_p,rxo_rd_wait_n; // rx read pushback output

   /********************************/
   /*ELINK TRANSMITTER             */
   /********************************/          
   output 	txo_lclk_p,   txo_lclk_n;    // tx clock output
   output       txo_frame_p,  txo_frame_n;   // tx frame signal
   output [7:0] txo_data_p,   txo_data_n;    // tx data
   input 	txi_wr_wait_p,txi_wr_wait_n; // tx write pushback input
   input 	txi_rd_wait_p,txi_rd_wait_n; // tx read pushback input

   /*************************************/
   /*EPIPHANY MISC INTERFACE (I/O PINS) */
   /*************************************/          
   output [11:0]   e_chipid;	// chip id strap pins for epiphany
   output 	   elink_en;    // master enable (reset) for elink/epiphany 
   
   /*****************************/
   /*MAILBOX INTERRUPTS         */
   /*****************************/
   output       mailbox_not_empty;   
   output       mailbox_full;

   /*****************************/
   /*READBACK TIMEOUT (TBD)     */
   /*****************************/
   output 	timeout;

   /*****************************/
   /*SYSTEM SIDE INTERFACE      */
   /*****************************/   
   
   //Master Write (from RX)
   output 	   rxwr_access;
   output [PW-1:0] rxwr_packet;
   input 	   rxwr_wait;
      
   //Master Read Request (from RX)
   output 	   rxrd_access;
   output [PW-1:0] rxrd_packet;
   input 	   rxrd_wait;
   
   //Slave Read Response (from RX)
   output 	   rxrr_access;
   output [PW-1:0] rxrr_packet;
   input 	   rxrr_wait;
   
   //Slave Write (to TX)
   input 	   txwr_access;
   input [PW-1:0]  txwr_packet;
   output 	   txwr_wait;

   //Slave Read Request (to TX) 
   input 	   txrd_access;
   input [PW-1:0]  txrd_packet;
   output 	   txrd_wait;
   
   //Master Read Response (to TX)
   input 	   txrr_access;
   input [PW-1:0]  txrr_packet;
   output 	   txrr_wait;

   /*#############################################*/
   /*  END OF BLOCK INTERFACE                     */
   /*#############################################*/
   
   /*AUTOINPUT*/

   //wire
   wire 		erx_cfg_access;		// To erx of erx.v
   wire [PW-1:0] 	erx_cfg_packet;		// To erx of erx.v
   wire 		etx_cfg_wait;		// To etx of etx.v
   wire [31:0] 		mi_rd_data;
   wire [31:0] 		mi_dout_ecfg;
   wire [31:0] 		mi_dout_embox;

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [15:0]		clk_config;		// From ecfg_elink of ecfg_elink.v
   wire			erx_cfg_wait;		// From erx of erx.v
   wire			erx_reset;		// From ereset of ereset.v
   wire			etx_cfg_access;		// From etx of etx.v
   wire [PW-1:0]	etx_cfg_packet;		// From etx of etx.v
   wire			etx_reset;		// From ereset of ereset.v
   wire			sys_reset;		// From ereset of ereset.v
   wire			txwr_gated_access;	// From ecfg_elink of ecfg_elink.v
   // End of automatics
   
   /***********************************************************/
   /*CLOCK AND RESET CONFIG                                   */
   /***********************************************************/

   defparam ecfg_elink.ID=ID;
   
   ecfg_elink ecfg_elink (.clk		        (sys_clk),
			  .reset		(por_reset),          
			  /*AUTOINST*/
			  // Outputs
			  .txwr_gated_access	(txwr_gated_access),
			  .elink_en		(elink_en),
			  .clk_config		(clk_config[15:0]),
			  .e_chipid		(e_chipid[11:0]),
			  // Inputs
			  .txwr_access		(txwr_access),
			  .txwr_packet		(txwr_packet[PW-1:0]));

   /***********************************************************/
   /*RESET CIRCUITRY                                          */
   /***********************************************************/
   //Synchronize with each clock domain

   ereset ereset (
		  /*AUTOINST*/
		  // Outputs
		  .etx_reset		(etx_reset),
		  .erx_reset		(erx_reset),
		  .sys_reset		(sys_reset),
		  // Inputs
		  .reset		(reset),
		  .sys_clk		(sys_clk),
		  .tx_lclk_div4		(tx_lclk_div4),
		  .rx_lclk_div4		(rx_lclk_div4));
   
   /***********************************************************/
   /*RECEIVER                                                 */
   /***********************************************************/
   /*erx AUTO_TEMPLATE ( 
	                .mi_dout      (mi_rx_dout[]),
                        .reset        (erx_reset),
                       );
   */
   
   defparam erx.ID          = ID;
   defparam erx.IOSTD_ELINK = IOSTD_ELINK;
   defparam erx.ETYPE       = ETYPE;
   
   erx erx(
	   /*AUTOINST*/
	   // Outputs
	   .rx_lclk_pll			(rx_lclk_pll),
	   .rxo_wr_wait_p		(rxo_wr_wait_p),
	   .rxo_wr_wait_n		(rxo_wr_wait_n),
	   .rxo_rd_wait_p		(rxo_rd_wait_p),
	   .rxo_rd_wait_n		(rxo_rd_wait_n),
	   .rxwr_access			(rxwr_access),
	   .rxwr_packet			(rxwr_packet[PW-1:0]),
	   .rxrd_access			(rxrd_access),
	   .rxrd_packet			(rxrd_packet[PW-1:0]),
	   .rxrr_access			(rxrr_access),
	   .rxrr_packet			(rxrr_packet[PW-1:0]),
	   .erx_cfg_wait		(erx_cfg_wait),
	   .timeout			(timeout),
	   .mailbox_full		(mailbox_full),
	   .mailbox_not_empty		(mailbox_not_empty),
	   // Inputs
	   .erx_reset			(erx_reset),
	   .sys_reset			(sys_reset),
	   .sys_clk			(sys_clk),
	   .rx_lclk			(rx_lclk),
	   .rx_lclk_div4		(rx_lclk_div4),
	   .rxi_lclk_p			(rxi_lclk_p),
	   .rxi_lclk_n			(rxi_lclk_n),
	   .rxi_frame_p			(rxi_frame_p),
	   .rxi_frame_n			(rxi_frame_n),
	   .rxi_data_p			(rxi_data_p[7:0]),
	   .rxi_data_n			(rxi_data_n[7:0]),
	   .rxwr_wait			(rxwr_wait),
	   .rxrd_wait			(rxrd_wait),
	   .rxrr_wait			(rxrr_wait),
	   .erx_cfg_access		(erx_cfg_access),
	   .erx_cfg_packet		(erx_cfg_packet[PW-1:0]));

   /***********************************************************/
   /*TRANSMITTER                                              */
   /***********************************************************/
   /*etx AUTO_TEMPLATE (.mi_dout      (mi_tx_dout[]),
                        .emwr_\(.*\)  (esaxi_emwr_\1[]),
                        .emrq_\(.*\)  (esaxi_emrq_\1[]),
                        .emrr_\(.*\)  (emaxi_emrr_\1[]),
                        .reset        (etx_reset),
                        
                       );
   */

   defparam etx.ID          = ID;
   defparam etx.IOSTD_ELINK = IOSTD_ELINK;
   defparam etx.ETYPE       = ETYPE;

   etx etx(.txwr_access  (txwr_gated_access),
	   /*AUTOINST*/
	   // Outputs
	   .txo_lclk_p			(txo_lclk_p),
	   .txo_lclk_n			(txo_lclk_n),
	   .txo_frame_p			(txo_frame_p),
	   .txo_frame_n			(txo_frame_n),
	   .txo_data_p			(txo_data_p[7:0]),
	   .txo_data_n			(txo_data_n[7:0]),
	   .txrd_wait			(txrd_wait),
	   .txwr_wait			(txwr_wait),
	   .txrr_wait			(txrr_wait),
	   .etx_cfg_access		(etx_cfg_access),
	   .etx_cfg_packet		(etx_cfg_packet[PW-1:0]),
	   // Inputs
	   .etx_reset			(etx_reset),
	   .sys_reset			(sys_reset),
	   .sys_clk			(sys_clk),
	   .tx_lclk			(tx_lclk),
	   .tx_lclk90			(tx_lclk90),
	   .tx_lclk_div4		(tx_lclk_div4),
	   .txi_wr_wait_p		(txi_wr_wait_p),
	   .txi_wr_wait_n		(txi_wr_wait_n),
	   .txi_rd_wait_p		(txi_rd_wait_p),
	   .txi_rd_wait_n		(txi_rd_wait_n),
	   .txrd_access			(txrd_access),
	   .txrd_packet			(txrd_packet[PW-1:0]),
	   .txwr_packet			(txwr_packet[PW-1:0]),
	   .txrr_access			(txrr_access),
	   .txrr_packet			(txrr_packet[PW-1:0]),
	   .etx_cfg_wait		(etx_cfg_wait));
   
   /***********************************************************/
   /*TX-->RX REGISTER INTERFACE CONNECTION                    */
   /***********************************************************/
   defparam ecfg_cdc.DW=104;
   defparam ecfg_cdc.DEPTH=32;
   
   fifo_cdc ecfg_cdc (// Outputs
		      .wait_out		(etx_cfg_wait),	
		      .access_out	(erx_cfg_access),	
		      .packet_out	(erx_cfg_packet[PW-1:0]),
		      // Inputs
		      .clk_in		(tx_lclk_div4),	
		      .reset_in		(etx_reset),
		      .access_in	(etx_cfg_access),
		      .packet_in	(etx_cfg_packet[PW-1:0]),
		      .clk_out		(rx_lclk_div4),	
		      .reset_out	(erx_reset),
		      .wait_in		(erx_cfg_wait)
		      );
   
   
endmodule // elink
// Local Variables:
// verilog-library-directories:("." "../../erx/hdl" "../../etx/hdl"  "../../memory/hdl")
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
