//#############################################################################
//# Function: Generic RAM memory                                              #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT  (see LICENSE file in OH! repository)                       # 
//#############################################################################

`ifndef CFG_PLATFORM
`define CFG_PLATFORM "GENERIC"
`endif

module oh_memory_ram  # (parameter DW    = 104,           //memory width
			 parameter DEPTH = 32,            //memory depth
			 parameter AW    = $clog2(DEPTH),  // address width
			 parameter PLATFORM = `CFG_PLATFORM
			 )
   (// read-port
    input 		rd_clk,// rd clock
    input 		rd_en, // memory access
    input [AW-1:0] 	rd_addr, // address
    output reg [DW-1:0] rd_dout, // data output   
    // write-port
    input 		wr_clk,// wr clock
    input 		wr_en, // memory access
    input [AW-1:0] 	wr_addr, // address
    input [DW-1:0] 	wr_wem, // write enable vector    
    input [DW-1:0] 	wr_din // data input
   );


   generate
      if(PLATFORM == "ZYNQ")
      begin : xilinx
	 integer 	       i;
	 /* Block RAM is scarse. Use LUTs instead */
	 (* ram_style = "distributed" *)
	 reg [DW-1:0]        ram    [DEPTH-1:0];

	 //registered read port
	 always @ (posedge rd_clk)
	   if(rd_en)
	     rd_dout[DW-1:0] <= ram[rd_addr[AW-1:0]];

	 //write port with vector enable
	 always @(posedge wr_clk)
	   for (i=0;i<DW;i=i+1)
	     if (wr_en & wr_wem[i])
	       ram[wr_addr[AW-1:0]][i] <= wr_din[i];

      end // xilinx
      else
      begin : generic
	 integer 	       i;
	 reg [DW-1:0]        ram    [DEPTH-1:0];

	 //registered read port
	 always @ (posedge rd_clk)
	   if(rd_en)
	     rd_dout[DW-1:0] <= ram[rd_addr[AW-1:0]];

	 //write port with vector enable
	 always @(posedge wr_clk)
	   for (i=0;i<DW;i=i+1)
	     if (wr_en & wr_wem[i])
	       ram[wr_addr[AW-1:0]][i] <= wr_din[i];

      end // generic
   endgenerate
endmodule // oh_memory_ram
