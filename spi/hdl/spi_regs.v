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
   reg [31:0] 	  config_reg;
   reg [31:0] 	  ilat_reg;
   reg [31:0] 	  imask_reg;
   reg [31:0] 	  delay_reg;
   reg [31:0] 	  tx_reg;
   reg [31:0] 	  rx_reg;
   
   
   
   
endmodule // spi_regs

   
