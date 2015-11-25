// ########################################################################
// ELINK CONFIGURATION REGISTER FILE
// ######################################################################## 

`include "elink_regmap.v"
module erx_cfg (/*AUTOARG*/
   // Outputs
   mi_dout, mmu_enable, remap_mode, remap_base, remap_pattern,
   remap_sel, timer_cfg, idelay_value, load_taps, test_mode,
   // Inputs
   nreset, clk, mi_en, mi_we, mi_addr, mi_din, erx_test_access,
   erx_test_data, gpio_datain, rx_status
   );

   /******************************/
   /*Compile Time Parameters     */
   /******************************/
   parameter RFAW            = 6;         // 32 registers for now
   parameter GROUP           = 4'h0;
   
   /******************************/
   /*HARDWARE RESET (EXTERNAL)   */
   /******************************/
   input 	nreset;
   input 	clk;

   /*****************************/
   /*SIMPLE MEMORY INTERFACE    */
   /*****************************/    
   input 	 mi_en;         
   input 	 mi_we;            // single we, must write 32 bit words
   input [14:0]  mi_addr;          // complete physical address (no shifting!)
   input [31:0]  mi_din;
   output [31:0] mi_dout;   

   //test interface
   input 	 erx_test_access;
   input [31:0]  erx_test_data;
   
   /*****************************/
   /*CONFIG SIGNALS             */
   /*****************************/
   //rx
   output 	 mmu_enable;     // enables MMU on rx path (static)  
   input [8:0] 	 gpio_datain;    // frame and data inputs (static)        
   input [15:0]  rx_status;      // etx status signals
   output [1:0]  remap_mode;     // remap mode (static)       
   output [31:0] remap_base;     // base for dynamic remap (static) 
   output [11:0] remap_pattern;  // patter for static remap (static)
   output [11:0] remap_sel;      // selects for static remap (static)
   output [1:0]  timer_cfg;      // timeout config (00=off) (static)
   output [44:0] idelay_value;   // tap values for erx idelay
   output        load_taps;      // loads the idelay_value into IDELAY prim
   output 	 test_mode;      // testmode blocks all rx ports to fifo
   
   /*------------------------CODE BODY---------------------------------------*/
   
   //registers
   reg [31:0] 	rx_cfg_reg;
   reg [31:0] 	rx_offset_reg;
   reg [8:0] 	rx_gpio_reg;
   reg [15:0] 	rx_status_reg;   
   reg [31:0] 	rx_testdata_reg;
   reg [44:0] 	idelay;
   reg 		load_taps;   
   reg [31:0] 	mi_dout;

   
   //wires
   wire 	ecfg_read;
   wire 	ecfg_write;
   wire 	rx_cffg_write;
   wire  	rx_offset_write;
   wire  	rx_idelay0_write;
   wire  	rx_idelay1_write;
   wire         rx_testdata_write;
   wire 	rx_status_write;
   
   /*****************************/
   /*ADDRESS DECODE LOGIC       */
   /*****************************/

   //read/write decode
   assign ecfg_write  = mi_en &  mi_we;
   assign ecfg_read   = mi_en & ~mi_we;   

   //Config write enables
   assign rx_cfg_write      = ecfg_write & (mi_addr[RFAW+1:2]==`ERX_CFG);
   assign rx_offset_write   = ecfg_write & (mi_addr[RFAW+1:2]==`ERX_OFFSET);
   assign rx_idelay0_write  = ecfg_write & (mi_addr[RFAW+1:2]==`ERX_IDELAY0);
   assign rx_idelay1_write  = ecfg_write & (mi_addr[RFAW+1:2]==`ERX_IDELAY1);
   assign rx_testdata_write = ecfg_write & (mi_addr[RFAW+1:2]==`ERX_TESTDATA);
   assign rx_status_write   = ecfg_write & (mi_addr[RFAW+1:2]==`ERX_STATUS);

   //###########################
   //# RXCFG
   //###########################
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       rx_cfg_reg[31:0] <= 'b0;
     else if (rx_cfg_write)
       rx_cfg_reg[31:0] <= mi_din[31:0];

   assign test_mode           = rx_cfg_reg[0];
   assign mmu_enable          = rx_cfg_reg[1];
   assign remap_mode[1:0]     = rx_cfg_reg[3:2];
   assign remap_sel[11:0]     = rx_cfg_reg[15:4];
   assign remap_pattern[11:0] = rx_cfg_reg[27:16];
   assign timer_cfg[1:0]      = rx_cfg_reg[29:28];
      
   //###########################
   //# DATAIN
   //###########################
   always @ (posedge clk)
     rx_gpio_reg[8:0] <= gpio_datain[8:0];
   
   //###########################1
   //# DEBUG
   //###########################   
   always @ (posedge clk)
     if (rx_status_write)
       rx_status_reg[15:0] <= mi_din[15:0];
     else
       rx_status_reg[15:0] <= rx_status_reg[15:0] | rx_status[15:0];

   //###########################1
   //# DYNAMIC REMAP BASE
   //###########################
   always @ (posedge clk)   
     if (rx_offset_write)
       rx_offset_reg[31:0] <= mi_din[31:0];

   assign remap_base[31:0] = rx_offset_reg[31:0];

   //###########################1
   //# IDELAY TAP VALUES
   //###########################
   always @ (posedge clk) 
     if (rx_idelay0_write)
       idelay[31:0]  <= mi_din[31:0];
     else if(rx_idelay1_write)
       idelay[44:32] <= mi_din[12:0];

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
   //# TESTMODE (ADD OR/LFSR)
   //###############################  
   wire 	testmode_add;
   wire 	testmode_lfsr;
   
   always @ (posedge clk)
     if(rx_testdata_write)
       rx_testdata_reg[31:0] <= mi_din[31:0];
     else if(erx_test_access)   
       rx_testdata_reg[31:0] <= rx_testdata_reg[31:0] + erx_test_data[31:0];
   				                    
   //###############################
   //# DATA READBACK MUX
   //###############################

   //Pipelineing readback
   always @ (posedge clk)
     if(ecfg_read)
       case(mi_addr[RFAW+1:2])
         `ERX_CFG:      mi_dout[31:0] <= {rx_cfg_reg[31:0]};
         `ERX_GPIO:     mi_dout[31:0] <= {23'b0, rx_gpio_reg[8:0]};
	 `ERX_STATUS:   mi_dout[31:0] <= {16'b0, rx_status_reg[15:0]};
	 `ERX_OFFSET:   mi_dout[31:0] <= {rx_offset_reg[31:0]};
	 `ERX_TESTDATA: mi_dout[31:0] <= {rx_testdata_reg[31:0]};
         default:       mi_dout[31:0] <= 32'd0;
       endcase // case (mi_addr[RFAW+1:2])
     else
       mi_dout[31:0] <= 32'd0;
   
endmodule // ecfg_rx


