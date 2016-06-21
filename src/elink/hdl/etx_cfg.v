//########################################################################
//# ELINK TX CONFIGURATION REGISTER FILE
//######################################################################## 
`include "elink_regmap.vh"
module etx_cfg (/*AUTOARG*/
   // Outputs
   cfg_mmu_access, etx_cfg_access, etx_cfg_packet, tx_enable,
   mmu_enable, gpio_enable, remap_enable, burst_enable, gpio_data,
   ctrlmode, ctrlmode_bypass,
   // Inputs
   nreset, clk, cfg_access, etx_access, etx_packet, etx_wait,
   tx_status
   );

   //##################################################################
   //# INTERFACE
   //##################################################################

   //parameters
   parameter AW       = 32;   
   parameter PW       = 2*AW+40;   
   parameter RFAW     = 6;
   parameter VERSION  = 16'h0000;
   parameter ID       = 999;

   //reset+clk
   input 	    nreset;         // sync reset      
   input 	    clk;            // slow clock
   
   //packet input 
   input 	    cfg_access;     // register access    
   input 	    etx_access;     // for transaction counter
   input [PW-1:0]   etx_packet;     // for transaction sampler
   input 	    etx_wait;       // wait signal   
   output 	    cfg_mmu_access; // mmu access

   //packet output (for RX)
   output 	    etx_cfg_access; // access for rx (write or rdata forward)
   output [PW-1:0]  etx_cfg_packet; // packet

   //tx (static configs)
   output 	   tx_enable;       // enable signal for TX  
   output 	   mmu_enable;      // enables MMU on transmit path  
   output 	   gpio_enable;     // forces TX output pins to constants
   output 	   remap_enable;    // enable address remapping
   output 	   burst_enable;    // enables bursting   
   output [8:0]    gpio_data;       // data for elink outputs (static)   
   output [3:0]    ctrlmode;        // value for emesh ctrlmode tag
   output          ctrlmode_bypass; // selects ctrlmode
   input [15:0]    tx_status;       // tx status signals 

   //##################################################################
   //# BODY
   //##################################################################

   //registers/wires
   reg [15:0] 	   tx_version_reg;
   reg [15:0] 	   tx_cfg_reg;
   reg [8:0] 	   tx_gpio_reg;
   reg [15:0] 	   tx_status_reg;
   reg [31:0] 	   tx_monitor_reg;
   reg [31:0] 	   tx_packet_reg;
   reg [31:0] 	   cfg_dout;      
   reg 		   ecfg_access;  
   reg [1:0] 	   datamode_out;
   reg [4:0] 	   ctrlmode_out;
   reg 		   write_out;
   reg [AW-1:0]    dstaddr_out;
   reg [AW-1:0]    srcaddr_out;
   reg [AW-1:0]    data_out;
   reg 		   read_sel;
   reg 		   etx_cfg_access;
   
   wire [15:0] 	   tx_status_sync;   
   wire [31:0] 	   data_mux;
 	   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [4:0]		ctrlmode_in;		// From p2e of packet2emesh.v
   wire [AW-1:0]	data_in;		// From p2e of packet2emesh.v
   wire [1:0]		datamode_in;		// From p2e of packet2emesh.v
   wire [AW-1:0]	dstaddr_in;		// From p2e of packet2emesh.v
   wire [AW-1:0]	srcaddr_in;		// From p2e of packet2emesh.v
   wire			write_in;		// From p2e of packet2emesh.v
   // End of automatics


   //###########################
   //# DECODE LOGIC
   //###########################
   packet2emesh #(.AW(AW))
   p2e (.packet_in   (etx_packet[PW-1:0]),
	/*AUTOINST*/
	// Outputs
	.write_in			(write_in),
	.datamode_in			(datamode_in[1:0]),
	.ctrlmode_in			(ctrlmode_in[4:0]),
	.dstaddr_in			(dstaddr_in[AW-1:0]),
	.srcaddr_in			(srcaddr_in[AW-1:0]),
	.data_in			(data_in[AW-1:0]));

   //read/write decode
   assign tx_match     = cfg_access &
		         (dstaddr_in[19:16] ==`EGROUP_MMR) &
		         (dstaddr_in[10:8]  ==`EGROUP_TX);
   			 			 
   //MMU access
   assign cfg_mmu_access = cfg_access & 
			   (dstaddr_in[19:16] ==`EGROUP_MMU) &
			   ~dstaddr_in[15];

   assign ecfg_read    = tx_match & ~write_in;
   assign ecfg_write   = tx_match & write_in;

   
   
   //Config write enables 
   assign tx_version_write  = ecfg_write & (dstaddr_in[RFAW+1:2]==`E_VERSION);
   assign tx_cfg_write      = ecfg_write & (dstaddr_in[RFAW+1:2]==`ETX_CFG);
   assign tx_status_write   = ecfg_write & (dstaddr_in[RFAW+1:2]==`ETX_STATUS);
   assign tx_gpio_write     = ecfg_write & (dstaddr_in[RFAW+1:2]==`ETX_GPIO);
   assign tx_monitor_write  = ecfg_write & (dstaddr_in[RFAW+1:2]==`ETX_MONITOR);
  
   //###########################
   //# TX CONFIG
   //###########################
   always @ (posedge clk)
     if(!nreset)
       tx_cfg_reg[15:0] <= 'b0;
     else if (tx_cfg_write)
       tx_cfg_reg[15:0] <= data_in[15:0];

   assign tx_enable       = 1'b1;//TODO: fix! ecfg_tx_config_reg[0];
   assign mmu_enable      = tx_cfg_reg[1];   
   assign remap_enable    = (tx_cfg_reg[3:2]==2'b01);
   assign ctrlmode[3:0]   = tx_cfg_reg[7:4];
   assign ctrlmode_bypass = tx_cfg_reg[9];
   assign burst_enable    = tx_cfg_reg[10];
   assign gpio_enable     = (tx_cfg_reg[12:11]==2'b01);
   
   //###########################
   //# STATUS REGISTER
   //###########################   

   //Synchronize to make easy regular
   oh_dsync isync[15:0] (.dout	 (tx_status_sync[15:0]),
			 .clk	 (clk),
			 .nreset (1'b1),
			 .din	 (tx_status[15:0]));

   always @ (posedge clk)
     if (tx_status_write)
       tx_status_reg[15:0] <= data_in[15:0];   
     else
       tx_status_reg[15:0]<= tx_status_reg[15:0] | {tx_status_sync[15:0]};

   //###########################
   //# GPIO DATA
   //###########################
   always @ (posedge clk)
     if (tx_gpio_write)
       tx_gpio_reg[8:0] <= data_in[8:0];

   assign gpio_data[8:0] = tx_gpio_reg[8:0];
   
   //###########################
   //# VERSION
   //###########################
   always @ (posedge clk)
     if(!nreset)
       tx_version_reg[15:0] <= VERSION;
     else if (tx_version_write)
       tx_version_reg[15:0] <= data_in[15:0];       

   //###########################
   //# MONITOR
   //###########################
   always @ (posedge clk)
     if (tx_monitor_write)
       tx_monitor_reg[31:0] <= data_in[31:0];       
     else
       tx_monitor_reg[31:0] <=  tx_monitor_reg[31:0] + (etx_access & ~etx_wait);

   //###########################
   //# PACKET (FOR DEBUG)
   //###########################     
   always @ (posedge clk)  
     if(etx_access)
       tx_packet_reg[31:0] <= etx_packet[39:8];
   
   //###############################
   //# DATA READBACK MUX
   //###############################
   //Pipelineing readback
   always @ (posedge clk)
     if(ecfg_read)
       case(dstaddr_in[RFAW+1:2])
         `E_VERSION:   cfg_dout[31:0] <= {16'b0, tx_version_reg[15:0]};
         `ETX_CFG:     cfg_dout[31:0] <= {16'b0, tx_cfg_reg[15:0]};
         `ETX_GPIO:    cfg_dout[31:0] <= {23'b0, tx_gpio_reg[8:0]};
	 `ETX_STATUS:  cfg_dout[31:0] <= {16'b0, tx_status_reg[15:0]};
	 `ETX_MONITOR: cfg_dout[31:0] <= {tx_monitor_reg[31:0]};
	 `ETX_PACKET:  cfg_dout[31:0] <= {tx_packet_reg[31:0]};	 
         default:      cfg_dout[31:0] <= 32'd0;
       endcase // case (dstaddr_in[RFAW+1:2])
     else
       cfg_dout[31:0] <= 32'd0;
   
   //###########################
   //# FORWARD PACKET TO RX
   //###########################

   //pipeline
   always @ (posedge clk)
     if(~etx_wait)
       begin
	  etx_cfg_access    <= cfg_access;	  
	  datamode_out[1:0] <= datamode_in[1:0];
	  ctrlmode_out[4:0] <= {1'b0,ctrlmode_in[3:0]};
	  write_out         <= ecfg_read | write_in;	  
	  dstaddr_out[31:0] <= ecfg_read ? srcaddr_in[31:0] : dstaddr_in[31:0];
	  data_out[31:0]    <= data_in[31:0];	  
	  srcaddr_out[31:0] <= srcaddr_in[31:0];
	  read_sel          <= ecfg_read;	  
       end

   assign data_mux[31:0] = read_sel ? cfg_dout[31:0] :
			              data_out[31:0];
   
   //Create packet
   emesh2packet #(.AW(AW))
   e2p (.packet_out			(etx_cfg_packet[PW-1:0]),
	.data_out			(data_mux[AW-1:0]),
	/*AUTOINST*/
	// Inputs
	.write_out			(write_out),
	.datamode_out			(datamode_out[1:0]),
	.ctrlmode_out			(ctrlmode_out[4:0]),
	.dstaddr_out			(dstaddr_out[AW-1:0]),
	.srcaddr_out			(srcaddr_out[AW-1:0]));
   
endmodule // ecfg_tx
// Local Variables:
// verilog-library-directories:("." "../../emesh/hdl" "../../common/hdl")
// End:


