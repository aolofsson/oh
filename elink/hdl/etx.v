module etx(/*AUTOARG*/
   // Outputs
   ecfg_tx_datain, ecfg_tx_debug, esaxi_emrq_full,
   esaxi_emrq_prog_full, esaxi_emwr_full, esaxi_emwr_prog_full,
   emaxi_emrr_full, emaxi_emrr_prog_full, tx_lclk_p, tx_lclk_n,
   tx_frame_p, tx_frame_n, tx_data_p, tx_data_n, mi_dout,
   // Inputs
   reset, tx_lclk, tx_lclk_out, tx_lclk_par, s_axi_aclk, m_axi_aclk,
   ecfg_tx_clkdiv, ecfg_tx_enable, ecfg_tx_gpio_enable,
   ecfg_tx_mmu_enable, ecfg_dataout, esaxi_emrq_wr_en,
   esaxi_emrq_wr_data, esaxi_emwr_wr_en, esaxi_emwr_wr_data,
   emaxi_emrr_wr_en, emaxi_emrr_wr_data, tx_wr_wait_p, tx_wr_wait_n,
   tx_rd_wait_p, tx_rd_wait_n, mi_clk, mi_en, mi_we, mi_addr, mi_din
   );
   parameter AW   = 32;
   parameter DW   = 32;
   parameter RFAW = 12;

   //Clocks and reset
   input         reset;
   input 	 tx_lclk;	       //high speed serdes clock
   input 	 tx_lclk_out;	       //lclk output
   input 	 tx_lclk_par;	       //slow speed parallel clock
   input 	 s_axi_aclk;           //clock for read request and write fifos
   input 	 m_axi_aclk;           //clock for read response fifo

   //Configuration signals
   input [3:0] 	 ecfg_tx_clkdiv;       //transmit clock divider
   input 	 ecfg_tx_enable;       //transmit output buffer enable   
  

   //gpio mode
   input 	 ecfg_tx_gpio_enable;    //sets output pins to constant values
   input 	 ecfg_tx_mmu_enable;     //sets output pins to constant values
   input [8:0] 	 ecfg_dataout;	       //data for gpio mode
   output [1:0]  ecfg_tx_datain;       //{wr_wait,rd_wait}
   
   //Testing
   output [15:0] ecfg_tx_debug;       //various debug signals
  

   //Read requests (from axi slave)
   input         esaxi_emrq_wr_en;
   input [103:0] esaxi_emrq_wr_data;
   output        esaxi_emrq_full;
   output 	 esaxi_emrq_prog_full;

   //Write requests (from axi slave)
   input         esaxi_emwr_wr_en;
   input [103:0] esaxi_emwr_wr_data;
   output        esaxi_emwr_full;
   output 	 esaxi_emwr_prog_full;

   //Read responses (from axi master)
   input         emaxi_emrr_wr_en;
   input [103:0] emaxi_emrr_wr_data;
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


   //MMU table configuration interface
   input 	    mi_clk;     //source synchronous clock
   input 	    mi_en;      //memory access 
   input  	    mi_we;      //byte wise write enable
   input [15:0]     mi_addr;    //table address
   input [31:0]     mi_din;     //input data  
   output [31:0]    mi_dout;    //read back data
   
   //regs
   reg [15:0] 	    ecfg_tx_debug; 
  
   /*AUTOOUTPUT*/

   /*AUTOINPUT*/

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			e_tx_access;		// From etx_arbiter of etx_arbiter.v
   wire			e_tx_ack;		// From etx_protocol of etx_protocol.v
   wire [3:0]		e_tx_ctrlmode;		// From etx_arbiter of etx_arbiter.v
   wire [31:0]		e_tx_data;		// From etx_arbiter of etx_arbiter.v
   wire [1:0]		e_tx_datamode;		// From etx_arbiter of etx_arbiter.v
   wire [31:0]		e_tx_dstaddr;		// From etx_arbiter of etx_arbiter.v
   wire			e_tx_rd_wait;		// From etx_protocol of etx_protocol.v
   wire [31:0]		e_tx_srcaddr;		// From etx_arbiter of etx_arbiter.v
   wire			e_tx_wr_wait;		// From etx_protocol of etx_protocol.v
   wire			e_tx_write;		// From etx_arbiter of etx_arbiter.v
   wire			emrq_empty;		// From s_rq_fifo of fifo_async_104x16.v
   wire [103:0]		emrq_rd_data;		// From s_rq_fifo of fifo_async_104x16.v
   wire			emrq_rd_en;		// From etx_arbiter of etx_arbiter.v
   wire			emrr_empty;		// From m_rr_fifo of fifo_async_104x16.v
   wire [103:0]		emrr_rd_data;		// From m_rr_fifo of fifo_async_104x16.v
   wire			emrr_rd_en;		// From etx_arbiter of etx_arbiter.v
   wire			emwr_empty;		// From s_wr_fifo of fifo_async_104x16.v
   wire [103:0]		emwr_rd_data;		// From s_wr_fifo of fifo_async_104x16.v
   wire			emwr_rd_en;		// From etx_arbiter of etx_arbiter.v
   wire [63:0]		tx_data_par;		// From etx_protocol of etx_protocol.v
   wire [7:0]		tx_frame_par;		// From etx_protocol of etx_protocol.v
   wire			tx_rd_wait;		// From etx_io of etx_io.v
   wire			tx_wr_wait;		// From etx_io of etx_io.v
   // End of automatics
   
   /************************************************************/
   /*FIFOs                                                     */
   /************************************************************/
   /*fifo_async_104x16 AUTO_TEMPLATE ( 
                                 // Outputs
			          .dout	(em@"(substring vl-cell-name  2 4)"_rd_data[103:0]),
                                  .prog_full	(e@"(substring vl-cell-name  0 1)"axi_em@"(substring vl-cell-name  2 4)"_prog_full),
                                  .empty	(em@"(substring vl-cell-name  2 4)"_empty),
                                  .full      (e@"(substring vl-cell-name  0 1)"axi_em@"(substring vl-cell-name  2 4)"_full),
                                  //Inputs
                                  .din	(e@"(substring vl-cell-name  0 1)"axi_em@"(substring vl-cell-name  2 4)"_wr_data[103:0]),
			          .wr_clk       (@"(substring vl-cell-name  0 1)"_axi_aclk),
                                  .wr_en	(e@"(substring vl-cell-name  0 1)"axi_em@"(substring vl-cell-name  2 4)"_wr_en),
                                  .rd_clk       (tx_lclk_par),
                                  .rd_en	(em@"(substring vl-cell-name  2 4)"_rd_en),
                                  .rst          (reset),
                                                     
        );
   */
   
   //Read request fifo (from slave)
   fifo_async_104x16  s_rq_fifo(/*AUTOINST*/
				// Outputs
				.dout		(emrq_rd_data[103:0]), // Templated
				.full		(esaxi_emrq_full), // Templated
				.empty		(emrq_empty),	 // Templated
				.prog_full	(esaxi_emrq_prog_full), // Templated
				// Inputs
				.rst		(reset),	 // Templated
				.wr_clk		(s_axi_aclk),	 // Templated
				.rd_clk		(tx_lclk_par),	 // Templated
				.din		(esaxi_emrq_wr_data[103:0]), // Templated
				.wr_en		(esaxi_emrq_wr_en), // Templated
				.rd_en		(emrq_rd_en));	 // Templated
   

   //Write fifo (from slave)
   fifo_async_104x16 s_wr_fifo(/*AUTOINST*/
			       // Outputs
			       .dout		(emwr_rd_data[103:0]), // Templated
			       .full		(esaxi_emwr_full), // Templated
			       .empty		(emwr_empty),	 // Templated
			       .prog_full	(esaxi_emwr_prog_full), // Templated
			       // Inputs
			       .rst		(reset),	 // Templated
			       .wr_clk		(s_axi_aclk),	 // Templated
			       .rd_clk		(tx_lclk_par),	 // Templated
			       .din		(esaxi_emwr_wr_data[103:0]), // Templated
			       .wr_en		(esaxi_emwr_wr_en), // Templated
			       .rd_en		(emwr_rd_en));	 // Templated
   

   //Read response fifo (from master)
   fifo_async_104x16  m_rr_fifo(/*AUTOINST*/
				// Outputs
				.dout		(emrr_rd_data[103:0]), // Templated
				.full		(emaxi_emrr_full), // Templated
				.empty		(emrr_empty),	 // Templated
				.prog_full	(emaxi_emrr_prog_full), // Templated
				// Inputs
				.rst		(reset),	 // Templated
				.wr_clk		(m_axi_aclk),	 // Templated
				.rd_clk		(tx_lclk_par),	 // Templated
				.din		(emaxi_emrr_wr_data[103:0]), // Templated
				.wr_en		(emaxi_emrr_wr_en), // Templated
				.rd_en		(emrr_rd_en));	 // Templated
   
   
   /************************************************************/
   /*ELINK TRANSMIT ARBITER                                    */
   /*-arbiter between write (slave), read request (slave),     */
   /* and read response channel (master)                       */
   /************************************************************/

   etx_arbiter etx_arbiter (
			      /*AUTOINST*/
			    // Outputs
			    .emwr_rd_en		(emwr_rd_en),
			    .emrq_rd_en		(emrq_rd_en),
			    .emrr_rd_en		(emrr_rd_en),
			    .e_tx_access	(e_tx_access),
			    .e_tx_write		(e_tx_write),
			    .e_tx_datamode	(e_tx_datamode[1:0]),
			    .e_tx_ctrlmode	(e_tx_ctrlmode[3:0]),
			    .e_tx_dstaddr	(e_tx_dstaddr[31:0]),
			    .e_tx_srcaddr	(e_tx_srcaddr[31:0]),
			    .e_tx_data		(e_tx_data[31:0]),
			    // Inputs
			    .tx_lclk_par	(tx_lclk_par),
			    .reset		(reset),
			    .emwr_rd_data	(emwr_rd_data[103:0]),
			    .emwr_empty		(emwr_empty),
			    .emrq_rd_data	(emrq_rd_data[103:0]),
			    .emrq_empty		(emrq_empty),
			    .emrr_rd_data	(emrr_rd_data[103:0]),
			    .emrr_empty		(emrr_empty),
			    .e_tx_rd_wait	(e_tx_rd_wait),
			    .e_tx_wr_wait	(e_tx_wr_wait),
			    .e_tx_ack		(e_tx_ack));
   

   /************************************************************/
   /*ELINK PROTOCOL LOGIC                                      */
   /*-translates the 104 bit emesh transaction to elink packeet*/
   /************************************************************/

   etx_protocol etx_protocol (/*AUTOINST*/
			      // Outputs
			      .e_tx_rd_wait	(e_tx_rd_wait),
			      .e_tx_wr_wait	(e_tx_wr_wait),
			      .e_tx_ack		(e_tx_ack),
			      .tx_frame_par	(tx_frame_par[7:0]),
			      .tx_data_par	(tx_data_par[63:0]),
			      .ecfg_tx_datain	(ecfg_tx_datain[1:0]),
			      // Inputs
			      .reset		(reset),
			      .e_tx_access	(e_tx_access),
			      .e_tx_write	(e_tx_write),
			      .e_tx_datamode	(e_tx_datamode[1:0]),
			      .e_tx_ctrlmode	(e_tx_ctrlmode[3:0]),
			      .e_tx_dstaddr	(e_tx_dstaddr[31:0]),
			      .e_tx_srcaddr	(e_tx_srcaddr[31:0]),
			      .e_tx_data	(e_tx_data[31:0]),
			      .tx_lclk_par	(tx_lclk_par),
			      .tx_rd_wait	(tx_rd_wait),
			      .tx_wr_wait	(tx_wr_wait));

   
   /***********************************************************/
   /*ELINK TRANSMIT I/O LOGIC                                 */
   /*-parallel data and frame as input                        */
   /*-serializes data for I/O                                 */  
   /***********************************************************/

   etx_io etx_io (
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
		  .tx_wr_wait_p		(tx_wr_wait_p),
		  .tx_wr_wait_n		(tx_wr_wait_n),
		  .tx_rd_wait_p		(tx_rd_wait_p),
		  .tx_rd_wait_n		(tx_rd_wait_n),
		  .tx_lclk_par		(tx_lclk_par),
		  .tx_lclk		(tx_lclk),
		  .tx_lclk_out		(tx_lclk_out),
		  .tx_frame_par		(tx_frame_par[7:0]),
		  .tx_data_par		(tx_data_par[63:0]),
		  .ecfg_tx_enable	(ecfg_tx_enable),
		  .ecfg_tx_gpio_enable	(ecfg_tx_gpio_enable),
		  .ecfg_tx_clkdiv	(ecfg_tx_clkdiv[3:0]),
		  .ecfg_dataout		(ecfg_dataout[8:0]));


   /************************************************************/
   /*Debug signals                                             */
   /************************************************************/
   always @ (posedge tx_lclk_par)
     begin
	ecfg_tx_debug[15:0] <= {2'b0,                     //15:14
				e_tx_rd_wait,             //13
				e_tx_wr_wait,             //12
				emrr_rd_en,               //11			
				emaxi_emrr_prog_full,     //10
				emaxi_emrr_wr_en,	  //9			
				emrq_rd_en,               //8			
				esaxi_emrq_prog_full,     //7
				esaxi_emrq_wr_en,	  //6	 
				emwr_rd_en,               //5
				esaxi_emwr_prog_full,     //4
				esaxi_emwr_wr_en,         //3
				emaxi_emrr_full,          //2
				esaxi_emrq_full,          //1
				esaxi_emwr_full	          //0	 
				};
     end
   
endmodule // elink
// Local Variables:
// verilog-library-directories:("." "../../stubs/hdl")
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
