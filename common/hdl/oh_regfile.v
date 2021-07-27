//#############################################################################
//# Function: Parametrized register file                                      #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module oh_regfile
  # (parameter REGS  = 8,          // number of registeres
     parameter RW    = 16,         // register width
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


   reg [RW-1:0]        mem[0:REGS-1];
   wire [WP-1:0]       write_en [0:REGS-1];
   wire [RW-1:0]       datamux [0:REGS-1];

   genvar 	       i,j;

   //TODO: Make an array of cells

   //#########################################
   // write ports
   //#########################################

   //One hote write enables
   for(i=0;i<REGS;i=i+1)
     begin: gen_regwrite
	for(j=0;j<WP;j=j+1)
	  begin: gen_wp
	     assign write_en[i][j] = wr_valid[j] & (wr_addr[j*RAW+:RAW] == i);
	  end
     end

   //Multi Write-Port Mux
   for(i=0;i<REGS;i=i+1)
     begin: gen_wrmux
	oh_mux #(.N(RW), .M(WP))
	iwrmux(.out (datamux[i][RW-1:0]),
	       .sel (write_en[i][WP-1:0]),
	       .in  (wr_data[WP*RW-1:0]));
     end

   //Memory Array Write
   for(i=0;i<REGS;i=i+1)
     begin: gen_reg
	always @ (posedge clk)
	  if (|write_en[i][WP-1:0])
	    mem[i] <= datamux[i];
end


   //#########################################
   // read ports
   //#########################################

   for (i=0;i<RP;i=i+1) begin: gen_rdport
      assign rd_data[i*RW+:RW] = {(RW){rd_valid[i]}} &
				mem[rd_addr[i*RAW+:RAW]];
   end

endmodule // oh_regfile
