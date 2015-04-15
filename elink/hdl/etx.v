module etx(/*AUTOARG*/
   // Outputs
   ecfg_tx_datain, ecfg_tx_debug, emrq_progfull, emwr_progfull,
   emrr_progfull, txo_lclk_p, txo_lclk_n, txo_frame_p, txo_frame_n,
   txo_data_p, txo_data_n, mi_dout,
   // Inputs
   reset, tx_lclk, tx_lclk_out, tx_lclk_par, s_axi_aclk, m_axi_aclk,
   ecfg_tx_enable, ecfg_tx_gpio_enable, ecfg_tx_mmu_enable,
   ecfg_dataout, emrq_access, emrq_write, emrq_datamode,
   emrq_ctrlmode, emrq_dstaddr, emrq_data, emrq_srcaddr, emwr_access,
   emwr_write, emwr_datamode, emwr_ctrlmode, emwr_dstaddr, emwr_data,
   emwr_srcaddr, emrr_access, emrr_write, emrr_datamode,
   emrr_ctrlmode, emrr_dstaddr, emrr_data, emrr_srcaddr,
   txi_wr_wait_p, txi_wr_wait_n, txi_rd_wait_p, txi_rd_wait_n, mi_clk,
   mi_en, mi_we, mi_addr, mi_din
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
   input 	 ecfg_tx_enable;       //transmit output buffer enable   
  

   //gpio mode
   input 	 ecfg_tx_gpio_enable;    //sets output pins to constant values
   input 	 ecfg_tx_mmu_enable;     //sets output pins to constant values
   input [8:0] 	 ecfg_dataout;	       //data for gpio mode
   output [1:0]  ecfg_tx_datain;       //{wr_wait,rd_wait}
   
   //Testing
   output [15:0] ecfg_tx_debug;       //various debug signals
  

   //Read requests (from axi slave)
   input 	 emrq_access;
   input 	 emrq_write;
   input [1:0] 	 emrq_datamode;
   input [3:0] 	 emrq_ctrlmode;
   input [31:0]  emrq_dstaddr;
   input [31:0]  emrq_data;
   input [31:0]  emrq_srcaddr;  
   output 	 emrq_progfull;

   //Write requests (from axi slave)
   input 	 emwr_access;
   input 	 emwr_write;
   input [1:0] 	 emwr_datamode;
   input [3:0] 	 emwr_ctrlmode;
   input [31:0]  emwr_dstaddr;
   input [31:0]  emwr_data;
   input [31:0]  emwr_srcaddr;  
   output 	 emwr_progfull;

   //Read responses (from axi master)
   input 	 emrr_access;
   input 	 emrr_write;
   input [1:0] 	 emrr_datamode;
   input [3:0] 	 emrr_ctrlmode;
   input [31:0]  emrr_dstaddr;
   input [31:0]  emrr_data;
   input [31:0]  emrr_srcaddr;  
   output 	 emrr_progfull;
   
   //Transmit signals for IO
   output        txo_lclk_p, txo_lclk_n;        //tx clock (up to 500MHz)
   output        txo_frame_p, txo_frame_n;     //tx frame signal
   output [7:0]  txo_data_p, txo_data_n;       //tx data (dual data rate)
   input 	 txi_wr_wait_p,txi_wr_wait_n;  //tx write pushback
   input 	 txi_rd_wait_p, txi_rd_wait_n; //tx read pushback

   //MMU table configuration interface
   input 	 mi_clk;     //source synchronous clock
   input 	 mi_en;      //memory access 
   input 	 mi_we;      //byte wise write enable
   input [15:0]  mi_addr;    //table address
   input [31:0]  mi_din;     //input data  
   output [31:0] mi_dout;    //read back data
   
   //debug declarations
   reg [15:0] 	 ecfg_tx_debug; 
   wire 	 emwr_full;
   wire 	 emrr_full;
   wire 	 emrq_full;
   
   /*AUTOOUTPUT*/
   /*AUTOINPUT*/
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			emrq_fifo_access;	// From s_rq_fifo of fifo_async_emesh.v
   wire [3:0]		emrq_fifo_ctrlmode;	// From s_rq_fifo of fifo_async_emesh.v
   wire [31:0]		emrq_fifo_data;		// From s_rq_fifo of fifo_async_emesh.v
   wire [1:0]		emrq_fifo_datamode;	// From s_rq_fifo of fifo_async_emesh.v
   wire [31:0]		emrq_fifo_dstaddr;	// From s_rq_fifo of fifo_async_emesh.v
   wire [31:0]		emrq_fifo_srcaddr;	// From s_rq_fifo of fifo_async_emesh.v
   wire			emrq_fifo_write;	// From s_rq_fifo of fifo_async_emesh.v
   wire			emrq_rd_en;		// From etx_arbiter of etx_arbiter.v
   wire			emrr_fifo_access;	// From m_rr_fifo of fifo_async_emesh.v
   wire [3:0]		emrr_fifo_ctrlmode;	// From m_rr_fifo of fifo_async_emesh.v
   wire [31:0]		emrr_fifo_data;		// From m_rr_fifo of fifo_async_emesh.v
   wire [1:0]		emrr_fifo_datamode;	// From m_rr_fifo of fifo_async_emesh.v
   wire [31:0]		emrr_fifo_dstaddr;	// From m_rr_fifo of fifo_async_emesh.v
   wire [31:0]		emrr_fifo_srcaddr;	// From m_rr_fifo of fifo_async_emesh.v
   wire			emrr_fifo_write;	// From m_rr_fifo of fifo_async_emesh.v
   wire			emrr_rd_en;		// From etx_arbiter of etx_arbiter.v
   wire			emwr_fifo_access;	// From s_wr_fifo of fifo_async_emesh.v
   wire [3:0]		emwr_fifo_ctrlmode;	// From s_wr_fifo of fifo_async_emesh.v
   wire [31:0]		emwr_fifo_data;		// From s_wr_fifo of fifo_async_emesh.v
   wire [1:0]		emwr_fifo_datamode;	// From s_wr_fifo of fifo_async_emesh.v
   wire [31:0]		emwr_fifo_dstaddr;	// From s_wr_fifo of fifo_async_emesh.v
   wire [31:0]		emwr_fifo_srcaddr;	// From s_wr_fifo of fifo_async_emesh.v
   wire			emwr_fifo_write;	// From s_wr_fifo of fifo_async_emesh.v
   wire			emwr_rd_en;		// From etx_arbiter of etx_arbiter.v
   wire			etx_access;		// From etx_arbiter of etx_arbiter.v
   wire			etx_ack;		// From etx_protocol of etx_protocol.v
   wire [3:0]		etx_ctrlmode;		// From etx_arbiter of etx_arbiter.v
   wire [31:0]		etx_data;		// From etx_arbiter of etx_arbiter.v
   wire [1:0]		etx_datamode;		// From etx_arbiter of etx_arbiter.v
   wire [31:0]		etx_dstaddr;		// From etx_arbiter of etx_arbiter.v
   wire			etx_rd_wait;		// From etx_protocol of etx_protocol.v
   wire [31:0]		etx_srcaddr;		// From etx_arbiter of etx_arbiter.v
   wire			etx_wr_wait;		// From etx_protocol of etx_protocol.v
   wire			etx_write;		// From etx_arbiter of etx_arbiter.v
   wire [63:0]		tx_data_par;		// From etx_protocol of etx_protocol.v
   wire [7:0]		tx_frame_par;		// From etx_protocol of etx_protocol.v
   wire			tx_rd_wait;		// From etx_io of etx_io.v
   wire			tx_wr_wait;		// From etx_io of etx_io.v
   // End of automatics
   

   /************************************************************/
   /*FIFOs                                                     */
   /************************************************************/
   /*fifo_async_emesh  AUTO_TEMPLATE (
			       // Outputs
			       
			       .emesh_\(.*\)_out(em@"(substring vl-cell-name  2 4)"_fifo_\1[]),
			       .fifo_empty	(em@"(substring vl-cell-name  2 4)"_fifo_empty),
			       .fifo_full	(em@"(substring vl-cell-name  2 4)"_fifo_full),
			       .fifo_progfull	(em@"(substring vl-cell-name  2 4)"_progfull),
			       // Inputs
			       .rd_clk		(tx_lclk_par),
			       .wr_clk		(@"(substring vl-cell-name  0 1)"_axi_aclk),
			       .reset		(reset),
			       .fifo_read	(em@"(substring vl-cell-name  2 4)"_rd_en),
                               .emesh_\(.*\)_in	(em@"(substring vl-cell-name  2 4)"_\1[]),
    );
    */


   
   //Write fifo (from slave)
   fifo_async_emesh s_wr_fifo(.fifo_full	(emwr_full),
			      /*AUTOINST*/
			      // Outputs
			      .emesh_access_out	(emwr_fifo_access), // Templated
			      .emesh_write_out	(emwr_fifo_write), // Templated
			      .emesh_datamode_out(emwr_fifo_datamode[1:0]), // Templated
			      .emesh_ctrlmode_out(emwr_fifo_ctrlmode[3:0]), // Templated
			      .emesh_dstaddr_out(emwr_fifo_dstaddr[31:0]), // Templated
			      .emesh_data_out	(emwr_fifo_data[31:0]), // Templated
			      .emesh_srcaddr_out(emwr_fifo_srcaddr[31:0]), // Templated
			      .fifo_progfull	(emwr_progfull), // Templated
			      // Inputs
			      .rd_clk		(tx_lclk_par),	 // Templated
			      .wr_clk		(s_axi_aclk),	 // Templated
			      .reset		(reset),	 // Templated
			      .emesh_access_in	(emwr_access),	 // Templated
			      .emesh_write_in	(emwr_write),	 // Templated
			      .emesh_datamode_in(emwr_datamode[1:0]), // Templated
			      .emesh_ctrlmode_in(emwr_ctrlmode[3:0]), // Templated
			      .emesh_dstaddr_in	(emwr_dstaddr[31:0]), // Templated
			      .emesh_data_in	(emwr_data[31:0]), // Templated
			      .emesh_srcaddr_in	(emwr_srcaddr[31:0]), // Templated
			      .fifo_read	(emwr_rd_en));	 // Templated
   
   //Read request fifo (from slave)
   fifo_async_emesh  s_rq_fifo(.fifo_full	(emrq_full),
				/*AUTOINST*/
			       // Outputs
			       .emesh_access_out(emrq_fifo_access), // Templated
			       .emesh_write_out	(emrq_fifo_write), // Templated
			       .emesh_datamode_out(emrq_fifo_datamode[1:0]), // Templated
			       .emesh_ctrlmode_out(emrq_fifo_ctrlmode[3:0]), // Templated
			       .emesh_dstaddr_out(emrq_fifo_dstaddr[31:0]), // Templated
			       .emesh_data_out	(emrq_fifo_data[31:0]), // Templated
			       .emesh_srcaddr_out(emrq_fifo_srcaddr[31:0]), // Templated
			       .fifo_progfull	(emrq_progfull), // Templated
			       // Inputs
			       .rd_clk		(tx_lclk_par),	 // Templated
			       .wr_clk		(s_axi_aclk),	 // Templated
			       .reset		(reset),	 // Templated
			       .emesh_access_in	(emrq_access),	 // Templated
			       .emesh_write_in	(emrq_write),	 // Templated
			       .emesh_datamode_in(emrq_datamode[1:0]), // Templated
			       .emesh_ctrlmode_in(emrq_ctrlmode[3:0]), // Templated
			       .emesh_dstaddr_in(emrq_dstaddr[31:0]), // Templated
			       .emesh_data_in	(emrq_data[31:0]), // Templated
			       .emesh_srcaddr_in(emrq_srcaddr[31:0]), // Templated
			       .fifo_read	(emrq_rd_en));	 // Templated
   

  
   //Read response fifo (from master)
   fifo_async_emesh  m_rr_fifo(.fifo_full	(emrr_full),
				/*AUTOINST*/
			       // Outputs
			       .emesh_access_out(emrr_fifo_access), // Templated
			       .emesh_write_out	(emrr_fifo_write), // Templated
			       .emesh_datamode_out(emrr_fifo_datamode[1:0]), // Templated
			       .emesh_ctrlmode_out(emrr_fifo_ctrlmode[3:0]), // Templated
			       .emesh_dstaddr_out(emrr_fifo_dstaddr[31:0]), // Templated
			       .emesh_data_out	(emrr_fifo_data[31:0]), // Templated
			       .emesh_srcaddr_out(emrr_fifo_srcaddr[31:0]), // Templated
			       .fifo_progfull	(emrr_progfull), // Templated
			       // Inputs
			       .rd_clk		(tx_lclk_par),	 // Templated
			       .wr_clk		(m_axi_aclk),	 // Templated
			       .reset		(reset),	 // Templated
			       .emesh_access_in	(emrr_access),	 // Templated
			       .emesh_write_in	(emrr_write),	 // Templated
			       .emesh_datamode_in(emrr_datamode[1:0]), // Templated
			       .emesh_ctrlmode_in(emrr_ctrlmode[3:0]), // Templated
			       .emesh_dstaddr_in(emrr_dstaddr[31:0]), // Templated
			       .emesh_data_in	(emrr_data[31:0]), // Templated
			       .emesh_srcaddr_in(emrr_srcaddr[31:0]), // Templated
			       .fifo_read	(emrr_rd_en));	 // Templated
   
   
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
			    .etx_access		(etx_access),
			    .etx_write		(etx_write),
			    .etx_datamode	(etx_datamode[1:0]),
			    .etx_ctrlmode	(etx_ctrlmode[3:0]),
			    .etx_dstaddr	(etx_dstaddr[31:0]),
			    .etx_srcaddr	(etx_srcaddr[31:0]),
			    .etx_data		(etx_data[31:0]),
			    // Inputs
			    .tx_lclk_par	(tx_lclk_par),
			    .reset		(reset),
			    .emwr_fifo_access	(emwr_fifo_access),
			    .emwr_fifo_write	(emwr_fifo_write),
			    .emwr_fifo_datamode	(emwr_fifo_datamode[1:0]),
			    .emwr_fifo_ctrlmode	(emwr_fifo_ctrlmode[3:0]),
			    .emwr_fifo_dstaddr	(emwr_fifo_dstaddr[31:0]),
			    .emwr_fifo_data	(emwr_fifo_data[31:0]),
			    .emwr_fifo_srcaddr	(emwr_fifo_srcaddr[31:0]),
			    .emrq_fifo_access	(emrq_fifo_access),
			    .emrq_fifo_write	(emrq_fifo_write),
			    .emrq_fifo_datamode	(emrq_fifo_datamode[1:0]),
			    .emrq_fifo_ctrlmode	(emrq_fifo_ctrlmode[3:0]),
			    .emrq_fifo_dstaddr	(emrq_fifo_dstaddr[31:0]),
			    .emrq_fifo_data	(emrq_fifo_data[31:0]),
			    .emrq_fifo_srcaddr	(emrq_fifo_srcaddr[31:0]),
			    .emrr_fifo_access	(emrr_fifo_access),
			    .emrr_fifo_write	(emrr_fifo_write),
			    .emrr_fifo_datamode	(emrr_fifo_datamode[1:0]),
			    .emrr_fifo_ctrlmode	(emrr_fifo_ctrlmode[3:0]),
			    .emrr_fifo_dstaddr	(emrr_fifo_dstaddr[31:0]),
			    .emrr_fifo_data	(emrr_fifo_data[31:0]),
			    .emrr_fifo_srcaddr	(emrr_fifo_srcaddr[31:0]),
			    .etx_rd_wait	(etx_rd_wait),
			    .etx_wr_wait	(etx_wr_wait),
			    .etx_ack		(etx_ack));
   

   /************************************************************/
   /*ELINK PROTOCOL LOGIC                                      */
   /*-translates the 104 bit emesh transaction to elink packeet*/
   /************************************************************/

   etx_protocol etx_protocol (/*AUTOINST*/
			      // Outputs
			      .etx_rd_wait	(etx_rd_wait),
			      .etx_wr_wait	(etx_wr_wait),
			      .etx_ack		(etx_ack),
			      .tx_frame_par	(tx_frame_par[7:0]),
			      .tx_data_par	(tx_data_par[63:0]),
			      .ecfg_tx_datain	(ecfg_tx_datain[1:0]),
			      // Inputs
			      .reset		(reset),
			      .etx_access	(etx_access),
			      .etx_write	(etx_write),
			      .etx_datamode	(etx_datamode[1:0]),
			      .etx_ctrlmode	(etx_ctrlmode[3:0]),
			      .etx_dstaddr	(etx_dstaddr[31:0]),
			      .etx_srcaddr	(etx_srcaddr[31:0]),
			      .etx_data		(etx_data[31:0]),
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
		  .tx_lclk_par		(tx_lclk_par),
		  .tx_lclk		(tx_lclk),
		  .tx_lclk_out		(tx_lclk_out),
		  .tx_frame_par		(tx_frame_par[7:0]),
		  .tx_data_par		(tx_data_par[63:0]),
		  .ecfg_tx_enable	(ecfg_tx_enable),
		  .ecfg_tx_gpio_enable	(ecfg_tx_gpio_enable),
		  .ecfg_dataout		(ecfg_dataout[8:0]));


   /************************************************************/
   /*Debug signals                                             */
   /************************************************************/
   always @ (posedge tx_lclk_par)
     begin
	ecfg_tx_debug[15:0] <= {2'b0,                     //15:14
				etx_rd_wait,              //13
				etx_wr_wait,              //12
				emrr_rd_en,               //11			
				emrr_progfull,            //10
				emrr_access,	          //9			
				emrq_rd_en,               //8			
				emrq_progfull,            //7
				emrq_access,	          //6	 
				emwr_rd_en,               //5
				emwr_progfull,            //4
				emwr_access,              //3
				emrr_full,                //2
				emrq_full,                //1
				emwr_full	          //0	 
				};
     end
   
endmodule // elink
// Local Variables:
// verilog-library-directories:("." "../../stubs/hdl" "../../memory/hdl")
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
