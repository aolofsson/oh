module oh_memory_sp(/*AUTOARG*/
   // Outputs
   dout,
   // Inputs
   clk, en, we, wem, addr, din, vdd, vddm, sleep, shutdown, repair,
   bist_en, bist_we, bist_wem, bist_addr, bist_din
   );

   // parameters
   parameter  DW      = 32;             // memory width
   parameter  DEPTH   = 14;             // memory depth
   parameter  RW      = 32;             // repair vector width
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

   // Power/repai interface (ASICs only)
   input 	       vdd;        // periphery power rail
   input 	       vddm;       // array power rail     
   input 	       sleep;      // sleep (content retained)
   input 	       shutdown;   // shutdown (no retention)
   input [RW-1:0]      repair;     // "wildcard" repair vector   

   // BIST interface (ASICs only)
   input 	       bist_en;   // bist enable
   input 	       bist_we;   // write enable global signal   
   input [DW-1:0]      bist_wem;  // write enable vector
   input [AW-1:0]      bist_addr; // address
   input [DW-1:0]      bist_din;  // data input
   
`ifdef CFG_ASIC

   //Actual IP hidden behind wrapper to protect the innocent

   sram_sp #(.DW(DW).
	     .DEPTH(DEPTH),
	     .PROJ(PROJ),
	     .RW(RW))	     

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
	    .sleep			(sleep),
	    .shutdown			(shutdown),
	    .cfg_repair			(cfg_repair[RW-1:0]),
	    .bist_en			(bist_en),
	    .bist_we			(bist_we),
	    .bist_wem			(bist_wem[DW-1:0]),
	    .bist_addr			(bist_addr[AW-1:0]),
	    .bist_din			(bist_din[DW-1:0]));
   
`else

   //Assume FPGA tool knows what it's doing (single clock...)
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



  
     

