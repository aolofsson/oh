`include "elink_regmap.vh"
module elink_cfg (/*AUTOARG*/
   // Outputs
   txwr_gated_access, etx_soft_reset, erx_soft_reset, clk_config,
   chipid,
   // Inputs
   clk, nreset, txwr_access, txwr_packet
   );

   parameter RFAW             = 6;     // 32 registers for now
   parameter PW               = 104;   // 32 registers for now
   parameter ID               = 12'h000;
   parameter DEFAULT_CHIPID   = 12'h808;

   /******************************/
   /*Clock/reset                 */
   /******************************/
   input 	  clk;   
   input 	  nreset;      // POR "hard reset"

   /******************************/
   /*REGISTER ACCESS             */
   /******************************/
   input 	  txwr_access;
   input [PW-1:0] txwr_packet;

   /******************************/
   /*FILTERED WRITE FOR TX FIFO  */
   /******************************/
   output 	  txwr_gated_access;
   
   /******************************/
   /*Outputs                     */
   /******************************/
   output 	 etx_soft_reset;  // tx soft reset (level)
   output 	 erx_soft_reset;  // rx soft reset (level)
   output [15:0] clk_config;      // clock settings (for pll)
   output [11:0] chipid;          // chip-id for Epiphany   
   
   /*------------------------CODE BODY---------------------------------------*/
   
   //registers
   reg [1:0] 	ecfg_reset_reg;
   reg [15:0] 	ecfg_clk_reg;
   reg [11:0] 	ecfg_chipid;
   reg [31:0] 	mi_dout;
   
   //wires
   wire 	ecfg_read;
   wire 	ecfg_write;
   wire 	ecfg_clk_write;
   wire 	ecfg_chipid_write;
   wire 	ecfg_reset_write;
   wire 	mi_en;
   wire [31:0] 	mi_addr;
   wire [31:0] 	mi_din;
   wire 	mi_we;
   
   packet2emesh #(.AW(32))
   pe2 (
	// Outputs
	.write_in	(mi_we),
	.datamode_in	(),
	.ctrlmode_in	(),
	.dstaddr_in	(mi_addr[31:0]),
	.data_in	(mi_din[31:0]),
	.srcaddr_in	(),
	// Inputs
	.packet_in	(txwr_packet[PW-1:0])
	);   
   
   /*****************************/
   /*ADDRESS DECODE LOGIC       */
   /*****************************/
   assign mi_en = txwr_access & 
		  (mi_addr[31:20]==ID) &
		  (mi_addr[10:8]==3'h2);
   

   //read/write decode
   assign ecfg_write  = mi_en &  mi_we;
   assign ecfg_read   = mi_en & ~mi_we;   

   //Config write enables
   assign ecfg_reset_write    = ecfg_write & (mi_addr[RFAW+1:2]==`E_RESET);
   assign ecfg_clk_write      = ecfg_write & (mi_addr[RFAW+1:2]==`E_CLK);
   assign ecfg_chipid_write   = ecfg_write & (mi_addr[RFAW+1:2]==`E_CHIPID);
   
   /*****************************/
   /*FILTER ACCESS              */
   /*****************************/
   assign 	txwr_gated_access =  txwr_access & ~(ecfg_reset_write | 
						     ecfg_clk_write   |
                                                     ecfg_chipid_write);
   
   //###########################
   //# RESET REG (ASYNC)
   //###########################
    always @ (posedge clk or negedge nreset)
      if(!nreset)
	ecfg_reset_reg[1:0] <= 'b0;         
      else if (ecfg_reset_write)
	ecfg_reset_reg[1:0] <= mi_din[1:0];  

   assign etx_soft_reset  = ecfg_reset_reg[0];
   assign erx_soft_reset  = ecfg_reset_reg[1];
     
   //###########################
   //# CCLK/LCLK (PLL)
   //###########################
   //TODO: implement!
    always @ (posedge clk or negedge nreset)
     if(!nreset)
       ecfg_clk_reg[15:0] <= 16'h573;//all clocks on at lowest speed   
     else if (ecfg_clk_write)
       ecfg_clk_reg[15:0] <= mi_din[15:0];

   assign clk_config[15:0] = ecfg_clk_reg[15:0];

   //###########################
   //# CHIPID
   //###########################
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       ecfg_chipid[11:0] <= DEFAULT_CHIPID;
     else if (ecfg_chipid_write)
       ecfg_chipid[11:0] <= mi_din[11:0];   
   
   assign chipid[11:0]=ecfg_chipid[11:0];   
    
endmodule // ecfg_elink

// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:
