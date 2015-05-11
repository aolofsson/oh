module etx_core(/*AUTOARG*/
   // Outputs
   tx_data_par, tx_frame_par, txrd_wait, txrr_wait, txwr_wait,
   etx_cfg_access, etx_cfg_packet,
   // Inputs
   reset, clk, tx_rd_wait, tx_wr_wait, txrd_access, txrd_packet,
   txrr_access, txrr_packet, txwr_access, txwr_packet, etx_cfg_wait
   );
   parameter AW      = 32;
   parameter DW      = 32;
   parameter PW      = 104;
   parameter RFAW    = 6;
   parameter ID      = 12'h000;
   
   //Clocks,reset,config
   input           reset;
   input 	   clk;   
  
   //IO interface
   output [63:0]   tx_data_par;
   output [7:0]    tx_frame_par;
   input 	   tx_rd_wait;
   input 	   tx_wr_wait;
   
   //TXRD
   input 	   txrd_access;
   input [PW-1:0]  txrd_packet;
   output 	   txrd_wait;
   
   //TXRR
   input 	   txrr_access;
   input [PW-1:0]  txrr_packet;
   output 	   txrr_wait;
   
   //TXWR
   input 	   txwr_access;
   input [PW-1:0]  txwr_packet;
   output 	   txwr_wait;

   //Configuration Interface (for ERX)
   output 	   etx_cfg_access;
   output [PW-1:0] etx_cfg_packet;
   input 	   etx_cfg_wait;

   //for status?
   wire[15:0] 	   tx_status; 
   
   /*AUTOOUTPUT*/
   /*AUTOINPUT*/
     
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [3:0]		ctrlmode;		// From etx_cfg of etx_cfg.v
   wire			ctrlmode_bypass;	// From etx_cfg of etx_cfg.v
   wire			edma_access;		// From etx_dma of edma.v
   wire [PW-1:0]	edma_packet;		// From etx_dma of edma.v
   wire			edma_wait;		// From etx_arbiter of etx_arbiter.v
   wire			emmu_access;		// From etx_mmu of emmu.v
   wire [PW-1:0]	emmu_packet;		// From etx_mmu of emmu.v
   wire			etx_access;		// From etx_arbiter of etx_arbiter.v
   wire [PW-1:0]	etx_packet;		// From etx_arbiter of etx_arbiter.v
   wire			etx_rd_wait;		// From etx_protocol of etx_protocol.v
   wire			etx_remap_access;	// From etx_remap of etx_remap.v
   wire [PW-1:0]	etx_remap_packet;	// From etx_remap of etx_remap.v
   wire			etx_rr;			// From etx_arbiter of etx_arbiter.v
   wire			etx_wr_wait;		// From etx_protocol of etx_protocol.v
   wire [8:0]		gpio_data;		// From etx_cfg of etx_cfg.v
   wire			gpio_enable;		// From etx_cfg of etx_cfg.v
   wire [14:0]		mi_addr;		// From etx_cfgif of ecfg_if.v
   wire [DW-1:0]	mi_cfg_dout;		// From etx_cfg of etx_cfg.v
   wire			mi_cfg_en;		// From etx_cfgif of ecfg_if.v
   wire [63:0]		mi_din;			// From etx_cfgif of ecfg_if.v
   wire [DW-1:0]	mi_dma_dout;		// From etx_dma of edma.v
   wire			mi_dma_en;		// From etx_cfgif of ecfg_if.v
   wire [DW-1:0]	mi_mmu_dout;		// From etx_mmu of emmu.v
   wire			mi_mmu_en;		// From etx_cfgif of ecfg_if.v
   wire			mi_we;			// From etx_cfgif of ecfg_if.v
   wire			mmu_enable;		// From etx_cfg of etx_cfg.v
   wire			remap_enable;		// From etx_cfg of etx_cfg.v
   wire			tx_enable;		// From etx_cfg of etx_cfg.v
   // End of automatics

   /************************************************************/
   /*EDMA ("4th channel")                                      */
   /************************************************************/
  
  
   /*edma AUTO_TEMPLATE (
                         .mi_en		(mi_dma_en),
                         .edma_access	(edma_access),   
                         .mi_dout       (mi_dma_dout[DW-1:0]),
                         .edma_access	(edma_access),
                         .edma_write	(edma_packet[1]),
	                 .edma_datamode	(edma_packet[3:2]),
	                 .edma_ctrlmode	(edma_packet[7:4]),
	                 .edma_dstaddr	(edma_packet[39:8]),
	                 .edma_data	(edma_packet[71:40]),
	                 .edma_srcaddr	(edma_packet[103:72]),
                               );
    */
   
   edma etx_dma (/*AUTOINST*/
		 // Outputs
		 .mi_dout		(mi_dma_dout[DW-1:0]),	 // Templated
		 .edma_access		(edma_access),		 // Templated
		 .edma_packet		(edma_packet[PW-1:0]),
		 // Inputs
		 .reset			(reset),
		 .clk			(clk),
		 .mi_en			(mi_dma_en),		 // Templated
		 .mi_we			(mi_we),
		 .mi_addr		(mi_addr[RFAW+1:0]),
		 .mi_din		(mi_din[63:0]),
		 .edma_wait		(edma_wait));
   
   /************************************************************/
   /*ELINK TRANSMIT ARBITER                                    */
   /************************************************************/
   defparam etx_arbiter.ID=ID;   
   etx_arbiter etx_arbiter (
			      /*AUTOINST*/
			    // Outputs
			    .txwr_wait		(txwr_wait),
			    .txrd_wait		(txrd_wait),
			    .txrr_wait		(txrr_wait),
			    .edma_wait		(edma_wait),
			    .etx_access		(etx_access),
			    .etx_packet		(etx_packet[PW-1:0]),
			    .etx_rr		(etx_rr),
			    // Inputs
			    .clk		(clk),
			    .reset		(reset),
			    .txwr_access	(txwr_access),
			    .txwr_packet	(txwr_packet[PW-1:0]),
			    .txrd_access	(txrd_access),
			    .txrd_packet	(txrd_packet[PW-1:0]),
			    .txrr_access	(txrr_access),
			    .txrr_packet	(txrr_packet[PW-1:0]),
			    .edma_access	(edma_access),
			    .edma_packet	(edma_packet[PW-1:0]),
			    .etx_rd_wait	(etx_rd_wait),
			    .etx_wr_wait	(etx_wr_wait),
			    .etx_cfg_wait	(etx_cfg_wait),
			    .ctrlmode_bypass	(ctrlmode_bypass),
			    .ctrlmode		(ctrlmode[3:0]));
      

   /************************************************************/
   /* CONFIGURATOIN PACKET                                     */
   /************************************************************/
   /*ecfg_if AUTO_TEMPLATE ( 
    .\(.*\)_in          (etx_\1[]),
    .\(.*\)_out         (etx_cfg_\1[]),
    .mi_dout0		({32'b0,mi_cfg_dout[31:0]}),
    .mi_dout1		({32'b0,mi_dma_dout[31:0]}),
    .mi_dout2		({32'b0,mi_mmu_dout[31:0]}),
    .wait_in		(etx_cfg_wait),
    );
        */
   
   defparam etx_cfgif.RX =0;   
   ecfg_if etx_cfgif (.mi_dout3		(64'b0),
		      /*AUTOINST*/
		      // Outputs
		      .mi_mmu_en	(mi_mmu_en),
		      .mi_dma_en	(mi_dma_en),
		      .mi_cfg_en	(mi_cfg_en),
		      .mi_we		(mi_we),
		      .mi_addr		(mi_addr[14:0]),
		      .mi_din		(mi_din[63:0]),
		      .access_out	(etx_cfg_access),	 // Templated
		      .packet_out	(etx_cfg_packet[PW-1:0]), // Templated
		      // Inputs
		      .clk		(clk),
		      .reset		(reset),
		      .access_in	(etx_access),		 // Templated
		      .packet_in	(etx_packet[PW-1:0]),	 // Templated
		      .mi_dout0		({32'b0,mi_cfg_dout[31:0]}), // Templated
		      .mi_dout1		({32'b0,mi_dma_dout[31:0]}), // Templated
		      .mi_dout2		({32'b0,mi_mmu_dout[31:0]}), // Templated
		      .wait_in		(etx_cfg_wait));		 // Templated
   
   /************************************************************/
   /* ETX CONFIGURATION REGISTERS                              */
   /************************************************************/
    /*etx_cfg AUTO_TEMPLATE (.mi_dout       (mi_cfg_dout[DW-1:0]), 
                             .mi_en	    (mi_cfg_en),
    );
        */

   //todo: make more useufl
   assign tx_status[15:0]  = 16'b0;
/*   

{2'b0,                //15:14
			      etx_rd_wait,         //13
			      etx_wr_wait,         //12
			      txrr_fifo_read,      //11			
			      txrr_wait,           //10
			      txrr_access,         //9	 		
			      txrd_fifo_read,      //8			
			      txrd_wait,           //7
			      txrd_access,         //6
			      txwr_fifo_read,      //5
			      txwr_wait,           //4
			      txwr_access,         //3
			      1'b0,                //2
			      1'b0,                //1
			      1'b0	           //0
			      };
*/
 
   etx_cfg etx_cfg (
		    /*AUTOINST*/
		    // Outputs
		    .mi_dout		(mi_cfg_dout[DW-1:0]),	 // Templated
		    .tx_enable		(tx_enable),
		    .mmu_enable		(mmu_enable),
		    .gpio_enable	(gpio_enable),
		    .remap_enable	(remap_enable),
		    .gpio_data		(gpio_data[8:0]),
		    .ctrlmode		(ctrlmode[3:0]),
		    .ctrlmode_bypass	(ctrlmode_bypass),
		    // Inputs
		    .reset		(reset),
		    .clk		(clk),
		    .mi_en		(mi_cfg_en),		 // Templated
		    .mi_we		(mi_we),
		    .mi_addr		(mi_addr[RFAW+1:0]),
		    .mi_din		(mi_din[31:0]),
		    .tx_status		(tx_status[15:0]));
      
   /************************************************************/
   /* REMAPPING (SHIFT) DESTINATION ADDRESS                    */
   /************************************************************/
    /*etx_remap  AUTO_TEMPLATE (	
                          .emesh_\(.*\)_in  (etx_\1[]),
                          .emesh_\(.*\)_out (etx_remap_\1[]),
                          .remap_en	    (remap_enable),
                          .remap_bypass	    (etx_rr),
                          .emesh_wait       (etx_wait),
                          );
   */

   etx_remap etx_remap (/*AUTOINST*/
			// Outputs
			.emesh_access_out(etx_remap_access),	 // Templated
			.emesh_packet_out(etx_remap_packet[PW-1:0]), // Templated
			// Inputs
			.clk		(clk),
			.reset		(reset),
			.emesh_access_in(etx_access),		 // Templated
			.emesh_packet_in(etx_packet[PW-1:0]),	 // Templated
			.remap_en	(remap_enable),		 // Templated
			.remap_bypass	(etx_rr),		 // Templated
			.etx_rd_wait	(etx_rd_wait),
			.etx_wr_wait	(etx_wr_wait));
   
 
   /************************************************************/
   /* EMMU                                                     */
   /************************************************************/
   /*emmu  AUTO_TEMPLATE (	
                          .emesh_\(.*\)_in  (etx_remap_\1[]),
                          .emesh_\(.*\)_out (emmu_\1[]),
                          .mmu_en	    (mmu_enable),
                          .mmu_bp	    (etx_rr),
                          .rd_clk           (clk),
                          .wr_clk           (clk),
                          .emmu_access_out  (emmu_access),
                          .emmu_packet_out  (emmu_packet[PW-1:0]),
                          .mi_dout	    (mi_mmu_dout[DW-1:0]),
                          .emesh_rd_wait    (etx_rd_wait),
                          .emesh_wr_wait    (etx_wr_wait),
                          .emesh_packet_hi_out	(),
                          .mi_en	    (mi_mmu_en),
                         );
   */

   emmu etx_mmu (
	      /*AUTOINST*/
		 // Outputs
		 .mi_dout		(mi_mmu_dout[DW-1:0]),	 // Templated
		 .emesh_access_out	(emmu_access),		 // Templated
		 .emesh_packet_out	(emmu_packet[PW-1:0]),	 // Templated
		 .emesh_packet_hi_out	(),			 // Templated
		 // Inputs
		 .reset			(reset),
		 .rd_clk		(clk),			 // Templated
		 .wr_clk		(clk),			 // Templated
		 .mmu_en		(mmu_enable),		 // Templated
		 .mmu_bp		(etx_rr),		 // Templated
		 .mi_en			(mi_mmu_en),		 // Templated
		 .mi_we			(mi_we),
		 .mi_addr		(mi_addr[14:0]),
		 .mi_din		(mi_din[DW-1:0]),
		 .emesh_access_in	(etx_remap_access),	 // Templated
		 .emesh_packet_in	(etx_remap_packet[PW-1:0]), // Templated
		 .emesh_rd_wait		(etx_rd_wait),		 // Templated
		 .emesh_wr_wait		(etx_wr_wait));		 // Templated
   

   /************************************************************/
   /*ELINK PROTOCOL LOGIC                                      */
   /************************************************************/
   /*etx_protocol  AUTO_TEMPLATE (			       
                                  .etx_rd_wait     (etx_rd_wait),
                                  .etx_wr_wait     (etx_wr_wait),
                                  .etx_\(.*\)      (emmu_\1[]),
                                  .etx_wait	   (etx_wait),    
                             );
   */

   defparam etx_protocol.ID=ID;   
   etx_protocol etx_protocol (
			      /*AUTOINST*/
			      // Outputs
			      .etx_rd_wait	(etx_rd_wait),	 // Templated
			      .etx_wr_wait	(etx_wr_wait),	 // Templated
			      .tx_frame_par	(tx_frame_par[7:0]),
			      .tx_data_par	(tx_data_par[63:0]),
			      // Inputs
			      .reset		(reset),
			      .clk		(clk),
			      .etx_access	(emmu_access),	 // Templated
			      .etx_packet	(emmu_packet[PW-1:0]), // Templated
			      .tx_enable	(tx_enable),
			      .gpio_data	(gpio_data[8:0]),
			      .gpio_enable	(gpio_enable),
			      .tx_rd_wait	(tx_rd_wait),
			      .tx_wr_wait	(tx_wr_wait));
   
endmodule // elink
// Local Variables:
// verilog-library-directories:("." "../../emmu/hdl" "../../memory/hdl" "../../edma/hdl/")
// End:


/*
 Copyright (C) 2015 Adapteva, Inc.
 
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
