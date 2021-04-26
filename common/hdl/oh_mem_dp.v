//#############################################################################
//# Function: Dual Ported Memory                                              #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_memory_dp
  #(parameter DW      = 104,          // FIFO width
    parameter DEPTH   = 32,           // FIFO depth
    parameter REG     = 1,            // Register fifo output    
    parameter AW      = $clog2(DEPTH),// rd_count width (derived)
    parameter TYPE    = "soft",       // hard (macro) or soft (rtl)    
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
    input [AW-1:0]  rd_addr,//read address
    output [DW-1:0] rd_dout,//read output data
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
    
      if(TYPE=="soft") begin: soft
	 oh_memory_soft
	 //#########################################
	 // Generic RAM for synthesis
	 //#########################################
	 //local variables
	 reg [DW-1:0]        ram    [0:DEPTH-1];  
	 wire [DW-1:0] 	     rdata;
	 integer 	     i;

	 //write port
	 always @(posedge wr_clk)    
	   for (i=0;i<DW;i=i+1)
	     if (wr_en & wr_wem[i]) 
               ram[wr_addr[AW-1:0]][i] <= wr_din[i];
	 //read port
	 assign rdata[DW-1:0] = ram[rd_addr[AW-1:0]];
	 
	 //Configurable output register
	 reg [DW-1:0] 	     rd_reg;
	 always @ (posedge rd_clk)
	   if(rd_en)       
	     rd_reg[DW-1:0] <= rdata[DW-1:0];
	 
	 //Drive output from register or RAM directly
	 assign rd_dout[DW-1:0] = (REG==1) ? rd_reg[DW-1:0] :
		                  rdata[DW-1:0];
      end // block: soft
      else begin: hard
	 //#########################################
	 // Hard coded RAM Macros
	 //#########################################
	 oh_memory_hard #(.DW(DW),
			  .DEPTH(DEPTH),
			  .SHAPE(SHAPE)
			  .REG(REG))
	 asic_mem_dp (//read port
		.rd_dout	(rd_dout[DW-1:0]),
		.rd_clk	(rd_clk),
		.rd_en	(rd_en),
		.rd_addr	(rd_addr[AW-1:0]),
		//write port
		.wr_en	(wr_en),
		.wr_clk	(wr_clk),
		.wr_addr	(wr_addr[AW-1:0]),
		.wr_wem	(wr_wem[DW-1:0]),
		.wr_din	(wr_din[DW-1:0]));
      else
	begin
	   
endmodule // oh_memory_dp



