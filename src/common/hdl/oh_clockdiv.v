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

   //bypass divider on "divide by 1"
   //TODO: Fix clock glitch!
   assign clkout0 = (clkdiv[7:0]==8'd0) ? clk :        // bypass
		                          clkout0_reg; // all others

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
      
   //TODO: Fix clock glitch!
   assign clkout1 = (clkdiv[7:0]==8'd0) ? clk           : //bypass
		    (clkdiv[7:0]==8'd1) ? clkout1_shift : //div2
		                          clkout1_reg;    //all others
      
endmodule // oh_clockdiv



    
