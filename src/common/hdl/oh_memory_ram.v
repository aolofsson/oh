//#############################################################################
//# Function: Generic RAM memory                                              #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT  (see LICENSE file in OH! repository)                       # 
//#############################################################################

module oh_memory_ram  # (parameter DW    = 104,           //memory width
			 parameter DEPTH = 32,            //memory depth
			 parameter AW    = $clog2(DEPTH)  // address width  
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
   
   reg [DW-1:0]        ram    [DEPTH-1:0];  
   integer 	       i;
      
   //registered read port
   always @ (posedge rd_clk)
     if(rd_en)       
       rd_dout[DW-1:0] <= ram[rd_addr[AW-1:0]];
   
   //write port with vector enable
   always @(posedge wr_clk)    
     for (i=0;i<DW;i=i+1)
       if (wr_en & wr_wem[i]) 
         ram[wr_addr[AW-1:0]][i] <= wr_din[i];
  
endmodule // oh_memory_ram





  
     

