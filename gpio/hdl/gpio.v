
//#########################################################################
//# GPIO (Supports up to 32 GPIO pins)
//# -each pin can be an output or input
//# -level and edge interrupts supported on every input pin
//#########################################################################

`include "gpio_regmap.v"
module gpio(/*AUTOARG*/
   // Outputs
   reg_rdata, gpio_out, gpio_en, gpio_irq, gpio_ilat,
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
   input 	   reg_access;  // register access (read only)
   input [PW-1:0]  reg_packet;  // data/address
   output [31:0]   reg_rdata;   // readback data

   //IO signals
   output [N-1:0]  gpio_out;    // data to drive to IO pins
   output [N-1:0]  gpio_en;     // tristate enables for IO pins
   input  [N-1:0]  gpio_in;     // data from IO pins
   
   //global interrupt   
   output 	   gpio_irq;    // or of all interrupts
   output [31:0]   gpio_ilat;   // individual interrupt outputs
   
   
   //##################################################################
   //# BODY
   //##################################################################
   
   //registers
   reg [N-1:0] 	   odata_reg;
   reg [N-1:0] 	   oen_reg;
   reg [N-1:0] 	   idata_reg;
   reg [N-1:0] 	   itype_reg;
   reg [N-1:0] 	   ipol_reg;
   reg [N-1:0] 	   imask_reg;   
   reg [N-1:0] 	   ilat_reg;
   reg [N-1:0] 	   gpio_reg;
   reg [AW-1:0]    reg_rdata;
 	   
   //nets
   reg [N-1:0] 	   ilat_in;
   reg [N-1:0] 	   ilat_event;   
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


   assign gpio_match  = reg_access             &
		        (dstaddr_in[10:8]==ID);

   assign gpio_write      = gpio_match & write_in;
   assign gpio_read      = gpio_match  & ~write_in;

   assign odata_write     = gpio_write & (dstaddr_in[7:2]==`GPIO_ODATA);
   assign odataand_write  = gpio_write & (dstaddr_in[7:2]==`GPIO_ODATAAND);
   assign odataorr_write  = gpio_write & (dstaddr_in[7:2]==`GPIO_ODATAORR);
   assign odataxor_write  = gpio_write & (dstaddr_in[7:2]==`GPIO_ODATAXOR);
   assign oen_write       = gpio_write & (dstaddr_in[7:2]==`GPIO_OEN);
   assign idata_write     = gpio_write & (dstaddr_in[7:2]==`GPIO_IDATA);
   assign itype_write     = gpio_write & (dstaddr_in[7:2]==`GPIO_ITYPE);
   assign ipol_write      = gpio_write & (dstaddr_in[7:2]==`GPIO_IPOL);
   assign imask_write     = gpio_write & (dstaddr_in[7:2]==`GPIO_IMASK);
   assign imaskand_write  = gpio_write & (dstaddr_in[7:2]==`GPIO_IMASKAND);
   assign imaskorr_write  = gpio_write & (dstaddr_in[7:2]==`GPIO_IMASKORR);
   assign ilat_write      = gpio_write & (dstaddr_in[7:2]==`GPIO_ILAT);
   assign ilatand_write   = gpio_write & (dstaddr_in[7:2]==`GPIO_ILATAND);

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

   //ITYPE
   //0=level
   //1=edge
   always @ (posedge clk)
     if(itype_write)
       itype_reg[N-1:0] <= data_in[N-1:0];

   //IPOLARITY
   //0=positive
   //1=negative
   always @ (posedge clk)
     if(ipol_write)
       ipol_reg[N-1:0] <= data_in[N-1:0];

   //IMASK
   always @ (posedge clk)
     if(imask_write)
       imask_reg[N-1:0] <= data_in[N-1:0];
     else if(imaskand_write)
       imask_reg[N-1:0] <= imask_reg[N-1:0] & data_in[N-1:0];
     else if(imaskorr_write)
       imask_reg[N-1:0] <= imask_reg[N-1:0] | data_in[N-1:0];
   
   //ILAT
   always @ (posedge clk or negedge nreset)
     if(~nreset)
       ilat_reg[N-1:0] <= 'b0;
     else       
       ilat_reg[N-1:0] <= ilat_in[N-1:0];
   
   //################################
   //# INTERRUPT CONTROL
   //################################ 

   //ILAT
   always @*
     for(i=0;i<N;i=i+1)     
       ilat_in[i] =(ilat_write & data_in[i]) |                    // ilat set
	           (ilat_reg[i] & ~(ilatand_write & ~data_in[i]))|// ilat clear
	           (ilat_event[i]);                               // event
   
   //shadow
   always @ (posedge clk)    
     gpio_reg[N-1:0] <= gpio_sync[N-1:0];
   
   //events
   assign event_posedge[N-1:0] = gpio_sync[N-1:0]  & ~gpio_reg[N-1:0];
   assign event_negedge[N-1:0] = ~gpio_sync[N-1:0] & gpio_reg[N-1:0];
   
   always @*
     for(j=0;j<N;j=j+1)     
       ilat_event[j] = (~itype_reg[j] & ~ipol_reg[j] & gpio_sync[j])    |
	               (~itype_reg[j] & ipol_reg[j]  & ~gpio_sync[j])   |
                       (itype_reg[j]  & ~ipol_reg[j] & event_posedge[j]) |
	               (itype_reg[j]  &  ipol_reg[j] & event_negedge[j]);
   
   
   //global interrupt output
   assign gpio_irq = |ilat_reg[N-1:0];


   //################################
   //# READBACK
   //################################ 
   always @ (posedge clk)
     if(gpio_read)
       case(dstaddr_in[7:2])
	 `GPIO_OEN    :  reg_rdata[31:0]   <= oen_reg[N-1:0];
	 `GPIO_IDATA  :  reg_rdata[31:0]   <= idata_reg[N-1:0];
	 `GPIO_ITYPE  :  reg_rdata[31:0]   <= itype_reg[N-1:0];
	 `GPIO_IPOL   :  reg_rdata[31:0]   <= ipol_reg[N-1:0];
	 `GPIO_IMASK  :  reg_rdata[31:0]   <= imask_reg[N-1:0];
	 `GPIO_ILAT   :  reg_rdata[31:0]   <= ilat_reg[N-1:0];
	 default      :  reg_rdata[AW-1:0] <='b0;
       endcase // case (dstaddr_in[7:2])
	 
endmodule // gpio
// Local Variables:
// verilog-library-directories:("." "../../emesh/hdl" "../../common/hdl")
// End:


