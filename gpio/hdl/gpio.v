/*
 * GPIO MODULE:
 * -up to 64 GPIOs natively (in pairs)
 * -atomic and, or, xor on odata
 * -global edge detect on any signal
 * 
 */
`include "gpio_regmap.vh"
module gpio(/*AUTOARG*/
   // Outputs
   reg_rdata, gpio_out, gpio_oen, gpio_irq, gpio_data,
   // Inputs
   nreset, clk, reg_access, reg_packet, gpio_in
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
   input 	   reg_access;  // register access
   input [PW-1:0]  reg_packet;  // data/address
   output [31:0]   reg_rdata;   // readback data

   //IO signals
   output [N-1:0]  gpio_out;    // data to drive to IO pins
   output [N-1:0]  gpio_oen;    // tristate enables for IO pins
   input [N-1:0]   gpio_in;     // data from IO pins
   
   //global interrupt   
   output 	   gpio_irq;    // toggle detect edge interrupt
   output [N-1:0]  gpio_data;   // individual interrupt outputs
   
   //##################################################################
   //# BODY
   //##################################################################
   
   //registers
   reg [63:0] 	   oen_reg;
   reg [63:0] 	   odata_reg;
   reg [63:0] 	   ien_reg;
   reg [63:0] 	   idata_reg;
   reg [63:0] 	   irqmask_reg;
   reg [31:0] 	   reg_rdata;

   //nets

   wire [N-1:0]    gpio_sync;
   wire [N-1:0]    gpio_edge;  
   wire [63:0] 	   reg_wdata;
   
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

   assign reg_write        = reg_access & write_in;
   assign reg_read         = reg_access & ~write_in;
   assign reg_double       = datamode_in[1:0]==2'b11;
   assign reg_wdata[63:0]  = {srcaddr_in[31:0],data_in[31:0]};
   
   assign oen_write       = reg_write & (dstaddr_in[7:3]==`GPIO_OEN);
   assign odata_write     = reg_write & (dstaddr_in[7:3]==`GPIO_OUT);
   assign ien_write       = reg_write & (dstaddr_in[7:3]==`GPIO_IEN);
   assign idata_write     = reg_write & (dstaddr_in[7:3]==`GPIO_IN);
   assign odataand_write  = reg_write & (dstaddr_in[7:3]==`GPIO_OUTAND);
   assign odataorr_write  = reg_write & (dstaddr_in[7:3]==`GPIO_OUTORR);
   assign odataxor_write  = reg_write & (dstaddr_in[7:3]==`GPIO_OUTXOR);
   assign irqmask_write   = reg_write & (dstaddr_in[7:3]==`GPIO_IRQMASK);
   
   //################################
   //# OUTPUT
   //################################ 

   //oen (active low, tristate by default)
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       oen_reg[63:0] <= 'b0;   
     else if(oen_write & reg_double)
       oen_reg[63:0] <= reg_wdata[63:0];
     else if(oen_write)
       oen_reg[31:0] <= reg_wdata[31:0];
   
   assign gpio_oen[N-1:0] = oen_reg[N-1:0];
   
   //odata
   always @ (posedge clk)
     if(odata_write & reg_double)
       odata_reg[63:0] <= reg_wdata[63:0];
     else if(odata_write)
       odata_reg[31:0] <= reg_wdata[31:0];
 
   assign gpio_out[N-1:0] = odata_reg[N-1:0];

   //################################
   //# INPUT
   //################################ 

   //ien
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       ien_reg[63:0] <= {(64){1'b1}}; 
     else if(ien_write & reg_double)
       ien_reg[63:0] <= reg_wdata[63:0];
     else if(ien_write)
       ien_reg[31:0] <= reg_wdata[31:0];

   //idata
   always @ (posedge clk)
     idata_reg[63:0] <= idata_reg[63:0] |
			(gpio_sync[N-1:0] & ien_reg[63:0]);

   assign gpio_data[N-1:0] = idata_reg[63:0];

   //################################
   //# IRQS
   //################################ 

   always @ (posedge clk or negedge nreset)
     if(!nreset)
       irqmask_reg[63:0] <= 'b0;   
     else if(irqmask_write & reg_double)
       irqmask_reg[63:0] <= reg_wdata[63:0];
     else if(irqmask_write)
       irqmask_reg[31:0] <= reg_wdata[31:0];
   
   //detect any edge on input data
   oh_edgedetect #(.DW(N))
   oh_edgedetect (.out	(gpio_edge[N-1:0]),
		  .clk	(clk),
		  .cfg	(2'b11), //toggle detect
		  .in	(idata_reg[N-1:0]));

   assign gpio_irq = |gpio_edge[N-1:0];
			    
   //################################
   //# READBACK
   //################################ 
   
   assign odd = (N>32) & dstaddr_in[2];
         
   always @ (posedge clk)
     if(reg_read)
       case(dstaddr_in[7:3])		 
	 `GPIO_OEN     :  reg_rdata[31:0] <= odd ? oen_reg[63:32]     : oen_reg[31:0];
	 `GPIO_OUT   :  reg_rdata[31:0] <= odd ? odata_reg[63:32]   : odata_reg[31:0];
	 `GPIO_IEN     :  reg_rdata[31:0] <= odd ? ien_reg[63:32]     : ien_reg[31:0]; 
	 `GPIO_IN   :  reg_rdata[31:0] <= odd ? idata_reg[63:32]   : idata_reg[31:0];	 
	 `GPIO_IRQMASK :  reg_rdata[31:0] <= odd ? irqmask_reg[63:32] : irqmask_reg[31:0];	 
	 default       :  reg_rdata[31:0] <='b0;
       endcase // case (dstaddr_in[7:3])

endmodule // gpio
// Local Variables:
// verilog-library-directories:("." "../../emesh/hdl" "../../common/hdl")
// End:


