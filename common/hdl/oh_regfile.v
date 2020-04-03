//#############################################################################
//# Function: Parametrized register file                                      #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_regfile # (parameter DW    = 64,  // data width
		     parameter REGS  = 32,  // memory 
		     parameter RP    = 5,   // read ports
		     parameter WP    = 5,   // write prots
		     parameter AW    = $clog2(REGS) // address width 
		     ) 
   (//Control inputs
    input 	       clk,
    input 	       nreset,
    // Write Ports (concatenated)
    input [WP-1:0]     wr_valid, // write access
    input [WP*AW-1:0]  wr_addr, // register address
    input [WP*DW-1:0]  wr_data, // write data
    // Read Ports (concatenated)   
    input [RP-1:0]     rd_valid, // read access
    input [RP*AW-1:0]  rd_addr, // register address
    output [RP*DW-1:0] rd_data // output data
    );

   genvar i;
   
   reg [DW-1:0] mem [0:REGS-1];
   
   //#########################################
   // write port
   //#########################################	
   for (i=0;i<RP;i=i+1)
     always @ (posedge clk)
       if (wr_valid[i])
         mem[wr_addr[(i+1)*AW-1:i*AW]] <= wr_data[(i+1)*DW-1:i*DW];
   
   //#########################################
   // read ports
   //#########################################	
   
   for (i=0;i<RP;i=i+1)
     assign rd_data[(i+1)*DW-1:i*DW] = mem[rd_addr[(i+1)*AW-1:i*AW]];
   
endmodule // oh_regfile




