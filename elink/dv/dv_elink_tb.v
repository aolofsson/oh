module dv_elink_tb();

/* verilator lint_off STMTDLY */

   //REGS
   reg           clk;   
   reg 		 reset;   
   reg 		 go;
   reg [1:0] 	 datamode;
   reg 		 ext_access;
   reg           ext_write;
   reg [1:0]     ext_datamode;
   reg [3:0]     ext_ctrlmode;            
   reg [31:0]    ext_dstaddr;
   reg [31:0]    ext_data;
   reg [31:0]    ext_srcaddr;   
   reg           ext_wr_wait;
   reg           ext_rd_wait;
   reg 		 init;
   
   //Forever clock
   always
     #10 clk = ~clk;
   
   //Reset
   initial
     begin
	#0
	  reset    = 1'b1;    // reset is active
          go       = 1'b0;
	  clk      = 1'b0;
	  datamode = 2'b11;	
	#400 
          //Setting config clocks to higher value to speed sims
          dv_elink.elink.ecfg.ecfg_clk_reg[15:0]=16'h0066;	
	  reset    = 1'b0;    // at time 100 release reset
	#1000
          
	  go       = 1'b1;
	#2000
	  datamode = 2'b10;
	#3000
	  datamode = 2'b01;
	#4000
	  datamode = 2'b00;
	#10000	  
	  $finish;
     end

   //Notes:The testbench connects a 64 bit master to a 32 bit slave
   //To make this work, we limit the addresses to 64 bit aligned
   
   
always @ (posedge clk)
  if(reset)
    begin
       ext_access        <=1'b0; //empty
       ext_write         <=1'b1;
       ext_datamode[1:0] <=2'b0;
       ext_ctrlmode[3:0] <=4'b0;
       ext_data[31:0]    <=32'b0;
       ext_dstaddr[31:0] <=32'b0;
       ext_srcaddr[31:0] <=32'b0;
       ext_rd_wait       <=1'b0;
       ext_wr_wait       <=1'b0;
    end   
  else if ((go & ~ext_access) | (ext_access & ~dut_wr_wait))
    begin
       ext_access        <=  1'b1;
       ext_data[31:0]    <=  ext_data[31:0]    + 32'b1;
       ext_dstaddr[31:0] <=  ext_dstaddr[31:0] + 32'd8;//(32'b1<<datamode)
       ext_srcaddr[31:0] <=  ext_srcaddr[31:0] + 32'd8;//(32'b1<<datamode)
       ext_datamode[1:0] <=  datamode[1:0];
    end
   
   //Waveform dump
`ifndef TARGET_VERILATOR
   initial
     begin
	$dumpfile("test.vcd");
	$dumpvars(0, dv_elink_tb);
     end
`endif
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			dut_access;		// From dv_elink of dv_elink.v
   wire [3:0]		dut_ctrlmode;		// From dv_elink of dv_elink.v
   wire [31:0]		dut_data;		// From dv_elink of dv_elink.v
   wire [1:0]		dut_datamode;		// From dv_elink of dv_elink.v
   wire [31:0]		dut_dstaddr;		// From dv_elink of dv_elink.v
   wire			dut_failed;		// From dv_elink of dv_elink.v
   wire			dut_passed;		// From dv_elink of dv_elink.v
   wire			dut_rd_wait;		// From dv_elink of dv_elink.v
   wire [31:0]		dut_srcaddr;		// From dv_elink of dv_elink.v
   wire			dut_wr_wait;		// From dv_elink of dv_elink.v
   wire			dut_write;		// From dv_elink of dv_elink.v
   // End of automatics
   
   //dut
   dv_elink dv_elink(/*AUTOINST*/
		     // Outputs
		     .dut_passed	(dut_passed),
		     .dut_failed	(dut_failed),
		     .dut_wr_wait	(dut_wr_wait),
		     .dut_rd_wait	(dut_rd_wait),
		     .dut_access	(dut_access),
		     .dut_write		(dut_write),
		     .dut_datamode	(dut_datamode[1:0]),
		     .dut_ctrlmode	(dut_ctrlmode[3:0]),
		     .dut_dstaddr	(dut_dstaddr[31:0]),
		     .dut_srcaddr	(dut_srcaddr[31:0]),
		     .dut_data		(dut_data[31:0]),
		     // Inputs
		     .clk		(clk),
		     .reset		(reset),
		     .ext_access	(ext_access),
		     .ext_write		(ext_write),
		     .ext_datamode	(ext_datamode[1:0]),
		     .ext_ctrlmode	(ext_ctrlmode[3:0]),
		     .ext_dstaddr	(ext_dstaddr[31:0]),
		     .ext_data		(ext_data[31:0]),
		     .ext_srcaddr	(ext_srcaddr[31:0]),
		     .ext_wr_wait	(ext_wr_wait),
		     .ext_rd_wait	(ext_rd_wait));
  
endmodule // dv_elink_tb


