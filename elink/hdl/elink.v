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

module e_link(/*AUTOARG*/
   // Outputs
   rowid, colid, reset_n, cclk_p, cclk_n, rx_wr_wait_p, rx_wr_wait_n,
   rx_rd_wait_p, rx_rd_wait_n, tx_lclk_p, tx_lclk_n, tx_frame_p,
   tx_frame_n, tx_data_p, tx_data_n, embox_not_empty, embox_full,
   m_axi_araddr, m_axi_arburst, m_axi_arcache, m_axi_arid,
   m_axi_arlen, m_axi_arlock, m_axi_arprot, m_axi_arqos, m_axi_arsize,
   m_axi_arvalid, m_axi_awaddr, m_axi_awburst, m_axi_awcache,
   m_axi_awid, m_axi_awlen, m_axi_awlock, m_axi_awprot, m_axi_awqos,
   m_axi_awsize, m_axi_awvalid, m_axi_bready, m_axi_rready,
   m_axi_wdata, m_axi_wlast, m_axi_wstrb, m_axi_wvalid, s_axi_arready,
   s_axi_awready, s_axi_bid, s_axi_bresp, s_axi_bvalid, s_axi_rdata,
   s_axi_rid, s_axi_rlast, s_axi_rresp, s_axi_rvalid, s_axi_wready,
   s_axicfg_arready, s_axicfg_awready, s_axicfg_bresp,
   s_axicfg_bvalid, s_axicfg_rdata, s_axicfg_rresp, s_axicfg_rvalid,
   s_axicfg_wready,
   // Inputs
   hw_reset, clkin, rx_lclk_p, rx_lclk_n, rx_frame_p, rx_frame_n,
   rx_data_p, rx_data_n, tx_wr_wait_p, tx_wr_wait_n, tx_rd_wait_p,
   tx_rd_wait_n, m_axi_aclk, m_axi_aresetn, m_axi_arready,
   m_axi_awready, m_axi_bid, m_axi_bresp, m_axi_bvalid, m_axi_rdata,
   m_axi_rid, m_axi_rlast, m_axi_rresp, m_axi_rvalid, m_axi_wready,
   s_axi_aclk, s_axi_aresetn, s_axi_araddr, s_axi_arburst,
   s_axi_arcache, s_axi_arid, s_axi_arlen, s_axi_arlock, s_axi_arprot,
   s_axi_arqos, s_axi_arregion, s_axi_arsize, s_axi_arvalid,
   s_axi_awaddr, s_axi_awburst, s_axi_awcache, s_axi_awid,
   s_axi_awlen, s_axi_awlock, s_axi_awprot, s_axi_awqos,
   s_axi_awregion, s_axi_awsize, s_axi_awvalid, s_axi_bready,
   s_axi_rready, s_axi_wdata, s_axi_wlast, s_axi_wstrb, s_axi_wvalid,
   s_axicfg_araddr, s_axicfg_arprot, s_axicfg_arvalid,
   s_axicfg_awaddr, s_axicfg_awprot, s_axicfg_awvalid,
   s_axicfg_bready, s_axicfg_rready, s_axicfg_wdata, s_axicfg_wstrb,
   s_axicfg_wvalid
   );
   parameter COREID   = `CFG_COREID;
   
   
   /****************************/
   /*BASIC SIGNALS             */
   /****************************/
   input        hw_reset;        //active high asynchronous hardware reset
   input 	clkin;           //primary clock input
   
   /*****************************/
   /*EPIPHANY BASIC INTERFACE   */
   /*****************************/         
   output [3:0] rowid;         //row id to drive out to Epiphany 
   output [3:0] colid;         //col id to drive out to Epiphany 
   output 	reset_n;       //reset signal for Epiphany (active low)
   output 	cclk_p;        //high speed core clock (1GHz) to Epiphany
   output 	cclk_n;

   /*****************************/
   /*ELINK INTERFACE (I/O PINS) */
   /*****************************/          
   //Receiver
   input        rx_lclk_p;       //linkh speed clock input (up to 500MHz)
   input        rx_lclk_n;
   input        rx_frame_p;      //transaction frame signal
   input        rx_frame_n;
   input [7:0]  rx_data_p;       //receive data (dual data rate)
   input [7:0]  rx_data_n;
   output       rx_wr_wait_p;    //outgoing pushback on write transactions
   output       rx_wr_wait_n;     
   output       rx_rd_wait_p;    //outgoing pushback on read transactions
   output       rx_rd_wait_n;     
   
   //Transmitter
   output       tx_lclk_p;       //hlink clock output (up to 500MHz)
   output       tx_lclk_n;
   output       tx_frame_p;      //transaction frame signal
   output       tx_frame_n;
   output [7:0] tx_data_p;       //transmit data (dual data rate)
   output [7:0] tx_data_n;          
   input 	tx_wr_wait_p;    //incoming pushback on write transactions
   input 	tx_wr_wait_n;    
   input 	tx_rd_wait_p;    //incoming pushback on read transactions
   input 	tx_rd_wait_n;    

   /*****************************/
   /*MAILBOX                    */
   /*****************************/
   output       embox_not_empty;   
   output       embox_full;
   
   /*****************************/
   /*AXI master interface       */
   /*****************************/  
   //Clock and reset
   input 	 m_axi_aclk;
   input 	 m_axi_aresetn;

   //Read address channel
   output [31:0] m_axi_araddr;  //read address
   output [1:0]  m_axi_arburst; //burst type
   output [3:0]  m_axi_arcache; //memory type
   output [0:0]  m_axi_arid;    //address ID
   output [7:0]  m_axi_arlen;   //burst length (number of data transfers)
   output [0:0]  m_axi_arlock;  //lock type (atomic characteristics)
   output [2:0]  m_axi_arprot;  //protection type
   output [3:0]  m_axi_arqos;   //quality of service (setting?)
   input 	 m_axi_arready; //read ready
   output [2:0]  m_axi_arsize;  //burst size (the size of each transfer)
   output 	 m_axi_arvalid; //write address valid

   //Write address channel
   output [31:0] m_axi_awaddr;
   output [1:0]  m_axi_awburst; 
   output [3:0]  m_axi_awcache;
   output [0:0]  m_axi_awid;
   output [7:0]  m_axi_awlen;
   output [0:0]  m_axi_awlock;
   output [2:0]  m_axi_awprot;
   output [3:0]  m_axi_awqos;
   input 	 m_axi_awready;
   output [2:0]  m_axi_awsize;
   output 	 m_axi_awvalid;
   
   //Buffered write response channel
   input [0:0] 	 m_axi_bid;    //response tag
   output 	 m_axi_bready;
   input [1:0] 	 m_axi_bresp;
   input 	 m_axi_bvalid;
   
   //Read channel
   input [63:0]  m_axi_rdata;
   input [0:0] 	 m_axi_rid;     //read id tag
   input 	 m_axi_rlast;   //indicates last transfer of a burst
   output 	 m_axi_rready;  //read ready signal
   input [1:0] 	 m_axi_rresp;
   input 	 m_axi_rvalid;
   
   //Write channel
   output [63:0] m_axi_wdata;
   output 	 m_axi_wlast;   //indicates last transfer of a burs
   input 	 m_axi_wready;  //response ready
   output [7:0]  m_axi_wstrb;
   output 	 m_axi_wvalid;
   
   /*****************************/
   /*AXI slave interface        */
   /*****************************/  
   //Clock and reset
   input 	 s_axi_aclk;
   input 	 s_axi_aresetn;

   //Read address channel
   input [29:0]  s_axi_araddr;
   input [1:0] 	 s_axi_arburst;
   input [3:0] 	 s_axi_arcache;
   input [11:0]  s_axi_arid;
   input [7:0] 	 s_axi_arlen;
   input [0:0] 	 s_axi_arlock;
   input [2:0] 	 s_axi_arprot;
   input [3:0] 	 s_axi_arqos;
   output 	 s_axi_arready;
   input [3:0] 	 s_axi_arregion;
   input [2:0] 	 s_axi_arsize;
   input 	 s_axi_arvalid;

   //Write address channel
   input [29:0]  s_axi_awaddr;
   input [1:0] 	 s_axi_awburst;
   input [3:0] 	 s_axi_awcache;
   input [11:0]  s_axi_awid;
   input [7:0] 	 s_axi_awlen;
   input [0:0] 	 s_axi_awlock;
   input [2:0] 	 s_axi_awprot;
   input [3:0] 	 s_axi_awqos;
   output 	 s_axi_awready;
   input [3:0] 	 s_axi_awregion;
   input [2:0] 	 s_axi_awsize;
   input 	 s_axi_awvalid;

   //Buffered write response channel
   output [11:0] s_axi_bid;
   input 	 s_axi_bready;
   output [1:0]  s_axi_bresp;
   output 	 s_axi_bvalid;

   //Read channel
   output [31:0] s_axi_rdata;
   output [11:0] s_axi_rid;
   output 	 s_axi_rlast;
   input 	 s_axi_rready;
   output [1:0]  s_axi_rresp;
   output 	 s_axi_rvalid;
   
   //Write channel
   input [31:0]  s_axi_wdata;
   input 	 s_axi_wlast;
   output 	 s_axi_wready;
   input [3:0] 	 s_axi_wstrb;
   input 	 s_axi_wvalid;

   /*****************************/
   /*AXI config slave interface */
   /*****************************/  

   //read address channel
   input [12:0]  s_axicfg_araddr;
   input [2:0] 	 s_axicfg_arprot;
   output 	 s_axicfg_arready;
   input 	 s_axicfg_arvalid;

   //write address channel
   input [12:0]  s_axicfg_awaddr;
   input [2:0] 	 s_axicfg_awprot;
   output 	 s_axicfg_awready;
   input 	 s_axicfg_awvalid;

   //buffered read response channel
   input 	 s_axicfg_bready;
   output [1:0]  s_axicfg_bresp;
   output 	 s_axicfg_bvalid;

   //read channel
   output [31:0] s_axicfg_rdata;
   input 	 s_axicfg_rready;
   output [1:0]  s_axicfg_rresp;
   output 	 s_axicfg_rvalid;

   //write channel
   input [31:0]  s_axicfg_wdata;
   output 	 s_axicfg_wready;
   input [3:0] 	 s_axicfg_wstrb;
   input 	 s_axicfg_wvalid;

   //wires
   wire [31:0] 	 mi_rd_data;
   wire [31:0] 	 mi_dout_ecfg;
   wire [31:0] 	 mi_dout_embox;
   wire [31:0] 	 mi_dout_rx;
   wire [31:0] 	 mi_dout_tx;
   
   /*AUTOINPUT*/

   /*AUTOOUTPUT*/

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [3:0]		ecfg_cclk_div;		// From ecfg of ecfg.v
   wire			ecfg_cclk_en;		// From ecfg of ecfg.v
   wire [3:0]		ecfg_cclk_pllcfg;	// From ecfg of ecfg.v
   wire [11:0]		ecfg_coreid;		// From ecfg of ecfg.v
   wire [8:0]		ecfg_datain;		// From erx of erx.v
   wire [10:0]		ecfg_dataout;		// From ecfg of ecfg.v
   wire [15:0]		ecfg_rx_debug_signals;	// From erx of erx.v
   wire			ecfg_rx_enable;		// From ecfg of ecfg.v
   wire			ecfg_rx_gpio_mode;	// From ecfg of ecfg.v
   wire			ecfg_rx_mmu_mode;	// From ecfg of ecfg.v
   wire [3:0]		ecfg_tx_clkdiv;		// From ecfg of ecfg.v
   wire [3:0]		ecfg_tx_ctrl_mode;	// From ecfg of ecfg.v
   wire [15:0]		ecfg_tx_debug_signals;	// From etx of etx.v
   wire			ecfg_tx_enable;		// From ecfg of ecfg.v
   wire			ecfg_tx_gpio_mode;	// From ecfg of ecfg.v
   wire			ecfg_tx_mmu_mode;	// From ecfg of ecfg.v
   wire			ecfg_tx_tp_mode;	// From ecfg of ecfg.v
   wire			emaxi_emrq_empty;	// From erx of erx.v
   wire [102:0]		emaxi_emrq_rd_data;	// From erx of erx.v
   wire			emaxi_emrq_rd_en;	// From emaxi of emaxi.v
   wire			emaxi_emrr_full;	// From etx of etx.v
   wire			emaxi_emrr_prog_full;	// From etx of etx.v
   wire [102:0]		emaxi_emrr_wr_data;	// From emaxi of emaxi.v
   wire			emaxi_emrr_wr_en;	// From emaxi of emaxi.v
   wire			emaxi_emwr_empty;	// From erx of erx.v
   wire [102:0]		emaxi_emwr_rd_data;	// From erx of erx.v
   wire			emaxi_emwr_rd_en;	// From emaxi of emaxi.v
   wire			esaxi_emrq_full;	// From etx of etx.v
   wire			esaxi_emrq_prog_full;	// From etx of etx.v
   wire [102:0]		esaxi_emrq_wr_data;	// From esaxi of esaxi.v
   wire			esaxi_emrq_wr_en;	// From esaxi of esaxi.v
   wire			esaxi_emrr_empty;	// From erx of erx.v
   wire [102:0]		esaxi_emrr_rd_data;	// From erx of erx.v
   wire			esaxi_emrr_rd_en;	// From esaxi of esaxi.v
   wire			esaxi_emwr_full;	// From etx of etx.v
   wire			esaxi_emwr_prog_full;	// From etx of etx.v
   wire [102:0]		esaxi_emwr_wr_data;	// From esaxi of esaxi.v
   wire			esaxi_emwr_wr_en;	// From esaxi of esaxi.v
   wire [RFAW-1:0]	mi_addr;		// From esaxilite of esaxilite.v
   wire			mi_clk;			// From esaxilite of esaxilite.v
   wire [31:0]		mi_din;			// From esaxilite of esaxilite.v
   wire			mi_en;			// From esaxilite of esaxilite.v
   wire			mi_we;			// From esaxilite of esaxilite.v
   wire			reset;			// From ecfg of ecfg.v
   wire			txlclk_out;		// From eclock of eclock.v
   wire			txlclk_p;		// From eclock of eclock.v
   wire			txlclk_s;		// From eclock of eclock.v
   // End of automatics

 
   
   /***********************************************************/
   /*AXI MASTER                                               */
   /***********************************************************/
  /*emaxi AUTO_TEMPLATE ( 
                        // Outputs
	                .m00_\(.*\)       (m_\1[]),
                        .em\(.*\)         (emaxi_em\1[]),  
                        );
   */
   

   emaxi emaxi(/*AUTOINST*/
	       // Outputs
	       .emwr_rd_en		(emaxi_emwr_rd_en),	 // Templated
	       .emrq_rd_en		(emaxi_emrq_rd_en),	 // Templated
	       .emrr_wr_data		(emaxi_emrr_wr_data[102:0]), // Templated
	       .emrr_wr_en		(emaxi_emrr_wr_en),	 // Templated
	       .m00_axi_awid		(m_axi_awid[0:0]),	 // Templated
	       .m00_axi_awaddr		(m_axi_awaddr[31:0]),	 // Templated
	       .m00_axi_awlen		(m_axi_awlen[7:0]),	 // Templated
	       .m00_axi_awsize		(m_axi_awsize[2:0]),	 // Templated
	       .m00_axi_awburst		(m_axi_awburst[1:0]),	 // Templated
	       .m00_axi_awlock		(m_axi_awlock),		 // Templated
	       .m00_axi_awcache		(m_axi_awcache[3:0]),	 // Templated
	       .m00_axi_awprot		(m_axi_awprot[2:0]),	 // Templated
	       .m00_axi_awqos		(m_axi_awqos[3:0]),	 // Templated
	       .m00_axi_awvalid		(m_axi_awvalid),	 // Templated
	       .m00_axi_wdata		(m_axi_wdata[31:0]),	 // Templated
	       .m00_axi_wstrb		(m_axi_wstrb[3:0]),	 // Templated
	       .m00_axi_wlast		(m_axi_wlast),		 // Templated
	       .m00_axi_wvalid		(m_axi_wvalid),		 // Templated
	       .m00_axi_bready		(m_axi_bready),		 // Templated
	       .m00_axi_arid		(m_axi_arid[0:0]),	 // Templated
	       .m00_axi_araddr		(m_axi_araddr[31:0]),	 // Templated
	       .m00_axi_arlen		(m_axi_arlen[7:0]),	 // Templated
	       .m00_axi_arsize		(m_axi_arsize[2:0]),	 // Templated
	       .m00_axi_arburst		(m_axi_arburst[1:0]),	 // Templated
	       .m00_axi_arlock		(m_axi_arlock),		 // Templated
	       .m00_axi_arcache		(m_axi_arcache[3:0]),	 // Templated
	       .m00_axi_arprot		(m_axi_arprot[2:0]),	 // Templated
	       .m00_axi_arqos		(m_axi_arqos[3:0]),	 // Templated
	       .m00_axi_arvalid		(m_axi_arvalid),	 // Templated
	       .m00_axi_rready		(m_axi_rready),		 // Templated
	       // Inputs
	       .emwr_rd_data		(emaxi_emwr_rd_data[102:0]), // Templated
	       .emwr_empty		(emaxi_emwr_empty),	 // Templated
	       .emrq_rd_data		(emaxi_emrq_rd_data[102:0]), // Templated
	       .emrq_empty		(emaxi_emrq_empty),	 // Templated
	       .emrr_full		(emaxi_emrr_full),	 // Templated
	       .emrr_prog_full		(emaxi_emrr_prog_full),	 // Templated
	       .m00_axi_aclk		(m_axi_aclk),		 // Templated
	       .m00_axi_aresetn		(m_axi_aresetn),	 // Templated
	       .m00_axi_awready		(m_axi_awready),	 // Templated
	       .m00_axi_wready		(m_axi_wready),		 // Templated
	       .m00_axi_bid		(m_axi_bid[0:0]),	 // Templated
	       .m00_axi_bresp		(m_axi_bresp[1:0]),	 // Templated
	       .m00_axi_bvalid		(m_axi_bvalid),		 // Templated
	       .m00_axi_arready		(m_axi_arready),	 // Templated
	       .m00_axi_rid		(m_axi_rid[0:0]),	 // Templated
	       .m00_axi_rdata		(m_axi_rdata[31:0]),	 // Templated
	       .m00_axi_rresp		(m_axi_rresp[1:0]),	 // Templated
	       .m00_axi_rlast		(m_axi_rlast),		 // Templated
	       .m00_axi_rvalid		(m_axi_rvalid));		 // Templated

   /***********************************************************/
   /*AXI SLAVE                                                */
   /***********************************************************/
   /*esaxi AUTO_TEMPLATE ( 
                        // Outputs
	                .s00_\(.*\)       (s_\1[]),
                        .em\(.*\)         (esaxi_em\1[]),  
                        );
   */
   
   esaxi esaxi(/*AUTOINST*/
	       // Outputs
	       .emwr_wr_data		(esaxi_emwr_wr_data[102:0]), // Templated
	       .emwr_wr_en		(esaxi_emwr_wr_en),	 // Templated
	       .emrq_wr_data		(esaxi_emrq_wr_data[102:0]), // Templated
	       .emrq_wr_en		(esaxi_emrq_wr_en),	 // Templated
	       .emrr_rd_en		(esaxi_emrr_rd_en),	 // Templated
	       .s00_axi_awready		(s_axi_awready),	 // Templated
	       .s00_axi_wready		(s_axi_wready),		 // Templated
	       .s00_axi_bid		(s_axi_bid[0:0]),	 // Templated
	       .s00_axi_bresp		(s_axi_bresp[1:0]),	 // Templated
	       .s00_axi_bvalid		(s_axi_bvalid),		 // Templated
	       .s00_axi_arready		(s_axi_arready),	 // Templated
	       .s00_axi_rid		(s_axi_rid[0:0]),	 // Templated
	       .s00_axi_rdata		(s_axi_rdata[31:0]),	 // Templated
	       .s00_axi_rresp		(s_axi_rresp[1:0]),	 // Templated
	       .s00_axi_rlast		(s_axi_rlast),		 // Templated
	       .s00_axi_rvalid		(s_axi_rvalid),		 // Templated
	       // Inputs
	       .emwr_full		(esaxi_emwr_full),	 // Templated
	       .emwr_prog_full		(esaxi_emwr_prog_full),	 // Templated
	       .emrq_full		(esaxi_emrq_full),	 // Templated
	       .emrq_prog_full		(esaxi_emrq_prog_full),	 // Templated
	       .emrr_rd_data		(esaxi_emrr_rd_data[102:0]), // Templated
	       .emrr_empty		(esaxi_emrr_empty),	 // Templated
	       .ecfg_tx_ctrl_mode	(ecfg_tx_ctrl_mode[3:0]),
	       .ecfg_coreid		(ecfg_coreid[11:0]),
	       .s00_axi_aclk		(s_axi_aclk),		 // Templated
	       .s00_axi_aresetn		(s_axi_aresetn),	 // Templated
	       .s00_axi_awid		(s_axi_awid[0:0]),	 // Templated
	       .s00_axi_awaddr		(s_axi_awaddr[29:0]),	 // Templated
	       .s00_axi_awlen		(s_axi_awlen[7:0]),	 // Templated
	       .s00_axi_awsize		(s_axi_awsize[2:0]),	 // Templated
	       .s00_axi_awburst		(s_axi_awburst[1:0]),	 // Templated
	       .s00_axi_awlock		(s_axi_awlock),		 // Templated
	       .s00_axi_awcache		(s_axi_awcache[3:0]),	 // Templated
	       .s00_axi_awprot		(s_axi_awprot[2:0]),	 // Templated
	       .s00_axi_awqos		(s_axi_awqos[3:0]),	 // Templated
	       .s00_axi_awregion	(s_axi_awregion[3:0]),	 // Templated
	       .s00_axi_awvalid		(s_axi_awvalid),	 // Templated
	       .s00_axi_wdata		(s_axi_wdata[31:0]),	 // Templated
	       .s00_axi_wstrb		(s_axi_wstrb[3:0]),	 // Templated
	       .s00_axi_wlast		(s_axi_wlast),		 // Templated
	       .s00_axi_wvalid		(s_axi_wvalid),		 // Templated
	       .s00_axi_bready		(s_axi_bready),		 // Templated
	       .s00_axi_arid		(s_axi_arid[0:0]),	 // Templated
	       .s00_axi_araddr		(s_axi_araddr[29:0]),	 // Templated
	       .s00_axi_arlen		(s_axi_arlen[7:0]),	 // Templated
	       .s00_axi_arsize		(s_axi_arsize[2:0]),	 // Templated
	       .s00_axi_arburst		(s_axi_arburst[1:0]),	 // Templated
	       .s00_axi_arlock		(s_axi_arlock),		 // Templated
	       .s00_axi_arcache		(s_axi_arcache[3:0]),	 // Templated
	       .s00_axi_arprot		(s_axi_arprot[2:0]),	 // Templated
	       .s00_axi_arqos		(s_axi_arqos[3:0]),	 // Templated
	       .s00_axi_arregion	(s_axi_arregion[3:0]),	 // Templated
	       .s00_axi_arvalid		(s_axi_arvalid),	 // Templated
	       .s00_axi_rready		(s_axi_rready));		 // Templated
   
   /***********************************************************/
   /*AXI CONFIGURATION SLAVE (LITE)                           */
   /***********************************************************/
   
    esaxilite esaxilite(
		       /*AUTOINST*/
			// Outputs
			.s_axicfg_arready(s_axicfg_arready),
			.s_axicfg_awready(s_axicfg_awready),
			.s_axicfg_bresp	(s_axicfg_bresp[1:0]),
			.s_axicfg_bvalid(s_axicfg_bvalid),
			.s_axicfg_rdata	(s_axicfg_rdata[31:0]),
			.s_axicfg_rresp	(s_axicfg_rresp[1:0]),
			.s_axicfg_rvalid(s_axicfg_rvalid),
			.s_axicfg_wready(s_axicfg_wready),
			.mi_clk		(mi_clk),
			.mi_en		(mi_en),
			.mi_we		(mi_we),
			.mi_addr	(mi_addr[RFAW-1:0]),
			.mi_din		(mi_din[31:0]),
			// Inputs
			.s_axicfg_araddr(s_axicfg_araddr[15:0]),
			.s_axicfg_arprot(s_axicfg_arprot[2:0]),
			.s_axicfg_arvalid(s_axicfg_arvalid),
			.s_axicfg_awaddr(s_axicfg_awaddr[15:0]),
			.s_axicfg_awprot(s_axicfg_awprot[2:0]),
			.s_axicfg_awvalid(s_axicfg_awvalid),
			.s_axicfg_bready(s_axicfg_bready),
			.s_axicfg_rready(s_axicfg_rready),
			.s_axicfg_wdata	(s_axicfg_wdata[31:0]),
			.s_axicfg_wstrb	(s_axicfg_wstrb[3:0]),
			.s_axicfg_wvalid(s_axicfg_wvalid),
			.mi_rd_data	(mi_rd_data[31:0]));
   
   /***********************************************************/
   /*ELINK CLOCK GENERATOR                                    */
   /***********************************************************/

   eclock eclock(/*AUTOINST*/
		 // Outputs
		 .cclk_p		(cclk_p),
		 .cclk_n		(cclk_n),
		 .txlclk_s		(txlclk_s),
		 .txlclk_out		(txlclk_out),
		 .txlclk_p		(txlclk_p),
		 // Inputs
		 .clkin			(clkin),
		 .reset			(reset),
		 .ecfg_cclk_en		(ecfg_cclk_en),
		 .ecfg_cclk_div		(ecfg_cclk_div[3:0]),
		 .ecfg_cclk_pllcfg	(ecfg_cclk_pllcfg[3:0]));
   
  
   /***********************************************************/
   /*RECEIVER                                                 */
   /***********************************************************/

   erx erx(.mi_dout			(mi_dout_rx[DW-1:0]),
	   /*AUTOINST*/
	   // Outputs
	   .ecfg_rx_debug_signals	(ecfg_rx_debug_signals[15:0]),
	   .ecfg_datain			(ecfg_datain[8:0]),
	   .emaxi_emwr_empty		(emaxi_emwr_empty),
	   .emaxi_emwr_rd_data		(emaxi_emwr_rd_data[102:0]),
	   .emaxi_emrq_empty		(emaxi_emrq_empty),
	   .emaxi_emrq_rd_data		(emaxi_emrq_rd_data[102:0]),
	   .esaxi_emrr_empty		(esaxi_emrr_empty),
	   .esaxi_emrr_rd_data		(esaxi_emrr_rd_data[102:0]),
	   .rx_wr_wait_p		(rx_wr_wait_p),
	   .rx_wr_wait_n		(rx_wr_wait_n),
	   .rx_rd_wait_p		(rx_rd_wait_p),
	   .rx_rd_wait_n		(rx_rd_wait_n),
	   // Inputs
	   .reset			(reset),
	   .s_axi_aclk			(s_axi_aclk),
	   .m_axi_aclk			(m_axi_aclk),
	   .ecfg_rx_enable		(ecfg_rx_enable),
	   .ecfg_rx_mmu_mode		(ecfg_rx_mmu_mode),
	   .ecfg_rx_gpio_mode		(ecfg_rx_gpio_mode),
	   .ecfg_dataout		(ecfg_dataout[10:0]),
	   .emaxi_emwr_rd_en		(emaxi_emwr_rd_en),
	   .emaxi_emrq_rd_en		(emaxi_emrq_rd_en),
	   .esaxi_emrr_rd_en		(esaxi_emrr_rd_en),
	   .rx_lclk_p			(rx_lclk_p),
	   .rx_lclk_n			(rx_lclk_n),
	   .rx_frame_p			(rx_frame_p),
	   .rx_frame_n			(rx_frame_n),
	   .rx_data_p			(rx_data_p[7:0]),
	   .rx_data_n			(rx_data_n[7:0]),
	   .mi_clk			(mi_clk),
	   .mi_en			(mi_en),
	   .mi_we			(mi_we),
	   .mi_addr			(mi_addr[RFAW-1:0]),
	   .mi_din			(mi_din[31:0]));


   /***********************************************************/
   /*TRANSMITTER                                              */
   /***********************************************************/
   etx etx(.mi_dout			(mi_dout_tx[DW-1:0]),
	   /*AUTOINST*/
	   // Outputs
	   .ecfg_tx_debug_signals	(ecfg_tx_debug_signals[15:0]),
	   .esaxi_emrq_full		(esaxi_emrq_full),
	   .esaxi_emrq_prog_full	(esaxi_emrq_prog_full),
	   .esaxi_emwr_full		(esaxi_emwr_full),
	   .esaxi_emwr_prog_full	(esaxi_emwr_prog_full),
	   .emaxi_emrr_full		(emaxi_emrr_full),
	   .emaxi_emrr_prog_full	(emaxi_emrr_prog_full),
	   .tx_lclk_p			(tx_lclk_p),
	   .tx_lclk_n			(tx_lclk_n),
	   .tx_frame_p			(tx_frame_p),
	   .tx_frame_n			(tx_frame_n),
	   .tx_data_p			(tx_data_p[7:0]),
	   .tx_data_n			(tx_data_n[7:0]),
	   // Inputs
	   .reset			(reset),
	   .txlclk_out			(txlclk_out),
	   .txlclk_p			(txlclk_p),
	   .txlclk_s			(txlclk_s),
	   .s_axi_aclk			(s_axi_aclk),
	   .m_axi_aclk			(m_axi_aclk),
	   .ecfg_tx_clkdiv		(ecfg_tx_clkdiv[3:0]),
	   .ecfg_tx_enable		(ecfg_tx_enable),
	   .ecfg_tx_gpio_mode		(ecfg_tx_gpio_mode),
	   .ecfg_tx_mmu_mode		(ecfg_tx_mmu_mode),
	   .ecfg_dataout		(ecfg_dataout[10:0]),
	   .ecfg_tx_tp_mode		(ecfg_tx_tp_mode),
	   .esaxi_emrq_wr_en		(esaxi_emrq_wr_en),
	   .esaxi_emrq_wr_data		(esaxi_emrq_wr_data[102:0]),
	   .esaxi_emwr_wr_en		(esaxi_emwr_wr_en),
	   .esaxi_emwr_wr_data		(esaxi_emwr_wr_data[102:0]),
	   .emaxi_emrr_wr_en		(emaxi_emrr_wr_en),
	   .emaxi_emrr_wr_data		(emaxi_emrr_wr_data[102:0]),
	   .tx_wr_wait_p		(tx_wr_wait_p),
	   .tx_wr_wait_n		(tx_wr_wait_n),
	   .tx_rd_wait_p		(tx_rd_wait_p),
	   .tx_rd_wait_n		(tx_rd_wait_n));

   
   /***********************************************************/
   /*ELINK CONFIGURATION REGISTERES                           */
   /***********************************************************/

   /*ecfg AUTO_TEMPLATE ( 
                         // Outputs
	                .ecfg_reset		(reset),
                        .ecfg_debug_signals ({embox_full, embox_not_empty, ecfg_rx_debug_signals[13:0],ecfg_tx_debug_signals[15:0]}),    
                            );
   */
   
   
   ecfg ecfg(.mi_dout			(mi_dout_ecfg[DW-1:0]),
	     /*AUTOINST*/
	     // Outputs
	     .ecfg_reset		(reset),		 // Templated
	     .ecfg_tx_enable		(ecfg_tx_enable),
	     .ecfg_tx_mmu_mode		(ecfg_tx_mmu_mode),
	     .ecfg_tx_gpio_mode		(ecfg_tx_gpio_mode),
	     .ecfg_tx_tp_mode		(ecfg_tx_tp_mode),
	     .ecfg_tx_ctrl_mode		(ecfg_tx_ctrl_mode[3:0]),
	     .ecfg_tx_clkdiv		(ecfg_tx_clkdiv[3:0]),
	     .ecfg_rx_enable		(ecfg_rx_enable),
	     .ecfg_rx_mmu_mode		(ecfg_rx_mmu_mode),
	     .ecfg_rx_gpio_mode		(ecfg_rx_gpio_mode),
	     .ecfg_cclk_en		(ecfg_cclk_en),
	     .ecfg_cclk_div		(ecfg_cclk_div[3:0]),
	     .ecfg_cclk_pllcfg		(ecfg_cclk_pllcfg[3:0]),
	     .ecfg_coreid		(ecfg_coreid[11:0]),
	     .ecfg_dataout		(ecfg_dataout[10:0]),
	     // Inputs
	     .hw_reset			(hw_reset),
	     .mi_clk			(mi_clk),
	     .mi_en			(mi_en),
	     .mi_we			(mi_we),
	     .mi_addr			(mi_addr[RFAW-1:0]),
	     .mi_din			(mi_din[31:0]),
	     .ecfg_datain		(ecfg_datain[10:0]),
	     .ecfg_debug_signals	({embox_full, embox_not_empty, ecfg_rx_debug_signals[13:0],ecfg_tx_debug_signals[15:0]})); // Templated

   
   /***********************************************************/
   /*GENERAL PURPOSE MAILBOX                                  */
   /***********************************************************/

   embox embox(.clk			(mi_clk),
	       .mi_dout			(mi_dout_embox[DW-1:0]),
	       /*AUTOINST*/
	       // Outputs
	       .embox_full		(embox_full),
	       .embox_not_empty		(embox_not_empty),
	       // Inputs
	       .reset			(reset),
	       .mi_en			(mi_en),
	       .mi_we			(mi_we),
	       .mi_addr			(mi_addr[RFAW-1:0]),
	       .mi_din			(mi_din[DW-1:0]));
   
   /***********************************************************/
   /*AXI-LITE READBACK                                        */
   /***********************************************************/
   //TODO: fix decode logic

   assign mi_rd_data[31:0] = (mi_addr[15:14]==2'b00) ? mi_dout_ecfg[31:0]  :
			     (mi_addr[15:14]==2'b01) ? mi_dout_embox[31:0] :
			     (mi_addr[15:14]==2'b10) ? mi_dout_rx[31:0]    :
			      mi_dout_tx[31:0]    ;
   
endmodule // elink
// Local Variables:
// verilog-library-directories:("." "../../embox/hdl" "../../erx/hdl" "../../etx/hdl" "../../emaxi/hdl" "../../esaxi/hdl" "../../esaxilite/hdl" )
// End:

