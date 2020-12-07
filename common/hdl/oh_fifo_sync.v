//#############################################################################
//# Function: Synchronous FIFO                                                #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_fifo_sync 
  #(parameter DW       = 104,          // FIFO width
    parameter DEPTH    = 32,           // FIFO depth
    parameter REG      = 1,            // Register fifo output    
    parameter AW       = $clog2(DEPTH),// rd_count width (derived)
    parameter PROGFULL = DEPTH-1,      // programmable almost full level
    parameter TYPE     = "soft",       // hard=hard macro,soft=synthesizable
    parameter CONFIG   = "default",    // hard macro user config pass through
    parameter SHAPE    = "square"      // hard macro shape (square, tall, wide)
    ) 
   (
    //basic interface
    input 		clk, // clock
    input 		nreset, //async reset
    input 		clear, //clear fifo (synchronous)
    input 		shutdown,//power down signal for memory
    //write port
    input [DW-1:0] 	din, // data to write
    input 		wr_en, // write fifo
    output 		full, // fifo full
    output 		almost_full, //progfull level reached 
    //read port
    input 		rd_en, // read fifo    
    output [DW-1:0] 	dout, // output data (next cycle)
    output 		empty, // fifo is empty  
    output reg [AW-1:0] rd_count, // valid entries in fifo
    // test interface for ASIC 
    // leave floating for non-ASICs
    input [7:0] 	memconfig,
    input [7:0] 	memrepair,
    input 		bist_en,
    input 		bist_we,
    input [DW-1:0] 	bist_wem,
    input [DW-1:0] 	bist_din,
    input [AW-1:0] 	bist_addr,
    output [DW-1:0] 	bist_dout
 );
   //############################
   //local wires
   //############################
   reg [AW:0]          wr_addr;
   reg [AW:0]          rd_addr;
   wire 	       fifo_read;
   wire 	       fifo_write;
   wire 	       ptr_match;
   wire 	       fifo_empty;

   //############################
   // FIFO Control
   //############################
   assign fifo_read   = rd_en & ~empty;
   assign fifo_write  = wr_en & ~full;
   assign almost_full = (rd_count[AW-1:0] == PROGFULL);
   assign ptr_match   = (wr_addr[AW-1:0] == rd_addr[AW-1:0]);
   assign full        = ptr_match & (wr_addr[AW]==!rd_addr[AW]);
   assign fifo_empty  = ptr_match & (wr_addr[AW]==rd_addr[AW]);
   
   always @ (posedge clk or negedge nreset) 
     if(~nreset) 
       begin	   
          wr_addr[AW:0]   <= 'd0;
          rd_addr[AW:0]   <= 'b0;
          rd_count[AW-1:0]  <= 'b0;
       end
     else if(clear) 
       begin	   
          wr_addr[AW:0]   <= 'd0;
          rd_addr[AW:0]   <= 'b0;
          rd_count[AW-1:0]  <= 'b0;
       end
     else if(fifo_write & fifo_read) 
       begin
	  wr_addr[AW:0] <= wr_addr[AW:0] + 'd1;
	  rd_addr[AW:0] <= rd_addr[AW:0] + 'd1;	      
       end 
     else if(fifo_write) 
       begin
	  wr_addr[AW:0]   <=  wr_addr[AW:0]   + 'd1;
	  rd_count[AW-1:0]<= rd_count[AW-1:0] + 'd1;	
       end 
     else if(fifo_read) 
       begin	      
          rd_addr[AW:0]   <= rd_addr[AW:0]  + 'd1;
          rd_count[AW-1:0]<= rd_count[AW-1:0] - 'd1;
       end

   //Pipeline register to account for RAM output register  
   reg empty_reg;	   
   always @ (posedge clk)
     empty_reg <= fifo_empty;

   assign empty = (REG==1) ? empty_reg :
		             fifo_empty;
   //############################
   // Dual Ported Memory
   //############################
   oh_memory 
     #(.DUALPORT(1),
       .DW      (DW),
       .DEPTH   (DEPTH),
       .REG     (REG),
       .TYPE    (TYPE),
       .CONFIG  (CONFIG),
       .SHAPE   (SHAPE))
   oh_memory (// read port
	      .rd_dout   (dout[DW-1:0]),
	      .rd_clk    (clk),
	      .rd_en	 (fifo_read),
	      .rd_addr   (rd_addr[AW-1:0]),
	      // write port
	      .wr_clk    (clk),
	      .wr_en	 (fifo_write),
  	      .wr_wem    ({(DW){1'b1}}),
	      .wr_addr   (wr_addr[AW-1:0]),
	      .wr_din    (din[DW-1:0]),
	      // hard macro signals
	      .shutdown  (shutdown),
	      .memconfig (memconfig),
	      .memrepair (memrepair),
	      .bist_en   (bist_en),
	      .bist_we   (bist_we),
	      .bist_wem  (bist_wem[DW-1:0]),
	      .bist_addr (bist_addr[AW-1:0]),
	      .bist_din  (bist_din[DW-1:0]),
	      .bist_dout (bist_dout[DW-1:0]));
   
endmodule // oh_fifo_sync

// Local Variables:
// verilog-library-directories:("." "../dv" "../../fpu/hdl" "../../../oh/common/hdl") 
// End:
