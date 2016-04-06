module oh_memory_sp(/*AUTOARG*/
   // Outputs
   dout,
   // Inputs
   clk, en, we, wem, addr, din, vss, vdd, vddm, shutdown, memconfig,
   memrepair, bist_en, bist_we, bist_wem, bist_addr, bist_din
   );

   // parameters
   parameter  DW      = 32;             // memory width
   parameter  DEPTH   = 14;             // memory depth
   parameter  MCW     = 8;              // repair/config vector width
   parameter  PROJ    = "";             // project name (used for IP selection)
   localparam AW      = $clog2(DEPTH);  // address bus width  
 
   // standard memory interface 
   input               clk;        // clock
   input               en;         // memory access   
   input 	       we;         // write enable global signal   
   input [DW-1:0]      wem;        // write enable vector
   input [AW-1:0]      addr;       // address
   input [DW-1:0]      din;        // data input
   output [DW-1:0]     dout;       // data output

   // Power/repair interface (ASICs only)
   input 	       vss;        // common ground   
   input 	       vdd;        // periphery power rail
   input 	       vddm;       // array power rail
   input 	       shutdown;   // shutdown signal from always on domain   
   input [MCW-1:0]     memconfig;  // generic memory config      
   input [MCW-1:0]     memrepair;  // repair vector   

   // BIST interface (ASICs only)
   input 	       bist_en;   // bist enable
   input 	       bist_we;   // write enable global signal   
   input [DW-1:0]      bist_wem;  // write enable vector
   input [AW-1:0]      bist_addr; // address
   input [DW-1:0]      bist_din;  // data input
   
`ifdef CFG_ASIC

   //Actual IP hidden behind wrapper to protect the innocent

   sram_sp #(.DW(DW),
	     .DEPTH(DEPTH),
	     .PROJ(PROJ),
	     .MCW(MCW))	     
   sram_sp (// Outputs
	    .dout			(dout[DW-1:0]),
	    // Inputs
	    .clk			(clk),
	    .en				(en),
	    .we				(we),
	    .wem			(wem[DW-1:0]),
	    .addr			(addr[AW-1:0]),
	    .din			(din[DW-1:0]),
	    .vdd			(vdd),
	    .vddm			(vddm),
	    .vss                        (vss),
	    .shutdown                   (shutdown),
	    .memconfig			(memconfig[MCW-1:0]),
	    .memrepair			(memrepair[MCW-1:0]),
	    .bist_en			(bist_en),
	    .bist_we			(bist_we),
	    .bist_wem			(bist_wem[DW-1:0]),
	    .bist_addr			(bist_addr[AW-1:0]),
	    .bist_din			(bist_din[DW-1:0]));
   
`else

   //Assume FPGA tool knows what it's doing (single clock...)
   //Note: shutdown not modeleled properly, should invalidate all entries
   //Retention should depend on vdd as well

   reg [DW-1:0]        ram    [DEPTH-1:0];  
   reg [DW-1:0]        dout;
   integer 	       i;
   
   //read port (one cycle latency)
   always @ (posedge clk)
     if(en)       
       dout[DW-1:0] <= ram[addr[AW-1:0]];

   //write port
   always @ (posedge clk)
     for(i=0;i<DW;i=i+1)	   
       if(en & wem[i] & we)	       
 	 ram[addr[AW-1:0]][i] <= din[i]; 
`endif
  
endmodule // oh_memory_sp



  
     

