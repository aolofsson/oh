//#############################################################################
//# Function: Single Ported Memory                                            #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_memory_sp
  #(parameter DW      = 104,          // FIFO width
    parameter DEPTH   = 32,           // FIFO depth
    parameter REG     = 1,            // Register fifo output
    parameter SYN     = "true",       // hard (macro) or soft (rtl)
    parameter TYPE    = "default",    // pass through variable for hard macro
    parameter SHAPE   = "square",     // hard macro shape (square, tall, wide)
    parameter AW      = $clog2(DEPTH) // rd_count width (derived)
    )
   (// Memory interface (dual port)
    input 	    clk, //write clock
    input 	    en, //write enable
    input [DW-1:0]  wem, //per bit write enable
    input [AW-1:0]  addr,//write address
    input [DW-1:0]  din, //write data
    output [DW-1:0] dout,//read output data
    // BIST interface
    input 	    bist_en, // bist enable
    input 	    bist_we, // write enable global signal
    input [DW-1:0]  bist_wem, // write enable vector
    input [AW-1:0]  bist_addr, // address
    input [DW-1:0]  bist_din, // data input
    // Power/repair (hard macro only)
    input 	    shutdown, // shutdown signal
    input 	    vss, // ground signal
    input 	    vdd, // memory array power
    input 	    vddio, // periphery/io power
    input [7:0]     memconfig, // generic memory config
    input [7:0]     memrepair // repair vector
    );

   generate
      if(SYN=="true") begin: soft
	 //#########################################
	 // Generic RAM for synthesis
	 //#########################################
	 //local variables
	 reg [DW-1:0]        ram    [0:DEPTH-1];
	 wire [DW-1:0] 	     rdata;
	 integer 	     i;

	 //write port
	 always @(posedge clk)
	   for (i=0;i<DW;i=i+1)
	     if (en & wem[i])
               ram[addr[AW-1:0]][i] <= din[i];
	 //read port
	 assign rdata[DW-1:0] = ram[addr[AW-1:0]];

	 //Configurable output register
	 reg [DW-1:0] 	     rd_reg;
	 always @ (posedge clk)
	   if(en)
	     rd_reg[DW-1:0] <= rdata[DW-1:0];

	 //Drive output from register or RAM directly
	 assign dout[DW-1:0] = (REG==1) ? rd_reg[DW-1:0] :
		                          rdata[DW-1:0];
      end // block: soft
      else begin: hard
	 asic_memory_sp #(.DW(DW),
			  .DEPTH(DEPTH),
			  .SHAPE(SHAPE),
			  .REG(REG))
	 asic_memory_sp ();
      end // block: hard
   endgenerate
endmodule // oh_memory_dp
