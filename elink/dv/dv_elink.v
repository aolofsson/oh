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

   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			elink0_cclk_n;		// From elink0 of elink.v
   wire			elink0_cclk_p;		// From elink0 of elink.v
   wire			elink0_chip_resetb;	// From elink0 of elink.v
   wire [3:0]		elink0_colid;		// From elink0 of elink.v
   wire			elink0_mailbox_full;	// From elink0 of elink.v
   wire			elink0_mailbox_not_empty;// From elink0 of elink.v
   wire [3:0]		elink0_rowid;		// From elink0 of elink.v
   wire			elink0_rxo_rd_wait_n;	// From elink0 of elink.v
   wire			elink0_rxo_rd_wait_p;	// From elink0 of elink.v
   wire			elink0_rxo_wr_wait_n;	// From elink0 of elink.v
   wire			elink0_rxo_wr_wait_p;	// From elink0 of elink.v
   wire			elink0_rxrd_access;	// From elink0 of elink.v
   wire [PW-1:0]	elink0_rxrd_packet;	// From elink0 of elink.v
   wire			elink0_rxrr_access;	// From elink0 of elink.v
   wire [PW-1:0]	elink0_rxrr_packet;	// From elink0 of elink.v
   wire			elink0_rxwr_access;	// From elink0 of elink.v
   wire [PW-1:0]	elink0_rxwr_packet;	// From elink0 of elink.v
   wire			elink0_timeout;		// From elink0 of elink.v
   wire [7:0]		elink0_txo_data_n;	// From elink0 of elink.v
   wire [7:0]		elink0_txo_data_p;	// From elink0 of elink.v
   wire			elink0_txo_frame_n;	// From elink0 of elink.v
   wire			elink0_txo_frame_p;	// From elink0 of elink.v
   wire			elink0_txo_lclk_n;	// From elink0 of elink.v
   wire			elink0_txo_lclk_p;	// From elink0 of elink.v
   wire			elink0_txrd_wait;	// From elink0 of elink.v
   wire			elink0_txrr_wait;	// From elink0 of elink.v
   wire			elink0_txwr_wait;	// From elink0 of elink.v
   wire			elink1_cclk_n;		// From elink1 of elink.v
   wire			elink1_cclk_p;		// From elink1 of elink.v
   wire			elink1_chip_resetb;	// From elink1 of elink.v
   wire [3:0]		elink1_colid;		// From elink1 of elink.v
   wire			elink1_mailbox_full;	// From elink1 of elink.v
   wire			elink1_mailbox_not_empty;// From elink1 of elink.v
   wire [3:0]		elink1_rowid;		// From elink1 of elink.v
   wire			elink1_rxo_rd_wait_n;	// From elink1 of elink.v
   wire			elink1_rxo_rd_wait_p;	// From elink1 of elink.v
   wire			elink1_rxo_wr_wait_n;	// From elink1 of elink.v
   wire			elink1_rxo_wr_wait_p;	// From elink1 of elink.v
   wire			elink1_rxrd_access;	// From elink1 of elink.v
   wire [PW-1:0]	elink1_rxrd_packet;	// From elink1 of elink.v
   wire			elink1_rxrr_access;	// From elink1 of elink.v
   wire [PW-1:0]	elink1_rxrr_packet;	// From elink1 of elink.v
   wire			elink1_rxwr_access;	// From elink1 of elink.v
   wire [PW-1:0]	elink1_rxwr_packet;	// From elink1 of elink.v
   wire			elink1_timeout;		// From elink1 of elink.v
   wire [7:0]		elink1_txo_data_n;	// From elink1 of elink.v
   wire [7:0]		elink1_txo_data_p;	// From elink1 of elink.v
   wire			elink1_txo_frame_n;	// From elink1 of elink.v
   wire			elink1_txo_frame_p;	// From elink1 of elink.v
   wire			elink1_txo_lclk_n;	// From elink1 of elink.v
   wire			elink1_txo_lclk_p;	// From elink1 of elink.v
   wire			elink1_txrd_wait;	// From elink1 of elink.v
   wire			elink1_txrr_access;	// From emem of ememory.v
   wire [PW-1:0]	elink1_txrr_packet;	// From emem of ememory.v
   wire			elink1_txrr_wait;	// From elink1 of elink.v
   wire			elink1_txwr_wait;	// From elink1 of elink.v
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

   wire 		elink0_txrr_access;
   wire [PW-1:0] 	elink0_txrr_packet;
   wire 		elink0_txwr_access;
   wire [PW-1:0] 	elink0_txwr_packet;
   wire 		elink0_txrd_access;
   wire [PW-1:0] 	elink0_txrd_packet;
  
   wire 		elink1_txwr_access;
   wire [PW-1:0] 	elink1_txwr_packet;
   wire 		elink1_txrd_access;
   wire [PW-1:0] 	elink1_txrd_packet;

   wire                 txrd_wait;
   wire                 txwr_wait;
   wire                 txrr_wait; 
   wire                 rxrr_wait;
   wire                 emem_wait;
   wire 		rxrd_wait;
   
   reg [31:0]    etime;  
   wire 	 itrace = 1'b1;
 
   
   //Clocks
   wire clkin         = clk[0]; //for pll-->cclk, rxclk, txclk

  

   //Read path
   assign elink0_txrd_access         = ext_access & ~ext_packet[1];
   assign elink0_txrd_packet[PW-1:0] = ext_packet[PW-1:0];
        
   //Write path
   assign elink0_txwr_access         = ext_access & ext_packet[1];
   assign elink0_txwr_packet[PW-1:0] = ext_packet[PW-1:0];

   //TX Pushback
   assign dut_rd_wait                = elink0_txrd_wait;   
   assign dut_wr_wait                = elink0_txwr_wait;
      
   //Getting results back
   assign dut_access                 = elink0_rxrr_access;
   assign dut_packet[PW-1:0]         = elink0_rxrr_packet[PW-1:0];
   
   //No pushback testing on elink0
   assign elink0_rxrd_wait = 1'b0;
   assign elink0_rxwr_wait = 1'b0;
   assign elink0_rxrr_wait = 1'b0;

 /*elink AUTO_TEMPLATE ( 
                        // Outputs                        
                        .hard_reset	    (reset),
                        .clkbypass          ({clkin,clkin,clkin}),
                        .clkin		    (clkin),
                        .sys_clk            (clk[1]),
                        .\(.*\)             (@"(substring vl-cell-name  0 6)"_\1[]),
                         );
  */

   defparam elink0.ID = 12'h810;   
   elink elink0 (.txrr_access		(),//not used
		 .txrr_packet		(),//not used	
		 .rxi_lclk_p		(elink1_txo_lclk_p),
		 .rxi_lclk_n		(elink1_txo_lclk_n),
		 .rxi_frame_p		(elink1_txo_frame_p),
		 .rxi_frame_n		(elink1_txo_frame_n),
		 .rxi_data_p		(elink1_txo_data_p[7:0]),
		 .rxi_data_n		(elink1_txo_data_n[7:0]),
		 .txi_wr_wait_p		(elink1_rxo_wr_wait_p),
		 .txi_wr_wait_n		(elink1_rxo_wr_wait_n),
		 .txi_rd_wait_p		(elink1_rxo_rd_wait_p),
		 .txi_rd_wait_n		(elink1_rxo_rd_wait_n),	
		 
		 /*AUTOINST*/
		 // Outputs
		 .colid			(elink0_colid[3:0]),	 // Templated
		 .rowid			(elink0_rowid[3:0]),	 // Templated
		 .chip_resetb		(elink0_chip_resetb),	 // Templated
		 .cclk_p		(elink0_cclk_p),	 // Templated
		 .cclk_n		(elink0_cclk_n),	 // Templated
		 .rxo_wr_wait_p		(elink0_rxo_wr_wait_p),	 // Templated
		 .rxo_wr_wait_n		(elink0_rxo_wr_wait_n),	 // Templated
		 .rxo_rd_wait_p		(elink0_rxo_rd_wait_p),	 // Templated
		 .rxo_rd_wait_n		(elink0_rxo_rd_wait_n),	 // Templated
		 .txo_lclk_p		(elink0_txo_lclk_p),	 // Templated
		 .txo_lclk_n		(elink0_txo_lclk_n),	 // Templated
		 .txo_frame_p		(elink0_txo_frame_p),	 // Templated
		 .txo_frame_n		(elink0_txo_frame_n),	 // Templated
		 .txo_data_p		(elink0_txo_data_p[7:0]), // Templated
		 .txo_data_n		(elink0_txo_data_n[7:0]), // Templated
		 .mailbox_not_empty	(elink0_mailbox_not_empty), // Templated
		 .mailbox_full		(elink0_mailbox_full),	 // Templated
		 .timeout		(elink0_timeout),	 // Templated
		 .rxwr_access		(elink0_rxwr_access),	 // Templated
		 .rxwr_packet		(elink0_rxwr_packet[PW-1:0]), // Templated
		 .rxrd_access		(elink0_rxrd_access),	 // Templated
		 .rxrd_packet		(elink0_rxrd_packet[PW-1:0]), // Templated
		 .rxrr_access		(elink0_rxrr_access),	 // Templated
		 .rxrr_packet		(elink0_rxrr_packet[PW-1:0]), // Templated
		 .txwr_wait		(elink0_txwr_wait),	 // Templated
		 .txrd_wait		(elink0_txrd_wait),	 // Templated
		 .txrr_wait		(elink0_txrr_wait),	 // Templated
		 // Inputs
		 .hard_reset		(reset),		 // Templated
		 .clkin			(clkin),		 // Templated
		 .clkbypass		({clkin,clkin,clkin}),	 // Templated
		 .sys_clk		(clk[1]),		 // Templated
		 .rxwr_wait		(elink0_rxwr_wait),	 // Templated
		 .rxrd_wait		(elink0_rxrd_wait),	 // Templated
		 .rxrr_wait		(elink0_rxrr_wait),	 // Templated
		 .txwr_access		(elink0_txwr_access),	 // Templated
		 .txwr_packet		(elink0_txwr_packet[PW-1:0]), // Templated
		 .txrd_access		(elink0_txrd_access),	 // Templated
		 .txrd_packet		(elink0_txrd_packet[PW-1:0])); // Templated

   
   defparam elink1.ID = 12'h820;   
   elink elink1 (.rxi_lclk_p		(elink0_txo_lclk_p),
		 .rxi_lclk_n		(elink0_txo_lclk_n),
		 .rxi_frame_p		(elink0_txo_frame_p),
		 .rxi_frame_n		(elink0_txo_frame_n),
		 .rxi_data_p		(elink0_txo_data_p[7:0]),
		 .rxi_data_n		(elink0_txo_data_n[7:0]),
		 .txi_wr_wait_p		(elink0_rxo_wr_wait_p),
		 .txi_wr_wait_n		(elink0_rxo_wr_wait_n),
		 .txi_rd_wait_p		(elink0_rxo_rd_wait_p),
		 .txi_rd_wait_n		(elink0_rxo_rd_wait_n),	
		 /*AUTOINST*/
		 // Outputs
		 .colid			(elink1_colid[3:0]),	 // Templated
		 .rowid			(elink1_rowid[3:0]),	 // Templated
		 .chip_resetb		(elink1_chip_resetb),	 // Templated
		 .cclk_p		(elink1_cclk_p),	 // Templated
		 .cclk_n		(elink1_cclk_n),	 // Templated
		 .rxo_wr_wait_p		(elink1_rxo_wr_wait_p),	 // Templated
		 .rxo_wr_wait_n		(elink1_rxo_wr_wait_n),	 // Templated
		 .rxo_rd_wait_p		(elink1_rxo_rd_wait_p),	 // Templated
		 .rxo_rd_wait_n		(elink1_rxo_rd_wait_n),	 // Templated
		 .txo_lclk_p		(elink1_txo_lclk_p),	 // Templated
		 .txo_lclk_n		(elink1_txo_lclk_n),	 // Templated
		 .txo_frame_p		(elink1_txo_frame_p),	 // Templated
		 .txo_frame_n		(elink1_txo_frame_n),	 // Templated
		 .txo_data_p		(elink1_txo_data_p[7:0]), // Templated
		 .txo_data_n		(elink1_txo_data_n[7:0]), // Templated
		 .mailbox_not_empty	(elink1_mailbox_not_empty), // Templated
		 .mailbox_full		(elink1_mailbox_full),	 // Templated
		 .timeout		(elink1_timeout),	 // Templated
		 .rxwr_access		(elink1_rxwr_access),	 // Templated
		 .rxwr_packet		(elink1_rxwr_packet[PW-1:0]), // Templated
		 .rxrd_access		(elink1_rxrd_access),	 // Templated
		 .rxrd_packet		(elink1_rxrd_packet[PW-1:0]), // Templated
		 .rxrr_access		(elink1_rxrr_access),	 // Templated
		 .rxrr_packet		(elink1_rxrr_packet[PW-1:0]), // Templated
		 .txwr_wait		(elink1_txwr_wait),	 // Templated
		 .txrd_wait		(elink1_txrd_wait),	 // Templated
		 .txrr_wait		(elink1_txrr_wait),	 // Templated
		 // Inputs
		 .hard_reset		(reset),		 // Templated
		 .clkin			(clkin),		 // Templated
		 .clkbypass		({clkin,clkin,clkin}),	 // Templated
		 .sys_clk		(clk[1]),		 // Templated
		 .rxwr_wait		(elink1_rxwr_wait),	 // Templated
		 .rxrd_wait		(elink1_rxrd_wait),	 // Templated
		 .rxrr_wait		(elink1_rxrr_wait),	 // Templated
		 .txwr_access		(elink1_txwr_access),	 // Templated
		 .txwr_packet		(elink1_txwr_packet[PW-1:0]), // Templated
		 .txrd_access		(elink1_txrd_access),	 // Templated
		 .txrd_packet		(elink1_txrd_packet[PW-1:0]), // Templated
		 .txrr_access		(elink1_txrr_access),	 // Templated
		 .txrr_packet		(elink1_txrr_packet[PW-1:0])); // Templated
   
   
   
   assign  emem_access           = elink1_rxwr_access | elink1_rxrd_access;
    
   assign  emem_packet[PW-1:0]   = elink1_rxwr_access ? elink1_rxwr_packet[PW-1:0]:
                                                        elink1_rxrd_packet[PW-1:0];

   assign rxrd_wait = emem_wait | elink1_rxwr_access;
   
   /*ememory AUTO_TEMPLATE ( 
                        // Outputs
                        .\(.*\)_out       (elink1_txrr_\1[]),
                        .\(.*\)_in        (emem_\1[]),
                        .wait_out	  (emem_wait),
                         );
   */

   ememory emem (.wait_in	(1'b0),       //only one read at a time, set to zero for no1
		 .clk		(clk[1]),
		 .wait_out		(emem_wait),
		 /*AUTOINST*/
		 // Outputs
		 .access_out		(elink1_txrr_access),	 // Templated
		 .packet_out		(elink1_txrr_packet[PW-1:0]), // Templated
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

   emesh_monitor #(.NAME("emem")) mem_monitor (.emesh_wait	(1'b0),
						.clk		(clk[1]),
					       .emesh_access	(emem_access),
					       .emesh_packet	(emem_packet[PW-1:0]),
						/*AUTOINST*/
					       // Inputs
					       .reset		(reset),
					       .itrace		(itrace),
					       .etime		(etime[31:0]));
   

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

