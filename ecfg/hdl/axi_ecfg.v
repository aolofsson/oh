/*
  Copyright (C) 2013 Adapteva, Inc.
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

/*########################################################################
 AXI WRAPPER FOR ECFG BLOCK
 ########################################################################
 */
module axi_ecfg (/*AUTOARG*/
   // Outputs
   s_axi_awready, s_axi_wready, s_axi_bresp, s_axi_bvalid,
   s_axi_arready, s_axi_rdata, s_axi_rresp, s_axi_rvalid,
   esys_tx_enable, esys_tx_mmu_mode, esys_tx_gpio_mode,
   esys_tx_ctrl_mode, esys_tx_clkdiv, esys_rx_enable,
   esys_rx_mmu_mode, esys_rx_gpio_mode, esys_rx_loopback_mode,
   esys_cclk_div, esys_cclk_pllcfg, esys_coreid, esys_dataout,
   esys_irqsrc_read,
   // Inputs
   s_axi_aclk, s_axi_aresetn, s_axi_awaddr, s_axi_awprot,
   s_axi_awvalid, s_axi_wdata, s_axi_wstrb, s_axi_wvalid,
   s_axi_bready, s_axi_araddr, s_axi_arprot, s_axi_arvalid,
   s_axi_rready, param_coreid, erx_irq_fifo_src, erx_irq_fifo_data,
   erx_rdfifo_access, erx_rdfifo_wait, erx_wrfifo_access,
   erx_wrfifo_wait, erx_wbfifo_access, erx_wbfifo_wait,
   etx_rdfifo_access, etx_rdfifo_wait, etx_wrfifo_access,
   etx_wrfifo_wait, etx_wbfifo_access, etx_wbfifo_wait
   );
   //Register file parameters

/*
 #####################################################################
 COMPILE TIME PARAMETERS 
 ######################################################################
 */
   parameter DW   = 32;   //elink monitor register width
   parameter AW   = 32;   //mmu table address width
   parameter SW   = DW/8; //mmu table address width
   parameter MAW  = 6;    //register file address width
   parameter MDW  = 32;   //
   parameter IDW  = 12;   //Elink ID (row,column coordinate)


   /*****************************/
   /*AXI SLAVE INTERFACE (LITE) */
   /*****************************/

   //Global signals
   input 	     s_axi_aclk;      //clock source for axi slave interfaces
   input 	     s_axi_aresetn;   //asynchronous reset signal, active low 
   
   //Write address channel
   input [AW-1:0]    s_axi_awaddr;    //write address
   input [2:0] 	     s_axi_awprot;    //write protection type
   input 	     s_axi_awvalid;   //write address valid
   output 	     s_axi_awready;   //write address ready
   
   //Write data channel
   input [DW-1:0]    s_axi_wdata;     //write data
   input [SW-1:0]    s_axi_wstrb;     //write strobes
   input 	     s_axi_wvalid;    //write valid
   output            s_axi_wready;    //write channel ready
   
   //Buffered write response channel
   input 	     s_axi_bready;    //write ready
   output [1:0]      s_axi_bresp;     //write response
   output 	     s_axi_bvalid;    //write response valid
   
   //Read address channel
   input [AW-1:0]    s_axi_araddr;    //read address
   input [2:0] 	     s_axi_arprot;    //read protection type
   input 	     s_axi_arvalid;   //read address valid
   output 	     s_axi_arready;   //read address ready
   
   //Read data channel
   output [DW-1:0]   s_axi_rdata;     //read data
   output [1:0]      s_axi_rresp;     //read response
   output 	     s_axi_rvalid;    //read valid
   input 	     s_axi_rready;    //read ready
   
   
   /*****************************/
   /*STATIC SIGNALS             */
   /*****************************/
   input [IDW-1:0]  param_coreid;
    
   /*****************************/
   /*ELINK DATAPATH INPUTS      */
   /*****************************/
   input [11:0]      erx_irq_fifo_src;
   input [11:0]      erx_irq_fifo_data;
   input 	     erx_rdfifo_access;
   input 	     erx_rdfifo_wait;
   input 	     erx_wrfifo_access;
   input 	     erx_wrfifo_wait;
   input 	     erx_wbfifo_access;
   input 	     erx_wbfifo_wait;   
   input 	     etx_rdfifo_access;
   input 	     etx_rdfifo_wait;
   input 	     etx_wrfifo_access;
   input 	     etx_wrfifo_wait;
   input 	     etx_wbfifo_access;
   input 	     etx_wbfifo_wait;
  
   /*****************************/
   /*ECFG CONTROL OUTPUTS       */
   /*****************************/
   //tx
   output 	     esys_tx_enable;      //enable signal for TX  
   output 	     esys_tx_mmu_mode;    //enables MMU on transnmit path  
   output 	     esys_tx_gpio_mode;   //forces TX output pins to constants
   output [3:0]	     esys_tx_ctrl_mode;   //value for emesh ctrlmode tag
   output [3:0]      esys_tx_clkdiv;      //transmit clock divider

   //rx
   output 	     esys_rx_enable;         //enable signal for rx  
   output 	     esys_rx_mmu_mode;       //enables MMU on rx path  
   output 	     esys_rx_gpio_mode;      //forces rx wait pins to constants
   output 	     esys_rx_loopback_mode;  //loops back tx to rx receiver (after serdes)

   //cclk
   output [3:0]      esys_cclk_div;          //cclk divider setting
   output [3:0]      esys_cclk_pllcfg;       //pll configuration

   //coreid
   output [11:0]     esys_coreid;            //core-id for fpga elink

   //gpio
   output [11:0]     esys_dataout;          //data for elink outputs {rd_wait,wr_wait,frame,data[7:0}

   //irq
   output 	     esys_irqsrc_read;      //increments the irq fifo pointer

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [3:0]		ecfg_cclk_div;		// From ecfg of ecfg.v
   wire [3:0]		ecfg_cclk_pllcfg;	// From ecfg of ecfg.v
   wire [11:0]		ecfg_coreid;		// From ecfg of ecfg.v
   wire [11:0]		ecfg_dataout;		// From ecfg of ecfg.v
   wire			ecfg_rx_enable;		// From ecfg of ecfg.v
   wire			ecfg_rx_gpio_mode;	// From ecfg of ecfg.v
   wire			ecfg_rx_loopback_mode;	// From ecfg of ecfg.v
   wire			ecfg_rx_mmu_mode;	// From ecfg of ecfg.v
   wire [3:0]		ecfg_tx_clkdiv;		// From ecfg of ecfg.v
   wire [3:0]		ecfg_tx_ctrl_mode;	// From ecfg of ecfg.v
   wire			ecfg_tx_enable;		// From ecfg of ecfg.v
   wire			ecfg_tx_gpio_mode;	// From ecfg of ecfg.v
   wire			ecfg_tx_mmu_mode;	// From ecfg of ecfg.v
   wire			mi_access;		// From axi_memif of axi_memif.v
   wire [MAW-1:0]	mi_addr;		// From axi_memif of axi_memif.v
   wire [MDW-1:0]	mi_data_in;		// From axi_memif of axi_memif.v
   wire [31:0]		mi_data_out;		// From ecfg of ecfg.v
   wire			mi_write;		// From axi_memif of axi_memif.v
   // End of automatics

   axi_memif axi_memif(/*AUTOINST*/
		       // Outputs
		       .s_axi_awready	(s_axi_awready),
		       .s_axi_wready	(s_axi_wready),
		       .s_axi_bresp	(s_axi_bresp[1:0]),
		       .s_axi_bvalid	(s_axi_bvalid),
		       .s_axi_arready	(s_axi_arready),
		       .s_axi_rdata	(s_axi_rdata[DW-1:0]),
		       .s_axi_rresp	(s_axi_rresp[1:0]),
		       .s_axi_rvalid	(s_axi_rvalid),
		       .mi_addr		(mi_addr[MAW-1:0]),
		       .mi_access	(mi_access),
		       .mi_write	(mi_write),
		       .mi_data_in	(mi_data_in[MDW-1:0]),
		       // Inputs
		       .s_axi_aclk	(s_axi_aclk),
		       .s_axi_aresetn	(s_axi_aresetn),
		       .s_axi_awaddr	(s_axi_awaddr[AW-1:0]),
		       .s_axi_awprot	(s_axi_awprot[2:0]),
		       .s_axi_awvalid	(s_axi_awvalid),
		       .s_axi_wdata	(s_axi_wdata[DW-1:0]),
		       .s_axi_wstrb	(s_axi_wstrb[SW-1:0]),
		       .s_axi_wvalid	(s_axi_wvalid),
		       .s_axi_bready	(s_axi_bready),
		       .s_axi_araddr	(s_axi_araddr[AW-1:0]),
		       .s_axi_arprot	(s_axi_arprot[2:0]),
		       .s_axi_arvalid	(s_axi_arvalid),
		       .s_axi_rready	(s_axi_rready),
		       .mi_data_out	(mi_data_out[MDW-1:0]));
   
   ecfg ecfg(
	     /*AUTOINST*/
	     // Outputs
	     .mi_data_out		(mi_data_out[31:0]),
	     .ecfg_tx_enable		(ecfg_tx_enable),
	     .ecfg_tx_mmu_mode		(ecfg_tx_mmu_mode),
	     .ecfg_tx_gpio_mode		(ecfg_tx_gpio_mode),
	     .ecfg_tx_ctrl_mode		(ecfg_tx_ctrl_mode[3:0]),
	     .ecfg_tx_clkdiv		(ecfg_tx_clkdiv[3:0]),
	     .ecfg_rx_enable		(ecfg_rx_enable),
	     .ecfg_rx_mmu_mode		(ecfg_rx_mmu_mode),
	     .ecfg_rx_gpio_mode		(ecfg_rx_gpio_mode),
	     .ecfg_rx_loopback_mode	(ecfg_rx_loopback_mode),
	     .ecfg_cclk_div		(ecfg_cclk_div[3:0]),
	     .ecfg_cclk_pllcfg		(ecfg_cclk_pllcfg[3:0]),
	     .ecfg_coreid		(ecfg_coreid[11:0]),
	     .ecfg_dataout		(ecfg_dataout[11:0]),
	     // Inputs
	     .param_coreid		(param_coreid[IDW-1:0]),
	     .clk			(clk),
	     .reset			(reset),
	     .mi_access			(mi_access),
	     .mi_write			(mi_write),
	     .mi_addr			(mi_addr[5:0]),
	     .mi_data_in		(mi_data_in[31:0]));

   
		       endmodule // axi_ecfg
		       
// Local Variables:
// verilog-library-directories:("." "../axi")
// End:

