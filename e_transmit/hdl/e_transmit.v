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

module e_transmit(/*AUTOARG*/
   // Outputs
   esaxi_emrq_full, esaxi_emrq_prog_full, esaxi_emwr_full,
   esaxi_emwr_prog_full, emaxi_emrr_full, emaxi_emrr_prog_full,
   tx_lclk_p, tx_lclk_n, tx_frame_p, tx_frame_n, tx_data_p, tx_data_n,
   // Inputs
   reset, txlclk_out, txlclk_p, txlclk_s, s_axi_aclk, m_axi_aclk,
   ecfg_dataout, ecfg_tx_clkdiv, ecfg_tx_enable, ecfg_tx_gpio_mode,
   esaxi_emrq_wr_en, esaxi_emrq_wr_data, esaxi_emwr_wr_en,
   esaxi_emwr_wr_data, emaxi_emrr_wr_en, emaxi_emrr_wr_data,
   tx_wr_wait_p, tx_wr_wait_n, tx_rd_wait_p, tx_rd_wait_n
   );


   //Clocks and reset
   input         reset;
   input 	 txlclk_out;	        //lclk output
   input 	 txlclk_p;	       //slow speed parallel clock for serializer
   input 	 txlclk_s;	       //high speed serdes clock
   input 	 s_axi_aclk;           //clock for slave read request and write fifos
   input 	 m_axi_aclk;           //clock for master read response fifo
   
   //Configuration signals
   input [10:0]  ecfg_dataout;	       //data for gpio mode 
   input [3:0] 	 ecfg_tx_clkdiv;       //transmit clock divider
   input 	 ecfg_tx_enable;       //transmit output buffer enable
   input 	 ecfg_tx_gpio_mode;

   //Read requests (from axi slave)
   input         esaxi_emrq_wr_en;
   input [102:0] esaxi_emrq_wr_data;
   output        esaxi_emrq_full;
   output 	 esaxi_emrq_prog_full;

   //Write requests (from axi slave)
   input         esaxi_emwr_wr_en;
   input [102:0] esaxi_emwr_wr_data;
   output        esaxi_emwr_full;
   output 	 esaxi_emwr_prog_full;

   //Read responses (from axi master)
   input         emaxi_emrr_wr_en;
   input [102:0] emaxi_emrr_wr_data;
   output        emaxi_emrr_full;
   output 	 emaxi_emrr_prog_full;
   
   //Transmit signals for IO
   output        tx_lclk_p;        //link clock output (up to 500MHz)
   output        tx_lclk_n;
   output        tx_frame_p;       //transaction frame signal
   output        tx_frame_n;
   output [7:0]  tx_data_p;        //transmit data (dual data rate)
   output [7:0]  tx_data_n;          
   input 	 tx_wr_wait_p;     //incoming pushback on write transactions
   input 	 tx_wr_wait_n;    
   input 	 tx_rd_wait_p;     //incoming pushback on read transactions
   input 	 tx_rd_wait_n;    
  
   /*AUTOOUTPUT*/
   /*AUTOINPUT*/

   /************************************************************/
   /*FIFOs                                                     */
   /************************************************************/
   /*fifo_103x16 AUTO_TEMPLATE ( 
                                 // Outputs
			          .dout		(em@"(substring vl-cell-name  2 4)"_rd_data[102:0]),
                                  .prog_full	(e@"(substring vl-cell-name  0 1)"axi_em@"(substring vl-cell-name  2 4)"_prog_full),
                                  .empty	        (em@"(substring vl-cell-name  2 4)"_empty),
                                  .full	        (e@"(substring vl-cell-name  0 1)"axi_em@"(substring vl-cell-name  2 4)"_full),
                                  //Inputs
                                  .din		(e@"(substring vl-cell-name  0 1)"axi_em@"(substring vl-cell-name  2 4)"_wr_data[103:0]),
			          .wr_clk       (@"(substring vl-cell-name  0 1)"_axi_aclk),
                                  .wr_en	(e@"(substring vl-cell-name  0 1)"axi_em@"(substring vl-cell-name  2 4)"_wr_en),
                                  .rd_clk       (txlclk_p),
                                  .rd_en	(em@"(substring vl-cell-name  2 4)"_rd_en),
                                  .rst          (reset),
                                                     
        );
   */
   //Read request fifo (from slave)
   fifo_103x16 s_rq_fifo(/*AUTOINST*/
			 // Outputs
			 .dout			(emrq_rd_data[102:0]), // Templated
			 .empty			(emrq_empty),	 // Templated
			 .full			(esaxi_emrq_full), // Templated
			 .prog_full		(esaxi_emrq_prog_full), // Templated
			 // Inputs
			 .din			(esaxi_emrq_wr_data[103:0]), // Templated
			 .rd_clk		(txlclk_p),	 // Templated
			 .rd_en			(emrq_rd_en),	 // Templated
			 .rst			(reset),	 // Templated
			 .wr_clk		(s_axi_aclk),	 // Templated
			 .wr_en			(esaxi_emrq_wr_en)); // Templated
   

   //Write fifo (from slave)
   fifo_103x16 s_wr_fifo(/*AUTOINST*/
			 // Outputs
			 .dout			(emwr_rd_data[102:0]), // Templated
			 .empty			(emwr_empty),	 // Templated
			 .full			(esaxi_emwr_full), // Templated
			 .prog_full		(esaxi_emwr_prog_full), // Templated
			 // Inputs
			 .din			(esaxi_emwr_wr_data[103:0]), // Templated
			 .rd_clk		(txlclk_p),	 // Templated
			 .rd_en			(emwr_rd_en),	 // Templated
			 .rst			(reset),	 // Templated
			 .wr_clk		(s_axi_aclk),	 // Templated
			 .wr_en			(esaxi_emwr_wr_en)); // Templated
   

   //Read response fifo (from master)
   fifo_103x16 m_rr_fifo(/*AUTOINST*/
			 // Outputs
			 .dout			(emrr_rd_data[102:0]), // Templated
			 .empty			(emrr_empty),	 // Templated
			 .full			(emaxi_emrr_full), // Templated
			 .prog_full		(emaxi_emrr_prog_full), // Templated
			 // Inputs
			 .din			(emaxi_emrr_wr_data[103:0]), // Templated
			 .rd_clk		(txlclk_p),	 // Templated
			 .rd_en			(emrr_rd_en),	 // Templated
			 .rst			(reset),	 // Templated
			 .wr_clk		(m_axi_aclk),	 // Templated
			 .wr_en			(emaxi_emrr_wr_en)); // Templated
   
   
   /************************************************************/
   /*ELINK TRANSMIT ARBITER                                    */
   /*-arbiter between write (slave), read request (slave),     */
   /* and read response channel (master)                       */
   /********************1****************************************/

   e_tx_arbiter e_tx_arbiter (.clk		(txlclk_p),
			      /*AUTOINST*/
			      // Outputs
			      .emwr_rd_en	(emwr_rd_en),
			      .emrq_rd_en	(emrq_rd_en),
			      .emrr_rd_en	(emrr_rd_en),
			      .e_tx_access	(e_tx_access),
			      .e_tx_write	(e_tx_write),
			      .e_tx_datamode	(e_tx_datamode[1:0]),
			      .e_tx_ctrlmode	(e_tx_ctrlmode[3:0]),
			      .e_tx_dstaddr	(e_tx_dstaddr[31:0]),
			      .e_tx_srcaddr	(e_tx_srcaddr[31:0]),
			      .e_tx_data	(e_tx_data[31:0]),
			      // Inputs
			      .reset		(reset),
			      .emwr_rd_data	(emwr_rd_data[102:0]),
			      .emwr_empty	(emwr_empty),
			      .emrq_rd_data	(emrq_rd_data[102:0]),
			      .emrq_empty	(emrq_empty),
			      .emrr_rd_data	(emrr_rd_data[102:0]),
			      .emrr_empty	(emrr_empty),
			      .e_tx_rd_wait	(e_tx_rd_wait),
			      .e_tx_wr_wait	(e_tx_wr_wait),
			      .e_tx_ack		(e_tx_ack));
   

   /************************************************************/
   /*ELINK PROTOCOL LOGIC                                      */
   /*-translates the 104 bit emesh transaction to elink packeet*/
   /************************************************************/

   e_tx_protocol e_tx_protocol (/*AUTOINST*/
				// Outputs
				.e_tx_rd_wait	(e_tx_rd_wait),
				.e_tx_wr_wait	(e_tx_wr_wait),
				.e_tx_ack	(e_tx_ack),
				.txframe_p	(txframe_p[7:0]),
				.txdata_p	(txdata_p[63:0]),
				// Inputs
				.reset		(reset),
				.e_tx_access	(e_tx_access),
				.e_tx_write	(e_tx_write),
				.e_tx_datamode	(e_tx_datamode[1:0]),
				.e_tx_ctrlmode	(e_tx_ctrlmode[3:0]),
				.e_tx_dstaddr	(e_tx_dstaddr[31:0]),
				.e_tx_srcaddr	(e_tx_srcaddr[31:0]),
				.e_tx_data	(e_tx_data[31:0]),
				.txlclk_p	(txlclk_p),
				.tx_rd_wait	(tx_rd_wait),
				.tx_wr_wait	(tx_wr_wait));

   
   /***********************************************************/
   /*ELINK TRANSMIT I/O LOGIC                                 */
   /*-parallel data and frame as input                        */
   /*-serializes data for I/O                                 */  
   /***********************************************************/

   e_tx_io e_tx_io (.ioreset		(reset),
		    /*AUTOINST*/
		    // Outputs
		    .tx_lclk_p		(tx_lclk_p),
		    .tx_lclk_n		(tx_lclk_n),
		    .tx_frame_p		(tx_frame_p),
		    .tx_frame_n		(tx_frame_n),
		    .tx_data_p		(tx_data_p[7:0]),
		    .tx_data_n		(tx_data_n[7:0]),
		    .tx_wr_wait		(tx_wr_wait),
		    .tx_rd_wait		(tx_rd_wait),
		    // Inputs
		    .reset		(reset),
		    .tx_wr_wait_p	(tx_wr_wait_p),
		    .tx_wr_wait_n	(tx_wr_wait_n),
		    .tx_rd_wait_p	(tx_rd_wait_p),
		    .tx_rd_wait_n	(tx_rd_wait_n),
		    .txlclk_p		(txlclk_p),
		    .txlclk_s		(txlclk_s),
		    .txlclk_out		(txlclk_out),
		    .txframe_p		(txframe_p[7:0]),
		    .txdata_p		(txdata_p[63:0]),
		    .ecfg_tx_enable	(ecfg_tx_enable),
		    .ecfg_tx_gpio_mode	(ecfg_tx_gpio_mode),
		    .ecfg_tx_clkdiv	(ecfg_tx_clkdiv[3:0]),
		    .ecfg_dataout	(ecfg_dataout[10:0]));
   
   
endmodule // elink
// Local Variables:
// verilog-library-directories:("." "../../stubs/hdl")
// End:


