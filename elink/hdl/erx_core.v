module erx_core (/*AUTOARG*/
   // Outputs
   rx_rd_wait, rx_wr_wait, rxrd_access, rxrd_packet, rxrr_access,
   rxrr_packet, rxwr_access, rxwr_packet, erx_cfg_wait, mailbox_full,
   mailbox_not_empty,
   // Inputs
   reset, clk, rx_data_par, rx_frame_par, rxrd_wait, rxrr_wait,
   rxwr_wait, erx_cfg_access, erx_cfg_packet
   );

   parameter AW      = 32;
   parameter DW      = 32;
   parameter PW      = 104;
   parameter RFAW    = 6;
   parameter ID      = 12'h800;


   //clock and reset
   input		reset;
   input		clk;

   //IO Interface
   input [63:0] 	rx_data_par;
   input [7:0]		rx_frame_par;
   output 		rx_rd_wait;
   output 		rx_wr_wait;
   
   //FIFO Access
   output		rxrd_access;
   output [PW-1:0]	rxrd_packet;
   input		rxrd_wait;
   
   output		rxrr_access;
   output [PW-1:0]	rxrr_packet;
   input		rxrr_wait;
   
   output		rxwr_access;
   output [PW-1:0]	rxwr_packet;
   input		rxwr_wait;

   //register interface
   input		erx_cfg_access;
   input [PW-1:0]	erx_cfg_packet;
   output 		erx_cfg_wait;

   //mailbox outputs
   output		mailbox_full;           //need to sync to sys_clk
   output		mailbox_not_empty;      //need to sync to sys_clk

   
   /*AUTOINPUT*/
   /*AUTOOUTPUT*/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			ecfg_access;		// From erx_cfgif of ecfg_if.v
   wire [PW-1:0]	ecfg_packet;		// From erx_cfgif of ecfg_if.v
   wire			edma_access;		// From erx_dma of edma.v
   wire			edma_wait;		// From erx_arbiter of erx_arbiter.v
   wire			emesh_remap_access;	// From erx_remap of erx_remap.v
   wire [PW-1:0]	emesh_remap_packet;	// From erx_remap of erx_remap.v
   wire			emmu_access;		// From erx_mmu of emmu.v
   wire [PW-1:0]	emmu_packet;		// From erx_mmu of emmu.v
   wire			erx_access;		// From erx_protocol of erx_protocol.v
   wire [PW-1:0]	erx_packet;		// From erx_protocol of erx_protocol.v
   wire [14:0]		mi_addr;		// From erx_cfgif of ecfg_if.v
   wire [DW-1:0]	mi_cfg_dout;		// From erx_cfg of erx_cfg.v
   wire			mi_cfg_en;		// From erx_cfgif of ecfg_if.v
   wire [63:0]		mi_din;			// From erx_cfgif of ecfg_if.v
   wire [DW-1:0]	mi_dma_dout;		// From erx_dma of edma.v
   wire			mi_dma_en;		// From erx_cfgif of ecfg_if.v
   wire [63:0]		mi_mailbox_dout;	// From erx_mailbox of emailbox.v
   wire [DW-1:0]	mi_mmu_dout;		// From erx_mmu of emmu.v
   wire			mi_mmu_en;		// From erx_cfgif of ecfg_if.v
   wire			mi_we;			// From erx_cfgif of ecfg_if.v
   wire			mmu_enable;		// From erx_cfg of erx_cfg.v
   wire [31:0]		remap_base;		// From erx_cfg of erx_cfg.v
   wire			remap_bypass;		// From erx_protocol of erx_protocol.v
   wire [1:0]		remap_mode;		// From erx_cfg of erx_cfg.v
   wire [11:0]		remap_pattern;		// From erx_cfg of erx_cfg.v
   wire [11:0]		remap_sel;		// From erx_cfg of erx_cfg.v
   wire			rx_enable;		// From erx_cfg of erx_cfg.v
   // End of automatics

     
   //regs
    wire [8:0] 	gpio_datain;		// To erx_cfg of erx_cfg.v
   wire [15:0] 	rx_status;
   wire 	rxwr_full;
   wire 	rxrr_full;
   wire 	rxrd_full;
   wire 	rxrd_empty;
   wire 	rxwr_empty;
   wire 	rxrr_empty;
   wire [103:0] edma_packet;		// From edma of edma.v, ...
   

   /**************************************************************/
   /*ELINK PROTOCOL LOGIC                                        */
   /**************************************************************/

   defparam erx_protocol.ID=ID;     
   erx_protocol erx_protocol (/*AUTOINST*/
			      // Outputs
			      .erx_access	(erx_access),
			      .erx_packet	(erx_packet[PW-1:0]),
			      .remap_bypass	(remap_bypass),
			      // Inputs
			      .reset		(reset),
			      .rx_enable	(rx_enable),
			      .clk		(clk),
			      .rx_frame_par	(rx_frame_par[7:0]),
			      .rx_data_par	(rx_data_par[63:0]));



   /**************************************************************/
   /*ADDRESS REMPAPPING                                          */
   /**************************************************************/

   /*erx_remap AUTO_TEMPLATE ( 
                        .emesh_\(.*\)_out	(emesh_remap_\1[]),   
                         //Inputs
                        .emesh_\(.*\)_in	(erx_\1[]),   
                        .mmu_en			(ecfg_rx_mmu_enable),
                        .emesh_packet_hi_out	(),
                           );
   */

   defparam erx_remap.ID = ID;
   erx_remap erx_remap (/*AUTOINST*/
			// Outputs
			.emesh_access_out(emesh_remap_access),	 // Templated
			.emesh_packet_out(emesh_remap_packet[PW-1:0]), // Templated
			// Inputs
			.clk		(clk),
			.reset		(reset),
			.emesh_access_in(erx_access),		 // Templated
			.emesh_packet_in(erx_packet[PW-1:0]),	 // Templated
			.remap_mode	(remap_mode[1:0]),
			.remap_sel	(remap_sel[11:0]),
			.remap_pattern	(remap_pattern[11:0]),
			.remap_base	(remap_base[31:0]),
			.remap_bypass	(remap_bypass),
			.rx_rd_wait	(rx_rd_wait),
			.rx_wr_wait	(rx_wr_wait));
   
 
   
   /************************************************************/
   /*ELINK MEMORY MANAGEMENT UNIT                              */
   /************************************************************/
   /*emmu AUTO_TEMPLATE ( 
                        .emesh_\(.*\)_out	(emmu_\1[]),   
                         //Inputs
                        .emesh_\(.*\)_in	(emesh_remap_\1[]),   
                        .mmu_en			(mmu_enable),
                        .rd_clk	        	(clk),
                        .wr_clk	        	(clk),
                        .mi_dout   	        (mi_mmu_dout[DW-1:0]),
                        .emesh_packet_hi_out	(),
                        .mmu_bp	    	        (remap_bypass),
                        .mi_en	                (mi_mmu_en),
                        .emesh_rd_wait		(rx_rd_wait),
		        .emesh_wr_wait		(rx_wr_wait),	 
                           );
   */

   emmu erx_mmu (
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
		 .mmu_bp		(remap_bypass),		 // Templated
		 .mi_en			(mi_mmu_en),		 // Templated
		 .mi_we			(mi_we),
		 .mi_addr		(mi_addr[14:0]),
		 .mi_din		(mi_din[DW-1:0]),
		 .emesh_access_in	(emesh_remap_access),	 // Templated
		 .emesh_packet_in	(emesh_remap_packet[PW-1:0]), // Templated
		 .emesh_rd_wait		(rx_rd_wait),		 // Templated
		 .emesh_wr_wait		(rx_wr_wait));		 // Templated
   

   /************************************************************/
   /*EMAILBOX                                                  */
   /************************************************************/
   /*emailbox AUTO_TEMPLATE ( 
    .mi_en              (mi_cfg_en),
    .mi_dout            (mi_mailbox_dout[]),
    .wr_clk		(clk),
    .rd_clk		(clk),
    .emesh_access	(emmu_access),
    .emesh_packet	(emmu_packet[PW-1:0]),
    );
        */

   defparam  erx_mailbox.ID=ID;   
   emailbox erx_mailbox(
			/*AUTOINST*/
			// Outputs
			.mi_dout	(mi_mailbox_dout[63:0]), // Templated
			.mailbox_full	(mailbox_full),
			.mailbox_not_empty(mailbox_not_empty),
			// Inputs
			.reset		(reset),
			.wr_clk		(clk),			 // Templated
			.rd_clk		(clk),			 // Templated
			.emesh_access	(emmu_access),		 // Templated
			.emesh_packet	(emmu_packet[PW-1:0]),	 // Templated
			.mi_en		(mi_cfg_en),		 // Templated
			.mi_we		(mi_we),
			.mi_addr	(mi_addr[RFAW+1:0]),
			.mi_din		(mi_din[63:0]));
   
   
   /************************************************************/
   /* CONFIGURATION INTERFACE                                  */
   /************************************************************/
   /*ecfg_if AUTO_TEMPLATE ( 
    .wait_in		(erx_cfg_wait),
    .\(.*\)_in          (erx_cfg_\1[]),
    .\(.*\)_out         (ecfg_\1[]),
    .mi_dout0		({32'b0,mi_cfg_dout[31:0]}),
    .mi_dout1		({32'b0,mi_dma_dout[31:0]}),
    .mi_dout2		({32'b0,mi_mmu_dout[31:0]}),
    .mi_dout3		(mi_mailbox_dout[63:0]),
    );
    */
   
   defparam erx_cfgif.RX=1;
   ecfg_if erx_cfgif (/*AUTOINST*/
		      // Outputs
		      .mi_mmu_en	(mi_mmu_en),
		      .mi_dma_en	(mi_dma_en),
		      .mi_cfg_en	(mi_cfg_en),
		      .mi_we		(mi_we),
		      .mi_addr		(mi_addr[14:0]),
		      .mi_din		(mi_din[63:0]),
		      .access_out	(ecfg_access),		 // Templated
		      .packet_out	(ecfg_packet[PW-1:0]),	 // Templated
		      // Inputs
		      .clk		(clk),
		      .reset		(reset),
		      .access_in	(erx_cfg_access),	 // Templated
		      .packet_in	(erx_cfg_packet[PW-1:0]), // Templated
		      .mi_dout0		({32'b0,mi_cfg_dout[31:0]}), // Templated
		      .mi_dout1		({32'b0,mi_dma_dout[31:0]}), // Templated
		      .mi_dout2		({32'b0,mi_mmu_dout[31:0]}), // Templated
		      .mi_dout3		(mi_mailbox_dout[63:0]), // Templated
		      .wait_in		(erx_cfg_wait));		 // Templated
   
   
   /************************************************************/
   /* ERX CONFIGURATION                                        */
   /************************************************************/
   /*erx_cfg AUTO_TEMPLATE (.mi_dout       (mi_cfg_dout[DW-1:0]),
                            .mi_en	   (mi_cfg_en),
    );
        */   
   
   assign rx_status[15:0] = {16'b0};
  
   assign gpio_datain[8:0]= {rx_frame_par[0],
			     rx_data_par[7],
			     rx_data_par[6],
			     rx_data_par[5],
			     rx_data_par[4],
			     rx_data_par[3],
			     rx_data_par[2],
			     rx_data_par[1],
			     rx_data_par[0]
			     };

   
   erx_cfg erx_cfg (.rx_status    	(rx_status[15:0]),
		    .timer_cfg		(),
		     /*AUTOINST*/
		    // Outputs
		    .mi_dout		(mi_cfg_dout[DW-1:0]),	 // Templated
		    .rx_enable		(rx_enable),
		    .mmu_enable		(mmu_enable),
		    .remap_mode		(remap_mode[1:0]),
		    .remap_base		(remap_base[31:0]),
		    .remap_pattern	(remap_pattern[11:0]),
		    .remap_sel		(remap_sel[11:0]),
		    // Inputs
		    .reset		(reset),
		    .clk		(clk),
		    .mi_en		(mi_cfg_en),		 // Templated
		    .mi_we		(mi_we),
		    .mi_addr		(mi_addr[14:0]),
		    .mi_din		(mi_din[31:0]),
		    .gpio_datain	(gpio_datain[8:0]));
    
   
   
  
   
 
   
   
   /************************************************************/
   /*ELINK DMA                                                 */
   /************************************************************/
   
   /*edma AUTO_TEMPLATE (
                         .mi_en		(mi_dma_en),
                         .edma_access	(edma_access),   
                         .mi_dout       (mi_dma_dout[DW-1:0]),
                             
                               );
   */   
   edma erx_dma(/*AUTOINST*/
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
		.mi_din			(mi_din[63:0]),
		.edma_wait		(edma_wait));
   
           

				 
   /************************************************************/
   /*ELINK RECEIVE DISTRIBUTOR ("DEMUX")                       */
   /*(figures out who RX transaction belongs to)               */
   /********************1***************************************/
   /*erx_arbiter AUTO_TEMPLATE ( 
                        //Inputs
                        .mmu_en		(ecfg_rx_mmu_enable),
                        .ecfg_wait	(erx_cfg_wait),
    )
    */

   defparam erx_arbiter.ID    = ID;
   erx_arbiter erx_arbiter (.timeout	(1'b0),//TODO
			/*AUTOINST*/
			    // Outputs
			    .rx_rd_wait		(rx_rd_wait),
			    .rx_wr_wait		(rx_wr_wait),
			    .edma_wait		(edma_wait),
			    .ecfg_wait		(erx_cfg_wait),	 // Templated
			    .rxwr_access	(rxwr_access),
			    .rxwr_packet	(rxwr_packet[PW-1:0]),
			    .rxrd_access	(rxrd_access),
			    .rxrd_packet	(rxrd_packet[PW-1:0]),
			    .rxrr_access	(rxrr_access),
			    .rxrr_packet	(rxrr_packet[PW-1:0]),
			    // Inputs
			    .erx_access		(erx_access),
			    .erx_packet		(erx_packet[PW-1:0]),
			    .emmu_access	(emmu_access),
			    .emmu_packet	(emmu_packet[PW-1:0]),
			    .edma_access	(edma_access),
			    .edma_packet	(edma_packet[PW-1:0]),
			    .ecfg_access	(ecfg_access),
			    .ecfg_packet	(ecfg_packet[PW-1:0]),
			    .rxwr_wait		(rxwr_wait),
			    .rxrd_wait		(rxrd_wait),
			    .rxrr_wait		(rxrr_wait));

   
endmodule // erx
// Local Variables:
// verilog-library-directories:("." "../../emmu/hdl" "../../edma/hdl" "../../memory/hdl" "../../emailbox/hdl")
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

