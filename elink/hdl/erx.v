module erx (/*AUTOARG*/
   // Outputs
   ecfg_rx_debug, ecfg_rx_datain, mi_dout, emwr_access, emwr_write,
   emwr_datamode, emwr_ctrlmode, emwr_dstaddr, emwr_data,
   emwr_srcaddr, emrq_access, emrq_write, emrq_datamode,
   emrq_ctrlmode, emrq_dstaddr, emrq_data, emrq_srcaddr, emrr_access,
   emrr_data, rxo_wr_wait_p, rxo_wr_wait_n, rxo_rd_wait_p,
   rxo_rd_wait_n,
   // Inputs
   reset, s_axi_aclk, m_axi_aclk, ecfg_rx_enable, ecfg_rx_mmu_enable,
   ecfg_rx_gpio_enable, ecfg_dataout, mi_clk, mi_en, mi_we, mi_addr,
   mi_din, emwr_rd_en, emrq_rd_en, emrr_rd_en, rxi_lclk_p, rxi_lclk_n,
   rxi_frame_p, rxi_frame_n, rxi_data_p, rxi_data_n
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
   input 	  ecfg_rx_enable;     //receiver enable
   input 	  ecfg_rx_mmu_enable; //enable mmu   
   output [15:0]  ecfg_rx_debug;      //various debug signals
   input 	  ecfg_rx_gpio_enable;//mode for sampling elink pins directly
   input [1:0] 	  ecfg_dataout;	      //data for pins in direct mode
   output [8:0]   ecfg_rx_datain;     //samples elink pins

   //MMU table configuration interface
   input 	  mi_clk;     //source synchronous clock
   input 	  mi_en;      //memory access 
   input 	  mi_we;      //byte wise write enable
   input [15:0]   mi_addr;    //table address
   input [31:0]   mi_din;     //input data  
   output [31:0]  mi_dout;    //read back data
   
   //Writes (to axi master)
   output 	  emwr_access;
   output         emwr_write;
   output [1:0]   emwr_datamode;
   output [3:0]   emwr_ctrlmode;
   output [31:0]  emwr_dstaddr;
   output [31:0]  emwr_data;
   output [31:0]  emwr_srcaddr;   
   input 	  emwr_rd_en;

   //Read requests (to axi master)
   output 	  emrq_access;
   output         emrq_write;
   output [1:0]   emrq_datamode;
   output [3:0]   emrq_ctrlmode;
   output [31:0]  emrq_dstaddr;
   output [31:0]  emrq_data;
   output [31:0]  emrq_srcaddr;   
   input 	  emrq_rd_en;

   //Read responses (to slave, only 32bit data needed) 
   output 	  emrr_access;
   output [31:0]  emrr_data;   
   input 	  emrr_rd_en;
   
   //IO Pins
   input 	  rxi_lclk_p,  rxi_lclk_n;     //link rx clock input
   input 	  rxi_frame_p,  rxi_frame_n;   //link rx frame signal
   input [7:0] 	  rxi_data_p,   rxi_data_n;    //link rx data
   output 	  rxo_wr_wait_p,rxo_wr_wait_n; //link rx write pushback output
   output 	  rxo_rd_wait_p,rxo_rd_wait_n; //link rx read pushback output

  
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
   wire			emrq_full;		// From m_rq_fifo of fifo_async_emesh.v
   wire			emrq_progfull;		// From m_rq_fifo of fifo_async_emesh.v
   wire			emrq_wr_en;		// From erx_disty of erx_disty.v
   wire			emrr_full;		// From s_rr_fifo of fifo_async_emesh.v
   wire			emrr_progfull;		// From s_rr_fifo of fifo_async_emesh.v
   wire			emrr_wr_en;		// From erx_disty of erx_disty.v
   wire			emwr_full;		// From m_wr_fifo of fifo_async_emesh.v
   wire			emwr_progfull;		// From m_wr_fifo of fifo_async_emesh.v
   wire			emwr_wr_en;		// From erx_disty of erx_disty.v
   wire [3:0]		erx_ctrlmode;		// From erx_disty of erx_disty.v
   wire [31:0]		erx_data;		// From erx_disty of erx_disty.v
   wire [1:0]		erx_datamode;		// From erx_disty of erx_disty.v
   wire [31:0]		erx_dstaddr;		// From erx_disty of erx_disty.v
   wire [31:0]		erx_srcaddr;		// From erx_disty of erx_disty.v
   wire			erx_write;		// From erx_disty of erx_disty.v
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

   /*fifo_async_emesh AUTO_TEMPLATE ( 
    //outputs
    .emesh_\(.*\)_out	(em@"(substring vl-cell-name  2 4)"_\1[]),

    .fifo_\(.*\)        (em@"(substring vl-cell-name  2 4)"_\1),
    //inputs
    .rd_clk             (@"(substring vl-cell-name  0 1)"_axi_aclk),
    .wr_clk             (rx_lclk_div4),
    .emesh_\(.*\)_in	(erx_\1[]),
    .emesh_access_in	(em@"(substring vl-cell-name  2 4)"_wr_en),
    .fifo_read          (em@"(substring vl-cell-name  2 4)"_rd_en),
    );
   */

   //Read request fifo (from Epiphany)
   fifo_async_emesh m_rq_fifo(/*AUTOINST*/
			      // Outputs
			      .emesh_access_out	(emrq_access),	 // Templated
			      .emesh_write_out	(emrq_write),	 // Templated
			      .emesh_datamode_out(emrq_datamode[1:0]), // Templated
			      .emesh_ctrlmode_out(emrq_ctrlmode[3:0]), // Templated
			      .emesh_dstaddr_out(emrq_dstaddr[31:0]), // Templated
			      .emesh_data_out	(emrq_data[31:0]), // Templated
			      .emesh_srcaddr_out(emrq_srcaddr[31:0]), // Templated
			      .fifo_full	(emrq_full),	 // Templated
			      .fifo_progfull	(emrq_progfull), // Templated
			      // Inputs
			      .rd_clk		(m_axi_aclk),	 // Templated
			      .wr_clk		(rx_lclk_div4),	 // Templated
			      .reset		(reset),
			      .emesh_access_in	(emrq_wr_en),	 // Templated
			      .emesh_write_in	(erx_write),	 // Templated
			      .emesh_datamode_in(erx_datamode[1:0]), // Templated
			      .emesh_ctrlmode_in(erx_ctrlmode[3:0]), // Templated
			      .emesh_dstaddr_in	(erx_dstaddr[31:0]), // Templated
			      .emesh_data_in	(erx_data[31:0]), // Templated
			      .emesh_srcaddr_in	(erx_srcaddr[31:0]), // Templated
			      .fifo_read	(emrq_rd_en));	 // Templated
   
   //Write fifo (from Epiphany)
   fifo_async_emesh m_wr_fifo(/*AUTOINST*/
			      // Outputs
			      .emesh_access_out	(emwr_access),	 // Templated
			      .emesh_write_out	(emwr_write),	 // Templated
			      .emesh_datamode_out(emwr_datamode[1:0]), // Templated
			      .emesh_ctrlmode_out(emwr_ctrlmode[3:0]), // Templated
			      .emesh_dstaddr_out(emwr_dstaddr[31:0]), // Templated
			      .emesh_data_out	(emwr_data[31:0]), // Templated
			      .emesh_srcaddr_out(emwr_srcaddr[31:0]), // Templated
			      .fifo_full	(emwr_full),	 // Templated
			      .fifo_progfull	(emwr_progfull), // Templated
			      // Inputs
			      .rd_clk		(m_axi_aclk),	 // Templated
			      .wr_clk		(rx_lclk_div4),	 // Templated
			      .reset		(reset),
			      .emesh_access_in	(emwr_wr_en),	 // Templated
			      .emesh_write_in	(erx_write),	 // Templated
			      .emesh_datamode_in(erx_datamode[1:0]), // Templated
			      .emesh_ctrlmode_in(erx_ctrlmode[3:0]), // Templated
			      .emesh_dstaddr_in	(erx_dstaddr[31:0]), // Templated
			      .emesh_data_in	(erx_data[31:0]), // Templated
			      .emesh_srcaddr_in	(erx_srcaddr[31:0]), // Templated
			      .fifo_read	(emwr_rd_en));	 // Templated
   
   

   //Read response fifo (for host)
   fifo_async_emesh s_rr_fifo(
			      .emesh_access_out	(),
			      .emesh_write_out	(),
			      .emesh_datamode_out(),
			      .emesh_ctrlmode_out(),
			      .emesh_dstaddr_out(),
			      .emesh_srcaddr_out(),
			      /*AUTOINST*/
			      // Outputs
			      .emesh_data_out	(emrr_data[31:0]), // Templated
			      .fifo_full	(emrr_full),	 // Templated
			      .fifo_progfull	(emrr_progfull), // Templated
			      // Inputs
			      .rd_clk		(s_axi_aclk),	 // Templated
			      .wr_clk		(rx_lclk_div4),	 // Templated
			      .reset		(reset),
			      .emesh_access_in	(emrr_wr_en),	 // Templated
			      .emesh_write_in	(erx_write),	 // Templated
			      .emesh_datamode_in(erx_datamode[1:0]), // Templated
			      .emesh_ctrlmode_in(erx_ctrlmode[3:0]), // Templated
			      .emesh_dstaddr_in	(erx_dstaddr[31:0]), // Templated
			      .emesh_data_in	(erx_data[31:0]), // Templated
			      .emesh_srcaddr_in	(erx_srcaddr[31:0]), // Templated
			      .fifo_read	(emrr_rd_en));	 // Templated
   
   
   /************************************************************/
   /*ELINK RECEIVE DISTRIBUTOR ("DEMUX")                       */
   /*(figures out who RX transaction belongs to)               */
   /********************1***************************************/
   /*erx_disty AUTO_TEMPLATE ( 
                        //Inputs
                        .emesh_rd_wait	(emesh_rx_rd_wait),
			.emesh_wr_wait	(emesh_rx_wr_wait),
                        .mmu_en		(ecfg_rx_mmu_enable),
                        .clk		(rx_lclk_div4),
    );
   */
   
   erx_disty erx_disty (
			/*AUTOINST*/
			// Outputs
			.emesh_rd_wait	(emesh_rx_rd_wait),	 // Templated
			.emesh_wr_wait	(emesh_rx_wr_wait),	 // Templated
			.emwr_wr_en	(emwr_wr_en),
			.emrq_wr_en	(emrq_wr_en),
			.emrr_wr_en	(emrr_wr_en),
			.erx_write	(erx_write),
			.erx_datamode	(erx_datamode[1:0]),
			.erx_ctrlmode	(erx_ctrlmode[3:0]),
			.erx_dstaddr	(erx_dstaddr[31:0]),
			.erx_srcaddr	(erx_srcaddr[31:0]),
			.erx_data	(erx_data[31:0]),
			// Inputs
			.clk		(rx_lclk_div4),		 // Templated
			.mmu_en		(ecfg_rx_mmu_enable),	 // Templated
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
                        .mmu_en			(ecfg_rx_mmu_enable),
                        .clk			(rx_lclk_div4),
                        );
   */

   emmu emmu (
	      /*AUTOINST*/
	      // Outputs
	      .mi_dout			(mi_dout[DW-1:0]),
	      .emmu_access_out		(emmu_access),		 // Templated
	      .emmu_write_out		(emmu_write),		 // Templated
	      .emmu_datamode_out	(emmu_datamode[1:0]),	 // Templated
	      .emmu_ctrlmode_out	(emmu_ctrlmode[3:0]),	 // Templated
	      .emmu_dstaddr_out		(emmu_dstaddr[63:0]),	 // Templated
	      .emmu_srcaddr_out		(emmu_srcaddr[AW-1:0]),	 // Templated
	      .emmu_data_out		(emmu_data[DW-1:0]),	 // Templated
	      // Inputs
	      .clk			(rx_lclk_div4),		 // Templated
	      .reset			(reset),
	      .mmu_en			(ecfg_rx_mmu_enable),	 // Templated
	      .mi_clk			(mi_clk),
	      .mi_en			(mi_en),
	      .mi_we			(mi_we),
	      .mi_addr			(mi_addr[15:0]),
	      .mi_din			(mi_din[DW-1:0]),
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
		  .rxo_wr_wait_p	(rxo_wr_wait_p),
		  .rxo_wr_wait_n	(rxo_wr_wait_n),
		  .rxo_rd_wait_p	(rxo_rd_wait_p),
		  .rxo_rd_wait_n	(rxo_rd_wait_n),
		  .rx_lclk_div4		(rx_lclk_div4),
		  .rx_frame_par		(rx_frame_par[7:0]),
		  .rx_data_par		(rx_data_par[63:0]),
		  .ecfg_rx_datain	(ecfg_rx_datain[8:0]),
		  // Inputs
		  .reset		(reset),
		  .rxi_lclk_p		(rxi_lclk_p),
		  .rxi_lclk_n		(rxi_lclk_n),
		  .rxi_frame_p		(rxi_frame_p),
		  .rxi_frame_n		(rxi_frame_n),
		  .rxi_data_p		(rxi_data_p[7:0]),
		  .rxi_data_n		(rxi_data_n[7:0]),
		  .rx_wr_wait		(rx_wr_wait),
		  .rx_rd_wait		(rx_rd_wait),
		  .ecfg_rx_enable	(ecfg_rx_enable),
		  .ecfg_rx_gpio_enable	(ecfg_rx_gpio_enable),
		  .ecfg_dataout		(ecfg_dataout[1:0]));

   /************************************************************/
   /*Debug signals                                             */
   /************************************************************/
   always @ (posedge rx_lclk_div4)
     begin
	ecfg_rx_debug[15:0] <= {2'b0,                     //15:14
				emesh_rx_rd_wait,         //13
				emesh_rx_wr_wait,         //12
				emrr_rd_en,               //11
				emrr_progfull,            //10
				emrr_wr_en,	          //9			
				emrq_rd_en,               //8
				emrq_progfull,            //7
				emrq_wr_en,	          //6		 
				emwr_rd_en,               //5
				emwr_progfull,            //4
				emwr_wr_en,               //3
				emrr_full,                //2
				emrq_full,                //1
				emwr_full	          //0	
				};
     end

   
endmodule // erx
// Local Variables:
// verilog-library-directories:("." "../../emmu/hdl" "../../stubs/hdl" "../../memory/hdl")
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

