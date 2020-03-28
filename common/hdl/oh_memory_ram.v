//#############################################################################
//# Function: Generic RAM memory                                              #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT  (see LICENSE file in OH! repository)                       # 
//#############################################################################

module oh_memory_ram  # (parameter DW      = 104,           // memory width
			 parameter DEPTH   = 32,            // memory depth
			 parameter REG     = 1,             // register output
			 parameter AW      = $clog2(DEPTH), // address width
			 parameter DUMPVAR = 0              // dump array
			 ) 
   (// read-port
    input 	    rd_clk,// rd clock
    input 	    rd_en, // memory access
    input [AW-1:0]  rd_addr, // address
    output [DW-1:0] rd_dout, // data output   
    // write-port
    input 	    wr_clk,// wr clock
    input 	    wr_en, // memory access
    input [AW-1:0]  wr_addr, // address
    input [DW-1:0]  wr_wem, // write enable vector    
    input [DW-1:0]  wr_din // data input
    );
   
   reg [DW-1:0]        ram    [0:DEPTH-1];  
   reg [DW-1:0]        ram    [DEPTH-1:0];  
   wire [DW-1:0]       rdata;
   integer 	       i;

   //#########################################
   //write port
   //#########################################	
   always @(posedge wr_clk)    
     for (i=0;i<DW;i=i+1)
       if (wr_en & wr_wem[i]) 
         ram[wr_addr[AW-1:0]][i] <= wr_din[i];

   //#########################################
   //read port
   //#########################################

   //RAM read
   assign rdata[DW-1:0] = ram[rd_addr[AW-1:0]];
   
   //Configurable output register
   generate
      if(REG)
	begin
	   reg [DW-1:0] rd_reg;
	   always @ (posedge rd_clk)
	     if(rd_en)       
	       rd_reg[DW-1:0] <= rdata[DW-1:0];
	   assign rd_dout[DW-1:0] = rd_reg[DW-1:0];
	end
      else
	begin
	   assign rd_dout[DW-1:0] = rdata[DW-1:0];
	end
   endgenerate

//##########################
//# SIMULATION/DEBUG LOGIC
//##########################

`ifdef TARGET_SIM
   generate
      if(DUMPVAR)
	begin
	   integer i;	   
	   initial
	     for (i = 0; i < DEPTH; i = i + 1)
	       $dumpvars(0,ram[i]);
	end
   endgenerate
   
`endif //  `ifdef TARGET_SIM

  
endmodule






  
     

