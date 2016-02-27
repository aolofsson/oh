
//#########################################################################
//# GPIO
//# -each pin can be an output or input
//#########################################################################

`include "gpio_regmap.v"
module gpio(/*AUTOARG*/
   // Outputs
   reg_rdata, io_out, io_en, gpio_irq, gpio_data,
   // Inputs
   nreset, clk, reg_access, reg_packet, io_in
   );
  
   //##################################################################
   //# INTERFACE
   //##################################################################

   parameter  N      = 24;      // number of gpio pins
   parameter  AW     = 32;      // address width
   parameter  PW     = 2*AW+40; // packet width   
   parameter  ID     = 0;       // block id to match to, bits [10:8]
      
   //clk, reset
   input           nreset;      // asynchronous active low reset
   input 	   clk;         // clock

   //register access interface
   input 	   reg_access;  // register access (read only)
   input [PW-1:0]  reg_packet;  // data/address
   output [31:0]   reg_rdata;   // readback data

   //IO signals
   output [N-1:0]  io_out;      // data to drive to IO pins
   output [N-1:0]  io_en;       // tristate enables for IO pins
   input  [N-1:0]  io_in;       // data from IO pins
   
   //global interrupt   
   output 	   gpio_irq;    // change detected on an input
   output [N-1:0]  gpio_data;   // individual interrupt outputs
   
   //##################################################################
   //# BODY
   //##################################################################
   
   //registers
   reg [N-1:0] 	   odata_reg;
   reg [N-1:0] 	   oen_reg;
   reg [N-1:0] 	   idata_reg;
   reg [AW-1:0]    reg_rdata;
 	   
   //nets
   wire [N-1:0]    gpio_sync;
   wire [N-1:0]    event_posedge;
   wire [N-1:0]    event_negedge;
   
   integer 	   i,j;
   
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
   //# SYNCHRONIZE INPUT DATA
   //################################  
   oh_dsync #(.DW(N))
   dsync (.dout	(gpio_sync[N-1:0]),
          .clk	(clk),
          .din	(gpio_in[N-1:0]));
   
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

   assign odata_write     = reg_write & (dstaddr_in[7:2]==`GPIO_ODATA);
   assign odataand_write  = reg_write & (dstaddr_in[7:2]==`GPIO_ODATAAND);
   assign odataorr_write  = reg_write & (dstaddr_in[7:2]==`GPIO_ODATAORR);
   assign odataxor_write  = reg_write & (dstaddr_in[7:2]==`GPIO_ODATAXOR);
   assign oen_write       = reg_write & (dstaddr_in[7:2]==`GPIO_OEN);
   assign idata_write     = reg_write & (dstaddr_in[7:2]==`GPIO_IDATA);

   //################################
   //# OUTPUT CONTROL REGISTERS
   //################################ 

   //ODATA
   always @ (posedge clk)
     if(odata_write)
       odata_reg[N-1:0] <= data_in[N-1:0];
     else if(odataand_write)
       odata_reg[N-1:0] <= data_in[N-1:0] & odata_reg[N-1:0];
     else if(odataorr_write)
       odata_reg[N-1:0] <= data_in[N-1:0] | odata_reg[N-1:0];
   
   assign gpio_out[N-1:0] = odata_reg[N-1:0];

   //OEN
   always @ (posedge clk)
     if(oen_write)
       oen_reg[N-1:0] <= data_in[N-1:0];

   assign gpio_en[N-1:0] = oen_reg[N-1:0];

   //################################
   //# INPUT CONTROL REGISTERS
   //################################ 
   
   //IDATA
   always @ (posedge clk)
     idata_reg[N-1:0] <= gpio_sync[N-1:0];

   //################################
   //# READBACK
   //################################ 
   always @ (posedge clk)
     if(reg_read)
       case(dstaddr_in[7:2])
	 `GPIO_OEN    :  reg_rdata[31:0]   <= oen_reg[N-1:0];
	 `GPIO_IDATA  :  reg_rdata[31:0]   <= idata_reg[N-1:0];
	 default      :  reg_rdata[AW-1:0] <='b0;
       endcase // case (dstaddr_in[7:2])
	 
endmodule // gpio
// Local Variables:
// verilog-library-directories:("." "../../emesh/hdl" "../../common/hdl")
// End:


