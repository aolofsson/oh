/*
  Copyright (C) 2014 Adapteva, Inc.
 
  Contributed by Andreas Olofsson <andreas@adapteva.com>
  Contributed by Fred Huettig <fred@adapteva.com>

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
`define CFG_COREID 12'h808
module elink (/*AUTOARG*/
   // Outputs
   rxo_wr_wait_p, rxo_wr_wait_n, rxo_rd_wait_p, rxo_rd_wait_n,
   txo_lclk_p, txo_lclk_n, txo_frame_p, txo_frame_n, txo_data_p,
   txo_data_n, embox_full, embox_not_empty, ecfg_cclk_div,
   ecfg_cclk_en, ecfg_cclk_pllcfg,
   // Inputs
   s1_axi_wvalid, s1_axi_wstrb, s1_axi_wdata, s1_axi_rready,
   s1_axi_bready, s1_axi_awvalid, s1_axi_awprot, s1_axi_awaddr,
   s1_axi_arvalid, s1_axi_arprot, s1_axi_aresetn, s1_axi_araddr,
   s1_axi_aclk, mi_readback_data, clk, hw_reset, rxi_lclk_p,
   rxi_lclk_n, rxi_frame_p, rxi_frame_n, rxi_data_p, rxi_data_n,
   txi_wr_wait_p, txi_wr_wait_n, txi_rd_wait_p, txi_rd_wait_n
   );
   parameter COREID   = `CFG_COREID;
   parameter DW       = 32;
   parameter AW       = 32;
   parameter RAW      = 20;
   
   /*****************************/
   /*BASIC SIGNAL               */
   /*****************************/
  
   input        hw_reset;       //Active high asynchronous hardware reset           
   
   /*****************************/
   /*ELINK INTERFACE (I/O PINS) */
   /*****************************/

   //Receiver
   input        rxi_lclk_p;      //high speed clock input (up to 500MHz)
   input        rxi_lclk_n;
   input        rxi_frame_p;     //frame signal to indicate start/stop of transaction stream
   input        rxi_frame_n;
   input [7:0]  rxi_data_p;      //receive data (dual data rate)
   input [7:0]  rxi_data_n;
   output       rxo_wr_wait_p;   //outgoing pushback on write transactions
   output       rxo_wr_wait_n;     
   output       rxo_rd_wait_p;   //outgoing pushback on read transactions
   output       rxo_rd_wait_n;     
   
   //Transmitter
   output       txo_lclk_p;       //high speed clock output (up to 500MHz)
   output       txo_lclk_n;
   output       txo_frame_p;      //frame signal to indicate start/stop of transaction stream
   output       txo_frame_n;
   output [7:0] txo_data_p;       //transmit data (dual data rate)
   output [7:0] txo_data_n;          
   input 	txi_wr_wait_p;    //incoming pushback on write transactions
   input 	txi_wr_wait_n;    
   input 	txi_rd_wait_p;    //incoming pushback on read transactions
   input 	txi_rd_wait_n;    
   
   //Mailbox Signals
   output 	embox_full;       //Mailbox is full (-->interrupt)
   output 	embox_not_empty;  //"You have mail" (-->interrupt)

   //Outputs for FPGA PLL
   //Keep separate from elink to increase flexibility (elink orthoginal to # clocks)
   //ie: 2 link, 2 chips, 2links 4 chips, on board clock driver etc

   output [3:0]      ecfg_cclk_div;
   output 	     ecfg_cclk_en;
   output [3:0]      ecfg_cclk_pllcfg;

   //Wires
   wire [31:0] 	     ecfg_data_out;
   wire [31:0]	     embox_data_out;
   wire [5:0] 	     emon_zero_flag;   
   wire [31:0] 	     emon_data_out;
   

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [11:0]		ecfg_coreid;		// From ecfg of ecfg.v
   wire [11:0]		ecfg_gpio_dataout;	// From ecfg of ecfg.v
   wire			ecfg_reset;		// From ecfg of ecfg.v
   wire			ecfg_rx_enable;		// From ecfg of ecfg.v
   wire			ecfg_rx_gpio_mode;	// From ecfg of ecfg.v
   wire			ecfg_rx_loopback_mode;	// From ecfg of ecfg.v
   wire			ecfg_rx_mmu_mode;	// From ecfg of ecfg.v
   wire			ecfg_sw_reset;		// From ecfg of ecfg.v
   wire [3:0]		ecfg_tx_clkdiv;		// From ecfg of ecfg.v
   wire [3:0]		ecfg_tx_ctrl_mode;	// From ecfg of ecfg.v
   wire			ecfg_tx_enable;		// From ecfg of ecfg.v
   wire			ecfg_tx_gpio_mode;	// From ecfg of ecfg.v
   wire			ecfg_tx_mmu_mode;	// From ecfg of ecfg.v
   wire			erx_rdfifo_access;	// From elink_rx of elink_rx.v
   wire			erx_rdfifo_wait;	// From elink_rx of elink_rx.v
   wire			erx_wbfifo_access;	// From elink_rx of elink_rx.v
   wire			erx_wbfifo_wait;	// From elink_rx of elink_rx.v
   wire			erx_wrfifo_access;	// From elink_rx of elink_rx.v
   wire			erx_wrfifo_wait;	// From elink_rx of elink_rx.v
   wire			etx_rdfifo_access;	// From elink_tx of elink_tx.v
   wire			etx_rdfifo_wait;	// From elink_tx of elink_tx.v
   wire			etx_wbfifo_access;	// From elink_tx of elink_tx.v
   wire			etx_wbfifo_wait;	// From elink_tx of elink_tx.v
   wire			etx_wrfifo_access;	// From elink_tx of elink_tx.v
   wire			etx_wrfifo_wait;	// From elink_tx of elink_tx.v
   wire			mi_access;		// From axi_slave_memif of axi_slave_memif.v
   wire [19:0]		mi_addr;		// From axi_slave_memif of axi_slave_memif.v
   wire [DW-1:0]	mi_data_in;		// From axi_slave_memif of axi_slave_memif.v
   wire			mi_write;		// From axi_slave_memif of axi_slave_memif.v
   wire			s1_axi_arready;		// From axi_slave_memif of axi_slave_memif.v
   wire			s1_axi_awready;		// From axi_slave_memif of axi_slave_memif.v
   wire [1:0]		s1_axi_bresp;		// From axi_slave_memif of axi_slave_memif.v
   wire			s1_axi_bvalid;		// From axi_slave_memif of axi_slave_memif.v
   wire [DW-1:0]	s1_axi_rdata;		// From axi_slave_memif of axi_slave_memif.v
   wire [1:0]		s1_axi_rresp;		// From axi_slave_memif of axi_slave_memif.v
   wire			s1_axi_rvalid;		// From axi_slave_memif of axi_slave_memif.v
   wire			s1_axi_wready;		// From axi_slave_memif of axi_slave_memif.v
   // End of automatics

   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		clk;			// To elink_rx of elink_rx.v, ...
   input [DW-1:0]	mi_readback_data;	// To axi_slave_memif of axi_slave_memif.v
   input		s1_axi_aclk;		// To axi_slave_memif of axi_slave_memif.v
   input [AW-1:0]	s1_axi_araddr;		// To axi_slave_memif of axi_slave_memif.v
   input		s1_axi_aresetn;		// To axi_slave_memif of axi_slave_memif.v
   input [2:0]		s1_axi_arprot;		// To axi_slave_memif of axi_slave_memif.v
   input		s1_axi_arvalid;		// To axi_slave_memif of axi_slave_memif.v
   input [AW-1:0]	s1_axi_awaddr;		// To axi_slave_memif of axi_slave_memif.v
   input [2:0]		s1_axi_awprot;		// To axi_slave_memif of axi_slave_memif.v
   input		s1_axi_awvalid;		// To axi_slave_memif of axi_slave_memif.v
   input		s1_axi_bready;		// To axi_slave_memif of axi_slave_memif.v
   input		s1_axi_rready;		// To axi_slave_memif of axi_slave_memif.v
   input [DW-1:0]	s1_axi_wdata;		// To axi_slave_memif of axi_slave_memif.v
   input [3:0]		s1_axi_wstrb;		// To axi_slave_memif of axi_slave_memif.v
   input		s1_axi_wvalid;		// To axi_slave_memif of axi_slave_memif.v
   // End of automatics
   
   /*****************************/
   /*AXI INTERFACES             */
   /*****************************/

   axi_elink_master axi_elink_master(/*AUTOINST*/);

   /*****************************/
   /*AXI ELINK SLAVE I/F        */
   /*****************************/
      
   axi_elink_slave  axi_elink_slave(/*AUTOINST*/);

   /*****************************/
   /*AXI SLAVE CONFIGL I/F      */
   /*****************************/
   
   /*axi_slave_memif AUTO_TEMPLATE (   .s_axi_\(.*\) (s1_axi_\1[]), 
                                       .s_axi_wstrb  (s1_axi_wstrb[3:0]),
                                   );
   */

   axi_slave_memif axi_slave_memif (/*AUTOINST*/
				    // Outputs
				    .s_axi_awready	(s1_axi_awready), // Templated
				    .s_axi_wready	(s1_axi_wready), // Templated
				    .s_axi_bresp	(s1_axi_bresp[1:0]), // Templated
				    .s_axi_bvalid	(s1_axi_bvalid), // Templated
				    .s_axi_arready	(s1_axi_arready), // Templated
				    .s_axi_rdata	(s1_axi_rdata[DW-1:0]), // Templated
				    .s_axi_rresp	(s1_axi_rresp[1:0]), // Templated
				    .s_axi_rvalid	(s1_axi_rvalid), // Templated
				    .mi_addr		(mi_addr[19:0]),
				    .mi_access		(mi_access),
				    .mi_write		(mi_write),
				    .mi_data_in		(mi_data_in[DW-1:0]),
				    // Inputs
				    .s_axi_aclk		(s1_axi_aclk),	 // Templated
				    .s_axi_aresetn	(s1_axi_aresetn), // Templated
				    .s_axi_awaddr	(s1_axi_awaddr[AW-1:0]), // Templated
				    .s_axi_awprot	(s1_axi_awprot[2:0]), // Templated
				    .s_axi_awvalid	(s1_axi_awvalid), // Templated
				    .s_axi_wdata	(s1_axi_wdata[DW-1:0]), // Templated
				    .s_axi_wstrb	(s1_axi_wstrb[3:0]), // Templated
				    .s_axi_wvalid	(s1_axi_wvalid), // Templated
				    .s_axi_bready	(s1_axi_bready), // Templated
				    .s_axi_araddr	(s1_axi_araddr[AW-1:0]), // Templated
				    .s_axi_arprot	(s1_axi_arprot[2:0]), // Templated
				    .s_axi_arvalid	(s1_axi_arvalid), // Templated
				    .s_axi_rready	(s1_axi_rready), // Templated
				    .mi_readback_data	(mi_readback_data[DW-1:0]));

   
   /*****************************/
   /*ELINKS RX/TX               */
   /*****************************/
			  
   //receive
   elink_rx elink_rx(.reset		(ecfg_reset),
		     .ecfg_rx_dataout	(ecfg_gpio_dataout[11:10]),
		     /*AUTOINST*/
		     // Outputs
		     .rxo_wr_wait_p	(rxo_wr_wait_p),
		     .rxo_wr_wait_n	(rxo_wr_wait_n),
		     .rxo_rd_wait_p	(rxo_rd_wait_p),
		     .rxo_rd_wait_n	(rxo_rd_wait_n),
		     .erx_rdfifo_access	(erx_rdfifo_access),
		     .erx_rdfifo_wait	(erx_rdfifo_wait),
		     .erx_wrfifo_access	(erx_wrfifo_access),
		     .erx_wrfifo_wait	(erx_wrfifo_wait),
		     .erx_wbfifo_access	(erx_wbfifo_access),
		     .erx_wbfifo_wait	(erx_wbfifo_wait),
		     // Inputs
		     .clk		(clk),
		     .ecfg_coreid	(ecfg_coreid[11:0]),
		     .rxi_lclk_p	(rxi_lclk_p),
		     .rxi_lclk_n	(rxi_lclk_n),
		     .rxi_frame_p	(rxi_frame_p),
		     .rxi_frame_n	(rxi_frame_n),
		     .rxi_data_p	(rxi_data_p[7:0]),
		     .rxi_data_n	(rxi_data_n[7:0]),
		     .ecfg_rx_enable	(ecfg_rx_enable),
		     .ecfg_rx_gpio_mode	(ecfg_rx_gpio_mode),
		     .ecfg_rx_loopback_mode(ecfg_rx_loopback_mode),
		     .ecfg_rx_mmu_mode	(ecfg_rx_mmu_mode));

   //transmit
   elink_tx elink_tx(.reset		(ecfg_reset),
		     .ecfg_tx_dataout	(ecfg_gpio_dataout[8:0]),
		     /*AUTOINST*/
		     // Outputs
		     .txo_lclk_p	(txo_lclk_p),
		     .txo_lclk_n	(txo_lclk_n),
		     .txo_frame_p	(txo_frame_p),
		     .txo_frame_n	(txo_frame_n),
		     .txo_data_p	(txo_data_p[7:0]),
		     .txo_data_n	(txo_data_n[7:0]),
		     .etx_rdfifo_access	(etx_rdfifo_access),
		     .etx_rdfifo_wait	(etx_rdfifo_wait),
		     .etx_wrfifo_access	(etx_wrfifo_access),
		     .etx_wrfifo_wait	(etx_wrfifo_wait),
		     .etx_wbfifo_access	(etx_wbfifo_access),
		     .etx_wbfifo_wait	(etx_wbfifo_wait),
		     // Inputs
		     .clk		(clk),
		     .ecfg_coreid	(ecfg_coreid[11:0]),
		     .txi_wr_wait_p	(txi_wr_wait_p),
		     .txi_wr_wait_n	(txi_wr_wait_n),
		     .txi_rd_wait_p	(txi_rd_wait_p),
		     .txi_rd_wait_n	(txi_rd_wait_n),
		     .ecfg_tx_enable	(ecfg_tx_enable),
		     .ecfg_tx_mmu_mode	(ecfg_tx_mmu_mode),
		     .ecfg_tx_gpio_mode	(ecfg_tx_gpio_mode),
		     .ecfg_tx_ctrl_mode	(ecfg_tx_ctrl_mode[3:0]),
		     .ecfg_tx_clkdiv	(ecfg_tx_clkdiv[3:0]));

   
   /*****************************/
   /*ELINKS CONFIG              */
   /*****************************/
   
   ecfg ecfg(.param_coreid		(COREID),
	     .mi_data_out		(ecfg_data_out[31:0]),
	     .mi_data_sel		(ecfg_select),
	     /*AUTOINST*/
	     // Outputs
	     .ecfg_sw_reset		(ecfg_sw_reset),
	     .ecfg_reset		(ecfg_reset),
	     .ecfg_tx_enable		(ecfg_tx_enable),
	     .ecfg_tx_mmu_mode		(ecfg_tx_mmu_mode),
	     .ecfg_tx_gpio_mode		(ecfg_tx_gpio_mode),
	     .ecfg_tx_ctrl_mode		(ecfg_tx_ctrl_mode[3:0]),
	     .ecfg_tx_clkdiv		(ecfg_tx_clkdiv[3:0]),
	     .ecfg_rx_enable		(ecfg_rx_enable),
	     .ecfg_rx_mmu_mode		(ecfg_rx_mmu_mode),
	     .ecfg_rx_gpio_mode		(ecfg_rx_gpio_mode),
	     .ecfg_rx_loopback_mode	(ecfg_rx_loopback_mode),
	     .ecfg_cclk_en		(ecfg_cclk_en),
	     .ecfg_cclk_div		(ecfg_cclk_div[3:0]),
	     .ecfg_cclk_pllcfg		(ecfg_cclk_pllcfg[3:0]),
	     .ecfg_coreid		(ecfg_coreid[11:0]),
	     .ecfg_gpio_dataout		(ecfg_gpio_dataout[11:0]),
	     // Inputs
	     .clk			(clk),
	     .hw_reset			(hw_reset),
	     .mi_access			(mi_access),
	     .mi_write			(mi_write),
	     .mi_addr			(mi_addr[19:0]),
	     .mi_data_in		(mi_data_in[31:0]));
   
   /*****************************/
   /*ELINK MAILBOX              */
   /*****************************/
   embox embox(.reset			(ecfg_reset),
	       .mi_data_out		(embox_data_out[DW-1:0]),
	       .mi_data_sel		(embox_select),
	       /*AUTOINST*/
	       // Outputs
	       .embox_full		(embox_full),
	       .embox_not_empty		(embox_not_empty),
	       // Inputs
	       .clk			(clk),
	       .mi_access		(mi_access),
	       .mi_write		(mi_write),
	       .mi_addr			(mi_addr[19:0]),
	       .mi_data_in		(mi_data_in[DW-1:0]));
   
   /*****************************/
   /*ELINKS MONITORS            */
   /*****************************/
`ifdef CFG_EMON
   emon emon(.reset			(ecfg_reset),
	     .mi_data_out		(emon_data_out[DW-1:0]),
	     .mi_data_sel		(emon_select),
	     /*AUTOINST*/
	     // Outputs
	     .emon_zero_flag		(emon_zero_flag[5:0]),
	     // Inputs
	     .clk			(clk),
	     .mi_access			(mi_access),
	     .mi_write			(mi_write),
	     .mi_addr			(mi_addr[19:0]),
	     .mi_data_in		(mi_data_in[DW-1:0]),
	     .erx_rdfifo_access		(erx_rdfifo_access),
	     .erx_rdfifo_wait		(erx_rdfifo_wait),
	     .erx_wrfifo_access		(erx_wrfifo_access),
	     .erx_wrfifo_wait		(erx_wrfifo_wait),
	     .erx_wbfifo_access		(erx_wbfifo_access),
	     .erx_wbfifo_wait		(erx_wbfifo_wait),
	     .etx_rdfifo_access		(etx_rdfifo_access),
	     .etx_rdfifo_wait		(etx_rdfifo_wait),
	     .etx_wrfifo_access		(etx_wrfifo_access),
	     .etx_wrfifo_wait		(etx_wrfifo_wait),
	     .etx_wbfifo_access		(etx_wbfifo_access),
	     .etx_wbfifo_wait		(etx_wbfifo_wait));
`else // !`ifdef CFG_EMON
   assign emon_zero_flag[5:0]=6'b0;
   assign emon_data_out[31:0]=32'b0;
   assign  mi_data_sel=1'b0;   
`endif

   
   /*****************************/
   /*MUXING DATA FROM REGS      */
   /*****************************/
   mux3 #(.DW(DW)) mux3(
	     // Outputs
	     .out			(mi_readback_data[DW-1:0]),
	     // Inputs
	     .in0			(ecfg_data_out[DW-1:0]),
	     .in1			(emon_data_out[DW-1:0]),
	     .in2			(embox_data_out[DW-1:0]),
	     .sel0			(ecfg_select),
	     .sel1			(emon_select),
	     .sel2			(embox_select)
	     );

endmodule // elink
// Local Variables:
// verilog-library-directories:("." "../../embox/hdl" "../../common/hdl" "../../axi/hdl" "../../ecfg/hdl" "../../emmu/hdl" "../../emon/hdl")
// End:


