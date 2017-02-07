//#############################################################################
//# Function: Single Port Memory                                              #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_memory_sp  # (parameter DW    = 104,          // memory width
			parameter DEPTH = 32,           // memory depth
			parameter MCW   = 8,            // repair/config width
			parameter AW    = $clog2(DEPTH) // address bus width  
		       ) 
   (// memory interface (single port)
    input 	    clk, // clock
    input 	    en, // memory access   
    input 	    we, // write enable global signal   
    input [DW-1:0]  wem, // write enable vector
    input [AW-1:0]  addr, // address
    input [DW-1:0]  din, // data input
    output [DW-1:0] dout, // data output
    // Power/repair (ASICs)
    input 	    vss, // common ground   
    input 	    vdd, // periphery power rail
    input 	    vddm, // sram array power rail
    input 	    shutdown, // shutdown signal from always on domain   
    input [MCW-1:0] memconfig, // generic memory config      
    input [MCW-1:0] memrepair, // repair vector   
    // BIST interface (ASICs)
    input 	    bist_en, // bist enable
    input 	    bist_we, // write enable global signal   
    input [DW-1:0]  bist_wem, // write enable vector
    input [AW-1:0]  bist_addr, // address
    input [DW-1:0]  bist_din  // data input
    );

   localparam ASIC = `CFG_ASIC;  // use ASIC lib

   generate
      if(ASIC)
	begin : g0
	   asic_sram_sp #(.DW(DW),
			  .DEPTH(DEPTH),
			  .MCW(MCW))	     
	   sram_sp (// Outputs
		    .dout       (dout[DW-1:0]),
		    // Inputs
		    .clk        (clk),
		    .en         (en),
		    .we         (we),
		    .wem        (wem[DW-1:0]),
		    .addr       (addr[AW-1:0]),
		    .din        (din[DW-1:0]),
		    .vdd        (vdd),
		    .vddm       (vddm),
		    .vss        (vss),
		    .shutdown   (shutdown),
		    .memconfig  (memconfig[MCW-1:0]),
		    .memrepair  (memrepair[MCW-1:0]),
		    .bist_en    (bist_en),
		    .bist_we    (bist_we),
		    .bist_wem   (bist_wem[DW-1:0]),
		    .bist_addr  (bist_addr[AW-1:0]),
		    .bist_din   (bist_din[DW-1:0]));
	end
      else
	begin : g0
	   oh_memory_ram #(.DW(DW),
			   .DEPTH(DEPTH))	     
	   sram_sp (//read port
		    .rd_dout (dout[DW-1:0]),
		    .rd_clk  (clk),
		    .rd_addr (addr[AW-1:0]),
		    .rd_en   (en & ~we),
		    //write port
		    .wr_clk  (clk),
		    .wr_en   (en & we),
		    .wr_addr (addr[AW-1:0]),
		    .wr_wem  (wem[DW-1:0]),
		    .wr_din  (din[DW-1:0]));
	end
   endgenerate
  
endmodule // oh_memory_sp




  
     

