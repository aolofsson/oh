module dv_emmu_tb;

   reg clk;
   
   reg reset;
   
   reg 	      go;

   //Clock
   always
     #10 clk = ~clk;
   
   initial
     begin
	$display($time, " << Starting the Simulation >>");
	#0
        clk                    = 1'b0;    // at time 0
	reset                  = 1'b1;    // reset is active
	#100 
	  reset    = 1'b0;    // at time 100 release reset
	#100
	  go       = 1'b1;	
	#10000	  
	  $finish;
     end	

   //Waveform dump
   initial
     begin
	$dumpfile("test.vcd");
	$dumpvars(0, dv_emmu);
     end


dv_emmu dv_emmu
  (.clk (clk),
   .reset (reset),
   .go (go));
endmodule
