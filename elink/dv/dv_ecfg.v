//`timescale 1 ns / 100 ps
module dv_ecfg();

   //Stimulus to drive
   reg        clk;
   reg        reset;
   reg        mi_access;
   reg [19:0]  mi_addr;
   reg [31:0] mi_data_in;
   reg 	      mi_write;
   reg [1:0]  test_state;
   
   //Reset
   initial
     begin
	$display($time, " << Starting the Simulation >>");	
	#0
        clk              = 1'b0;    // at time 0
	reset            = 1'b1;    // reset is active
	mi_write         = 1'b0;
	mi_access        = 1'b0;
	mi_addr[19:0]    = 20'hf0340;
	mi_data_in[31:0] = 32'h0;
	test_state[1:0]  = 2'b00;
	#100 
	reset    = 1'b0;    // at time 100 release reset
	#100
	mi_write   = 1'b1;
	mi_access  = 1'b1;
	#10000	  
	  $finish;
     end
   
   //Clock
   always
     #10 clk = ~clk;

   //Pattern generator
   always @ (posedge clk)
     if(mi_access)
       case(test_state[1:0])
	 2'b00:
	   if(~done)
	     begin
		mi_addr[19:0]    <= mi_addr[19:0]+20'h4;
		mi_data_in[5:0] <= mi_data_in[5:0]+1'b1;
	     end
	   else
	     begin
		test_state      <= 2'b01;	    
		mi_addr[19:0]   <= 20'hf0340;
		mi_write        <= 1'b0;
	     end
	 2'b01:
	   if(~done)
	     begin
		mi_addr[19:0]    <= mi_addr[19:0]+20'h4;
		mi_data_in[5:0]  <= 32'hffffffff;
	     end
	   else
	     test_state <= 2'b01;	    
       endcase// case (test_state[1:0])
   
   wire done =  (mi_addr[19:0]==20'hf0360);
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [3:0]		ecfg_cclk_div;		// From ecfg of ecfg.v
   wire			ecfg_cclk_en;		// From ecfg of ecfg.v
   wire [3:0]		ecfg_cclk_pllcfg;	// From ecfg of ecfg.v
   wire [11:0]		ecfg_coreid;		// From ecfg of ecfg.v
   wire [11:0]		ecfg_dataout;		// From ecfg of ecfg.v
   wire			ecfg_rx_enable;		// From ecfg of ecfg.v
   wire			ecfg_rx_gpio_mode;	// From ecfg of ecfg.v
   wire			ecfg_rx_loopback_mode;	// From ecfg of ecfg.v
   wire			ecfg_rx_mmu_mode;	// From ecfg of ecfg.v
   wire			ecfg_sw_reset;		// From ecfg of ecfg.v
   wire [3:0]		ecfg_tx_clkdiv;		// From ecfg of ecfg.v
   wire [3:0]		ecfg_tx_ctrl_mode;	// From ecfg of ecfg.v
   wire			ecfg_tx_enable;		// From ecfg of ecfg.v
   wire			ecfg_tx_gpio_mode;	// From ecfg of ecfg.v
   wire			ecfg_tx_mmu_mode;	// From ecfg of ecfg.v
   wire [31:0]		mi_data_out;		// From ecfg of ecfg.v
   // End of automatics
   
   //DUT
   ecfg ecfg(.param_coreid		(12'h808),
	     /*AUTOINST*/
	     // Outputs
	     .mi_data_out		(mi_data_out[31:0]),
	     .ecfg_sw_reset		(ecfg_sw_reset),
	     .ecfg_tx_enable		(ecfg_tx_enable),
	     .ecfg_tx_mmu_mode		(ecfg_tx_mmu_mode),
	     .ecfg_tx_gpio_mode		(ecfg_tx_gpio_mode),
	     .ecfg_tx_ctrl_mode		(ecfg_tx_ctrl_mode[3:0]),
	     .ecfg_tx_clkdiv		(ecfg_tx_clkdiv[3:0]),
	     .ecfg_rx_enable		(ecfg_rx_enable),
	     .ecfg_rx_mmu_mode		(ecfg_rx_mmu_mode),
	     .ecfg_rx_gpio_mode		(ecfg_rx_gpio_mode),
	     .ecfg_rx_loopback_mode	(ecfg_rx_loopback_mode),
	     .ecfg_cclk_en		(ecfg_cclk_en),
	     .ecfg_cclk_div		(ecfg_cclk_div[3:0]),
	     .ecfg_cclk_pllcfg		(ecfg_cclk_pllcfg[3:0]),
	     .ecfg_coreid		(ecfg_coreid[11:0]),
	     .ecfg_dataout		(ecfg_dataout[11:0]),
	     // Inputs
	     .clk			(clk),
	     .reset			(reset),
	     .mi_access			(mi_access),
	     .mi_write			(mi_write),
	     .mi_addr			(mi_addr[19:0]),
	     .mi_data_in		(mi_data_in[31:0]));


   //Waveform dump
   initial
     begin
	$dumpfile("test.vcd");
	$dumpvars(0, dv_ecfg);
     end

   
endmodule // dv_ecfg
// Local Variables:
// verilog-library-directories:("." "../hdl" "../../memory/hdl ")
// End:

