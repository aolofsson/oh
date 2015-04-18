module dv_elink_tb();
   parameter AW=32;
   parameter DW=32;
   parameter CW=2;    //number of clocks to send int
   parameter MW=104;
   parameter MAW=10;    
   parameter MD=1<<MAW;//limit test to 1K transactions
   //TODO:generealize
   

/* verilator lint_off STMTDLY */
/* verilator lint_off UNOPTFLAT */
   //REGS
   reg  [1:0]    clk;   
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
   reg [MW-1:0]  stimarray[MD-1:0];
   reg [MW-1:0]  transaction;
   reg [MAW-1:0] stim_addr;

   integer 	 i;
   
`ifdef MANUAL   
   //TODO: make test name a parameter, fancify,...   
   initial
     begin
	for(i=0;i<MD;i++)
	  stimarray[i]='d0;
	//$readmemh(`TESTNAME,stimarray,0,`TRANS-1);//How to?
	$readmemh("test.memh",stimarray,0,`TRANS-1);
     end
`endif

   //Forever clock
   always
     #1  clk[0] = ~clk[0];//clock for elink
    always
     #10 clk[1] = ~clk[1];//clock for axi interface
                           //should make variable to really test all fifos

   wire clkstim = clk[1];
      
   //Reset
   initial
     begin
	#0
	  reset    = 1'b1;    // reset is active
          go       = 1'b0;
	  clk[1:0] = 2'b0;
	  datamode = 2'b10;	
	#400 

`ifdef AUTO
          //clock config (fast /2)
          dv_elink.elink.ecfg.ecfg_clk_reg[15:0] = 16'h0113;
          //tx config  (enable)
   	  dv_elink.elink.ecfg.ecfg_tx_reg[8:0]   = 9'h001;
          //rx config (enable)
	  dv_elink.elink.ecfg.ecfg_rx_reg[4:0]   = 5'h01;
`endif
	  reset    = 1'b0;    // at time 100 release reset
	#1000
	  go       = 1'b1;	
	#2000
`ifdef AUTO
	  go       = 1'b0;
`endif
	#10000	  
	  $finish;
     end

   //Notes:The testbench connects a 64 bit master to a 32 bit slave
   //To make this work, we limit the addresses to 64 bit aligned
   
   
always @ (posedge clkstim)
  if(reset | ~go)
    begin
       ext_access          <= 1'b0; //empty
       ext_write           <= 1'b0;
       ext_datamode[1:0]   <= 2'b0;
       ext_ctrlmode[3:0]   <= 4'b0;
       ext_data[31:0]      <= 32'b0;
       ext_dstaddr[31:0]   <= 32'b0;
       ext_srcaddr[31:0]   <= 32'b0;
       ext_rd_wait         <= 1'b0;
       ext_wr_wait         <= 1'b0;
       stim_addr[MAW-1:0]  <= 'd0;
       transaction[MW-1:0] <= 'd0;
    end   
  else if (go & ~dut_wr_wait)
    //else if ((go & ~ext_access) | (go & ext_access & ~dut_wr_wait))    
    begin
`ifdef MANUAL
       transaction[MW-1:0] <= stimarray[stim_addr];
       ext_access          <= transaction[0];
       ext_write           <= transaction[1];
       ext_datamode[1:0]   <= transaction[3:2];
       ext_ctrlmode[3:0]   <= transaction[7:4];
       ext_dstaddr[31:0]   <= transaction[39:8];
       ext_data[31:0]      <= transaction[71:40];
       ext_srcaddr[31:0]   <= transaction[103:72];
       stim_addr[MAW-1:0]  <= stim_addr[MAW-1:0] + 1'b1; 
`else
       ext_access          <=  1'b1;
       ext_data[31:0]      <=  ext_data[31:0]    + 32'b1;
       ext_dstaddr[31:0]   <=  ext_dstaddr[31:0] + 32'd8;//(32'b1<<datamode)
       ext_datamode[1:0]   <=  datamode[1:0];       
`endif 
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
		     .dut_rd_wait	(dut_rd_wait),
		     .dut_wr_wait	(dut_wr_wait),
		     .dut_access	(dut_access),
		     .dut_write		(dut_write),
		     .dut_datamode	(dut_datamode[1:0]),
		     .dut_ctrlmode	(dut_ctrlmode[3:0]),
		     .dut_dstaddr	(dut_dstaddr[31:0]),
		     .dut_srcaddr	(dut_srcaddr[31:0]),
		     .dut_data		(dut_data[31:0]),
		     // Inputs
		     .clk		(clk[CW-1:0]),
		     .reset		(reset),
		     .ext_access	(ext_access),
		     .ext_write		(ext_write),
		     .ext_datamode	(ext_datamode[1:0]),
		     .ext_ctrlmode	(ext_ctrlmode[3:0]),
		     .ext_dstaddr	(ext_dstaddr[31:0]),
		     .ext_data		(ext_data[31:0]),
		     .ext_srcaddr	(ext_srcaddr[31:0]),
		     .ext_rd_wait	(ext_rd_wait),
		     .ext_wr_wait	(ext_wr_wait));
  
endmodule // dv_elink_tb


/*
 Copyright (C) 2014 Adapteva, Inc. 
 Contributed by Andreas Olofsson <andreas@adapteva.com>

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.This program is distributed in the hope 
 that it will be useful,but WITHOUT ANY WARRANTY; without even the implied 
 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details. You should have received a copy 
 of the GNU General Public License along with this program (see the file 
 COPYING).  If not, see <http://www.gnu.org/licenses/>.
 */
