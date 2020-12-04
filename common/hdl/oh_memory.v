//#############################################################################
//# Function: Configurable Memory
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_memory
  #(parameter DW      = 104,          // FIFO width
    parameter DEPTH   = 32,           // FIFO depth
    parameter REG     = 1,            // Register fifo output    
    parameter AW      = $clog2(DEPTH),// rd_count width (derived)
    parameter TYPE    = "soft",       // hard=hard macro,soft=synthesizable
    parameter DUALPORT= "1",          // 1=dual port,0=single port           
    parameter CONFIG  = "default",    // hard macro user config pass through
    parameter SHAPE   = "square"      // hard macro shape (square, tall, wide)
    )
   (// Memory interface (dual port)
    input 	    wr_clk, //write clock
    input 	    wr_en, //write enable
    input [DW-1:0]  wr_wem, //per bit write enable
    input [AW-1:0]  wr_addr,//write address
    input [DW-1:0]  wr_din, //write data
    input 	    rd_clk, //read clock
    input 	    rd_en, //read enable
    input [AW-1:0]  rd_addr,//read address (only used for dual port!)
    output [DW-1:0] rd_dout,//read output data
    // BIST interface
    input 	    bist_en, // bist enable
    input 	    bist_we, // write enable global signal   
    input [DW-1:0]  bist_wem, // write enable vector
    input [AW-1:0]  bist_addr, // address
    input [DW-1:0]  bist_din, // data input
    input [DW-1:0]  bist_dout, // data input
    // Power/repair (hard macro only)
    input 	    shutdown, // shutdown signal
    input 	    vss, // ground signal
    input 	    vdd, // memory array power
    input 	    vddio, // periphery/io power
    input [7:0]     memconfig, // generic memory config      
    input [7:0]     memrepair // repair vector
    );
   
   generate
      if(TYPE=="soft") begin: soft
	 oh_ram #(.DW(DW),
		  .DEPTH(DEPTH),
		  .REG(REG),
		  .DUALPORT(DUALPORT))
	 oh_ram(/*AUTOINST*/
		// Outputs
		.rd_dout		(rd_dout[DW-1:0]),
		// Inputs
		.rd_clk			(rd_clk),
		.rd_en			(rd_en),
		.rd_addr		(rd_addr[AW-1:0]),
		.wr_clk			(wr_clk),
		.wr_en			(wr_en),
		.wr_addr		(wr_addr[AW-1:0]),
		.wr_wem			(wr_wem[DW-1:0]),
		.wr_din			(wr_din[DW-1:0]));
      end // block: soft
      else begin: hard
	 //#########################################
	 // Hard coded RAM Macros
	 //#########################################
	 asic_ram #(.DW(DW),
		    .DEPTH(DEPTH),
		    .REG(REG),
		    .DUALPORT(DUALPORT),
		    .CONFIG(CONFIG),
		    .SHAPE(SHAPE))
	 asic_ram(// Outputs
		  .rd_dout   (rd_dout[DW-1:0]),
		  // Inputs
		  .rd_clk    (rd_clk),
		  .rd_en     (rd_en),
		  .rd_addr   (rd_addr[AW-1:0]),
		  .wr_clk    (wr_clk),
		  .wr_en     (wr_en),
		  .wr_addr   (wr_addr[AW-1:0]),
		  .wr_wem    (wr_wem[DW-1:0]),
		  .wr_din    (wr_din[DW-1:0]));
      end // block: hard
   endgenerate
   
endmodule // oh_memory_dp



