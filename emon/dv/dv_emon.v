//`timescale 1 ns / 100 ps
module dv_emon();

   parameter DW = 32;
   
   
   //Stimulus to drive
   reg        clk;
   reg        reset;
   reg        mi_access;
   reg [5:0]  mi_addr;
   reg [31:0] mi_data_in;
   reg 	      mi_write;
   reg [1:0]  test_state;
   reg 	      go;
   reg		erx_rdfifo_access;	// To emon of emon.v
   reg		erx_rdfifo_wait;	// To emon of emon.v
   reg		erx_wbfifo_access;	// To emon of emon.v
   reg		erx_wbfifo_wait;	// To emon of emon.v
   reg		erx_wrfifo_access;	// To emon of emon.v
   reg		erx_wrfifo_wait;	// To emon of emon.v
   reg		etx_rdfifo_access;	// To emon of emon.v
   reg		etx_rdfifo_wait;	// To emon of emon.v
   reg		etx_wbfifo_access;	// To emon of emon.v
   reg		etx_wbfifo_wait;	// To emon of emon.v
   reg		etx_wrfifo_access;	// To emon of emon.v
   reg		etx_wrfifo_wait;	// To emon of emon.v

   //Reset
   initial
     begin
	$display($time, " << Starting the Simulation >>");	
	#0
        clk                = 1'b0;    // at time 0
	reset              = 1'b1;    // reset is active
	mi_write           = 1'b0;
	mi_access          = 1'b0;
	mi_addr[5:0]       = 6'h9;
	mi_data_in[31:0]   = 32'h0;
	test_state[1:0]    = 2'b00;
	go                 = 1'b0;	
	erx_rdfifo_access  = 1'b1;
	erx_rdfifo_wait    = 1'b1;
	erx_wbfifo_access  = 1'b1;
	erx_wbfifo_wait    = 1'b1;
	erx_wrfifo_access  = 1'b1;
	erx_wrfifo_wait    = 1'b1;
	etx_rdfifo_access  = 1'b1;
	etx_rdfifo_wait    = 1'b1;
	etx_wbfifo_access  = 1'b1;
	etx_wbfifo_wait    = 1'b1;
	etx_wrfifo_access  = 1'b1;
	etx_wrfifo_wait    = 1'b1;
	#100 
	  reset    = 1'b0;    // at time 100 release reset
	#100
	  go       = 1'b1;	
	#10000	  
	  $finish;
     end

   //Clock
   always
     #10 clk = ~clk;

   //Pattern generator
   //1.) Write in 8 transactions (split into low and high)
   //2.) Read back 8 transactions (split into low and high)
      
   always @ (negedge clk)
     if(go)
       begin
	  case(test_state[1:0])
	    2'b00://write
	      if(~done)
		begin
		   mi_access        <= 1'b1;
		   mi_write         <= 1'b1;
		   mi_addr[5:0]     <= 6'h07;	  
		   mi_data_in[31:0] <= 32'h8_7_6_5_4_3_2_1;
		   test_state       <= 2'b01;
		end
	    2'b01://init array
	      if(~done)
		begin	    
		   mi_write         <= 1'b1;
		   mi_access        <= 1'b1;
		   mi_addr[5:0]     <= mi_addr[5:0]+1'b1;
		   mi_data_in[31:0] <= mi_data_in[31:0]-4'h8;		   
		end
	      else
		begin
		   test_state       <= 2'b10;
		   mi_write         <= 1'b0;
		end // else: !if(~done)
	    2'b10://init array
	      begin
		 mi_addr[5:0]     <= mi_addr[5:0]-1'b1;
	      end
	    
	  endcase // case (test_state[1:0])
       end

   wire done =  (mi_addr[5:0]==6'b001101);

  
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [5:0]		emon_zero_flag;		// From emon of emon.v
   wire [DW-1:0]	mi_data_out;		// From emon of emon.v
   // End of automatics
   /*AUTOWIRE*/
   
   //DUT
   emon emon(
	     /*AUTOINST*/
	     // Outputs
	     .mi_data_out		(mi_data_out[DW-1:0]),
	     .emon_zero_flag		(emon_zero_flag[5:0]),
	     // Inputs
	     .clk			(clk),
	     .reset			(reset),
	     .mi_access			(mi_access),
	     .mi_write			(mi_write),
	     .mi_addr			(mi_addr[5:0]),
	     .mi_data_in		(mi_data_in[DW-1:0]),
	     .erx_rdfifo_access		(erx_rdfifo_access),
	     .erx_rdfifo_wait		(erx_rdfifo_wait),
	     .erx_wrfifo_access		(erx_wrfifo_access),
	     .erx_wrfifo_wait		(erx_wrfifo_wait),
	     .erx_wbfifo_access		(erx_wbfifo_access),
	     .erx_wbfifo_wait		(erx_wbfifo_wait),
	     .etx_rdfifo_access		(etx_rdfifo_access),
	     .etx_rdfifo_wait		(etx_rdfifo_wait),
	     .etx_wrfifo_access		(etx_wrfifo_access),
	     .etx_wrfifo_wait		(etx_wrfifo_wait),
	     .etx_wbfifo_access		(etx_wbfifo_access),
	     .etx_wbfifo_wait		(etx_wbfifo_wait));


   //Waveform dump
   initial
     begin
	$dumpfile("test.vcd");
	$dumpvars(0, dv_emon);
     end

   
endmodule // dv_embox

