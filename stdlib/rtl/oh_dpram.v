//#############################################################################
//# Function: RAM (Dual Port)
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_dpram
  #(parameter N       = 32,           // FIFO width
    parameter DEPTH   = 32,           // FIFO depth
    parameter REG     = 1,            // Register fifo output
    parameter TARGET  = "DEFAULT",    // pass through variable for hard macro
    parameter SHAPE   = "SQUARE",     // hard macro shape (square, tall, wide)
    parameter AW      = $clog2(DEPTH) // rd_count width (derived)
    )
   (// Memory interface (dual port)
    input 	   wr_clk, //write clock
    input 	   wr_en, //write enable
    input [N-1:0]  wr_wem, //per bit write enable
    input [AW-1:0] wr_addr,//write address
    input [N-1:0]  wr_din, //write data
    input 	   rd_clk, //read clock
    input 	   rd_en, //read enable
    input [AW-1:0] rd_addr,//read address
    output [N-1:0] rd_dout,//read output data
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
      if(TARGET == "DEFAULT") begin
	 //#########################################
	 // Generic RAM for synthesis
	 //#########################################
	 //local variables
	 reg [N-1:0]        ram    [0:DEPTH-1];
	 wire [N-1:0] 	    rdata;
	 integer 	    i;

	 //write port
	 always @(posedge wr_clk)
	   for (i=0;i<N;i=i+1)
	     if (wr_en & wr_wem[i])
               ram[wr_addr[AW-1:0]][i] = wr_din[i];

	 //read port
	 assign rdata[N-1:0] = ram[rd_addr[AW-1:0]];

	 //Configurable output register
	 reg [N-1:0] 	     rd_reg;
	 always @ (posedge rd_clk)
	   if(rd_en)
	     rd_reg[N-1:0] <= rdata[N-1:0];

	 //Drive output from register or RAM directly
	 assign rd_dout[N-1:0] = (REG==1) ? rd_reg[N-1:0] : rdata[N-1:0];
      end // block: soft
      else begin
	 asic_memory_dp #(.N(N),
			  .DEPTH(DEPTH),
			  .SHAPE(SHAPE),
			  .REG(REG))
	 asic_memory_dp ();
      end // block: hard
   endgenerate
endmodule // oh_memory_dp
