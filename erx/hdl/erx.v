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

module erx (/*AUTOARG*/
   // Outputs
   ecfg_rx_debug, ecfg_datain, mi_dout, emaxi_emwr_empty,
   emaxi_emwr_rd_data, emaxi_emrq_empty, emaxi_emrq_rd_data,
   esaxi_emrr_empty, esaxi_emrr_rd_data, rx_wr_wait_p, rx_wr_wait_n,
   rx_rd_wait_p, rx_rd_wait_n,
   // Inputs
   reset, s_axi_aclk, m_axi_aclk, ecfg_rx_enable, ecfg_rx_mmu_mode,
   ecfg_rx_gpio_mode, ecfg_dataout, mi_clk, mi_en, mi_we, mi_addr,
   mi_din, emaxi_emwr_rd_en, emaxi_emrq_rd_en, esaxi_emrr_rd_en,
   rx_lclk_p, rx_lclk_n, rx_frame_p, rx_frame_n, rx_data_p, rx_data_n
   );

   parameter AW   = 32;
   parameter DW   = 32;
   parameter RFAW = 13;
   parameter MW   = 44; //width of MMU lookup table
   

   //Clocks and reset
   input          reset;
   input          s_axi_aclk;        //clock for host read response fifo
   input 	  m_axi_aclk;        //clock for read request and write fifo
   
   //Configuration signals  
   input 	  ecfg_rx_enable;    //receiver enable
   input 	  ecfg_rx_mmu_mode;  //enable mmu   
   output [15:0]  ecfg_rx_debug;     //various debug signals
   input 	  ecfg_rx_gpio_mode; //mode for sampling elink pins directly
   input [1:0] 	  ecfg_dataout;	     //data for pins in direct mode
   output [8:0]   ecfg_datain;       //samples elink pins

   //MMU table configuration interface
   input 	    mi_clk;     //source synchronous clock
   input 	    mi_en;      //memory access 
   input [3:0] 	    mi_we;      //byte wise write enable
   input [15:0]     mi_addr;    //table address
   input [31:0]     mi_din;     //input data  
   output [31:0]    mi_dout;    //read back data
   
   //Writes (to axi master)
   input 	  emaxi_emwr_rd_en;
   output 	  emaxi_emwr_empty;
   output [102:0] emaxi_emwr_rd_data;

   //Read requests (to axi master)
   input 	  emaxi_emrq_rd_en;
   output 	  emaxi_emrq_empty;
   output [102:0] emaxi_emrq_rd_data;

   //Read responses (to slave) 
   input 	  esaxi_emrr_rd_en;
   output 	  esaxi_emrr_empty;
   output [102:0] esaxi_emrr_rd_data;

   //IO Pins
   input 	  rx_lclk_p;        //link clock output (up to 500MHz)
   input 	  rx_lclk_n;
   input 	  rx_frame_p;       //transaction frame signal
   input 	  rx_frame_n;
   input [7:0] 	  rx_data_p;        //transmit data (dual data rate)
   input [7:0] 	  rx_data_n;          
   output 	  rx_wr_wait_p;     //incoming pushback on write transactions
   output 	  rx_wr_wait_n;    
   output 	  rx_rd_wait_p;     //incoming pushback on read transactions
   output 	  rx_rd_wait_n;    

   /*AUTOOUTPUT*/
   /*AUTOINPUT*/
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			emesh_rx_access;	// From erx_protocol of erx_protocol.v
   wire [3:0]		emesh_rx_ctrlmode;	// From erx_protocol of erx_protocol.v
   wire [31:0]		emesh_rx_data;		// From erx_protocol of erx_protocol.v
   wire [1:0]		emesh_rx_datamode;	// From erx_protocol of erx_protocol.v
   wire [31:0]		emesh_rx_dstaddr;	// From erx_protocol of erx_protocol.v
   wire			emesh_rx_rd_wait;	// From erx_disty of erx_disty.v
   wire [31:0]		emesh_rx_srcaddr;	// From erx_protocol of erx_protocol.v
   wire			emesh_rx_wr_wait;	// From erx_disty of erx_disty.v
   wire			emesh_rx_write;		// From erx_protocol of erx_protocol.v
   wire			emmu_access;		// From emmu of emmu.v
   wire [3:0]		emmu_ctrlmode;		// From emmu of emmu.v
   wire [DW-1:0]	emmu_data;		// From emmu of emmu.v
   wire [1:0]		emmu_datamode;		// From emmu of emmu.v
   wire [63:0]		emmu_dstaddr;		// From emmu of emmu.v
   wire [AW-1:0]	emmu_srcaddr;		// From emmu of emmu.v
   wire			emmu_write;		// From emmu of emmu.v
   wire			emrq_full;		// From m_rq_fifo of fifo_async_103x32.v
   wire			emrq_progfull;		// From m_rq_fifo of fifo_async_103x32.v
   wire [102:0]		emrq_wr_data;		// From erx_disty of erx_disty.v
   wire			emrq_wr_en;		// From erx_disty of erx_disty.v
   wire			emrr_full;		// From s_rr_fifo of fifo_async_103x32.v
   wire			emrr_progfull;		// From s_rr_fifo of fifo_async_103x32.v
   wire [102:0]		emrr_wr_data;		// From erx_disty of erx_disty.v
   wire			emrr_wr_en;		// From erx_disty of erx_disty.v
   wire			emwr_full;		// From m_wr_fifo of fifo_async_103x32.v
   wire			emwr_progfull;		// From m_wr_fifo of fifo_async_103x32.v
   wire [102:0]		emwr_wr_data;		// From erx_disty of erx_disty.v
   wire			emwr_wr_en;		// From erx_disty of erx_disty.v
   wire [63:0]		rx_data_par;		// From erx_io of erx_io.v
   wire [7:0]		rx_frame_par;		// From erx_io of erx_io.v
   wire			rx_lclk_div4;		// From erx_io of erx_io.v
   wire			rx_rd_wait;		// From erx_protocol of erx_protocol.v
   wire			rx_wr_wait;		// From erx_protocol of erx_protocol.v
   // End of automatics

   //regs
   reg [15:0] 	ecfg_rx_debug;
   
   /************************************************************/
   /*FIFOs                                                     */
   /*(for AXI 1. read request, 2. write, and 3. read response) */
   /************************************************************/

   /*fifo_async_103x32 AUTO_TEMPLATE ( 
         //outputs
         .dout        (e@"(substring vl-cell-name  0 1)"axi_em@"(substring vl-cell-name  2 4)"_rd_data[102:0]),
         .empty       (e@"(substring vl-cell-name  0 1)"axi_em@"(substring vl-cell-name  2 4)"_empty),
         .prog_full   (em@"(substring vl-cell-name  2 4)"_progfull),
         .full        (em@"(substring vl-cell-name  2 4)"_full),  
         //inputs
         .rd_clk      (@"(substring vl-cell-name  0 1)"_axi_aclk),
         .rd_en       (e@"(substring vl-cell-name  0 1)"axi_em@"(substring vl-cell-name  2 4)"_rd_en),
         .din         (em@"(substring vl-cell-name  2 4)"_wr_data[102:0]),
         .wr_en       (em@"(substring vl-cell-name  2 4)"_wr_en),
         .wr_clk      (rx_lclk_div4),
         .rst         (reset),
    );
   */

   //Read request fifo (from Epiphany)
   fifo_async_103x32 m_rq_fifo(/*AUTOINST*/
			       // Outputs
			       .dout		(emaxi_emrq_rd_data[102:0]), // Templated
			       .full		(emrq_full),	 // Templated
			       .empty		(emaxi_emrq_empty), // Templated
			       .prog_full	(emrq_progfull), // Templated
			       // Inputs
			       .rst		(reset),	 // Templated
			       .wr_clk		(rx_lclk_div4),	 // Templated
			       .rd_clk		(m_axi_aclk),	 // Templated
			       .din		(emrq_wr_data[102:0]), // Templated
			       .wr_en		(emrq_wr_en),	 // Templated
			       .rd_en		(emaxi_emrq_rd_en)); // Templated
   

   
   //Write fifo (from Epiphany)
   fifo_async_103x32 m_wr_fifo(/*AUTOINST*/
			       // Outputs
			       .dout		(emaxi_emwr_rd_data[102:0]), // Templated
			       .full		(emwr_full),	 // Templated
			       .empty		(emaxi_emwr_empty), // Templated
			       .prog_full	(emwr_progfull), // Templated
			       // Inputs
			       .rst		(reset),	 // Templated
			       .wr_clk		(rx_lclk_div4),	 // Templated
			       .rd_clk		(m_axi_aclk),	 // Templated
			       .din		(emwr_wr_data[102:0]), // Templated
			       .wr_en		(emwr_wr_en),	 // Templated
			       .rd_en		(emaxi_emwr_rd_en)); // Templated
   
   

   //Read response fifo (for host)
   fifo_async_103x32 s_rr_fifo(/*AUTOINST*/
			       // Outputs
			       .dout		(esaxi_emrr_rd_data[102:0]), // Templated
			       .full		(emrr_full),	 // Templated
			       .empty		(esaxi_emrr_empty), // Templated
			       .prog_full	(emrr_progfull), // Templated
			       // Inputs
			       .rst		(reset),	 // Templated
			       .wr_clk		(rx_lclk_div4),	 // Templated
			       .rd_clk		(s_axi_aclk),	 // Templated
			       .din		(emrr_wr_data[102:0]), // Templated
			       .wr_en		(emrr_wr_en),	 // Templated
			       .rd_en		(esaxi_emrr_rd_en)); // Templated
   
   
   /************************************************************/
   /*ELINK RECEIVE DISTRIBUTOR ("DEMUX")                       */
   /*(figures out who RX transaction belongs to)               */
   /********************1***************************************/
   /*erx_disty AUTO_TEMPLATE ( 
                        //Inputs
                        .emesh_rd_wait	(emesh_rx_rd_wait),
			.emesh_wr_wait	(emesh_rx_wr_wait),
                        .mmu_en		(ecfg_rx_mmu_mode),
                        .clk		(rx_lclk_div4),
                        );
   */
   erx_disty erx_disty (
			/*AUTOINST*/
			// Outputs
			.emesh_rd_wait	(emesh_rx_rd_wait),	 // Templated
			.emesh_wr_wait	(emesh_rx_wr_wait),	 // Templated
			.emwr_wr_data	(emwr_wr_data[102:0]),
			.emwr_wr_en	(emwr_wr_en),
			.emrq_wr_data	(emrq_wr_data[102:0]),
			.emrq_wr_en	(emrq_wr_en),
			.emrr_wr_data	(emrr_wr_data[102:0]),
			.emrr_wr_en	(emrr_wr_en),
			// Inputs
			.clk		(rx_lclk_div4),		 // Templated
			.mmu_en		(ecfg_rx_mmu_mode),	 // Templated
			.emmu_access	(emmu_access),
			.emmu_write	(emmu_write),
			.emmu_datamode	(emmu_datamode[1:0]),
			.emmu_ctrlmode	(emmu_ctrlmode[3:0]),
			.emmu_dstaddr	(emmu_dstaddr[31:0]),
			.emmu_srcaddr	(emmu_srcaddr[31:0]),
			.emmu_data	(emmu_data[31:0]),
			.emwr_full	(emwr_full),
			.emwr_progfull	(emwr_progfull),
			.emrq_full	(emrq_full),
			.emrq_progfull	(emrq_progfull),
			.emrr_full	(emrr_full),
			.emrr_progfull	(emrr_progfull),
			.ecfg_rx_enable	(ecfg_rx_enable));

 
   /************************************************************/
   /*ELINK MEMORY MANAGEMENT UNIT                              */
   /*(uses lookup table to translate destination address)      */
   /************************************************************/
   /*emmu AUTO_TEMPLATE ( 
                        .emmu_\(.*\)_out	(emmu_\1[]),   
                         //Inputs
                        .emesh_\(.*\)_in	(emesh_rx_\1[]),   
                        .mmu_en			(ecfg_rx_mmu_mode),
                        .clk			(rx_lclk_div4),
                        );
   */

   emmu emmu (
	      /*AUTOINST*/
	      // Outputs
	      .mi_dout			(mi_dout[31:0]),
	      .emmu_access_out		(emmu_access),		 // Templated
	      .emmu_write_out		(emmu_write),		 // Templated
	      .emmu_datamode_out	(emmu_datamode[1:0]),	 // Templated
	      .emmu_ctrlmode_out	(emmu_ctrlmode[3:0]),	 // Templated
	      .emmu_dstaddr_out		(emmu_dstaddr[63:0]),	 // Templated
	      .emmu_srcaddr_out		(emmu_srcaddr[AW-1:0]),	 // Templated
	      .emmu_data_out		(emmu_data[DW-1:0]),	 // Templated
	      // Inputs
	      .clk			(rx_lclk_div4),		 // Templated
	      .mmu_en			(ecfg_rx_mmu_mode),	 // Templated
	      .mi_clk			(mi_clk),
	      .mi_en			(mi_en),
	      .mi_we			(mi_we[3:0]),
	      .mi_addr			(mi_addr[15:0]),
	      .mi_din			(mi_din[31:0]),
	      .emesh_access_in		(emesh_rx_access),	 // Templated
	      .emesh_write_in		(emesh_rx_write),	 // Templated
	      .emesh_datamode_in	(emesh_rx_datamode[1:0]), // Templated
	      .emesh_ctrlmode_in	(emesh_rx_ctrlmode[3:0]), // Templated
	      .emesh_dstaddr_in		(emesh_rx_dstaddr[AW-1:0]), // Templated
	      .emesh_srcaddr_in		(emesh_rx_srcaddr[AW-1:0]), // Templated
	      .emesh_data_in		(emesh_rx_data[DW-1:0])); // Templated
   

   /**************************************************************/
   /*ELINK PROTOCOL LOGIC                                        */
   /*-translates a slowed down elink packet an emesh transaction */
   /**************************************************************/
   
   erx_protocol erx_protocol (/*AUTOINST*/
			      // Outputs
			      .rx_rd_wait	(rx_rd_wait),
			      .rx_wr_wait	(rx_wr_wait),
			      .emesh_rx_access	(emesh_rx_access),
			      .emesh_rx_write	(emesh_rx_write),
			      .emesh_rx_datamode(emesh_rx_datamode[1:0]),
			      .emesh_rx_ctrlmode(emesh_rx_ctrlmode[3:0]),
			      .emesh_rx_dstaddr	(emesh_rx_dstaddr[31:0]),
			      .emesh_rx_srcaddr	(emesh_rx_srcaddr[31:0]),
			      .emesh_rx_data	(emesh_rx_data[31:0]),
			      // Inputs
			      .reset		(reset),
			      .rx_lclk_div4	(rx_lclk_div4),
			      .rx_frame_par	(rx_frame_par[7:0]),
			      .rx_data_par	(rx_data_par[63:0]),
			      .emesh_rx_rd_wait	(emesh_rx_rd_wait),
			      .emesh_rx_wr_wait	(emesh_rx_wr_wait));

   
   /***********************************************************/
   /*ELINK TRANSMIT I/O LOGIC                                 */
   /*-parallel data and frame as input                        */
   /*-serializes data for I/O                                 */  
   /***********************************************************/

   erx_io erx_io (
		    /*AUTOINST*/
		  // Outputs
		  .rx_wr_wait_p		(rx_wr_wait_p),
		  .rx_wr_wait_n		(rx_wr_wait_n),
		  .rx_rd_wait_p		(rx_rd_wait_p),
		  .rx_rd_wait_n		(rx_rd_wait_n),
		  .rx_lclk_div4		(rx_lclk_div4),
		  .rx_frame_par		(rx_frame_par[7:0]),
		  .rx_data_par		(rx_data_par[63:0]),
		  .ecfg_datain		(ecfg_datain[8:0]),
		  // Inputs
		  .reset		(reset),
		  .rx_lclk_p		(rx_lclk_p),
		  .rx_lclk_n		(rx_lclk_n),
		  .rx_frame_p		(rx_frame_p),
		  .rx_frame_n		(rx_frame_n),
		  .rx_data_p		(rx_data_p[7:0]),
		  .rx_data_n		(rx_data_n[7:0]),
		  .rx_wr_wait		(rx_wr_wait),
		  .rx_rd_wait		(rx_rd_wait),
		  .ecfg_rx_enable	(ecfg_rx_enable),
		  .ecfg_rx_gpio_mode	(ecfg_rx_gpio_mode),
		  .ecfg_dataout		(ecfg_dataout[1:0]));

   /************************************************************/
   /*Debug signals                                             */
   /************************************************************/
   always @ (posedge rx_lclk_div4)
     begin
	ecfg_rx_debug[15:0] <= {2'b0,                     //15:14
				emesh_rx_rd_wait,         //13
				emesh_rx_wr_wait,         //12
				esaxi_emrr_rd_en,         //11
				emrr_full,                //10
				emrr_progfull,            //9
				emrr_wr_en,	          //8			
				emaxi_emrq_rd_en,         //7
				emrq_full,                //6
				emrq_progfull,            //5
				emrq_wr_en,	          //4			 
				emaxi_emwr_rd_en,         //3
				emwr_full,	          //2			 
				emwr_progfull,            //1
				emwr_wr_en                //0
				};
     end

   
endmodule // erx
// Local Variables:
// verilog-library-directories:("." "../../emmu/hdl" "../../stubs/hdl")
// End:


