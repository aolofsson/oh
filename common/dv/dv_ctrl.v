`timescale 1ns/1ps
module dv_ctrl(/*AUTOARG*/
   // Outputs
   nreset, clk, start,
   // Inputs
   dut_active, stim_done, test_done
   );

   parameter CLK_PERIOD = 10;
   parameter CLK_PHASE  = CLK_PERIOD/2;
   parameter TIMEOUT    = 10000;

   output nreset;     // async active low reset
   output clk;        // main clock
   output start;      // start test (level)

   input  dut_active; // reset sequence is done
   input  stim_done;  //stimulus is done  
   input  test_done;  //test is done
   
   //signal declarations
   reg 	  nreset = 1'b0;
   reg 	  clk    = 1'b0;
   reg 	  start;
   
   //init
   initial
     begin	
	#(CLK_PERIOD*20)   //hold reset for 20 cycles
	  nreset   = 'b1;
     end

   always @ (posedge clk or negedge nreset)
     if(!nreset)
       start = 1'b0;
     else if(dut_active)       
       start = 1'b1;

   always @ (posedge clk)
     if(stim_done & test_done)       
       #(TIMEOUT) $finish;	  
   
	   
   //Clock generator
   always
     #(CLK_PHASE) clk = ~clk;
   
   //Waveform dump
   //Better solution?
`ifdef NOVCD
`else
   initial
     begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, dv_top);
     end
`endif
               
endmodule // dv_ctrl



