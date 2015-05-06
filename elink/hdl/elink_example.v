module elink_example(/*AUTOARG*/
   // Outputs
   rxo_wr_wait_p, rxo_wr_wait_n, rxo_rd_wait_p, rxo_rd_wait_n,
   txo_lclk_p, txo_lclk_n, txo_frame_p, txo_frame_n, txo_data_p,
   txo_data_n, chipid, chip_resetb, cclk_p, cclk_n,
   // Inputs
   reset, clk, start, rxi_lclk_p, rxi_lclk_n, rxi_frame_p,
   rxi_frame_n, rxi_data_p, rxi_data_n, txi_wr_wait_p, txi_wr_wait_n,
   txi_rd_wait_p, txi_rd_wait_n
   );

   parameter AW          = 32;
   parameter DW          = 32; 
   parameter PW          = 104;      //packet width   
   parameter ELINK_ID    = 12'h810;
   parameter CHIP_ID     = 12'h808;

   /****************************/
   /*CLK AND RESET             */
   /****************************/
   input        reset;            // active high async reset
   input 	clk;              // pll input clock
   input 	start;            // start generator
   
   /********************************/
   /*ELINK I/O PINS                */
   /********************************/          
   //Receiver
   input        rxi_lclk_p,  rxi_lclk_n;     //link rx clock input
   input        rxi_frame_p,  rxi_frame_n;   //link rx frame signal
   input [7:0] 	rxi_data_p,   rxi_data_n;    //link rx data
   output       rxo_wr_wait_p,rxo_wr_wait_n; //link rx write pushback output
   output       rxo_rd_wait_p,rxo_rd_wait_n; //link rx read pushback output
   
   //Transmitter
   output       txo_lclk_p,   txo_lclk_n;    //link tx clock output
   output       txo_frame_p,  txo_frame_n;   //link tx frame signal
   output [7:0] txo_data_p,   txo_data_n;    //link tx data
   input 	txi_wr_wait_p,txi_wr_wait_n; //link tx write pushback input
   input 	txi_rd_wait_p,txi_rd_wait_n; //link tx read pushback input

   /********************************/
   /*EPIPHANY INTERFACE (I/O PINS) */
   /********************************/          
   output [11:0] chipid;			// From etx of etx.v
   output 	 chip_resetb;          //chip reset for Epiphany (active low)
   output 	 cclk_p, cclk_n;       //high speed clock (up to 1GHz) to Epiphany
   

   /*AUTOINPUT*/

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			done;			// From egen_txwr of egen.v
   wire			txrd_access;		// From egen_txrd of egen.v
   wire [PW-1:0]	txrd_packet;		// From egen_txrd of egen.v
   wire			txrd_wait;		// From elink of elink.v
   wire			txrr_access;		// From emem of ememory.v
   wire [PW-1:0]	txrr_packet;		// From emem of ememory.v
   wire			txrr_wait;		// From elink of elink.v
   wire			txwr_access;		// From egen_txwr of egen.v
   wire [PW-1:0]	txwr_packet;		// From egen_txwr of egen.v
   wire			txwr_wait;		// From elink of elink.v
   // End of automatics
   
   //local wires
   wire 		emem_access;
   wire [PW-1:0]	emem_packet;
   wire		        rxrd_wait;		// To elink of elink.v
   wire 		rxwr_wait;		// To elink of elink.v
   wire 	        rxrd_access;		// From elink of elink.v
   wire [PW-1:0]	rxrd_packet;		// From elink of elink.v
   wire		        rxwr_access;		// From elink of elink.v
   wire [PW-1:0]	rxwr_packet;		// From elink of elink.v
   wire		        rxrr_access;		// From elink of elink.v
   wire [PW-1:0]	rxrr_packet;		// From elink of elink.v

   
   //######
   //ELINK
   //######
   
   elink elink (.rxrr_wait		(1'b0),
		.rxrr_access		(rxrr_access),
		.rxrr_packet		(rxrr_packet[PW-1:0]),
		.mailbox_not_empty	(),
		.mailbox_full		(),
		.timeout		(),
		.chipid			(),
		.cclk_p			(),
		.cclk_n			(),	
		.rx_lclk_div4		(),
		.chip_resetb		(chip_resetb),
		.tx_lclk_div4		(),
		.sys_clk		(clk),
		.clkin			(clk),
		.testmode		(1'b0),
		.pll_bypass             (4'b0),
		/*AUTOINST*/
		// Outputs
		.rxo_wr_wait_p		(rxo_wr_wait_p),
		.rxo_wr_wait_n		(rxo_wr_wait_n),
		.rxo_rd_wait_p		(rxo_rd_wait_p),
		.rxo_rd_wait_n		(rxo_rd_wait_n),
		.txo_lclk_p		(txo_lclk_p),
		.txo_lclk_n		(txo_lclk_n),
		.txo_frame_p		(txo_frame_p),
		.txo_frame_n		(txo_frame_n),
		.txo_data_p		(txo_data_p[7:0]),
		.txo_data_n		(txo_data_n[7:0]),
		.rxwr_access		(rxwr_access),
		.rxwr_packet		(rxwr_packet[PW-1:0]),
		.rxrd_access		(rxrd_access),
		.rxrd_packet		(rxrd_packet[PW-1:0]),
		.txwr_wait		(txwr_wait),
		.txrd_wait		(txrd_wait),
		.txrr_wait		(txrr_wait),
		// Inputs
		.reset			(reset),
		.rxi_lclk_p		(rxi_lclk_p),
		.rxi_lclk_n		(rxi_lclk_n),
		.rxi_frame_p		(rxi_frame_p),
		.rxi_frame_n		(rxi_frame_n),
		.rxi_data_p		(rxi_data_p[7:0]),
		.rxi_data_n		(rxi_data_n[7:0]),
		.txi_wr_wait_p		(txi_wr_wait_p),
		.txi_wr_wait_n		(txi_wr_wait_n),
		.txi_rd_wait_p		(txi_rd_wait_p),
		.txi_rd_wait_n		(txi_rd_wait_n),
		.rxwr_wait		(rxwr_wait),
		.rxrd_wait		(rxrd_wait),
		.txwr_access		(txwr_access),
		.txwr_packet		(txwr_packet[PW-1:0]),
		.txrd_access		(txrd_access),
		.txrd_packet		(txrd_packet[PW-1:0]),
		.txrr_access		(txrr_access),
		.txrr_packet		(txrr_packet[PW-1:0]));
   
   //############################
   //EMESH TRANSACTION GENERATOR
   //############################
   /*egen AUTO_TEMPLATE ( 
                        // Outputs
                        .\(.*\)_out       (@"(substring vl-cell-name  5 9)"_\1[]),
                        .\(.*\)_in        (@"(substring vl-cell-name  5 9)"_\1[]),
                         );
   */

   defparam egen_txwr.MODE   =1;//write
   defparam egen_txwr.SRC_ID=12'h810;
   defparam egen_txwr.DST_ID=12'h808;
   
   egen egen_txwr (/*AUTOINST*/
		   // Outputs
		   .done		(done),
		   .access_out		(txwr_access),		 // Templated
		   .packet_out		(txwr_packet[PW-1:0]),	 // Templated
		   // Inputs
		   .clk			(clk),
		   .reset		(reset),
		   .start		(start),
		   .wait_in		(txwr_wait));		 // Templated
   

   
   defparam egen_txrd.MODE=0;//read
   defparam egen_txrd.SRC_ID=12'h810;
   defparam egen_txrd.DST_ID=12'h808;
   egen egen_txrd ( .start		(done),
		    .done		(),
		    /*AUTOINST*/
		   // Outputs
		   .access_out		(txrd_access),		 // Templated
		   .packet_out		(txrd_packet[PW-1:0]),	 // Templated
		   // Inputs
		   .clk			(clk),
		   .reset		(reset),
		   .wait_in		(txrd_wait));		 // Templated
   

   
   //#################
   //EMESH MEMORY
   //##################
   assign  emem_access           = (rxwr_access & ~(rxwr_packet[39:28]==ELINK_ID)) |
				   (rxrd_access & ~(rxrd_packet[39:28]==ELINK_ID));
   
   assign  emem_packet[PW-1:0]   = rxwr_access ? rxwr_packet[PW-1:0]:
                                                 rxrd_packet[PW-1:0];

   assign rxrd_wait = emem_wait | rxwr_access;
   assign rxwr_wait = 1'b0; //no wait on write
   

   /*ememory AUTO_TEMPLATE ( 
                        // Outputs
                        .\(.*\)_out       (txrr_\1[]),
                        .\(.*\)_in        (emem_\1[]),
                        .wait_out	  (emem_wait),
                        .wait_in          (txrr_wait),
                         );
   */

   ememory emem (.wait_out		(emem_wait),
		 /*AUTOINST*/
		 // Outputs
		 .access_out		(txrr_access),		 // Templated
		 .packet_out		(txrr_packet[PW-1:0]),	 // Templated
		 // Inputs
		 .clk			(clk),
		 .reset			(reset),
		 .access_in		(emem_access),		 // Templated
		 .packet_in		(emem_packet[PW-1:0]),	 // Templated
		 .wait_in		(txrr_wait));		 // Templated
   
   
   
endmodule // dv_elink
// Local Variables:
// verilog-library-directories:("." "../hdl" "../../memory/hdl" "../../emesh/hdl")
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

