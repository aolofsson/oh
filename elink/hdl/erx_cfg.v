`include "elink_regmap.vh"
module erx_cfg (/*AUTOARG*/
   // Outputs
   mmu_access, dma_access, mailbox_access, ecfg_access, ecfg_packet,
   mmu_enable, remap_mode, remap_base, remap_pattern, remap_sel,
   idelay_value, load_taps, test_mode, mailbox_irq_en,
   // Inputs
   nreset, clk, erx_cfg_access, erx_cfg_packet, edma_rdata,
   mailbox_rdata, erx_access, erx_packet, gpio_datain, rx_status
   );

   //##################################################################
   //# INTERFACE
   //##################################################################

   parameter  AW      = 32;        // address width
   localparam PW      = 2*AW+40;   // packet width
   localparam RFAW    = 6;         // register block size
        
   //reset+clk
   input 	   nreset;         // async active low reset
   input 	   clk;            // slow clock

   //packet input 
   input       	   erx_cfg_access; // access from TX
   input [PW-1:0]  erx_cfg_packet; // packet

   //readback/decode
   output 	   mmu_access;     // mmu access
   output 	   dma_access;     // dma access
   output 	   mailbox_access; // mailbox access  
   input [31:0]    edma_rdata;     // dma readback data
   input [31:0]    mailbox_rdata;  // mailbox readback data

   //output packet
   output 	   ecfg_access;    // access signal for axi_slave
   output [PW-1:0] ecfg_packet;    // readback data for axi_slave
   
   //rx config
   output 	   mmu_enable;     // enables MMU on rx path (static)     
   output [1:0]    remap_mode;     // remap mode (static)       
   output [31:0]   remap_base;     // base for dynamic remap (static) 
   output [11:0]   remap_pattern;  // patter for static remap (static)
   output [11:0]   remap_sel;      // selects for static remap (static)
   output [44:0]   idelay_value;   // tap values for erx idelay
   output          load_taps;      // loads the idelay_value into IDELAY prim
   output 	   test_mode;      // testmode blocks all rx ports to fifo
   output 	   mailbox_irq_en; // irq enable for mailbox

   //rx debug packets
   input 	   erx_access;     // rx raw access for debug
   input [PW-1:0]  erx_packet;     // rx raw packet for debug

   //status signals
   input [8:0] 	   gpio_datain;    // frame and data inputs (static)        
   input [15:0]    rx_status;      // etx status signals
   
   //##################################################################
   //# BODY
   //##################################################################
   
   //registers
   reg [31:0] 	rx_cfg_reg;
   reg [31:0] 	rx_offset_reg;
   reg [8:0] 	rx_gpio_reg;
   reg [15:0] 	rx_status_reg;   
   reg [31:0] 	rx_testdata_reg;
   reg [44:0] 	idelay;
   reg 		load_taps;   
   reg [31:0] 	cfg_rdata;
   reg [AW-1:0] data_out;
   reg [AW-1:0] dstaddr_out;
   reg [AW-1:0] srcaddr_out;
   reg 		write_out;
   reg [4:0] 	ctrlmode_out;
   reg [1:0] 	datamode_out;
   reg 		ecfg_access;
   reg 		rx_sel;
   reg 		dma_sel;
   reg 		mailbox_sel;
   reg 		tx_sel;   
   wire [31:0] 	data_mux;

   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [4:0]		ctrlmode_in;		// From p2e of packet2emesh.v
   wire [AW-1:0]	data_in;		// From p2e of packet2emesh.v
   wire [1:0]		datamode_in;		// From p2e of packet2emesh.v
   wire [AW-1:0]	dstaddr_in;		// From p2e of packet2emesh.v
   wire [AW-1:0]	srcaddr_in;		// From p2e of packet2emesh.v
   wire			write_in;		// From p2e of packet2emesh.v
   // End of automatics
   
   //#################################
   //# PACKET DECODE
   //#################################
   packet2emesh #(.AW(AW))
   p2e (.packet_in   (erx_cfg_packet[PW-1:0]),
	/*AUTOINST*/
	// Outputs
	.write_in			(write_in),
	.datamode_in			(datamode_in[1:0]),
	.ctrlmode_in			(ctrlmode_in[4:0]),
	.dstaddr_in			(dstaddr_in[AW-1:0]),
	.srcaddr_in			(srcaddr_in[AW-1:0]),
	.data_in			(data_in[AW-1:0]));
   
   //read/write decode
   assign cfg_access   = erx_cfg_access &
		         (dstaddr_in[19:16] ==`EGROUP_MMR) &
		         (dstaddr_in[10:8]  ==`EGROUP_RX);
   
   assign mailbox_access = erx_cfg_access &
		          (dstaddr_in[19:16] ==`EGROUP_MMR) &
		          (dstaddr_in[10:8]  ==`EGROUP_MESH);
			     
   assign dma_access     = erx_cfg_access & 
			  (dstaddr_in[19:16] ==`EGROUP_MMR) &
			  (dstaddr_in[10:8]  ==`EGROUP_DMA);
   
   assign mmu_access    = erx_cfg_access & 
			  (dstaddr_in[19:16] ==`EGROUP_MMU) &
			  dstaddr_in[15];

   //Read operation (cfg or dma or mailbox)
   assign ecfg_read      = erx_cfg_access & ~write_in;

   //Write to the register file
   assign ecfg_write     = cfg_access & write_in;

   //Passing through readback data from TX
   assign ecfg_tx_read   = erx_cfg_access &
                           (dstaddr_in[19:16] ==`EGROUP_RR);
   
   //Config write enables
   assign rx_cfg_write      = ecfg_write & (dstaddr_in[RFAW+1:2]==`ERX_CFG);
   assign rx_offset_write   = ecfg_write & (dstaddr_in[RFAW+1:2]==`ERX_OFFSET);
   assign rx_idelay0_write  = ecfg_write & (dstaddr_in[RFAW+1:2]==`ERX_IDELAY0);
   assign rx_idelay1_write  = ecfg_write & (dstaddr_in[RFAW+1:2]==`ERX_IDELAY1);
   assign rx_testdata_write = ecfg_write & (dstaddr_in[RFAW+1:2]==`ERX_TESTDATA);
   assign rx_status_write   = ecfg_write & (dstaddr_in[RFAW+1:2]==`ERX_STATUS);

   //###########################
   //# RXCFG
   //###########################
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       rx_cfg_reg[31:0] <= 'b0;
     else if (rx_cfg_write)
       rx_cfg_reg[31:0] <= data_in[31:0];

   assign test_mode           = rx_cfg_reg[0];
   assign mmu_enable          = rx_cfg_reg[1];
   assign remap_mode[1:0]     = rx_cfg_reg[3:2];
   assign remap_sel[11:0]     = rx_cfg_reg[15:4];
   assign remap_pattern[11:0] = rx_cfg_reg[27:16];
   assign mailbox_irq_en      = rx_cfg_reg[28];
      
   //###########################1
   //# STATUS
   //###########################   
   always @ (posedge clk)     
     if (rx_status_write)
       rx_status_reg[15:0] <= data_in[15:0];
     else
       rx_status_reg[15:0] <= rx_status_reg[15:0] | rx_status[15:0];
     
   //###########################
   //# GPIO-DATAIN
   //###########################
   always @ (posedge clk)
     rx_gpio_reg[8:0] <= gpio_datain[8:0];

   //###########################1
   //# DYNAMIC REMAP BASE
   //###########################
   always @ (posedge clk)   
     if (rx_offset_write)
       rx_offset_reg[31:0] <= data_in[31:0];

   assign remap_base[31:0] = rx_offset_reg[31:0];

   //###########################1
   //# IDELAY TAP VALUES
   //###########################
   always @ (posedge clk) 
     if (rx_idelay0_write)
       idelay[31:0]  <= data_in[31:0];
     else if(rx_idelay1_write)
       idelay[44:32] <= data_in[12:0];

   //Construct delay for io (5*9 bits)   
   assign idelay_value[44:0] = {idelay[44],idelay[35:32],//frame
				idelay[43],idelay[31:28],//d7
				idelay[42],idelay[27:24],//d6
				idelay[41],idelay[23:20],//d5
				idelay[40],idelay[19:16],//d4
				idelay[39],idelay[15:12],//d3
				idelay[38],idelay[11:8], //d2
				idelay[37],idelay[7:4],  //d1
				idelay[36],idelay[3:0]   //d0
				};
   always @ (posedge clk)
     load_taps <= rx_idelay1_write;
   
   //###############################
   //# TESTMODE (ADD OR/LFSR..)
   //###############################  
   
   always @ (posedge clk)
     if(rx_testdata_write)
       rx_testdata_reg[31:0] <= data_in[31:0];
     else if(erx_access)   
       rx_testdata_reg[31:0] <= rx_testdata_reg[31:0] + erx_packet[71:40];
   				                    
   //###############################
   //# DATA READBACK MUX
   //###############################
   always @ (posedge clk)
     if(ecfg_read)
       case(dstaddr_in[RFAW+1:2])
         `ERX_CFG:      cfg_rdata[31:0] <= {rx_cfg_reg[31:0]};
         `ERX_GPIO:     cfg_rdata[31:0] <= {23'b0, rx_gpio_reg[8:0]};
	 `ERX_STATUS:   cfg_rdata[31:0] <= {16'b0, rx_status_reg[15:0]};
	 `ERX_OFFSET:   cfg_rdata[31:0] <= {rx_offset_reg[31:0]};
	 `ERX_TESTDATA: cfg_rdata[31:0] <= {rx_testdata_reg[31:0]};
         default:       cfg_rdata[31:0] <= 32'd0;
       endcase // case (dstaddr_in[RFAW+1:2])
     else
       cfg_rdata[31:0] <= 32'd0;

   //###############################
   //# FORWARD PACKET TO OUTPUT
   //###############################
   
   //pipeline
   always @ (posedge clk)
     begin
	ecfg_access       <= ecfg_read | ecfg_tx_read;
	datamode_out[1:0] <= datamode_in[1:0];
	ctrlmode_out[4:0] <= ctrlmode_in[3:0];
	write_out         <= 1'b1;	
	dstaddr_out[31:0] <= ecfg_read ? srcaddr_in[31:0] : dstaddr_in[31:0];
	data_out[31:0]    <= data_in[31:0];
	srcaddr_out[31:0] <= srcaddr_in[31:0];
	rx_sel            <= cfg_access;
	dma_sel           <= dma_access;
	mailbox_sel       <= mailbox_access;
	tx_sel            <= ecfg_tx_read;
     end

      
   //readback mux (should be one hot!)
   oh_mux4 #(.DW(32))
   mux4(.out (data_mux[31:0]),
	.in0 (cfg_rdata[31:0]),    .sel0 (rx_sel),
	.in1 (mailbox_rdata[31:0]),.sel1 (mailbox_sel),
	.in2 (edma_rdata[31:0]),   .sel2 (dma_sel),   
	.in3 (data_out[31:0]),     .sel3 (tx_sel)     
	);

   emesh2packet #(.AW(AW))
   e2p (.packet_out			(ecfg_packet[PW-1:0]),
	.data_out			(data_mux[31:0]),
	/*AUTOINST*/
	// Inputs
	.write_out			(write_out),
	.datamode_out			(datamode_out[1:0]),
	.ctrlmode_out			(ctrlmode_out[4:0]),
	.dstaddr_out			(dstaddr_out[AW-1:0]),
	.srcaddr_out			(srcaddr_out[AW-1:0]));
   
endmodule // ecfg_rx

// Local Variables:
// verilog-library-directories:("." "../../emesh/hdl" "../../common/hdl")
// End:

