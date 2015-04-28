module erx (/*AUTOARG*/
   // Outputs
   rxo_wr_wait_p, rxo_wr_wait_n, rxo_rd_wait_p, rxo_rd_wait_n,
   rxwr_access, rxwr_packet, rxrd_access, rxrd_packet, rxrr_access,
   rxrr_packet, mi_dout, timeout,
   // Inputs
   reset, sys_clk, rxi_lclk_p, rxi_lclk_n, rxi_frame_p, rxi_frame_n,
   rxi_data_p, rxi_data_n, rxwr_wait, rxrd_wait, rxrr_wait, mi_en,
   mi_we, mi_addr, mi_din, etx_read
   );

   parameter AW      = 32;
   parameter DW      = 32;
   parameter PW      = 104;
   parameter ID      = 12'h800;
   
   //reset
   input           reset;
   input 	   sys_clk;
   
   //FROM IO Pins
   input 	  rxi_lclk_p,  rxi_lclk_n;     //link rx clock input
   input 	  rxi_frame_p,  rxi_frame_n;   //link rx frame signal
   input [7:0] 	  rxi_data_p,   rxi_data_n;    //link rx data
   output 	  rxo_wr_wait_p,rxo_wr_wait_n; //link rx write pushback output
   output 	  rxo_rd_wait_p,rxo_rd_wait_n; //link rx read pushback output

   //Master write
   output 	   rxwr_access;		
   output [PW-1:0] rxwr_packet;
   input 	   rxwr_wait;

   //Master read request
   output 	   rxrd_access;		
   output [PW-1:0] rxrd_packet;
   input 	   rxrd_wait;

   //Slave read response
   output 	   rxrr_access;		
   output [PW-1:0] rxrr_packet;
   input 	   rxrr_wait;
  
   //Register Access Interface
   input 	   mi_en; 
   input 	   mi_we;
   input [19:0]    mi_addr;
   input [31:0]    mi_din;
   output [31:0]   mi_dout;

   //Starts timeout counter
   input 	   etx_read;
  
   //Readback timeout
   output 	   timeout;
   
   
   /*AUTOOUTPUT*/
   /*AUTOINPUT*/

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			edma_access;		// From edma of edma.v
   wire			edma_wait;		// From erx_disty of erx_disty.v
   wire			emesh_remap_access;	// From erx_remap of erx_remap.v
   wire [PW-1:0]	emesh_remap_packet;	// From erx_remap of erx_remap.v
   wire			emmu_access;		// From emmu of emmu.v
   wire [PW-1:0]	emmu_packet;		// From emmu of emmu.v
   wire			erx_access;		// From erx_protocol of erx_protocol.v
   wire [PW-1:0]	erx_packet;		// From erx_protocol of erx_protocol.v
   wire			erx_rr;			// From erx_protocol of erx_protocol.v
   wire			erx_wait;		// From erx_disty of erx_disty.v
   wire [8:0]		gpio_datain;		// From erx_io of erx_io.v
   wire [DW-1:0]	mi_rx_cfg_dout;		// From ecfg_rx of ecfg_rx.v
   wire [DW-1:0]	mi_rx_edma_dout;	// From edma of edma.v
   wire [DW-1:0]	mi_rx_emmu_dout;	// From emmu of emmu.v
   wire			mmu_enable;		// From ecfg_rx of ecfg_rx.v
   wire [31:0]		remap_base;		// From ecfg_rx of ecfg_rx.v
   wire [1:0]		remap_mode;		// From ecfg_rx of ecfg_rx.v
   wire [11:0]		remap_pattern;		// From ecfg_rx of ecfg_rx.v
   wire [11:0]		remap_sel;		// From ecfg_rx of ecfg_rx.v
   wire [63:0]		rx_data_par;		// From erx_io of erx_io.v
   wire			rx_enable;		// From ecfg_rx of ecfg_rx.v
   wire [7:0]		rx_frame_par;		// From erx_io of erx_io.v
   wire			rx_lclk_div4;		// From erx_io of erx_io.v
   wire			rx_rd_wait;		// From erx_disty of erx_disty.v
   wire			rx_wr_wait;		// From erx_disty of erx_disty.v
   wire			rxrd_fifo_access;	// From erx_disty of erx_disty.v
   wire [PW-1:0]	rxrd_fifo_packet;	// From erx_disty of erx_disty.v
   wire			rxrd_fifo_wait;		// From rxrd_fifo of fifo_async.v
   wire			rxrr_fifo_access;	// From erx_disty of erx_disty.v
   wire [PW-1:0]	rxrr_fifo_packet;	// From erx_disty of erx_disty.v
   wire			rxrr_fifo_wait;		// From rxrr_fifo of fifo_async.v
   wire			rxwr_fifo_access;	// From erx_disty of erx_disty.v
   wire [PW-1:0]	rxwr_fifo_packet;	// From erx_disty of erx_disty.v
   wire			rxwr_fifo_wait;		// From rxwr_fifo of fifo_async.v
   wire [1:0]		timer_cfg;		// From ecfg_rx of ecfg_rx.v
   // End of automatics

   //regs
   reg [15:0] 	debug_vector;
   wire 	rxwr_fifo_full;
   wire 	rxrr_fifo_full;
   wire 	rxrd_fifo_full;
   wire 	rxrd_empty;
   wire 	rxwr_empty;
   wire 	rxrr_empty;
   wire [103:0] edma_packet;		// From edma of edma.v, ...


   /************************************************************/
   /* ERX CONFIGURATION                                        */
   /************************************************************/
   defparam ecfg_rx.GROUP=`EGROUP_RX;

   /*ecfg_rx AUTO_TEMPLATE (.mi_dout       (mi_rx_cfg_dout[DW-1:0]),
    );
        */
   
   ecfg_rx ecfg_rx (.debug_vector	(debug_vector[15:0]),
		     /*AUTOINST*/
		    // Outputs
		    .mi_dout		(mi_rx_cfg_dout[DW-1:0]), // Templated
		    .rx_enable		(rx_enable),
		    .mmu_enable		(mmu_enable),
		    .remap_mode		(remap_mode[1:0]),
		    .remap_base		(remap_base[31:0]),
		    .remap_pattern	(remap_pattern[11:0]),
		    .remap_sel		(remap_sel[11:0]),
		    .timer_cfg		(timer_cfg[1:0]),
		    // Inputs
		    .reset		(reset),
		    .sys_clk		(sys_clk),
		    .mi_en		(mi_en),
		    .mi_we		(mi_we),
		    .mi_addr		(mi_addr[19:0]),
		    .mi_din		(mi_din[31:0]),
		    .gpio_datain	(gpio_datain[8:0]));
    
   /************************************************************/
   /* ERX READBACK MUX                                         */
   /************************************************************/
   defparam ecfg_rx.GROUP=`EGROUP_RX;

   erx_mux erx_mux (/*AUTOINST*/
		    // Outputs
		    .mi_dout		(mi_dout[DW-1:0]),
		    // Inputs
		    .sys_clk		(sys_clk),
		    .mi_en		(mi_en),
		    .mi_addr		(mi_addr[19:0]),
		    .mi_rx_cfg_dout	(mi_rx_cfg_dout[DW-1:0]),
		    .mi_rx_edma_dout	(mi_rx_edma_dout[DW-1:0]),
		    .mi_rx_emmu_dout	(mi_rx_emmu_dout[DW-1:0]));
   
   
   /************************************************************/
   /* READ REQUEST TIMEOUT CIRCUIT                             */
   /************************************************************/
   /*erx_timer AUTO_TEMPLATE (.clk         (rx_lclk_div4),
                              .stop_count  (rxrr_fifo_access),
			      .start_count (etx_read),
                              .erx_timeout (timeout),
            
    );
    */
   erx_timer erx_timer(/*AUTOINST*/
		       // Outputs
		       .timeout		(timeout),
		       // Inputs
		       .clk		(rx_lclk_div4),		 // Templated
		       .reset		(reset),
		       .timer_cfg	(timer_cfg[1:0]),
		       .stop_count	(rxrr_fifo_access),	 // Templated
		       .start_count	(etx_read));		 // Templated
   
   /************************************************************/
   /*FIFOs                                                     */
   /*(for AXI 1. read request, 2. write, and 3. read response) */
   /************************************************************/

   /*fifo_async   AUTO_TEMPLATE ( 
 			       // Outputs
			       
			       .dout       (@"(substring vl-cell-name  0 4)"_packet[PW-1:0]),
			       .empty	   (@"(substring vl-cell-name  0 4)"_empty),
			       .full	   (@"(substring vl-cell-name  0 4)"_fifo_full),
			       .prog_full  (@"(substring vl-cell-name  0 4)"_fifo_wait),
    			       .valid      (@"(substring vl-cell-name  0 4)"_access),
			       // Inputs
			       .rd_clk	   (sys_clk),
                               .wr_clk	   (rx_lclk_div4),
                               .wr_en      (@"(substring vl-cell-name  0 4)"_fifo_access),
                               .rd_en      (~@"(substring vl-cell-name  0 4)"_wait & ~@"(substring vl-cell-name  0 4)"_empty),
			       .reset	   (reset),
                               .din	   (@"(substring vl-cell-name  0 4)"_fifo_packet[PW-1:0]),
    );
   */
   
  

 
      
   //Read request fifo (from Epiphany)
   fifo_async #(.DW(104), .AW(5)) 
   rxrd_fifo   (.full			(rxrd_fifo_full),
		.empty			(rxrd_empty),
		/*AUTOINST*/
		// Outputs
		.prog_full		(rxrd_fifo_wait),	 // Templated
		.dout			(rxrd_packet[PW-1:0]),	 // Templated
		.valid			(rxrd_access),		 // Templated
		// Inputs
		.reset			(reset),		 // Templated
		.wr_clk			(rx_lclk_div4),		 // Templated
		.rd_clk			(sys_clk),		 // Templated
		.wr_en			(rxrd_fifo_access),	 // Templated
		.din			(rxrd_fifo_packet[PW-1:0]), // Templated
		.rd_en			(~rxrd_wait & ~rxrd_empty)); // Templated

 

   //Write fifo (from Epiphany)
   fifo_async #(.DW(104), .AW(5)) 
   rxwr_fifo(.full			(rxwr_fifo_full),
	     .empty			(rxwr_empty),
	     /*AUTOINST*/
	     // Outputs
	     .prog_full			(rxwr_fifo_wait),	 // Templated
	     .dout			(rxwr_packet[PW-1:0]),	 // Templated
	     .valid			(rxwr_access),		 // Templated
	     // Inputs
	     .reset			(reset),		 // Templated
	     .wr_clk			(rx_lclk_div4),		 // Templated
	     .rd_clk			(sys_clk),		 // Templated
	     .wr_en			(rxwr_fifo_access),	 // Templated
	     .din			(rxwr_fifo_packet[PW-1:0]), // Templated
	     .rd_en			(~rxwr_wait & ~rxwr_empty)); // Templated
   
 

   //Read response fifo (for host)
   fifo_async #(.DW(104), .AW(5))  
   rxrr_fifo(.full			(rxrr_fifo_full),
	     .empty			(rxrr_empty),
	     /*AUTOINST*/
	     // Outputs
	     .prog_full			(rxrr_fifo_wait),	 // Templated
	     .dout			(rxrr_packet[PW-1:0]),	 // Templated
	     .valid			(rxrr_access),		 // Templated
	     // Inputs
	     .reset			(reset),		 // Templated
	     .wr_clk			(rx_lclk_div4),		 // Templated
	     .rd_clk			(sys_clk),		 // Templated
	     .wr_en			(rxrr_fifo_access),	 // Templated
	     .din			(rxrr_fifo_packet[PW-1:0]), // Templated
	     .rd_en			(~rxrr_wait & ~rxrr_empty)); // Templated
      
  
   /************************************************************/
   /*ELINK RECEIVE DISTRIBUTOR ("DEMUX")                       */
   /*(figures out who RX transaction belongs to)               */
   /********************1***************************************/
   /*erx_disty AUTO_TEMPLATE ( 
                        //Inputs
                        .mmu_en		(ecfg_rx_mmu_enable),
                        .clk		(rx_lclk_div4),
    )
    */

   defparam erx_disty.ID    = ID;

   erx_disty erx_disty (
			/*AUTOINST*/
			// Outputs
			.erx_wait	(erx_wait),
			.rx_rd_wait	(rx_rd_wait),
			.rx_wr_wait	(rx_wr_wait),
			.edma_wait	(edma_wait),
			.rxwr_fifo_access(rxwr_fifo_access),
			.rxwr_fifo_packet(rxwr_fifo_packet[PW-1:0]),
			.rxrd_fifo_access(rxrd_fifo_access),
			.rxrd_fifo_packet(rxrd_fifo_packet[PW-1:0]),
			.rxrr_fifo_access(rxrr_fifo_access),
			.rxrr_fifo_packet(rxrr_fifo_packet[PW-1:0]),
			// Inputs
			.erx_access	(erx_access),
			.erx_packet	(erx_packet[PW-1:0]),
			.emmu_access	(emmu_access),
			.emmu_packet	(emmu_packet[PW-1:0]),
			.edma_access	(edma_access),
			.edma_packet	(edma_packet[PW-1:0]),
			.rxwr_fifo_wait	(rxwr_fifo_wait),
			.rxrd_fifo_wait	(rxrd_fifo_wait),
			.rxrr_fifo_wait	(rxrr_fifo_wait),
			.timeout	(timeout));


   /************************************************************/
   /*ELINK DMA                                                 */
   /************************************************************/
   
   /*edma AUTO_TEMPLATE (.clk		(rx_lclk_div4),
                         .edma_access	(edma_access),   
                         .mi_dout       (mi_rx_edma_dout[DW-1:0]),
                         .edma_access	(edma_access),
                         .edma_write	(edma_packet[1]),
	                 .edma_datamode	(edma_packet[3:2]),
	                 .edma_ctrlmode	(edma_packet[7:4]),
	                 .edma_dstaddr	(edma_packet[39:8]),
	                 .edma_data	(edma_packet[71:40]),
	                 .edma_srcaddr	(edma_packet[103:72]),
                               );
   */
   assign edma_packet[0]=edma_access;   
   edma edma(/*AUTOINST*/
	     // Outputs
	     .mi_dout			(mi_rx_edma_dout[DW-1:0]), // Templated
	     .edma_access		(edma_access),		 // Templated
	     .edma_write		(edma_packet[1]),	 // Templated
	     .edma_datamode		(edma_packet[3:2]),	 // Templated
	     .edma_ctrlmode		(edma_packet[7:4]),	 // Templated
	     .edma_dstaddr		(edma_packet[39:8]),	 // Templated
	     .edma_data			(edma_packet[71:40]),	 // Templated
	     .edma_srcaddr		(edma_packet[103:72]),	 // Templated
	     // Inputs
	     .reset			(reset),
	     .clk			(rx_lclk_div4),		 // Templated
	     .mi_en			(mi_en),
	     .mi_we			(mi_we),
	     .mi_addr			(mi_addr[19:0]),
	     .mi_din			(mi_din[31:0]),
	     .edma_wait			(edma_wait));
   
           
   /************************************************************/
   /*ELINK MEMORY MANAGEMENT UNIT                              */
   /************************************************************/
   /*emmu AUTO_TEMPLATE ( 
                        .emesh_\(.*\)_out	(emmu_\1[]),   
                         //Inputs
                        .emesh_\(.*\)_in	(emesh_remap_\1[]),   
                        .mmu_en			(mmu_enable),
                        .clk			(rx_lclk_div4),
                        .mi_dout   	        (mi_rx_emmu_dout[DW-1:0]),
                        .emesh_packet_hi_out	(),
                        .mmu_bp	    	        (erx_rr),
                        .emesh_wait_in		(erx_wait),	 
                           );
   */

   defparam emmu.GROUP=`EGROUP_RX;
   emmu emmu (.emesh_clk		(emesh_clk),
	      /*AUTOINST*/
	      // Outputs
	      .mi_dout			(mi_rx_emmu_dout[DW-1:0]), // Templated
	      .emesh_access_out		(emmu_access),		 // Templated
	      .emesh_packet_out		(emmu_packet[PW-1:0]),	 // Templated
	      .emesh_packet_hi_out	(),			 // Templated
	      // Inputs
	      .reset			(reset),
	      .sys_clk			(sys_clk),
	      .mmu_en			(mmu_enable),		 // Templated
	      .mmu_bp			(erx_rr),		 // Templated
	      .mi_en			(mi_en),
	      .mi_we			(mi_we),
	      .mi_addr			(mi_addr[19:0]),
	      .mi_din			(mi_din[DW-1:0]),
	      .emesh_access_in		(emesh_remap_access),	 // Templated
	      .emesh_packet_in		(emesh_remap_packet[PW-1:0]), // Templated
	      .emesh_wait_in		(erx_wait));		 // Templated
   
   /**************************************************************/
   /*ADDRESS REMPAPPING                                          */
   /**************************************************************/
   //TODO: clean up signaling

   /*erx_remap AUTO_TEMPLATE ( 
                        .emesh_\(.*\)_out	(emesh_remap_\1[]),   
                         //Inputs
                        .emesh_\(.*\)_in	(erx_\1[]),   
                        .mmu_en			(ecfg_rx_mmu_enable),
                        .clk			(rx_lclk_div4),
                        .mi_dout   	        (mi_rx_emmu_dout[DW-1:0]),
                        .emesh_packet_hi_out	(),
                        .remap_bypass  	        (erx_rr),	 
                           );
   */

   defparam erx_remap.ID = ID;
   erx_remap erx_remap (/*AUTOINST*/
			// Outputs
			.emesh_access_out(emesh_remap_access),	 // Templated
			.emesh_packet_out(emesh_remap_packet[PW-1:0]), // Templated
			// Inputs
			.clk		(rx_lclk_div4),		 // Templated
			.reset		(reset),
			.emesh_access_in(erx_access),		 // Templated
			.emesh_packet_in(erx_packet[PW-1:0]),	 // Templated
			.remap_mode	(remap_mode[1:0]),
			.remap_sel	(remap_sel[11:0]),
			.remap_pattern	(remap_pattern[11:0]),
			.remap_base	(remap_base[31:0]),
			.remap_bypass	(erx_rr),		 // Templated
			.emesh_wait_in	(erx_wait));		 // Templated
   
   /**************************************************************/
   /*ELINK PROTOCOL LOGIC                                        */
   /**************************************************************/

   defparam erx_protocol.ID=ID;     
   erx_protocol erx_protocol (/*AUTOINST*/
			      // Outputs
			      .erx_access	(erx_access),
			      .erx_packet	(erx_packet[PW-1:0]),
			      .erx_rr		(erx_rr),
			      // Inputs
			      .reset		(reset),
			      .rx_enable	(rx_enable),
			      .rx_lclk_div4	(rx_lclk_div4),
			      .rx_frame_par	(rx_frame_par[7:0]),
			      .rx_data_par	(rx_data_par[63:0]));

   
   /***********************************************************/
   /*ELINK TRANSMIT I/O LOGIC                                 */
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
		  .gpio_datain		(gpio_datain[8:0]),
		  // Inputs
		  .reset		(reset),
		  .rxi_lclk_p		(rxi_lclk_p),
		  .rxi_lclk_n		(rxi_lclk_n),
		  .rxi_frame_p		(rxi_frame_p),
		  .rxi_frame_n		(rxi_frame_n),
		  .rxi_data_p		(rxi_data_p[7:0]),
		  .rxi_data_n		(rxi_data_n[7:0]),
		  .rx_wr_wait		(rx_wr_wait),
		  .rx_rd_wait		(rx_rd_wait));

   /************************************************************/
   /*Debug signals                                             */
   /************************************************************/
   always @ (posedge sys_clk)
     begin
	debug_vector[15:0] <= {2'b0,                     //15:14
				rx_rd_wait,               //13
				rx_wr_wait,               //12
				rxrr_wait,                //11
				rxrr_fifo_wait,           //10
				rxrr_fifo_access,         //9			
				rxrd_wait,                //8
				rxrd_fifo_wait,           //7
				rxrd_fifo_access,         //6		 
				rxwr_wait,                //5
				rxwr_fifo_wait,           //4
				rxwr_fifo_access,         //3
				rxrr_fifo_full,           //2
				rxrd_fifo_full,           //1
				rxwr_fifo_full	          //0	
				};
     end

   
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

