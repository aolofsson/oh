/*
 ########################################################################
 ELINK TX CONFIGURATION REGISTER FILE
 ######################################################################## 
 */
`include "elink_regmap.v"
module etx_cfg (/*AUTOARG*/
   // Outputs
   mi_dout, tx_enable, mmu_enable, gpio_enable, remap_enable,
   burst_enable, gpio_data, ctrlmode, ctrlmode_bypass,
   // Inputs
   nreset, clk, mi_en, mi_we, mi_addr, mi_din, tx_status, tx_access
   );

   /******************************/
   /*Compile Time Parameters     */
   /******************************/
   parameter PW               = 104;   
   parameter RFAW             = 6;
   parameter DEFAULT_VERSION  = 16'h0000;

   /******************************/
   /*HARDWARE RESET (EXTERNAL)   */
   /******************************/
   input 	 nreset;             
   input 	 clk;

   /*****************************/
   /*SIMPLE MEMORY INTERFACE    */
   /*****************************/    
   input 	     mi_en;         
   input 	     mi_we;            
   input [RFAW+1:0]  mi_addr;       // complete address (no shifting!)
   input [31:0]      mi_din;        // (lower 2 bits not used)
   output [31:0]     mi_dout;   
   
   /*****************************/
   /*ELINK CONTROL SIGNALS      */
   /*****************************/
   //tx (static configs)
   output 	   tx_enable;      // enable signal for TX  
   output 	   mmu_enable;     // enables MMU on transmit path  
   output 	   gpio_enable;    // forces TX output pins to constants
   output 	   remap_enable;   // enable address remapping
   output 	   burst_enable;   // enables bursting
   
   input [15:0]    tx_status;      // etx status signals
   input 	   tx_access;      // for transaction counter
   //    
   //sampled by tx_lclk (test)
   output [8:0]    gpio_data;      // data for elink outputs (static)   

   //dynamic (control timing by use mode)
   output [3:0]    ctrlmode;        // value for emesh ctrlmode tag
   output          ctrlmode_bypass; // selects ctrlmode

   //registers
   reg [15:0] 	   tx_version_reg;
   reg [11:0] 	   tx_cfg_reg;
   reg [8:0] 	   tx_gpio_reg;
   reg [15:0] 	   tx_status_reg;
   reg [31:0] 	   tx_monitor_reg;
   reg [31:0] 	   mi_dout;
   reg 		   ecfg_access;
   
   //wires
   wire 	   ecfg_read;
   wire 	   ecfg_write;
   wire 	   tx_cfg_write;
   wire 	   tx_gpio_write;
   wire 	   tx_addr_write;
   wire 	   tx_data_write;
   wire 	   tx_version_write;
   wire 	   tx_status_write;
   
   /*****************************/
   /*ADDRESS DECODE LOGIC       */
   /*****************************/

   //read/write decode
   assign ecfg_write  = mi_en &  mi_we;
   assign ecfg_read   = mi_en & ~mi_we;   

   //Config write enables 
   assign tx_version_write  = ecfg_write & (mi_addr[RFAW+1:2]==`E_VERSION);
   assign tx_cfg_write      = ecfg_write & (mi_addr[RFAW+1:2]==`ETX_CFG);
   assign tx_status_write   = ecfg_write & (mi_addr[RFAW+1:2]==`ETX_STATUS);
   assign tx_gpio_write     = ecfg_write & (mi_addr[RFAW+1:2]==`ETX_GPIO);
   assign tx_monitor_write  = ecfg_write & (mi_addr[RFAW+1:2]==`ETX_MONITOR);
  
   //###########################
   //# TX CONFIG
   //###########################
   always @ (posedge clk)
     if(!nreset)
       tx_cfg_reg[11:0] <= 'b0;
     else if (tx_cfg_write)
       tx_cfg_reg[11:0] <= mi_din[11:0];

   assign tx_enable       = 1'b1;//TODO: fix! ecfg_tx_config_reg[0];
   assign mmu_enable      = tx_cfg_reg[1];   
   assign remap_enable    = (tx_cfg_reg[3:2]==2'b01);
   assign ctrlmode[3:0]   = tx_cfg_reg[7:4];
   assign ctrlmode_bypass = tx_cfg_reg[8];
   assign gpio_enable     = (tx_cfg_reg[10:9]==2'b01);
   assign burst_enable    = tx_cfg_reg[11];
   
   //###########################
   //# STATUS REGISTER
   //###########################   
   always @ (posedge clk)
     if (tx_status_write)
       tx_status_reg[15:0] <= mi_din[15:0];   
     else
       tx_status_reg[15:0]<= tx_status_reg[15:0] | tx_status[15:0];

   //###########################
   //# GPIO DATA
   //###########################
   always @ (posedge clk)
     if (tx_gpio_write)
       tx_gpio_reg[8:0] <= mi_din[8:0];

   assign gpio_data[8:0] = tx_gpio_reg[8:0];
   
   //###########################
   //# VERSION
   //###########################
   always @ (posedge clk)
     if(!nreset)
       tx_version_reg[15:0] <= DEFAULT_VERSION;
     else if (tx_version_write)
       tx_version_reg[15:0] <= mi_din[15:0];       

   //###########################
   //# MONITOR
   //###########################
   always @ (posedge clk)
     if (tx_monitor_write)
       tx_monitor_reg[31:0] <= mi_din[31:0];       
     else
       tx_monitor_reg[31:0] <=  tx_monitor_reg[31:0] + tx_access;
      
   //###############################
   //# DATA READBACK MUX
   //###############################
   //Pipelineing readback
   always @ (posedge clk)
     if(ecfg_read)
       case(mi_addr[RFAW+1:2])
         `E_VERSION:   mi_dout[31:0] <= {16'b0, tx_version_reg[15:0]};
         `ETX_CFG:     mi_dout[31:0] <= {21'b0, tx_cfg_reg[10:0]};
         `ETX_GPIO:    mi_dout[31:0] <= {23'b0, tx_gpio_reg[8:0]};
	 `ETX_STATUS:  mi_dout[31:0] <= {16'b0, tx_status_reg[15:0]};
	 `ETX_MONITOR: mi_dout[31:0] <= {tx_monitor_reg[31:0]};
         default:     mi_dout[31:0] <= 32'd0;
       endcase // case (mi_addr[RFAW+1:2])
     else
       mi_dout[31:0] <= 32'd0;

endmodule // ecfg_tx


