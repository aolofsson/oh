`define CFG_FAKECLK   1      /*stupid verilator doesn't get clock gating*/
`define CFG_MDW       32     /*Width of mesh network*/
`define CFG_DW        32     /*Width of datapath*/
`define CFG_AW        32     /*Width of address space*/
`define CFG_LW        8      /*Link port width*/

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
   input           clk;        // system clock
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
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [11:0]		elink0_chipid;		// From elink0 of elink.v
   wire			elink0_mailbox_full;	// From elink0 of elink.v
   wire			elink0_mailbox_not_empty;// From elink0 of elink.v
   wire			elink0_rx_clk_pll;	// From elink0 of elink.v
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
   wire			elink0_soft_reset;	// From elink0 of elink.v
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
   wire [11:0]		elink1_chipid;		// From elink1 of elink.v
   wire			elink1_mailbox_full;	// From elink1 of elink.v
   wire			elink1_mailbox_not_empty;// From elink1 of elink.v
   wire			elink1_rx_clk_pll;	// From elink1 of elink.v
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
   wire			elink1_soft_reset;	// From elink1 of elink.v
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
   wire			resetb;			// From elink_example of elink_example.v
   wire			rx_lclk;		// From eclocks of eclocks.v
   wire			rx_lclk_div4;		// From eclocks of eclocks.v
   wire			rxo_rd_wait_n;		// From elink_example of elink_example.v
   wire			rxo_rd_wait_p;		// From elink_example of elink_example.v
   wire			rxo_wr_wait_n;		// From elink_example of elink_example.v
   wire			rxo_wr_wait_p;		// From elink_example of elink_example.v
   wire			tx_lclk;		// From eclocks of eclocks.v
   wire			tx_lclk90;		// From eclocks of eclocks.v
   wire			tx_lclk_div4;		// From eclocks of eclocks.v
   wire [7:0]		txo_data_n;		// From elink_example of elink_example.v
   wire [7:0]		txo_data_p;		// From elink_example of elink_example.v
   wire			txo_frame_n;		// From elink_example of elink_example.v
   wire			txo_frame_p;		// From elink_example of elink_example.v
   wire			txo_lclk_n;		// From elink_example of elink_example.v
   wire			txo_lclk_p;		// From elink_example of elink_example.v
   // End of automatics
   wire		elink0_rxrd_wait;	// To elink0 of elink.v
   wire		elink0_rxrr_wait;	// To elink0 of elink.v
   wire		elink0_rxwr_wait;	// To elink0 of elink.v
   wire		elink1_rxrd_wait;	// To elink1 of elink.v
   wire		elink1_rxrr_wait;	// To elink1 of elink.v
   wire		elink1_rxwr_wait;	// To elink1 of elink.v
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

   wire [7:0]           elink2_txo_data_p;
   wire 	        elink2_txo_frame_p;
   wire                 elink2_txo_lclk_p;

   
   wire                 emem_wait;

   
   reg [31:0] 		 etime;  
   wire 	 itrace = 1'b1;
 
   
   //Clocks
   wire clkin         = clk; //for pll-->cclk, rxclk, txclk

   //######
   //CLOCKS for all
   //######
   eclocks eclocks (
		    .clkin_elink	(clkin),
		    .clkin_cclk		(clkin),
		     /*AUTOINST*/
		    // Outputs
		    .tx_lclk		(tx_lclk),
		    .tx_lclk90		(tx_lclk90),
		    .tx_lclk_div4	(tx_lclk_div4),
		    .rx_lclk		(rx_lclk),
		    .rx_lclk_div4	(rx_lclk_div4),
		    .cclk_p		(cclk_p),
		    .cclk_n		(cclk_n),
		    // Inputs
		    .reset		(reset));

   //Read path
   assign elink0_txrd_access         = ext_access & ~ext_packet[1];
   assign elink0_txrd_packet[PW-1:0] = ext_packet[PW-1:0];
        
   //Write path
   assign elink0_txwr_access         = ext_access & ext_packet[1];
   assign elink0_txwr_packet[PW-1:0] = ext_packet[PW-1:0];

   //TX Pushback
   assign dut_rd_wait                = elink0_txrd_wait;// | elink2_wait_out;   
   assign dut_wr_wait                = elink0_txwr_wait;// | elink2_wait_out ;
      
   //Getting results back
   assign dut_access                 = elink0_rxrr_access;
   assign dut_packet[PW-1:0]         = elink0_rxrr_packet[PW-1:0];
   
   //No pushback testing on elink0
   assign elink0_rxrd_wait = 1'b0;
   assign elink0_rxwr_wait = 1'b0;
   assign elink0_rxrr_wait = 1'b0;

   //not connected
   assign elink0_txrr_access         =  1'b0;
   assign elink0_txrr_packet[PW-1:0] = 'b0;

   /*elink AUTO_TEMPLATE (.reset	     (reset),
                        // Outputs                        
                         .ioreset	     (reset),
                         .tx_lclk	     (tx_lclk),
                         .tx_lclk90	     (tx_lclk90),
    		         .tx_lclk_div4	     (tx_lclk_div4),
		         .rx_lclk	     (rx_lclk),
	                 .rx_lclk_div4	     (rx_lclk_div4),
                         .sys_clk            (clk),
                         .\(.*\)             (@"(substring vl-cell-name  0 6)"_\1[]),
                         );
  */

   defparam elink0.ID = 12'h810;   
   elink elink0 (
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
		 .rx_clk_pll		(elink0_rx_clk_pll),	 // Templated
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
		 .chipid		(elink0_chipid[11:0]),	 // Templated
		 .soft_reset		(elink0_soft_reset),	 // Templated
		 .rxwr_access		(elink0_rxwr_access),	 // Templated
		 .rxwr_packet		(elink0_rxwr_packet[PW-1:0]), // Templated
		 .rxrd_access		(elink0_rxrd_access),	 // Templated
		 .rxrd_packet		(elink0_rxrd_packet[PW-1:0]), // Templated
		 .rxrr_access		(elink0_rxrr_access),	 // Templated
		 .rxrr_packet		(elink0_rxrr_packet[PW-1:0]), // Templated
		 .txwr_wait		(elink0_txwr_wait),	 // Templated
		 .txrd_wait		(elink0_txrd_wait),	 // Templated
		 .txrr_wait		(elink0_txrr_wait),	 // Templated
		 .mailbox_not_empty	(elink0_mailbox_not_empty), // Templated
		 .mailbox_full		(elink0_mailbox_full),	 // Templated
		 .timeout		(elink0_timeout),	 // Templated
		 // Inputs
		 .reset			(reset),		 // Templated
		 .ioreset		(reset),		 // Templated
		 .sys_clk		(clk),			 // Templated
		 .tx_lclk		(tx_lclk),		 // Templated
		 .tx_lclk90		(tx_lclk90),		 // Templated
		 .tx_lclk_div4		(tx_lclk_div4),		 // Templated
		 .rx_lclk		(rx_lclk),		 // Templated
		 .rx_lclk_div4		(rx_lclk_div4),		 // Templated
		 .rxwr_wait		(elink0_rxwr_wait),	 // Templated
		 .rxrd_wait		(elink0_rxrd_wait),	 // Templated
		 .rxrr_wait		(elink0_rxrr_wait),	 // Templated
		 .txwr_access		(elink0_txwr_access),	 // Templated
		 .txwr_packet		(elink0_txwr_packet[PW-1:0]), // Templated
		 .txrd_access		(elink0_txrd_access),	 // Templated
		 .txrd_packet		(elink0_txrd_packet[PW-1:0]), // Templated
		 .txrr_access		(elink0_txrr_access),	 // Templated
		 .txrr_packet		(elink0_txrr_packet[PW-1:0])); // Templated



   //No read/write from elink1 (for now)
   assign elink1_txrd_access = 1'b0;
   assign elink1_txrd_packet = 'b0;
   assign elink1_txwr_access = 1'b0;
   assign elink1_txwr_packet = 'b0;
   assign elink1_rxrr_wait   = 1'b0;
   
   defparam elink1.ID = 12'h820;   
   elink elink1 (
		 .rxi_lclk_p		(elink0_txo_lclk_p),
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
		 .rx_clk_pll		(elink1_rx_clk_pll),	 // Templated
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
		 .chipid		(elink1_chipid[11:0]),	 // Templated
		 .soft_reset		(elink1_soft_reset),	 // Templated
		 .rxwr_access		(elink1_rxwr_access),	 // Templated
		 .rxwr_packet		(elink1_rxwr_packet[PW-1:0]), // Templated
		 .rxrd_access		(elink1_rxrd_access),	 // Templated
		 .rxrd_packet		(elink1_rxrd_packet[PW-1:0]), // Templated
		 .rxrr_access		(elink1_rxrr_access),	 // Templated
		 .rxrr_packet		(elink1_rxrr_packet[PW-1:0]), // Templated
		 .txwr_wait		(elink1_txwr_wait),	 // Templated
		 .txrd_wait		(elink1_txrd_wait),	 // Templated
		 .txrr_wait		(elink1_txrr_wait),	 // Templated
		 .mailbox_not_empty	(elink1_mailbox_not_empty), // Templated
		 .mailbox_full		(elink1_mailbox_full),	 // Templated
		 .timeout		(elink1_timeout),	 // Templated
		 // Inputs
		 .reset			(reset),		 // Templated
		 .ioreset		(reset),		 // Templated
		 .sys_clk		(clk),			 // Templated
		 .tx_lclk		(tx_lclk),		 // Templated
		 .tx_lclk90		(tx_lclk90),		 // Templated
		 .tx_lclk_div4		(tx_lclk_div4),		 // Templated
		 .rx_lclk		(rx_lclk),		 // Templated
		 .rx_lclk_div4		(rx_lclk_div4),		 // Templated
		 .rxwr_wait		(elink1_rxwr_wait),	 // Templated
		 .rxrd_wait		(elink1_rxrd_wait),	 // Templated
		 .rxrr_wait		(elink1_rxrr_wait),	 // Templated
		 .txwr_access		(elink1_txwr_access),	 // Templated
		 .txwr_packet		(elink1_txwr_packet[PW-1:0]), // Templated
		 .txrd_access		(elink1_txrd_access),	 // Templated
		 .txrd_packet		(elink1_txrd_packet[PW-1:0]), // Templated
		 .txrr_access		(elink1_txrr_access),	 // Templated
		 .txrr_packet		(elink1_txrr_packet[PW-1:0])); // Templated
   

   wire elink2_access;
   wire [PW-1:0] elink2_packet;
   
   defparam model_fifo.WIDTH=104;
   defparam model_fifo.DEPTH=16;   
   fifo_cdc  model_fifo(
			// Outputs
			.wait_out	(),
			.access_out	(elink2_access),
			.packet_out	(elink2_packet[PW-1:0]),
			// Inputs
			.clk_in		(clk),
			.clk_out	(clk),
			.reset		(reset),
			.access_in	(ext_access),
			.packet_in	(ext_packet[PW-1:0]),
			.wait_in	(elink2_wait_out)
			);   
   elink_e16 elink2 (
		     // Outputs
		     .rxi_rd_wait	(),
		     .rxi_wr_wait	(),
		     .txo_data		(elink2_txo_data_p[7:0]),
		     .txo_lclk		(elink2_txo_lclk_p),
		     .txo_frame		(elink2_txo_frame_p),
		     .c0_mesh_access_out(),
		     .c0_mesh_write_out	(),
		     .c0_mesh_dstaddr_out(),
		     .c0_mesh_srcaddr_out(),
		     .c0_mesh_data_out	(),
		     .c0_mesh_datamode_out(),
		     .c0_mesh_ctrlmode_out(),
		     .c0_emesh_wait_out	(),
		     .c0_mesh_wait_out	(elink2_wait_out),
		     // Inputs
		     .reset		(reset),
		     .c0_clk_in		(clk),
		     .c1_clk_in		(clk),
		     .c2_clk_in		(clk),
		     .c3_clk_in		(clk),
		     .rxi_data		(elink0_txo_data_p[7:0]),
		     .rxi_lclk		(elink0_txo_lclk_p),
		     .rxi_frame		(elink0_txo_frame_p),
		     .txo_rd_wait	(1'b0),
		     .txo_wr_wait	(1'b0),
		     .c0_mesh_access_in	(elink2_access),
		     .c0_mesh_write_in	(elink2_packet[1]),
		     .c0_mesh_dstaddr_in(elink2_packet[39:8]),
		     .c0_mesh_srcaddr_in(elink2_packet[103:72]),
		     .c0_mesh_data_in	(elink2_packet[71:40]),
		     .c0_mesh_datamode_in(elink2_packet[3:2]),
		     .c0_mesh_ctrlmode_in(elink2_packet[7:4])		     
		     );
   
   
   assign  emem_access           = (elink1_rxwr_access & ~(elink1_rxwr_packet[39:28]==elink1.ID)) |
				   (elink1_rxrd_access & ~(elink1_rxrd_packet[39:28]==elink1.ID));
   
   assign  emem_packet[PW-1:0]   = elink1_rxwr_access ? elink1_rxwr_packet[PW-1:0]:
                                                        elink1_rxrd_packet[PW-1:0];

   assign elink1_rxrd_wait = emem_wait | elink1_rxwr_access;
   assign elink1_rxwr_wait = 1'b0; //no wait on write
   
   /*ememory AUTO_TEMPLATE ( 
                        // Outputs
                        .\(.*\)_out       (elink1_txrr_\1[]),
                        .\(.*\)_in        (emem_\1[]),
                        .wait_out	  (emem_wait),
                         );
   */

   ememory emem (.wait_in	        (1'b0),       //only one read at a time, set to zero for no1
		 .clk		        (clk),
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
						   .clk			(clk),
						   /*AUTOINST*/
						   // Inputs
						   .reset		(reset),
						   .itrace		(itrace),
						   .etime		(etime[31:0]),
						   .emesh_access	(ext_access),	 // Templated
						   .emesh_packet	(ext_packet[PW-1:0])); // Templated
   
   emesh_monitor #(.NAME("dut")) dut_monitor (.emesh_wait	(1'b0),
					      .clk		(clk),
					      /*AUTOINST*/
					      // Inputs
					      .reset		(reset),
					      .itrace		(itrace),
					      .etime		(etime[31:0]),
					      .emesh_access	(dut_access),	 // Templated
					      .emesh_packet	(dut_packet[PW-1:0])); // Templated

   emesh_monitor #(.NAME("emem")) mem_monitor (.emesh_wait	(1'b0),
						.clk		(clk),
					       .emesh_access	(emem_access),
					       .emesh_packet	(emem_packet[PW-1:0]),
						/*AUTOINST*/
					       // Inputs
					       .reset		(reset),
					       .itrace		(itrace),
					       .etime		(etime[31:0]));
   

   elink_example elink_example (.sys_clk_p	(clkin),
				.sys_clk_n	(~clkin),
				.clkin_p	(clkin),
				.clkin_n	(~clkin),
				.chipid		(),
				.cclk_p		(),
				.cclk_n		(),	
				.start		(ext_access),
      				.rxi_lclk_p	(txo_lclk_p),
				.rxi_lclk_n	(txo_lclk_n),
				.rxi_frame_p	(txo_frame_p),
				.rxi_frame_n	(txo_frame_n),
				.rxi_data_p	(txo_data_p[7:0]),
				.rxi_data_n	(txo_data_n[7:0]),
				.txi_wr_wait_p	(rxo_wr_wait_p),
				.txi_wr_wait_n	(rxo_wr_wait_n),
				.txi_rd_wait_p	(rxo_rd_wait_p),
				.txi_rd_wait_n	(rxo_rd_wait_n),	
				/*AUTOINST*/
				// Outputs
				.rxo_wr_wait_p	(rxo_wr_wait_p),
				.rxo_wr_wait_n	(rxo_wr_wait_n),
				.rxo_rd_wait_p	(rxo_rd_wait_p),
				.rxo_rd_wait_n	(rxo_rd_wait_n),
				.txo_lclk_p	(txo_lclk_p),
				.txo_lclk_n	(txo_lclk_n),
				.txo_frame_p	(txo_frame_p),
				.txo_frame_n	(txo_frame_n),
				.txo_data_p	(txo_data_p[7:0]),
				.txo_data_n	(txo_data_n[7:0]),
				.resetb		(resetb),
				// Inputs
				.reset		(reset));
   
  
endmodule // dv_elink
// Local Variables:
// verilog-library-directories:("." "../hdl" "../../memory/hdl" "../../emesh/hdl")
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

