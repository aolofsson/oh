module dv_ctrl(/*AUTOARG*/
   // Outputs
   nreset, clk, start,
   // Inputs
   stim_done, test_done
   );
 
   parameter N          = 5000;

   input        nreset;  // async active low reset
   input        clk;     // main clock
   input [15:0] 
   
   output [N-1:0] stim_done; //stimulus is done  
   input 	  test_done; //test is done
   
   //signal declarations
   reg 	  nreset = 1'b0;
   reg 	  clk    = 1'b0;
   reg 	  start  = 1'b0;

   //init
   initial
     begin	
	#(CLK_PERIOD*10)
	  nreset   = 'b1;
	#(CLK_PERIOD*100)
	  start  = 'b1;
     end


   //finish circuitry
   always @*
     if(stim_done & test_done)
       begin
	  #(TIMEOUT) $finish;	  
       end
	   
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
   
endmodule // dv_init

