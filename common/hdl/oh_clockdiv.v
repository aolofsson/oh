//#############################################################################
//# Purpose: Clock divider with 2 outputs                                     #
//           Secondary clock must be multiple of first clock                  #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT (see LICENSE file in OH! repository)                        # 
//#############################################################################

module oh_clockdiv 
   (
    //inputs
    input 	 clk, // main clock
    input 	 nreset, // async active low reset (from oh_rsync)
    input 	 clkchange, // indicates a parameter change   
    input 	 clken, // clock enable
    input [7:0]  clkdiv, // [7:0]=period (0==bypass, 1=div/2, 2=div/3, etc)
    input [15:0] clkphase0, // [7:0]=rising,[15:8]=falling
    input [15:0] clkphase1, // [7:0]=rising,[15:8]=falling
    //outputs
    output 	 clkout0, // primary output clock
    output 	 clkrise0, // rising edge match
    output 	 clkfall0, // falling edge match
    output 	 clkout1, // secondary output clock
    output 	 clkrise1, // rising edge match
    output 	 clkfall1, // falling edge match 
    output 	 clkstable    // clock is guaranteed to be stable
    );

   //regs
   reg [7:0] counter;
   reg 	     clkout0_reg;
   reg 	     clkout1_reg;
   reg 	     clkout1_shift;
   reg [2:0] period;
   wire      period_match;
   wire [3:0] clk1_sel;
   wire [3:0] clk1_sel_sh;
   wire [1:0] clk0_sel;
   wire [1:0] clk0_sel_sh;

   //###########################################
   //# CHANGE DETECT (count 8 periods)
   //###########################################

   always @ (posedge clk or negedge nreset)
     if(!nreset)
       period[2:0] <= 'b0;   
     else if (clkchange)
       period[2:0] <='b0;      
     else if(period_match & ~clkstable)
       period[2:0] <= period[2:0] +1'b1;

   assign clkstable = (period[2:0]==3'b111);
   
   //###########################################
   //# CYCLE COUNTER
   //###########################################
   
   always @ (posedge clk or negedge nreset)
     if (!nreset)
       counter[7:0]   <= 'b0;
     else if(clken)
       if(period_match)
	 counter[7:0] <= 'b0;
       else
	 counter[7:0] <= counter[7:0] + 1'b1;

   assign period_match = (counter[7:0]==clkdiv[7:0]);   

   //###########################################
   //# RISING/FALLING EDGE SELECTORS
   //###########################################
     
   assign clkrise0     = (counter[7:0]==clkphase0[7:0]);   
   assign clkfall0     = (counter[7:0]==clkphase0[15:8]);   
   assign clkrise1     = (counter[7:0]==clkphase1[7:0]);   
   assign clkfall1     = (counter[7:0]==clkphase1[15:8]);   
       
   //###########################################
   //# CLKOUT0
   //###########################################

   always @ (posedge clk or negedge nreset)
     if(!nreset)
       clkout0_reg <= 1'b0;      
     else if(clkrise0)
       clkout0_reg <= 1'b1;
     else if(clkfall0)
       clkout0_reg <= 1'b0;
  
   // clock mux
   assign clk0_sel[1] =  (clkdiv[7:0]==8'd0);   // not implemented
   assign clk0_sel[0] = ~(clkdiv[7:0]==8'd0);

     
   // clock select needs to be stable high
   oh_lat0 #(.DW(2)) 
   latch_clk0 (.out (clk0_sel_sh[1:0]),
	       .clk (clk),
	       .in  (clk0_sel[1:0]));
   
   oh_clockmux #(.N(2))
   mux_clk0 (.clkout(clkout0),
	     .en(clk0_sel[1:0]),
	     .clkin({clk, clkout0_reg}));
   
   //###########################################
   //# CLKOUT1
   //###########################################

   always @ (posedge clk or negedge nreset)
     if(!nreset)
       clkout1_reg <= 1'b0;      
     else if(clkrise1)
       clkout1_reg <= 1'b1;
     else if(clkfall1)
       clkout1_reg <= 1'b0;
   
   // creating divide by 2 shifted clock with negedge
   always @ (negedge clk)
     clkout1_shift <= clkout1_reg;
   
   // clock mux
   assign clk1_sel[3] =  1'b0;               // not implemented
   assign clk1_sel[2] = (clkdiv[7:0]==8'd0); // div1 (bypass)
   assign clk1_sel[1] = (clkdiv[7:0]==8'd1); // div2 clock 
   assign clk1_sel[0] = |clkdiv[7:1];        // all others
   
   // clock select needs to be stable high
   oh_lat0 #(.DW(4)) 
   latch_clk1 (.out (clk1_sel_sh[3:0]),
	       .clk (clk),
	       .in  (clk1_sel[3:0]));

   oh_clockmux #(.N(4))
   mux_clk1 (.clkout(clkout1),
	     .en(clk1_sel[3:0]),
	     .clkin({1'b0, clk, clkout1_shift, clkout1_reg}));
   
endmodule // oh_clockdiv



    
