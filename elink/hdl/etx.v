module etx(/*AUTOARG*/
   // Outputs
   mi_tx_emmu_dout, mi_tx_cfg_dout, txrd_wait, txwr_wait, txrr_wait,
   txo_lclk_p, txo_lclk_n, txo_frame_p, txo_frame_n, txo_data_p,
   txo_data_n,
   // Inputs
   reset, tx_lclk, tx_lclk90, tx_lclk_div4, mi_clk, mi_en, mi_we,
   mi_addr, mi_din, txrd_clk, txrd_access, txrd_packet, txwr_clk,
   txwr_access, txwr_packet, txrr_clk, txrr_access, txrr_packet,
   txi_wr_wait_p, txi_wr_wait_n, txi_rd_wait_p, txi_rd_wait_n
   );
   parameter AW   = 32;
   parameter DW   = 32;
   parameter PW   = 104;
   parameter RFAW = 12;

   //Clocks and reset
   input          reset;
   input 	  tx_lclk;	  // high speed serdes clock
   input 	  tx_lclk90;	  // lclk for output
   input 	  tx_lclk_div4;	  // slow speed parallel clock

   //Register Access Interface
   input           mi_clk;
   input           mi_en;         
   input           mi_we;         // single we, must write 32 bit words
   input [19:0]    mi_addr;       // complete physical address (no shifting!)
   input [31:0]    mi_din;
   output [DW-1:0] mi_tx_emmu_dout;
   output [DW-1:0] mi_tx_cfg_dout;
   
   //Slave Read Request (to TX)
   input 	  txrd_clk;   
   input 	  txrd_access;
   input [PW-1:0] txrd_packet;
   output 	  txrd_wait;
   
   //Slave Write (to TX)
   input 	  txwr_clk;   
   input 	  txwr_access;
   input [PW-1:0] txwr_packet;
   output 	  txwr_wait;
   
   //Master Read Response (to TX)
   input 	  txrr_clk;   
   input 	  txrr_access;
   input [PW-1:0] txrr_packet;
   output 	  txrr_wait;
   
   //Transmit signals for IO
   output        txo_lclk_p, txo_lclk_n;       //tx center aligned clock (>500MHz)
   output        txo_frame_p, txo_frame_n;     //tx frame signal
   output [7:0]  txo_data_p, txo_data_n;       //tx data (dual data rate)
   input 	 txi_wr_wait_p,txi_wr_wait_n;  //tx async write pushback
   input 	 txi_rd_wait_p, txi_rd_wait_n; //tx async read pushback

   //debug declarations
   reg [15:0] 	 ecfg_tx_debug; 
   wire 	 txwr_fifo_full;
   wire 	 txrr_fifo_full;
   wire 	 txrd_fifo_full;

   /*AUTOOUTPUT*/
   /*AUTOINPUT*/
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [8:0]		ecfg_dataout;		// From ecfg_tx of ecfg_tx.v
   wire [3:0]		ecfg_tx_ctrlmode;	// From ecfg_tx of ecfg_tx.v
   wire			ecfg_tx_ctrlmode_bp;	// From ecfg_tx of ecfg_tx.v
   wire			ecfg_tx_enable;		// From ecfg_tx of ecfg_tx.v
   wire			ecfg_tx_gpio_enable;	// From ecfg_tx of ecfg_tx.v
   wire			ecfg_tx_mmu_enable;	// From ecfg_tx of ecfg_tx.v
   wire			ecfg_tx_tp_enable;	// From ecfg_tx of ecfg_tx.v
   wire			emmu_access;		// From emmu of emmu.v
   wire [PW-1:0]	emmu_packet;		// From emmu of emmu.v
   wire			etx_access;		// From etx_arbiter of etx_arbiter.v
   wire			etx_ack;		// From etx_protocol of etx_protocol.v
   wire [PW-1:0]	etx_packet;		// From etx_arbiter of etx_arbiter.v
   wire			etx_rd_wait;		// From etx_protocol of etx_protocol.v
   wire			etx_wr_wait;		// From etx_protocol of etx_protocol.v
   wire [63:0]		tx_data_par;		// From etx_protocol of etx_protocol.v
   wire [7:0]		tx_frame_par;		// From etx_protocol of etx_protocol.v
   wire			tx_rd_wait;		// From etx_io of etx_io.v
   wire			tx_wr_wait;		// From etx_io of etx_io.v
   wire			txrd_fifo_empty;	// From txrd_fifo of fifo_async.v
   wire [PW-1:0]	txrd_fifo_packet;	// From txrd_fifo of fifo_async.v
   wire			txrd_fifo_read;		// From etx_arbiter of etx_arbiter.v
   wire			txrr_fifo_empty;	// From txrr_fifo of fifo_async.v
   wire [PW-1:0]	txrr_fifo_packet;	// From txrr_fifo of fifo_async.v
   wire			txrr_fifo_read;		// From etx_arbiter of etx_arbiter.v
   wire			txwr_fifo_empty;	// From txwr_fifo of fifo_async.v
   wire [PW-1:0]	txwr_fifo_packet;	// From txwr_fifo of fifo_async.v
   wire			txwr_fifo_read;		// From etx_arbiter of etx_arbiter.v
   // End of automatics
   

   /************************************************************/
   /* ETX CONFIGURATION                                        */
   /************************************************************/
   ecfg_tx ecfg_tx (
		    .mi_dout		(mi_tx_cfg_dout[31:0]),
		    /*AUTOINST*/
		    // Outputs
		    .ecfg_tx_enable	(ecfg_tx_enable),
		    .ecfg_tx_mmu_enable	(ecfg_tx_mmu_enable),
		    .ecfg_tx_gpio_enable(ecfg_tx_gpio_enable),
		    .ecfg_tx_tp_enable	(ecfg_tx_tp_enable),
		    .ecfg_tx_ctrlmode	(ecfg_tx_ctrlmode[3:0]),
		    .ecfg_tx_ctrlmode_bp(ecfg_tx_ctrlmode_bp),
		    .ecfg_dataout	(ecfg_dataout[8:0]),
		    // Inputs
		    .reset		(reset),
		    .mi_clk		(mi_clk),
		    .mi_en		(mi_en),
		    .mi_we		(mi_we),
		    .mi_addr		(mi_addr[19:0]),
		    .mi_din		(mi_din[31:0]),
		    .ecfg_tx_debug	(ecfg_tx_debug[15:0]));
   

   
   /************************************************************/
   /*FIFOs                                                     */
   /************************************************************/
   //TODO: Minimize depth and width

   /*fifo_async  AUTO_TEMPLATE (
			       // Outputs
			       
			       .dout       (@"(substring vl-cell-name  0 4)"_fifo_packet[PW-1:0]),
			       .empty	   (@"(substring vl-cell-name  0 4)"_fifo_empty),
			       .full	   (@"(substring vl-cell-name  0 4)"_fifo_full),
			       .prog_full  (@"(substring vl-cell-name  0 4)"_fifo_prog_full),
			       // Inputs
			       .rd_clk	   (tx_lclk_div4),
                               .wr_clk	   (@"(substring vl-cell-name  0 4)"_clk),
                               .wr_en      (@"(substring vl-cell-name  0 4)"_access),
                               .rd_en      (@"(substring vl-cell-name  0 4)"_fifo_read),
			       .reset	   (reset),
                               .din	   (@"(substring vl-cell-name  0 4)"_packet[PW-1:0]),
    );
    */

   //Write fifo (from slave)
   fifo_async #(.DW(104), .AW(5)) txwr_fifo(
					    .prog_full		(txwr_wait),
					    .full		(txwr_fifo_full),
			                    /*AUTOINST*/
					    // Outputs
					    .dout		(txwr_fifo_packet[PW-1:0]), // Templated
					    .empty		(txwr_fifo_empty), // Templated
					    // Inputs
					    .reset		(reset),	 // Templated
					    .wr_clk		(txwr_clk),	 // Templated
					    .rd_clk		(tx_lclk_div4),	 // Templated
					    .wr_en		(txwr_access),	 // Templated
					    .din		(txwr_packet[PW-1:0]), // Templated
					    .rd_en		(txwr_fifo_read)); // Templated
   
   //Read request fifo (from slave)
   fifo_async  #(.DW(104), .AW(5)) txrd_fifo(
					     .prog_full		(txrd_wait),
					     .full		(txrd_fifo_full),
				             /*AUTOINST*/
					     // Outputs
					     .dout		(txrd_fifo_packet[PW-1:0]), // Templated
					     .empty		(txrd_fifo_empty), // Templated
					     // Inputs
					     .reset		(reset),	 // Templated
					     .wr_clk		(txrd_clk),	 // Templated
					     .rd_clk		(tx_lclk_div4),	 // Templated
					     .wr_en		(txrd_access),	 // Templated
					     .din		(txrd_packet[PW-1:0]), // Templated
					     .rd_en		(txrd_fifo_read)); // Templated
   

  
   //Read response fifo (from master)
   fifo_async  #(.DW(104), .AW(5)) txrr_fifo(
					     .prog_full		(txrr_wait),
					     .full		(txrr_fifo_full),
					     /*AUTOINST*/
					     // Outputs
					     .dout		(txrr_fifo_packet[PW-1:0]), // Templated
					     .empty		(txrr_fifo_empty), // Templated
					     // Inputs
					     .reset		(reset),	 // Templated
					     .wr_clk		(txrr_clk),	 // Templated
					     .rd_clk		(tx_lclk_div4),	 // Templated
					     .wr_en		(txrr_access),	 // Templated
					     .din		(txrr_packet[PW-1:0]), // Templated
					     .rd_en		(txrr_fifo_read)); // Templated
   
   
   /************************************************************/
   /*ELINK TRANSMIT ARBITER                                    */
   /************************************************************/

   etx_arbiter etx_arbiter (
			      /*AUTOINST*/
			    // Outputs
			    .txwr_fifo_read	(txwr_fifo_read),
			    .txrd_fifo_read	(txrd_fifo_read),
			    .txrr_fifo_read	(txrr_fifo_read),
			    .etx_access		(etx_access),
			    .etx_packet		(etx_packet[PW-1:0]),
			    // Inputs
			    .tx_lclk_div4	(tx_lclk_div4),
			    .reset		(reset),
			    .ecfg_tx_ctrlmode_bp(ecfg_tx_ctrlmode_bp),
			    .ecfg_tx_ctrlmode	(ecfg_tx_ctrlmode[3:0]),
			    .txwr_fifo_empty	(txwr_fifo_empty),
			    .txwr_fifo_packet	(txwr_fifo_packet[PW-1:0]),
			    .txrd_fifo_empty	(txrd_fifo_empty),
			    .txrd_fifo_packet	(txrd_fifo_packet[PW-1:0]),
			    .txrr_fifo_empty	(txrr_fifo_empty),
			    .txrr_fifo_packet	(txrr_fifo_packet[PW-1:0]),
			    .etx_rd_wait	(etx_rd_wait),
			    .etx_wr_wait	(etx_wr_wait),
			    .etx_ack		(etx_ack));
   
   /************************************************************/
   /* EMMU                                                     */
   /************************************************************/
   /*emmu  AUTO_TEMPLATE (	
                          .emmu_packet_out (emmu_packet[PW-1:0]),
                          .emesh_\(.*\)_in (etx_\1[]),
                          .mmu_en	   (ecfg_tx_mmu_enable),
                          .clk     	   (tx_lclk_div4),
                          .emmu_access_out (emmu_access),
                          .emmu_packet_out (emmu_packet[PW-1:0]),
                          .mi_dout	   (mi_tx_emmu_dout[DW-1:0]),
                          );
   */

   emmu emmu (.emmu_packet_hi_out	(),
	      /*AUTOINST*/
	      // Outputs
	      .mi_dout			(mi_tx_emmu_dout[DW-1:0]), // Templated
	      .emmu_access_out		(emmu_access),		 // Templated
	      .emmu_packet_out		(emmu_packet[PW-1:0]),	 // Templated
	      // Inputs
	      .clk			(tx_lclk_div4),		 // Templated
	      .reset			(reset),
	      .mmu_en			(ecfg_tx_mmu_enable),	 // Templated
	      .mi_clk			(mi_clk),
	      .mi_en			(mi_en),
	      .mi_we			(mi_we),
	      .mi_addr			(mi_addr[15:0]),
	      .mi_din			(mi_din[DW-1:0]),
	      .emesh_access_in		(etx_access),		 // Templated
	      .emesh_packet_in		(etx_packet[PW-1:0]));	 // Templated
   

   /************************************************************/
   /*ELINK PROTOCOL LOGIC                                      */
   /************************************************************/
   /*etx_protocol  AUTO_TEMPLATE (			       
                                  .etx_ack	   (etx_ack),
                                  .etx_rd_wait     (etx_rd_wait),
                                  .etx_wr_wait     (etx_wr_wait),
                                  .etx_\(.*\)      (emmu_\1[]),
    
                             );
   */
   etx_protocol etx_protocol (/*AUTOINST*/
			      // Outputs
			      .etx_rd_wait	(etx_rd_wait),	 // Templated
			      .etx_wr_wait	(etx_wr_wait),	 // Templated
			      .etx_ack		(etx_ack),	 // Templated
			      .tx_frame_par	(tx_frame_par[7:0]),
			      .tx_data_par	(tx_data_par[63:0]),
			      // Inputs
			      .etx_access	(emmu_access),	 // Templated
			      .etx_packet	(emmu_packet[PW-1:0]), // Templated
			      .ecfg_tx_tp_enable(ecfg_tx_tp_enable),
			      .reset		(reset),
			      .tx_lclk_div4	(tx_lclk_div4),
			      .tx_rd_wait	(tx_rd_wait),
			      .tx_wr_wait	(tx_wr_wait));

   
   /***********************************************************/
   /*ELINK TRANSMIT I/O LOGIC                                 */
   /***********************************************************/

   etx_io etx_io (
		    /*AUTOINST*/
		  // Outputs
		  .txo_lclk_p		(txo_lclk_p),
		  .txo_lclk_n		(txo_lclk_n),
		  .txo_frame_p		(txo_frame_p),
		  .txo_frame_n		(txo_frame_n),
		  .txo_data_p		(txo_data_p[7:0]),
		  .txo_data_n		(txo_data_n[7:0]),
		  .tx_wr_wait		(tx_wr_wait),
		  .tx_rd_wait		(tx_rd_wait),
		  // Inputs
		  .reset		(reset),
		  .txi_wr_wait_p	(txi_wr_wait_p),
		  .txi_wr_wait_n	(txi_wr_wait_n),
		  .txi_rd_wait_p	(txi_rd_wait_p),
		  .txi_rd_wait_n	(txi_rd_wait_n),
		  .tx_lclk_div4		(tx_lclk_div4),
		  .tx_lclk		(tx_lclk),
		  .tx_lclk90		(tx_lclk90),
		  .tx_frame_par		(tx_frame_par[7:0]),
		  .tx_data_par		(tx_data_par[63:0]),
		  .ecfg_tx_enable	(ecfg_tx_enable),
		  .ecfg_tx_gpio_enable	(ecfg_tx_gpio_enable),
		  .ecfg_dataout		(ecfg_dataout[8:0]));


   /************************************************************/
   /*Debug signals (async sampling)                            */
   /************************************************************/
   always @ (posedge mi_clk)
     begin
	ecfg_tx_debug[15:0] <= {2'b0,                     //15:14
				etx_rd_wait,              //13
				etx_wr_wait,              //12
				txrr_fifo_read,           //11			
				txrr_wait,                //10
				txrr_access,	          //9	 		
				txrd_fifo_read,           //8			
				txrd_wait,                //7
				txrd_access,	          //6
				txwr_fifo_read,           //5
				txwr_wait,                //4
				txwr_access,              //3
				txrr_fifo_full,           //2
				txrd_fifo_full,           //1
				txwr_fifo_full	          //0
				};
     end
   
endmodule // elink
// Local Variables:
// verilog-library-directories:("." "../../emmu/hdl" "../../memory/hdl")
// End:


/*
 Copyright (C) 2014 Adapteva, Inc.
 
 Contributed by Fred Huettig <fred@adapteva.com>
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
