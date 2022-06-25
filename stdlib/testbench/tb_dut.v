//#############################################################################
//# Function: DUT wrapper template/stub
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        #
//#############################################################################

module tb_dut
  #(parameter PW              = 256,      // packet width
    parameter N               = 36,       // ctrl/status width
    parameter TARGET          = "DEFAULT" // physical synthesis/sim target
    )
   (// basic test interface
    input 	    clk, // standard clock used for interface
    input 	    fastclk, // fast clock (optional for core)
    input 	    slowclk, // fast clock (optional for core)
    input 	    nreset, // async active low reset
    input 	    go, // go dut (if not self-booting)
    input [N-1:0]   ctrl, // env generic ctrl vector
    // environment packet interface
    input 	    valid, // env packet valid signal
    input [PW-1:0]  packet, // env packet to drive
    input 	    ready, // env is ready for packet
    // dut status signals
    output 	    dut_active, // dut reset sequence done
    output 	    dut_error, // per cycle error signal
    output 	    dut_done, // dut is done
    output [N-1:0]  dut_status, // dut generic status vector
    // dut response packets
    output 	    dut_valid, //dut packet valid signal
    output [PW-1:0] dut_packet, // dut packet to drive
    output 	    dut_ready // dut is ready for packet
    );

endmodule // tb_dut
