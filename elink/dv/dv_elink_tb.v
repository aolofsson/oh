module dv_elink_tb();
   parameter AW=32;
   parameter DW=32;
   parameter PW=104;
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
   reg 		 ext_write;
   reg [1:0] 	 ext_datamode;
   reg [3:0]     ext_ctrlmode;            
   reg [31:0]    ext_dstaddr;
   reg [31:0]    ext_data;
   reg [31:0]    ext_srcaddr;   
   reg           ext_wr_wait;
   reg           ext_rd_wait;
   wire [PW-1:0] ext_packet;

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
     #50 clk[1] = ~clk[1];//clock for axi interface
                           //should make variable to really test all fifos

   wire clkstim = clk[1];
      
   //Reset
   initial
     begin
	#0
	  reset    = 1'b1;    // reset is active
          go       = 1'b0;
	  clk[1:0] = 2'b0;
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
	#4000
	  go       = 1'b1;	
	#10000
`ifdef AUTO
	  go       = 1'b0;
`endif
	#20000	  
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
  else if (go & ~(dut_wr_wait|dut_rd_wait))
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
       ext_access          <=  |(transaction[103:0]);
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
   wire			dut_failed;		// From dv_elink of dv_elink.v
   wire [PW-1:0]	dut_packet;		// From dv_elink of dv_elink.v
   wire			dut_passed;		// From dv_elink of dv_elink.v
   wire			dut_rd_wait;		// From dv_elink of dv_elink.v
   wire			dut_wr_wait;		// From dv_elink of dv_elink.v
   wire [PW-1:0]	packet_out;		// From e2p of emesh2packet.v
   // End of automatics
   
   emesh2packet e2p (/*AUTOINST*/
		     // Outputs
		     .packet_out	(ext_packet[PW-1:0]),
		     // Inputs
		     .access_in		(ext_access),
		     .write_in		(ext_write),
		     .datamode_in	(ext_datamode[1:0]),
		     .ctrlmode_in	(ext_ctrlmode[3:0]),
		     .dstaddr_in	(ext_dstaddr[AW-1:0]),
		     .data_in		(ext_data[DW-1:0]),
		     .srcaddr_in	(ext_srcaddr[AW-1:0]));
   
   
   //dut
   dv_elink dv_elink(/*AUTOINST*/
		     // Outputs
		     .dut_passed	(dut_passed),
		     .dut_failed	(dut_failed),
		     .dut_rd_wait	(dut_rd_wait),
		     .dut_wr_wait	(dut_wr_wait),
		     .dut_access	(dut_access),
		     .dut_packet	(dut_packet[PW-1:0]),
		     // Inputs
		     .clk		(clk[CW-1:0]),
		     .reset		(reset),
		     .ext_access	(ext_access),
		     .ext_packet	(ext_packet[PW-1:0]),
		     .ext_rd_wait	(ext_rd_wait),
		     .ext_wr_wait	(ext_wr_wait));
  
endmodule // dv_elink_tb
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:


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
