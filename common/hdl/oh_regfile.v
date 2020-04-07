//#############################################################################
//# Function: Parametrized register file                                      #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_regfile # (parameter REGS  = 32,  // number of registeres
		     parameter RW    = 64,  // register width
		     parameter RP    = 5,   // read ports
		     parameter WP    = 3   // write prots
		     ) 
   (//Control inputs
    input 	       clk,
    input 	       nreset,
    // Write Ports (concatenated)
    input [WP-1:0]     wr_valid, // write access
    input [WP*RAW-1:0] wr_addr, // register address
    input [WP*RW-1:0]  wr_data, // write data
    // Read Ports (concatenated)   
    input [RP-1:0]     rd_valid, // read access
    input [RP*RAW-1:0] rd_addr, // register address
    output [RP*RW-1:0] rd_data // output data
    );

   localparam RAW = $clog2(REGS);

   genvar 	       i;
   
   reg [RW-1:0] mem [0:REGS-1];

   //TODO: Make an array of cells
   
   //#########################################
   // write ports
   //#########################################	
   for (i=0;i<WP;i=i+1)
     always @ (posedge clk)
       if (wr_valid[i])
         mem[wr_addr[(i+1)*RAW-1:i*RAW]] <= wr_data[(i+1)*RW-1:i*RW];
   
   //#########################################
   // read ports
   //#########################################	
   
   for (i=0;i<RP;i=i+1)
     assign rd_data[i*RW+:RW] = {(RW){rd_valid[i]}} & 
				mem[rd_addr[i*RAW+:RAW]];
   
endmodule // oh_regfile




