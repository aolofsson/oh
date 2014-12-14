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

module erx (/*AUTOARG*/
   // Outputs
   ecfg_rx_debug_signals, ecfg_datain, emaxi_emwr_empty,
   emaxi_emwr_rd_data, emaxi_emrq_empty, emaxi_emrq_rd_data,
   esaxi_emrr_empty, esaxi_emrr_rd_data, rx_wr_wait_p, rx_wr_wait_n,
   rx_rd_wait_p, rx_rd_wait_n, mi_data_out,
   // Inputs
   reset, s_axi_aclk, m_axi_aclk, ecfg_rx_enable, ecfg_rx_mmu_mode,
   ecfg_rx_gpio_mode, ecfg_dataout, emaxi_emwr_rd_en,
   emaxi_emrq_rd_en, esaxi_emrr_rd_en, rx_lclk_p, rx_lclk_n,
   rx_frame_p, rx_frame_n, rx_data_p, rx_data_n, mi_access, mi_addr,
   mi_data_in, mi_write
   );


   //Clocks and reset
   input          reset;
   input 	  s_axi_aclk;           //clock for slave read request and write fifos
   input 	  m_axi_aclk;           //clock for master read response fifo
   
   //Configuration signals
  
   input 	  ecfg_rx_enable;   
   input 	  ecfg_rx_mmu_mode;
   
   //Testing
   output [15:0]  ecfg_rx_debug_signals; //various debug signals

   //GPIO mode
   input 	  ecfg_rx_gpio_mode;
   input [10:0]   ecfg_dataout;	
   output [8:0]   ecfg_datain;

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

   //Transmit signals for IO
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

   //Write interface for MMU
   input 	    mi_clk;
   input 	    mi_en;
   input 	    mi_we;             //Single we, must write full words!
   input [RFAW-1:0] mi_addr;
   input [31:0]     mi_din;
   output [31:0]    mi_dout;   
   
   /*AUTOOUTPUT*/
   /*AUTOINPUT*/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			emesh_mmu_access;	// From emmu of emmu.v
   wire [3:0]		emesh_mmu_ctrlmode;	// From emmu of emmu.v
   wire [DW-1:0]	emesh_mmu_data;		// From emmu of emmu.v
   wire [1:0]		emesh_mmu_datamode;	// From emmu of emmu.v
   wire [63:0]		emesh_mmu_dstaddr;	// From emmu of emmu.v
   wire [AW-1:0]	emesh_mmu_srcaddr;	// From emmu of emmu.v
   wire			emesh_mmu_write;	// From emmu of emmu.v
   wire			emesh_rx_access;	// From erx_protocol of erx_protocol.v
   wire [3:0]		emesh_rx_ctrlmode;	// From erx_protocol of erx_protocol.v
   wire [31:0]		emesh_rx_data;		// From erx_protocol of erx_protocol.v
   wire [1:0]		emesh_rx_datamode;	// From erx_protocol of erx_protocol.v
   wire [31:0]		emesh_rx_dstaddr;	// From erx_protocol of erx_protocol.v
   wire			emesh_rx_rd_wait;	// From erx_disty of erx_disty.v
   wire [31:0]		emesh_rx_srcaddr;	// From erx_protocol of erx_protocol.v
   wire			emesh_rx_wr_wait;	// From erx_disty of erx_disty.v
   wire			emesh_rx_write;		// From erx_protocol of erx_protocol.v
   wire			emrq_full;		// From m_rq_fifo of fifo_103x32.v
   wire			emrq_prog_full;		// From m_rq_fifo of fifo_103x32.v
   wire [102:0]		emrq_wr_data;		// From erx_disty of erx_disty.v
   wire			emrq_wr_en;		// From erx_disty of erx_disty.v
   wire			emrr_full;		// From s_rr_fifo of fifo_103x32.v
   wire			emrr_prog_full;		// From s_rr_fifo of fifo_103x32.v
   wire [102:0]		emrr_wr_data;		// From erx_disty of erx_disty.v
   wire			emrr_wr_en;		// From erx_disty of erx_disty.v
   wire			emwr_full;		// From m_wr_fifo of fifo_103x32.v
   wire			emwr_prog_full;		// From m_wr_fifo of fifo_103x32.v
   wire [102:0]		emwr_wr_data;		// From erx_disty of erx_disty.v
   wire			emwr_wr_en;		// From erx_disty of erx_disty.v
   wire			rx_rd_wait;		// From erx_protocol of erx_protocol.v
   wire			rx_wr_wait;		// From erx_protocol of erx_protocol.v
   wire [63:0]		rxdata_p;		// From erx_io of erx_io.v
   wire [7:0]		rxframe_p;		// From erx_io of erx_io.v
   wire			rxlclk_p;		// From erx_io of erx_io.v
   // End of automatics
   
   
   /************************************************************/
   /*FIFOs                                                     */
   /************************************************************/
   /*fifo_103x32 AUTO_TEMPLATE ( 
  .dout     (e@"(substring vl-cell-name  0 1)"axi_em@"(substring vl-cell-name  2 4)"_rd_data[]),
  .empty    (e@"(substring vl-cell-name  0 1)"axi_em@"(substring vl-cell-name  2 4)"_empty),
  
  .prog_full(em@"(substring vl-cell-name  2 4)"_prog_full),
  .full	    (em@"(substring vl-cell-name  2 4)"_full),
  
  .rd_clk   (@"(substring vl-cell-name  0 1)"_axi_aclk),
  .rd_en    (e@"(substring vl-cell-name  0 1)"axi_em@"(substring vl-cell-name  2 4)"_rd_en),
  .din      (em@"(substring vl-cell-name  2 4)"_wr_data[]),
  .wr_en    (em@"(substring vl-cell-name  2 4)"_wr_en),
  .wr_clk   (rxlclk_p),
  .rst      (reset),
    );
   */

   //Read request fifo (from slave)
   fifo_103x32 m_rq_fifo(/*AUTOINST*/
			 // Outputs
			 .dout			(emaxi_emrq_rd_data[102:0]), // Templated
			 .empty			(emaxi_emrq_empty), // Templated
			 .full			(emrq_full),	 // Templated
			 .prog_full		(emrq_prog_full), // Templated
			 // Inputs
			 .din			(emrq_wr_data[102:0]), // Templated
			 .rd_clk		(m_axi_aclk),	 // Templated
			 .rd_en			(emaxi_emrq_rd_en), // Templated
			 .rst			(reset),	 // Templated
			 .wr_clk		(rxlclk_p),	 // Templated
			 .wr_en			(emrq_wr_en));	 // Templated
   

   
   //Write fifo (from slave)
   fifo_103x32 m_wr_fifo(/*AUTOINST*/
			 // Outputs
			 .dout			(emaxi_emwr_rd_data[102:0]), // Templated
			 .empty			(emaxi_emwr_empty), // Templated
			 .full			(emwr_full),	 // Templated
			 .prog_full		(emwr_prog_full), // Templated
			 // Inputs
			 .din			(emwr_wr_data[102:0]), // Templated
			 .rd_clk		(m_axi_aclk),	 // Templated
			 .rd_en			(emaxi_emwr_rd_en), // Templated
			 .rst			(reset),	 // Templated
			 .wr_clk		(rxlclk_p),	 // Templated
			 .wr_en			(emwr_wr_en));	 // Templated
   
   

   //Read response fifo (from master)
   fifo_103x32 s_rr_fifo(/*AUTOINST*/
			 // Outputs
			 .dout			(esaxi_emrr_rd_data[102:0]), // Templated
			 .empty			(esaxi_emrr_empty), // Templated
			 .full			(emrr_full),	 // Templated
			 .prog_full		(emrr_prog_full), // Templated
			 // Inputs
			 .din			(emrr_wr_data[102:0]), // Templated
			 .rd_clk		(s_axi_aclk),	 // Templated
			 .rd_en			(esaxi_emrr_rd_en), // Templated
			 .rst			(reset),	 // Templated
			 .wr_clk		(rxlclk_p),	 // Templated
			 .wr_en			(emrr_wr_en));	 // Templated
   
   
   
   /************************************************************/
   /*ELINK RECEIVE DISTRIBUTOR ("DEMUX")                       */
   /*-sends transactin to the correct AXI channel fifo         */
   /********************1***************************************/
   /*erx_disty AUTO_TEMPLATE ( 
                        //Inputs
                        .emesh_rd_wait	(emesh_rx_rd_wait),
			.emesh_wr_wait	(emesh_rx_wr_wait),
                        .emesh_\(.*\)   (emesh_mmu_\1[]),   
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
			.rxlclk_p	(rxlclk_p),
			.emesh_access	(emesh_mmu_access),	 // Templated
			.emesh_write	(emesh_mmu_write),	 // Templated
			.emesh_datamode	(emesh_mmu_datamode[1:0]), // Templated
			.emesh_ctrlmode	(emesh_mmu_ctrlmode[3:0]), // Templated
			.emesh_dstaddr	(emesh_mmu_dstaddr[31:0]), // Templated
			.emesh_srcaddr	(emesh_mmu_srcaddr[31:0]), // Templated
			.emesh_data	(emesh_mmu_data[31:0]),	 // Templated
			.emwr_full	(emwr_full),
			.emwr_prog_full	(emwr_prog_full),
			.emrq_full	(emrq_full),
			.emrq_prog_full	(emrq_prog_full),
			.emrr_full	(emrr_full),
			.emrr_prog_full	(emrr_prog_full),
			.ecfg_rx_enable	(ecfg_rx_enable));


   /************************************************************/
   /*ELINK MEMORY MANAGEMENT UNIT                              */
   /*-translates destination address                           */
   /************************************************************/
   /*emmu AUTO_TEMPLATE ( 
                        // Outputs
                        .emesh_\(.*\)_out	(emesh_mmu_\1[]),   
                        //Inputs
                        .emesh_\(.*\)_in	(emesh_rx_\1[]),   
                        );
   */

   emmu emmu (.clk			(rxlclk_p),
		.mmu_en			(ecfg_rx_mmu_mode),
		/*AUTOINST*/
	      // Outputs
	      .mi_data_out		(mi_data_out[DW-1:0]),
	      .emesh_access_out		(emesh_mmu_access),	 // Templated
	      .emesh_write_out		(emesh_mmu_write),	 // Templated
	      .emesh_datamode_out	(emesh_mmu_datamode[1:0]), // Templated
	      .emesh_ctrlmode_out	(emesh_mmu_ctrlmode[3:0]), // Templated
	      .emesh_dstaddr_out	(emesh_mmu_dstaddr[63:0]), // Templated
	      .emesh_srcaddr_out	(emesh_mmu_srcaddr[AW-1:0]), // Templated
	      .emesh_data_out		(emesh_mmu_data[DW-1:0]), // Templated
	      // Inputs
	      .mi_access		(mi_access),
	      .mi_write			(mi_write),
	      .mi_addr			(mi_addr[IW:0]),
	      .mi_data_in		(mi_data_in[DW-1:0]),
	      .emesh_access_in		(emesh_rx_access),	 // Templated
	      .emesh_write_in		(emesh_rx_write),	 // Templated
	      .emesh_datamode_in	(emesh_rx_datamode[1:0]), // Templated
	      .emesh_ctrlmode_in	(emesh_rx_ctrlmode[3:0]), // Templated
	      .emesh_dstaddr_in		(emesh_rx_dstaddr[AW-1:0]), // Templated
	      .emesh_srcaddr_in		(emesh_rx_srcaddr[AW-1:0]), // Templated
	      .emesh_data_in		(emesh_rx_data[DW-1:0])); // Templated
   

   /************************************************************/
   /*ELINK PROTOCOL LOGIC                                      */
   /*-translates the elink packet to 104 bit emesh bits        */
   /************************************************************/
   
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
			      .rxlclk_p		(rxlclk_p),
			      .rxframe_p	(rxframe_p[7:0]),
			      .rxdata_p		(rxdata_p[63:0]),
			      .emesh_rx_rd_wait	(emesh_rx_rd_wait),
			      .emesh_rx_wr_wait	(emesh_rx_wr_wait));

   
   /***********************************************************/
   /*ELINK TRANSMIT I/O LOGIC                                 */
   /*-parallel data and frame as input                        */
   /*-serializes data for I/O                                 */  
   /***********************************************************/

   erx_io erx_io (.ioreset		(reset),
		    .txlclk_p		(1'b0),//TODO
		    /*AUTOINST*/
		  // Outputs
		  .rx_wr_wait_p		(rx_wr_wait_p),
		  .rx_wr_wait_n		(rx_wr_wait_n),
		  .rx_rd_wait_p		(rx_rd_wait_p),
		  .rx_rd_wait_n		(rx_rd_wait_n),
		  .rxlclk_p		(rxlclk_p),
		  .rxframe_p		(rxframe_p[7:0]),
		  .rxdata_p		(rxdata_p[63:0]),
		  .ecfg_datain		(ecfg_datain[8:0]),
		  // Inputs
		  .rx_lclk_p		(rx_lclk_p),
		  .rx_lclk_n		(rx_lclk_n),
		  .reset		(reset),
		  .rx_frame_p		(rx_frame_p),
		  .rx_frame_n		(rx_frame_n),
		  .rx_data_p		(rx_data_p[7:0]),
		  .rx_data_n		(rx_data_n[7:0]),
		  .rx_wr_wait		(rx_wr_wait),
		  .rx_rd_wait		(rx_rd_wait),
		  .ecfg_rx_enable	(ecfg_rx_enable),
		  .ecfg_rx_gpio_mode	(ecfg_rx_gpio_mode),
		  .ecfg_dataout		(ecfg_dataout[10:0]));

   /************************************************************/
   /*Debug signals                                             */
   /************************************************************/
   always @ (posedge rxlclk_p)
     begin
	ecfg_rx_debug_signals[15:0] <= {2'b0,                     //15:14
					emesh_rx_rd_wait,         //13
					emesh_rx_wr_wait,         //12
					esaxi_emrr_rd_en,         //11
					emrr_full,                //10
					emrr_prog_full,           //9
					emrr_wr_en,	          //8			
					emaxi_emrq_rd_en,         //7
					emrq_full,                //6
					emrq_prog_full,           //5
					emrq_wr_en,	          //4			 
					emaxi_emwr_rd_en,         //3
					emwr_full,	          //2			 
					emwr_prog_full,           //1
					emwr_wr_en                //0
					};
     end

   
endmodule // elink
// Local Variables:
// verilog-library-directories:("." "../../stubs/hdl" "../../emmu/hdl")
// End:


