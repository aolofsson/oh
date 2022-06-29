//#############################################################################
//# Function: Stub testbench                                                  #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################
`timescale 1ns / 1ns
module testbench
  #(parameter PW             = 256,         // packet total width
    parameter CW             = 16,          // packet control width
    parameter N              = 32,          // ctrl/status width
    parameter DEPTH          = 8192,        // simulus memory depth
    parameter TARGET         = "DEFAULT"    // physical synthesis/sim target
    )
   (
    // control signals to drive
    input 	    nreset, // async active low reset
    input 	    clk, // core clock
    input 	    fastclk, // fast clock
    input 	    slowclk, //slow clock
    input [2:0]     mode, //0=idle,1=load,2=go,3=rng,4=bypass
    input [N-1:0]   ctrl, // generic ctrl vector
    input [N-1:0]  seed, // seed(s) for rng
    // external write interface
    input 	    ext_clk, //ext packet clock
    input 	    ext_valid, // ext valid signal
    input [PW-1:0]  ext_packet, // ext packet
    input 	    ext_ready, // external ready to receive
    // dut response packets
    output 	    dut_clk, // due packet clock
    output 	    dut_valid, //dut packet valid signal
    output [PW-1:0] dut_packet, // dut packet to drive
    output 	    dut_ready, // dut is ready for packet
    // dut status interface
    output [N-1:0]  dut_status, // generic status vector
    output 	    dut_error,// dut error flag (leads to failure)
    output 	    dut_done, // test done
    output 	    dut_fail  // test failed
    );

endmodule // testbench
