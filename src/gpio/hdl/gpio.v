//#############################################################################
//# Function: General Purpose Software Programmable IO                        #
//#           (See README.md for complete documentation)                      #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in this repository)                       # 
//#############################################################################

`include "gpio_regmap.vh"
module gpio #( parameter integer N = 24,  // number of gpio pins
	       parameter integer AW = 32, // architecture address width
	       parameter integer PW = 104 // packet width
	      ) 
   (
    input 	       nreset, // asynchronous active low reset
    input 	       clk, // clock   
    input 	       access_in, // register access
    input [PW-1:0]     packet_in, // data/address
    output 	       wait_out, // pushback from mesh
    output 	       access_out, // register access
    output [PW-1:0]    packet_out, // data/address
    input 	       wait_in, // pushback from mesh    
    output reg [N-1:0] gpio_out, // data to drive to IO pins
    output reg [N-1:0] gpio_dir, // gpio direction(0=input)
    input [N-1:0]      gpio_in, // data from IO pins
    output 	       gpio_irq // OR of GPIO_ILAT register
    );

   //################################
   //# wires/regs/ params
   //################################  

   //registers
   reg [N-1:0] 	   gpio_imask;
   reg [N-1:0] 	   gpio_itype;
   reg [N-1:0] 	   gpio_ipol;
   reg [N-1:0] 	   gpio_ilat;   
   reg [N-1:0]	   read_data;
   wire [N-1:0]    gpio_in_sync;
      
   //wires
   reg [N-1:0] 	   data_old; //shadow
   wire [N-1:0]    ilat_clr;   
   wire [N-1:0]    reg_wdata;
   wire [N-1:0]    out_dmux;   
   wire [N-1:0]    rising_edge;   
   wire [N-1:0]    falling_edge;
   wire [N-1:0]    irq_event;
   wire 	   reg_write;
   wire 	   reg_read;
   wire 	   reg_double;
   wire 	   dir_write;
   wire 	   imask_write;
   wire 	   itype_write;
   wire 	   ipol_write;
   wire 	   ilatclr_write;
   wire 	   out_write;
   wire 	   outset_write;
   wire 	   outclr_write;
   wire 	   outxor_write;
   wire 	   outreg_write;
		   
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
   //# DECODE LOGIC
   //################################  

   packet2emesh #(.AW(AW),
		  .PW(PW))
   p2e(
       /*AUTOINST*/
       // Outputs
       .write_in			(write_in),
       .datamode_in			(datamode_in[1:0]),
       .ctrlmode_in			(ctrlmode_in[4:0]),
       .dstaddr_in			(dstaddr_in[AW-1:0]),
       .srcaddr_in			(srcaddr_in[AW-1:0]),
       .data_in				(data_in[AW-1:0]),
       // Inputs
       .packet_in			(packet_in[PW-1:0]));

   assign reg_write        = access_in & write_in;
   assign reg_read         = access_in & ~write_in;
   assign reg_double       = datamode_in[1:0]==2'b11;
   assign reg_wdata[N-1:0] = data_in[N-1:0];
   
   assign dir_write     = reg_write & (dstaddr_in[6:3]==`GPIO_DIR);
   assign outreg_write  = reg_write & (dstaddr_in[6:3]==`GPIO_OUT);
   assign imask_write   = reg_write & (dstaddr_in[6:3]==`GPIO_IMASK);
   assign itype_write   = reg_write & (dstaddr_in[6:3]==`GPIO_ITYPE);
   assign ipol_write    = reg_write & (dstaddr_in[6:3]==`GPIO_IPOL);
   assign ilatclr_write = reg_write & (dstaddr_in[6:3]==`GPIO_ILATCLR);
   assign outclr_write  = reg_write & (dstaddr_in[6:3]==`GPIO_OUTCLR);
   assign outset_write  = reg_write & (dstaddr_in[6:3]==`GPIO_OUTSET);
   assign outxor_write  = reg_write & (dstaddr_in[6:3]==`GPIO_OUTXOR);

   assign out_write = outreg_write |
	              outclr_write |
		      outset_write |
		      outxor_write;
      
   //################################
   //# GPIO_DIR 
   //################################ 
   //0=input
   //1=output
   
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       gpio_dir[N-1:0] <= 'b0;   
     else if(dir_write)
       gpio_dir[N-1:0] <= reg_wdata[N-1:0];      

   //################################
   //# GPIO_IN
   //################################ 

   oh_dsync oh_dsync[N-1:0] (.dout   (gpio_in_sync[N-1:0]),
			     .clk    (clk),
			     .nreset (nreset), 
			     .din    (gpio_in[N-1:0]));

   always @ (posedge clk)
       data_old[N-1:0] <= gpio_in_sync[N-1:0];
   
   //################################
   //# GPIO_OUT
   //################################ 

   oh_mux4 #(.DW(N))
   oh_mux4 (.out (out_dmux[N-1:0]),
	    // Inputs
	    .in0 (reg_wdata[N-1:0]),                   .sel0 (outreg_write),
	    .in1 (gpio_out[N-1:0] & ~reg_wdata[N-1:0]),.sel1 (outclr_write),
	    .in2 (gpio_out[N-1:0] | reg_wdata[N-1:0]), .sel2 (outset_write),
	    .in3 (gpio_out[N-1:0] ^ reg_wdata[N-1:0]), .sel3 (outxor_write));
   
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       gpio_out[N-1:0] <= 'b0;   
     else if(out_write)
       gpio_out[N-1:0] <= out_dmux[N-1:0];
   
   //################################
   //# GPIO_IMASK
   //################################ 

   always @ (posedge clk or negedge nreset)
     if(!nreset)
       gpio_imask[N-1:0] <= {(N){1'b1}};   
     else if(imask_write)
       gpio_imask[N-1:0] <= reg_wdata[N-1:0];

   //################################
   //# GPIO_ITYPE
   //################################ 
   always @ (posedge clk)
     if(itype_write)
       gpio_itype[N-1:0] <= reg_wdata[N-1:0];

   //################################
   //# GPIO_IPOL
   //################################ 
   always @ (posedge clk)
     if(ipol_write)
       gpio_ipol[N-1:0] <= reg_wdata[N-1:0];

   //################################
   //# INTERRUPT LOGIC (DEFAULT EDGE)
   //################################ 
   
   assign rising_edge[N-1:0]  =  gpio_in_sync[N-1:0] & ~data_old[N-1:0];

   assign falling_edge[N-1:0] = ~gpio_in_sync[N-1:0] & data_old[N-1:0];

   assign irq_event[N-1:0] = (rising_edge[N-1:0]   & ~gpio_itype[N-1:0] & gpio_ipol[N-1:0]) |
			     (falling_edge[N-1:0]  & ~gpio_itype[N-1:0] & ~gpio_ipol[N-1:0]) |
			     (gpio_in_sync[N-1:0]  & gpio_itype[N-1:0]  & gpio_ipol[N-1:0]) |
			     (~gpio_in_sync[N-1:0] & gpio_itype[N-1:0]  & ~gpio_ipol[N-1:0]);

   //################################
   //# ILAT
   //################################ 

   assign ilat_clr[N-1:0] = ilatclr_write ? reg_wdata[N-1:0] : 'b0;

   always @ (posedge clk or negedge nreset)
     if(!nreset)
       gpio_ilat[N-1:0] <= 'b0;
     else
       gpio_ilat[N-1:0] <= (gpio_ilat[N-1:0] & ~ilat_clr[N-1:0]) |  //old values
			   (irq_event[N-1:0] & ~gpio_imask[N-1:0]); //new interrupts

   //################################
   //# ONE CYCLE IRQ PULSE
   //################################ 

   assign gpio_irq = |gpio_ilat[N-1:0];
   
   //################################
   //# READBACK
   //################################ 

   always @ (posedge clk)
     if(reg_read)
       case(dstaddr_in[6:3])
	 `GPIO_IN   : read_data[N-1:0]  <= gpio_in_sync[N-1:0];
	 `GPIO_ILAT : read_data[N-1:0]  <= gpio_ilat[N-1:0];
	 `GPIO_DIR  : read_data[N-1:0]  <= gpio_dir[N-1:0];
	 `GPIO_IMASK: read_data[N-1:0]  <= gpio_imask[N-1:0];
	 `GPIO_IPOL : read_data[N-1:0]  <= gpio_ipol[N-1:0];
	 `GPIO_ITYPE: read_data[N-1:0]  <= gpio_itype[N-1:0];
	 default    : read_data[N-1:0]  <='b0;
       endcase // case (dstaddr_in[7:3])

   emesh_readback #(.AW(AW),
		    .PW(PW))
   emesh_readback (/*AUTOINST*/
		   // Outputs
		   .wait_out		(wait_out),
		   .access_out		(access_out),
		   .packet_out		(packet_out[PW-1:0]),
		   // Inputs
		   .nreset		(nreset),
		   .clk			(clk),
		   .access_in		(access_in),
		   .packet_in		(packet_in[PW-1:0]),
		   .read_data		(read_data[63:0]),
		   .wait_in		(wait_in));
   
endmodule // gpio
// Local Variables:
// verilog-library-directories:("." "../../emesh/hdl" "../../common/hdl")
// End:
