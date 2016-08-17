module elink (/*AUTOARG*/
   // Outputs
   elink_active, rxo_wr_wait_p, rxo_wr_wait_n, rxo_rd_wait_p,
   rxo_rd_wait_n, txo_lclk_p, txo_lclk_n, txo_frame_p, txo_frame_n,
   txo_data_p, txo_data_n, chipid, cclk_p, cclk_n, chip_nreset,
   mailbox_irq, rxwr_access, rxwr_packet, rxrd_access, rxrd_packet,
   rxrr_access, rxrr_packet, txwr_wait, txrd_wait, txrr_wait,
   // Inputs
   sys_nreset, sys_clk, rxi_lclk_p, rxi_lclk_n, rxi_frame_p,
   rxi_frame_n, rxi_data_p, rxi_data_n, txi_wr_wait_p, txi_wr_wait_n,
   txi_rd_wait_p, txi_rd_wait_n, rxwr_wait, rxrd_wait, rxrr_wait,
   txwr_access, txwr_packet, txrd_access, txrd_packet, txrr_access,
   txrr_packet
   );   
   parameter AW          = 32;       //native address width
   parameter DW          = 32;       //native data width
   parameter PW          = 104;      //packet width   
   parameter ID          = 12'h810;  //epiphany ID for elink (ie addr[31:20])
   parameter ETYPE       = 1;
   parameter TARGET      = "XILINX";
   
   /****************************/
   /*MAIN CLOCK AND RESET      */
   /****************************/
   input        sys_nreset;    // reset for axi facing logic (active low)
   input 	sys_clk;       // single system clock for master/slave FIFOs
   output 	elink_active;  // rx and tx are both active
      
   /********************************/
   /*ELINK RECEIVER                */
   /********************************/          
   input 	rxi_lclk_p,   rxi_lclk_n;    // rx clock input
   input        rxi_frame_p,  rxi_frame_n;   // rx frame signal
   input [7:0] 	rxi_data_p,   rxi_data_n;    // rx data
   output       rxo_wr_wait_p,rxo_wr_wait_n; // rx write pushback output
   output       rxo_rd_wait_p,rxo_rd_wait_n; // rx read pushback output

   /********************************/
   /*ELINK TRANSMITTER             */
   /********************************/          
   output 	txo_lclk_p,   txo_lclk_n;    // tx clock output
   output       txo_frame_p,  txo_frame_n;   // tx frame signal
   output [7:0] txo_data_p,   txo_data_n;    // tx data
   input 	txi_wr_wait_p,txi_wr_wait_n; // tx write pushback input
   input 	txi_rd_wait_p,txi_rd_wait_n; // tx read pushback input

   /*************************************/
   /*EPIPHANY MISC INTERFACE (I/O PINS) */
   /*************************************/          
   output [11:0]   chipid;	   // chip id strap pins for epiphany
   output 	   cclk_p, cclk_n; //chip clock
   output 	   chip_nreset;	  // From etx of etx.v

   /*****************************/
   /*MAILBOX INTERRUPTS         */
   /*****************************/
   output 	   mailbox_irq;

   /*****************************/
   /*SYSTEM SIDE INTERFACE      */
   /*****************************/   
   
   //Master Write (from RX)
   output 	   rxwr_access;
   output [PW-1:0] rxwr_packet;
   input 	   rxwr_wait;
      
  //Master Read Request (from RX)
   output 	   rxrd_access;
   output [PW-1:0] rxrd_packet;
   input 	   rxrd_wait;
   
   //Slave Read Response (from RX)
   output 	   rxrr_access;
   output [PW-1:0] rxrr_packet;
   input 	   rxrr_wait;
   
   //Slave Write (to TX)
   input 	   txwr_access;
   input [PW-1:0]  txwr_packet;
   output 	   txwr_wait;

   //Slave Read Request (to TX) 
   input 	   txrd_access;
   input [PW-1:0]  txrd_packet;
   output 	   txrd_wait;
   
   //Master Read Response (to TX)
   input 	   txrr_access;
   input [PW-1:0]  txrr_packet;
   output 	   txrr_wait;

   /*#############################################*/
   /*  END OF BLOCK INTERFACE                     */
   /*#############################################*/
   
   /*AUTOINPUT*/
  
   //wire
   wire 		erx_cfg_access;		// To erx of erx.v
   wire [PW-1:0] 	erx_cfg_packet;		// To erx of erx.v
   wire 		etx_cfg_wait;		// To etx of etx.v
   wire [31:0] 		mi_rd_data;
   wire [31:0] 		mi_dout_ecfg;
   wire [31:0] 		mi_dout_embox;

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			erx_cfg_wait;		// From erx of erx.v
   wire			erx_nreset;		// From erx of erx.v
   wire			erx_soft_reset;		// From elink_cfg of elink_cfg.v
   wire			etx_cfg_access;		// From etx of etx.v
   wire [PW-1:0]	etx_cfg_packet;		// From etx of etx.v
   wire			etx_nreset;		// From etx of etx.v
   wire			etx_soft_reset;		// From elink_cfg of elink_cfg.v
   wire			rx_lclk_div4;		// From erx of erx.v
   wire			tx_active;		// From etx of etx.v
   wire			tx_lclk_div4;		// From etx of etx.v
   wire			txwr_gated_access;	// From elink_cfg of elink_cfg.v
   // End of automatics
   
   /***********************************************************/
   /*CLOCK AND RESET CONFIG                                   */
   /***********************************************************/
   
   elink_cfg #(.ID(ID)) 

   elink_cfg (.clk		(sys_clk),
	      .nreset	   	(sys_nreset),
	      .clk_config	(),
			  /*AUTOINST*/
	      // Outputs
	      .txwr_gated_access	(txwr_gated_access),
	      .etx_soft_reset		(etx_soft_reset),
	      .erx_soft_reset		(erx_soft_reset),
	      .chipid			(chipid[11:0]),
	      // Inputs
	      .txwr_access		(txwr_access),
	      .txwr_packet		(txwr_packet[PW-1:0]));

   /***********************************************************/
   /*RECEIVER                                                 */
   /***********************************************************/
   /*erx AUTO_TEMPLATE ( 
	                .mi_dout      (mi_rx_dout[]),
                        .soft_reset   (erx_soft_reset),
                       );
   */
   
   erx #(.ID(ID), .ETYPE(ETYPE), .TARGET(TARGET))
   erx(.rx_active			(elink_active),
	   /*AUTOINST*/
	   // Outputs
	   .rxo_wr_wait_p		(rxo_wr_wait_p),
	   .rxo_wr_wait_n		(rxo_wr_wait_n),
	   .rxo_rd_wait_p		(rxo_rd_wait_p),
	   .rxo_rd_wait_n		(rxo_rd_wait_n),
	   .rxwr_access			(rxwr_access),
	   .rxwr_packet			(rxwr_packet[PW-1:0]),
	   .rxrd_access			(rxrd_access),
	   .rxrd_packet			(rxrd_packet[PW-1:0]),
	   .rxrr_access			(rxrr_access),
	   .rxrr_packet			(rxrr_packet[PW-1:0]),
	   .erx_cfg_wait		(erx_cfg_wait),
	   .rx_lclk_div4		(rx_lclk_div4),
	   .erx_nreset			(erx_nreset),
	   .mailbox_irq			(mailbox_irq),
	   // Inputs
	   .soft_reset			(erx_soft_reset),	 // Templated
	   .sys_nreset			(sys_nreset),
	   .sys_clk			(sys_clk),
	   .tx_active			(tx_active),
	   .rxi_lclk_p			(rxi_lclk_p),
	   .rxi_lclk_n			(rxi_lclk_n),
	   .rxi_frame_p			(rxi_frame_p),
	   .rxi_frame_n			(rxi_frame_n),
	   .rxi_data_p			(rxi_data_p[7:0]),
	   .rxi_data_n			(rxi_data_n[7:0]),
	   .rxwr_wait			(rxwr_wait),
	   .rxrd_wait			(rxrd_wait),
	   .rxrr_wait			(rxrr_wait),
	   .erx_cfg_access		(erx_cfg_access),
	   .erx_cfg_packet		(erx_cfg_packet[PW-1:0]));

   /***********************************************************/
   /*TRANSMITTER                                              */
   /***********************************************************/
   /*etx AUTO_TEMPLATE (.mi_dout      (mi_tx_dout[]),
                        .emwr_\(.*\)  (esaxi_emwr_\1[]),
                        .emrq_\(.*\)  (esaxi_emrq_\1[]),
                        .emrr_\(.*\)  (emaxi_emrr_\1[]),
                        .soft_reset   (etx_soft_reset),
                        .txwr_access  (txwr_gated_access),
                       );
   */

   etx #(.ID(ID), .ETYPE(ETYPE), .TARGET(TARGET))
   etx(
	   /*AUTOINST*/
	   // Outputs
	   .tx_active			(tx_active),
	   .txo_lclk_p			(txo_lclk_p),
	   .txo_lclk_n			(txo_lclk_n),
	   .txo_frame_p			(txo_frame_p),
	   .txo_frame_n			(txo_frame_n),
	   .txo_data_p			(txo_data_p[7:0]),
	   .txo_data_n			(txo_data_n[7:0]),
	   .cclk_p			(cclk_p),
	   .cclk_n			(cclk_n),
	   .chip_nreset			(chip_nreset),
	   .txrd_wait			(txrd_wait),
	   .txwr_wait			(txwr_wait),
	   .txrr_wait			(txrr_wait),
	   .etx_cfg_access		(etx_cfg_access),
	   .etx_cfg_packet		(etx_cfg_packet[PW-1:0]),
	   .etx_nreset			(etx_nreset),
	   .tx_lclk_div4		(tx_lclk_div4),
	   // Inputs
	   .sys_clk			(sys_clk),
	   .sys_nreset			(sys_nreset),
	   .soft_reset			(etx_soft_reset),	 // Templated
	   .txi_wr_wait_p		(txi_wr_wait_p),
	   .txi_wr_wait_n		(txi_wr_wait_n),
	   .txi_rd_wait_p		(txi_rd_wait_p),
	   .txi_rd_wait_n		(txi_rd_wait_n),
	   .txrd_access			(txrd_access),
	   .txrd_packet			(txrd_packet[PW-1:0]),
	   .txwr_access			(txwr_gated_access),	 // Templated
	   .txwr_packet			(txwr_packet[PW-1:0]),
	   .txrr_access			(txrr_access),
	   .txrr_packet			(txrr_packet[PW-1:0]),
	   .etx_cfg_wait		(etx_cfg_wait));
   
   /***********************************************************/
   /*TX-->RX REGISTER INTERFACE CONNECTION                    */
   /***********************************************************/
   oh_fifo_cdc #(.DW(104), .DEPTH(32), .TARGET(TARGET))
   ecfg_cdc (.nreset   	(erx_nreset),
		      // Outputs
		      .wait_out		(etx_cfg_wait),	
		      .access_out	(erx_cfg_access),	
		      .packet_out	(erx_cfg_packet[PW-1:0]),
		      // Inputs
		      .clk_in		(tx_lclk_div4),	
		      .access_in	(etx_cfg_access),
		      .packet_in	(etx_cfg_packet[PW-1:0]),
		      .clk_out		(rx_lclk_div4),	
		      .wait_in		(erx_cfg_wait)
		      );
   
endmodule

