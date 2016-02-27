`include "spi_regmap.v"
module spi_regs (/*AUTOARG*/
   // Outputs
   reg_rdata, cpol, cpha, txdata,
   // Inputs
   nreset, clk, reg_access, reg_packet, rxdata
   );

   //##################################################################
   //# INTERFACE
   //##################################################################

   parameter AW     = 32;         // data width of fifo
   parameter PW     = 2*AW+40;    // packet size
   parameter DEPTH  = 32;         // fifo depth

   //clk+reset
   input          nreset;         // asynchronous active low reset
   input 	  clk;            // write clock
   
   //register access
   input 	  reg_access;     // register access (read only)
   input [PW-1:0] reg_packet;     // data/address
   output [31:0]  reg_rdata;      // readback data

   //controls
   output 	  cpol;
   output 	  cpha;

   //io interface
   output [7:0]   txdata;         // data in txfifo
   input [7:0] 	  rxdata;         // data for rxfifo    
   
   //##################################################################
   //# BODY
   //##################################################################

   reg [31:0] 	  status_reg;
   reg [31:0] 	  cfg_reg;
   reg [31:0] 	  ilat_reg;
   reg [31:0] 	  imask_reg;
   reg [31:0] 	  delay_reg;
   reg [31:0] 	  tx_reg;
   reg [31:0] 	  rx_reg;
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [4:0]		ctrlmode_in;		// From p2e of packet2emesh.v
   wire [AW-1:0]	data_in;		// From p2e of packet2emesh.v
   wire [1:0]		datamode_in;		// From p2e of packet2emesh.v
   wire [AW-1:0]	dstaddr_in;		// From p2e of packet2emesh.v
   wire [AW-1:0]	srcaddr_in;		// From p2e of packet2emesh.v
   wire			write_in;		// From p2e of packet2emesh.v
   // End of automatics
   
   //################################
   //# REGISTER ACCESS DECODE
   //################################  

   packet2emesh p2e(.packet_in		(reg_packet[PW-1:0]),
		    /*AUTOINST*/
		    // Outputs
		    .write_in		(write_in),
		    .datamode_in	(datamode_in[1:0]),
		    .ctrlmode_in	(ctrlmode_in[4:0]),
		    .dstaddr_in		(dstaddr_in[AW-1:0]),
		    .srcaddr_in		(srcaddr_in[AW-1:0]),
		    .data_in		(data_in[AW-1:0]));

   
   assign reg_write      = reg_access & write_in;
   assign reg_read       = reg_access & ~write_in;
   
   assign cfg_write     = reg_write & (dstaddr_in[7:2]==`SPI_CFG);
   assign status_write  = reg_write & (dstaddr_in[7:2]==`SPI_STATUS);
   assign ilat_write    = reg_write & (dstaddr_in[7:2]==`SPI_ILAT);
   assign imask_write   = reg_write & (dstaddr_in[7:2]==`SPI_IMASK);
   assign delay_write   = reg_write & (dstaddr_in[7:2]==`SPI_DELAY);
   assign tx_write      = reg_write & (dstaddr_in[7:2]==`SPI_TX);
   
   ////////////////////////
   //CFG
   always @ (posedge clk)
     if(cfg_write)
       cfg_reg[31:0] <= data_in[31:0];

   assign spi_en      = cfg_reg[1];
   assign cpol        = cfg_reg[2];
   assign cpha        = cfg_reg[3];
   assign master_mode = cfg_reg[4];
   assign manual_mode = cfg_reg[5];   //
   assign irqen       = cfg_reg[6];   //enable spi interrupt
   assign clkdiv[3:0] = cfg_reg[11:8];

   ////////////////////////
   //STATUS
   always @ (posedge clk)
     if(status_write)
       status_reg[31:0] <= data_in[31:0];
     else
       status_reg[31:0] <= status_in[31:0];

   ////////////////////////
   //ILAT
   always @ (posedge clk)
     if(status_write)
       status_reg[31:0] <= data_in[31:0];
     else
       status_reg[31:0] <= status_in[31:0];

   ////////////////////////
   //IMASK
   always @ (posedge clk)
     if(status_write)
   
   
   //################################
   //# READBACK
   //################################ 
   always @ (posedge clk)
     if(reg_read)
       case(dstaddr_in[7:2])
	 `SPI_CFG    :  reg_rdata[31:0]   <= cfg_reg[31:0];
	 `SPI_STATUS :  reg_rdata[31:0]   <= status_reg[31:0];
	 `SPI_ILAT   :  reg_rdata[31:0]   <= ilat_reg[31:0];
	 `SPI_IMASK  :  reg_rdata[31:0]   <= imask_reg[31:0];
	 `SPI_DELAY  :  reg_rdata[31:0]   <= delay_reg[31:0];
	 `SPI_RX     :  reg_rdata[31:0]   <= rx_reg[31:0];
       endcase // case (dstaddr_in[7:2])

endmodule // spi_regs
// Local Variables:
// verilog-library-directories:("." "../../emesh/hdl" "../../common/hdl")
// End:

