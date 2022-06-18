 //#############################################################################
//# Function: RAM (Single Port)
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_ram
  #(parameter N       = 32,           // FIFO width
    parameter DEPTH   = 32,           // FIFO depth
    parameter REG     = 1,            // Register fifo output
    parameter SYN     = "TRUE",       // hard (macro) or soft (rtl)
    parameter TYPE    = "DEFAULT",    // pass through variable for hard macro
    parameter SHAPE   = "SQUARE",     // hard macro shape (square, tall, wide)
    parameter AW      = $clog2(DEPTH) // rd_count width (derived)
    )
   (// Memory interface (dual port)
    input 	   clk, //write clock
    input 	   en, //write enable
    input [N-1:0]  wem, //per bit write enable
    input [AW-1:0] addr,//write address
    input [N-1:0]  din, //write data
    output [N-1:0] dout,//read output data
    // BIST interface
    input 	   bist_en, // bist enable
    input 	   bist_we, // write enable global signal
    input [N-1:0]  bist_wem, // write enable vector
    input [AW-1:0] bist_addr, // address
    input [N-1:0]  bist_din, // data input
    // Power/repair (hard macro only)
    input 	   shutdown, // shutdown signal
    input 	   vss, // ground signal
    input 	   vdd, // memory array power
    input 	   vddio, // periphery/io power
    input [7:0]    memconfig, // generic memory config
    input [7:0]    memrepair // repair vector
    );

   generate

      if(SYN == "TRUE") begin: rtl
	 // Generic RTL RAM
	 reg [N-1:0] 	   ram    [0:DEPTH-1];
	 wire [N-1:0] 	   rdata;
	 integer 	   i;

	 //write port
	 always @(posedge clk)
	   for (i=0;i<N;i=i+1)
	     if (en & wem[i])
               ram[addr[AW-1:0]][i] <= din[i];

	 //read port
	 assign rdata[N-1:0] = ram[addr[AW-1:0]];

	 //configurable output register
	 reg [N-1:0] 	     rd_reg;
	 always @ (posedge clk)
	   if(en)
	     rd_reg[N-1:0] <= rdata[N-1:0];

	 //Drive output from register or RAM directly
	 assign dout[N-1:0] = (REG==1) ? rd_reg[N-1:0] : rdata[N-1:0];

      end // block: rtl
      else begin: hard
	 // Hard macro ASIC RAM
	 asic_memory_sp #(.N(N),
			  .DEPTH(DEPTH),
			  .SHAPE(SHAPE),
			  .REG(REG))
	 asic_memory_sp ();
      end // block: hard
   endgenerate
endmodule // oh_memory_dp
