module dv_elink(/*AUTOARG*/
   // Outputs
   dut_passed, dut_failed, dut_rd_wait, dut_wr_wait, dut_access,
   dut_packet,
   // Inputs
   clk, reset, ext_access, ext_packet, ext_rd_wait, ext_wr_wait
   );

   parameter AW  = 32;
   parameter DW  = 32;
   parameter CW  = 2;             //number of clocks to send int
   parameter IDW = 12;
   parameter PW  = 104;
   
   
   //Basic
   input  [CW-1:0] clk;        // Core clock
   input           reset;      // Reset
   output          dut_passed; // Indicates passing test
   output          dut_failed; // Indicates failing test

   //Input Transaction
   input           ext_access;
   input [PW-1:0]  ext_packet; 
   output          dut_rd_wait;
   output          dut_wr_wait;

   //Output Transaction
   output          dut_access;
   output [PW-1:0] dut_packet; 
   input 	   ext_rd_wait;
   input 	   ext_wr_wait;

   
   /*AUTOINPUT*/
   /*AUTOOUTPUT*/
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [7:0]		data_n;			// From elink of elink.v
   wire [7:0]		data_p;			// From elink of elink.v
   wire			frame_n;		// From elink of elink.v
   wire			frame_p;		// From elink of elink.v
   wire			lclk_n;			// From elink of elink.v
   wire			lclk_p;			// From elink of elink.v
   wire			rd_wait_n;		// From elink of elink.v
   wire			rd_wait_p;		// From elink of elink.v
   wire			rxrd_wait;		// From emem of ememory.v
   wire			wr_wait_n;		// From elink of elink.v
   wire			wr_wait_p;		// From elink of elink.v
   // End of automatics

 
   wire [3:0] 		colid;
   wire [3:0] 		rowid;
   wire 		mailbox_full;
   wire 		mailbox_not_empty;
   wire 		cclk_p, cclk_n;
   wire 		chip_resetb;

   wire 		emem_access;
   wire [PW-1:0]	emem_packet;
   wire 		dut_access;
   wire [PW-1:0]	dut_packet;
   wire 		rxrr_access;
   wire [PW-1:0] 	rxrr_packet;
   wire 		rxwr_access;
   wire [PW-1:0] 	rxwr_packet;
   wire 		rxrd_access;
   wire [PW-1:0] 	rxrd_packet;

   wire 		txrr_access;
   wire [PW-1:0] 	txrr_packet;
   wire 		txwr_access;
   wire [PW-1:0] 	txwr_packet;
   wire 		txrd_access;
   wire [PW-1:0] 	txrd_packet;
   

   wire                 txrd_wait;
   wire                 txwr_wait;
   wire                 txrr_wait; 
   wire                 rxrr_wait;
   
   
   reg [31:0]    etime;  
   wire 	 itrace = 1'b1;
 
   
   //Clocks
   wire clkin         = clk[0]; //for pll-->cclk, rxclk, txclk

   //Splitting transaction into read/write path

   //Read path
   assign txrd_access         = ext_access & ~ext_packet[1];
   assign txrd_packet[PW-1:0] = ext_packet[PW-1:0];
        
   //Write path
   assign txwr_access         = ext_access & ext_packet[1];
   assign txwr_packet[PW-1:0] = ext_packet[PW-1:0];

   //TX Pushback
   assign dut_rd_wait         = txrd_wait;   
   assign dut_wr_wait         = txwr_wait;
      
   //Getting results back
   assign dut_access         = rxrr_access;
   assign dut_packet[PW-1:0] = rxrr_packet[PW-1:0];
   
   /*elink AUTO_TEMPLATE ( 
                        // Outputs
                        .txo_\(.*\)       (\1[]),
                        .rxi_\(.*\)       (\1[]),  
                        .rxo_\(.*\)       (\1[]),
                        .txi_\(.*\)       (\1[]),  
                        .\(.*\)_clk       (clk[1]),
                        );
   */

   defparam elink.ELINKID = 12'h800;

   elink elink (.hard_reset		(reset),
		.mailbox_not_empty	(mailbox_not_empty),
		.mailbox_full		(mailbox_full),
		.chip_resetb		(chip_resetb),
		.colid			(colid[3:0]),
		.rowid			(rowid[3:0]),
		.cclk_p			(cclk_p),
		.cclk_n			(cclk_n),
		.clkin			(clkin),
		.clkbypass              ({clkin,clkin,clkin}),
		.rxrd_access		(rxrd_access),//to emem
		.rxrd_packet		(rxrd_packet[PW-1:0]),
		.rxwr_access		(rxwr_access),//to emem
		.rxwr_packet		(rxwr_packet[PW-1:0]),
		.rxrr_access		(rxrr_access),//to ext
		.rxrr_packet		(rxrr_packet[PW-1:0]),
		.txrd_access		(txrd_access),//from ext
		.txrd_packet		(txrd_packet[PW-1:0]),
		.txwr_access		(txwr_access),//from ext
		.txwr_packet		(txwr_packet[PW-1:0]),
		.txrd_wait		(txrd_wait),
		.txrr_wait		(txrr_wait),
		.txwr_wait		(txwr_wait),
		.rxrr_wait		(rxrr_wait),
		.rxwr_wait		(rxwr_wait),
		/*AUTOINST*/
		// Outputs
		.rxo_wr_wait_p		(wr_wait_p),		 // Templated
		.rxo_wr_wait_n		(wr_wait_n),		 // Templated
		.rxo_rd_wait_p		(rd_wait_p),		 // Templated
		.rxo_rd_wait_n		(rd_wait_n),		 // Templated
		.txo_lclk_p		(lclk_p),		 // Templated
		.txo_lclk_n		(lclk_n),		 // Templated
		.txo_frame_p		(frame_p),		 // Templated
		.txo_frame_n		(frame_n),		 // Templated
		.txo_data_p		(data_p[7:0]),		 // Templated
		.txo_data_n		(data_n[7:0]),		 // Templated
		// Inputs
		.rxi_lclk_p		(lclk_p),		 // Templated
		.rxi_lclk_n		(lclk_n),		 // Templated
		.rxi_frame_p		(frame_p),		 // Templated
		.rxi_frame_n		(frame_n),		 // Templated
		.rxi_data_p		(data_p[7:0]),		 // Templated
		.rxi_data_n		(data_n[7:0]),		 // Templated
		.txi_wr_wait_p		(wr_wait_p),		 // Templated
		.txi_wr_wait_n		(wr_wait_n),		 // Templated
		.txi_rd_wait_p		(rd_wait_p),		 // Templated
		.txi_rd_wait_n		(rd_wait_n),		 // Templated
		.rxwr_clk		(clk[1]),		 // Templated
		.rxrd_clk		(clk[1]),		 // Templated
		.rxrd_wait		(rxrd_wait),
		.rxrr_clk		(clk[1]),		 // Templated
		.txwr_clk		(clk[1]),		 // Templated
		.txrd_clk		(clk[1]),		 // Templated
		.txrr_clk		(clk[1]),		 // Templated
		.txrr_access		(txrr_access),
		.txrr_packet		(txrr_packet[PW-1:0]));


   
   assign  emem_access           = rxwr_access | rxrd_access;
    
   assign  emem_packet[PW-1:0]   = rxwr_access ? rxwr_packet[PW-1:0]:
                                                 rxrd_packet[PW-1:0];
     
   /*ememory AUTO_TEMPLATE ( 
                        // Outputs
                        .\(.*\)_out       (txrr_\1[]),
                        .\(.*\)_in        (emem_\1[]),
                        .wait_out	  (rxrd_wait),
                         );
   */

   ememory emem (.wait_in	(1'b0),       //only one read at a time, set to zero for no1
		 .clk		(clk[1]),		 
		 /*AUTOINST*/
		 // Outputs
		 .wait_out		(rxrd_wait),		 // Templated
		 .access_out		(txrr_access),		 // Templated
		 .packet_out		(txrr_packet[PW-1:0]),	 // Templated
		 // Inputs
		 .reset			(reset),
		 .access_in		(emem_access),		 // Templated
		 .packet_in		(emem_packet[PW-1:0]));	 // Templated
   
   //Transaction Monitor
   
   always @ (posedge clkin or posedge reset)
     if(reset)
       etime[31:0] <= 32'b0;
     else
       etime[31:0] <= etime[31:0]+1'b1;

   

  /*emesh_monitor AUTO_TEMPLATE ( 
                        // Outputs
                        .emesh_\(.*\)     (@"(substring vl-cell-name  0 3)"_\1[]),
                        );
   */


   emesh_monitor #(.NAME("stimulus")) ext_monitor (.emesh_wait		((dut_rd_wait | dut_wr_wait)),//TODO:fix collisions
						   .clk			(clk[1]),
						   /*AUTOINST*/
						   // Inputs
						   .reset		(reset),
						   .itrace		(itrace),
						   .etime		(etime[31:0]),
						   .emesh_access	(ext_access),	 // Templated
						   .emesh_packet	(ext_packet[PW-1:0])); // Templated
   
   emesh_monitor #(.NAME("dut")) dut_monitor (.emesh_wait	(1'b0),
					      .clk		(clk[1]),
					      /*AUTOINST*/
					      // Inputs
					      .reset		(reset),
					      .itrace		(itrace),
					      .etime		(etime[31:0]),
					      .emesh_access	(dut_access),	 // Templated
					      .emesh_packet	(dut_packet[PW-1:0])); // Templated

endmodule // dv_elink
// Local Variables:
// verilog-library-directories:("." "../hdl" "../../memory/hdl")
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

