//`timescale 1 ns / 100 ps
module dv_embox();

   parameter DW = 32;
   
   
   //Stimulus to drive
   reg        clk;
   reg        reset;
   reg        mi_access;
   reg [19:0]  mi_addr;
   reg [31:0] mi_data_in;
   reg 	      mi_write;
   reg [1:0]  test_state;
   reg 	      go;
   
   //Reset
   initial
     begin
	$display($time, " << Starting the Simulation >>");	
	#0
        clk              = 1'b0;    // at time 0
	reset            = 1'b1;    // reset is active
	mi_write         = 1'b0;
	mi_access        = 1'b0;
	mi_addr[19:0]    = 20'hf0368;
	mi_data_in[31:0] = 32'h0;
	test_state[1:0]  = 2'b00;
	go               = 1'b0;	
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
		   mi_addr[19:0]    <= mi_addr[19:0] ^ 20'hc;	  
		   mi_data_in[31:0] <= mi_data_in[31:0]+1'b1;
		end
	      else
		begin
		   test_state       <= 2'b01;	    
		   mi_addr[19:0]    <= 20'hf0368;
		   mi_data_in[31:0] <= 32'h0;		   
		end
	    2'b01://read
	      if(~done)
		begin	    
		   mi_write         <= 1'b0;
		   mi_access        <= 1'b1;
		   mi_addr[19:0]    <= mi_addr[19:0] ^ 20'hc;
		   mi_data_in[31:0] <= mi_data_in[31:0]+1'b1;
		end
	      else
		begin
		   test_state       <= 2'b10;
		   mi_write         <= 1'b0;
		   mi_access        <= 1'b0;
		end
	  endcase // case (test_state[1:0])
       end

   wire done =  (mi_data_in[19:0]==20'h8);
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			embox_empty;		// From embox of embox.v
   wire			embox_full;		// From embox of embox.v
   wire [DW-1:0]	mi_data_out;		// From embox of embox.v
   // End of automatics
   
   //DUT
   embox embox(
	     /*AUTOINST*/
	       // Outputs
	       .mi_data_out		(mi_data_out[DW-1:0]),
	       .embox_full		(embox_full),
	       .embox_empty		(embox_empty),
	       // Inputs
	       .reset			(reset),
	       .clk			(clk),
	       .mi_access		(mi_access),
	       .mi_write		(mi_write),
	       .mi_addr			(mi_addr[19:0]),
	       .mi_data_in		(mi_data_in[DW-1:0]));


   //Waveform dump
   initial
     begin
	$dumpfile("test.vcd");
	$dumpvars(0, dv_embox);
     end

   
endmodule // dv_embox
// Local Variables:
// verilog-library-directories:("." "../hdl" "../../memory/hdl ")
// End:


