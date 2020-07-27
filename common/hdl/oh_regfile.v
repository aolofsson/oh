//#############################################################################
//# Function: Parametrized register file                                      #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_regfile # (parameter REGS  = 32,         // number of registeres
		     parameter RW    = 64,         // register width
		     parameter RP    = 5,          // read ports
		     parameter WP    = 3,          // write prots
		     parameter RAW   = $clog2(REGS)// (derived) rf addr width
		     ) 
   (//Control inputs
    input 	       clk,
    // Write Ports (concatenated)
    input [WP-1:0]     wr_valid, // write access
    input [WP*RAW-1:0] wr_addr, // register address
    input [WP*RW-1:0]  wr_data, // write data
    // Read Ports (concatenated)   
    input [RP-1:0]     rd_valid, // read access
    input [RP*RAW-1:0] rd_addr, // register address
    output [RP*RW-1:0] rd_data // output data
    );

   
   reg [RW-1:0]  mem [0:REGS-1];
   wire [WP-1:0] write_en [0:REGS-1];

   genvar 	 i,j;

   //TODO: Make an array of cells
   
   //#########################################
   // write ports
   //#########################################	

   //Write Select lines
   for(i=0;i<REGS;i=i+1)
     for(j=0;j<WP;j=j+1)
       assign write_en[i][j] = wr_valid[j] & (wr_addr[j*RAW+:RAW] == i);

   //Memory array
   for(i=0;i<REGS;i=i+1)
     for(j=0;j<WP;j=j+1)
       always @ (posedge clk)
	 if (write_en[i][j])
	   mem[i] <= wr_data[j*RW+:RW];

   //#########################################
   // read ports
   //#########################################	
   
   for (i=0;i<RP;i=i+1)
     assign rd_data[i*RW+:RW] = {(RW){rd_valid[i]}} & 
				mem[rd_addr[i*RAW+:RAW]];
   
endmodule // oh_regfile




