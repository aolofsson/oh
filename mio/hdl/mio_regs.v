`include "mio_regmap.vh"
module mio_regs (/*AUTOARG*/
   // Outputs
   wait_out, access_out, packet_out, tx_en, rx_en, ddr_mode, emode,
   amode, dmode, datasize, lsbfirst, dstaddr, clkdiv, clkphase0,
   clkphase1,
   // Inputs
   clk, nreset, access_in, packet_in, wait_in, tx_full, tx_prog_full,
   tx_empty, rx_full, rx_prog_full, rx_empty
   );

   // parameters
   parameter   AW     = 32;      // address width
   localparam  PW     = 2*AW+40; // packet width   
      
   // clk,reset
   input            clk;
   input            nreset;
   
   // packet interface
   input 	    access_in;   // incoming access
   input [PW-1:0]   packet_in;   // incoming packet
   output 	    wait_out;    
   output 	    access_out;  // outgoing read packet
   output [PW-1:0]  packet_out;  // outgoing read packet
   input 	    wait_in;
   
   // config
   output 	    tx_en;       // enable tx
   output 	    rx_en;       // enable rx
   output 	    ddr_mode;    // ddr mode for mio
   output 	    emode;       // epiphany packet mode
   output 	    amode;       // mio packet mode
   output 	    dmode;       // mio packet mode
   output [7:0]     datasize;    // mio datasize   
   output 	    lsbfirst;    // lsb shift first
   
   //address
   output [AW-1:0]  dstaddr;     // destination address for RX dmode
   
   // clock
   output [7:0]     clkdiv;     // mio clk clock setting
   output [15:0]    clkphase0;  // [7:0]=rising,[15:8]=falling
   output [15:0]    clkphase1;  // [7:0]=rising,[15:8]=falling
        
   // status
   input 	    tx_full;
   input 	    tx_prog_full;
   input 	    tx_empty;
   input 	    rx_full;
   input 	    rx_prog_full;
   input 	    rx_empty;

   //######################################################################
   //# BODY
   //######################################################################

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [4:0]		ctrlmode_in;		// From p2e of packet2emesh.v
   wire [AW-1:0]	data_in;		// From p2e of packet2emesh.v
   wire [1:0]		datamode_in;		// From p2e of packet2emesh.v
   wire [AW-1:0]	dstaddr_in;		// From p2e of packet2emesh.v
   wire [AW-1:0]	srcaddr_in;		// From p2e of packet2emesh.v
   wire			write_in;		// From p2e of packet2emesh.v
   // End of automatics

   //regs
   reg [15:0] 		config_reg;   
   reg [7:0] 		status_reg;
   wire [7:0] 		status_in;   
   reg [31:0] 		clkdiv_reg;
   reg [63:0] 		addr_reg;
   reg [31:0] 		clkphase_reg;
   
   //#####################################
   //# DECODE
   //#####################################
   
   packet2emesh #(.AW(AW))
   p2e (/*AUTOINST*/
	// Outputs
	.write_in			(write_in),
	.datamode_in			(datamode_in[1:0]),
	.ctrlmode_in			(ctrlmode_in[4:0]),
	.dstaddr_in			(dstaddr_in[AW-1:0]),
	.srcaddr_in			(srcaddr_in[AW-1:0]),
	.data_in			(data_in[AW-1:0]),
	// Inputs
	.packet_in			(packet_in[PW-1:0]));

   assign reg_write      = write_in & access_in;
   assign config_write   = reg_write & (dstaddr_in[5:2]==`MIO_CONFIG);
   assign status_write   = reg_write & (dstaddr_in[5:2]==`MIO_STATUS);
   assign clkdiv_write   = reg_write & (dstaddr_in[5:2]==`MIO_CLKDIV);
   assign clkphase_write = reg_write & (dstaddr_in[5:2]==`MIO_CLKPHASE);
   assign idelay_write   = reg_write & (dstaddr_in[5:2]==`MIO_IDELAY);
   assign odelay_write   = reg_write & (dstaddr_in[5:2]==`MIO_ODELAY);
   assign addr0_write    = reg_write & (dstaddr_in[5:2]==`MIO_ADDR0);
   assign addr1_write    = reg_write & (dstaddr_in[5:2]==`MIO_ADDR1);
   
   //################################
   //# CONFIG
   //################################ 

   always @ (posedge clk or negedge nreset)
     if(!nreset)
       config_reg[15:0] <= 'b0;   
     else if(config_write)
       config_reg[15:0] <= data_in[15:0];

   assign tx_en         = ~config_reg[0];         // tx disable
   assign rx_en         = ~config_reg[1];         // rx disable
   assign emode         = config_reg[3:2]==2'b00; // emesh packets
   assign dmode         = config_reg[3:2]==2'b01; // pure data mode (streaming)
   assign amode         = config_reg[3:2]==2'b10; // auto address mode
   assign datasize[7:0] = config_reg[11:4];       // number of flits per packet
   assign lsbfirst      = ~config_reg[12];        // msb first transmit
   assign ddr_mode      = config_reg[13];         // dual data rate mode   

   //###############################
   //# STATUS
   //################################ 
   assign status_in[7:0] = {2'b0,       //7:6
			   tx_full,     //5			   
			   tx_prog_full,//4
			   tx_empty,    //3
			   rx_full,     //2	 		   
			   rx_prog_full,//1
			   rx_empty     //0
			   };
   
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       status_reg[7:0] <= 'b0;   
     else if(status_write)
       status_reg[7:0] <= data_in[7:0];
     else
       status_reg[7:0] <= {(status_reg[15:8] | status_in[7:0]), // sticky bits
			   status_in[7:0]};                    // immediate bits

   
   //###############################
   //# CLKDIV
   //################################ 

   always @ (posedge clk or negedge nreset)
     if(!nreset)
       clkdiv_reg[7:0] <= 'b0;   
     else if(clkdiv_write)
       clkdiv_reg[7:0] <= data_in[7:0];

   assign clkdiv[7:0] = clkdiv_reg[7:0];

   //###############################
   //# CLKPHASE
   //################################ 
   always @ (posedge clk)
     if(clkdiv_write)
       clkphase_reg[31:0] <= data_in[31:0];

   assign clkphase0[15:0]  = clkphase_reg[15:0];
   assign clkphase1[15:0] = clkphase_reg[31:16];
     
   //###############################
   //# RX DESTINATION ADDR (DMODE)
   //################################ 
   always @ (posedge clk)
     if(addr0_write)
       addr_reg[31:0]  <= data_in[31:0];
     else if(addr1_write)
       addr_reg[63:32] <= data_in[31:0];
   
   assign dstaddr[AW-1:0] = addr_reg[AW-1:0];
   
endmodule // io_cfg
// Local Variables:
// verilog-library-directories:("." "../../../oh/emesh/hdl" "../../../oh/common/hdl") 
// End:
