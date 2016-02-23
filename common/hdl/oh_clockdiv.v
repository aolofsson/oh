// ###############################################################
// # FUNCTION: Synchronous clock divider that divides by integer
// # divcfg: 0 = div1
// #         1 = div2
// #         2 = div4
// #         3 = div8
// #         4 = div16
// #         5 = div32
// #         6 = div64
// #         7 = div128
// #       15:8= reserved   
// ############################################################### 
module oh_clockdiv(/*AUTOARG*/
   // Outputs
   clkout, clkout90,
   // Inputs
   clk, en, nreset, divcfg
   );

   //signals 
   input       clk;      // input clock
   input       en;       // synchronous clock enable
   input       nreset;   // async   
   input [3:0] divcfg;   // divide factor (1-128)
   output      clkout;   // divided clock phase aligned with clkin
   output      clkout90; // clkout shifted by 90 deg

   //regs
   reg        clkout_reg;
   reg        clkout90_reg;
   reg [7:0]  counter;   
   reg [7:0]  divcfg_dec;
   reg [3:0]  divcfg_reg;
   reg 	      clkout90_div2;
   
   wire       posedge_match;
   wire       negedge_match;  
    
   // divider setting
   always @ (divcfg[3:0])
     casez (divcfg[3:0])
       4'b0001 : divcfg_dec[7:0] = 8'b00000010;  // Divide by 2
       4'b0010 : divcfg_dec[7:0] = 8'b00000100;  // Divide by 4
       4'b0011 : divcfg_dec[7:0] = 8'b00001000;  // Divide by 8
       4'b0100 : divcfg_dec[7:0] = 8'b00010000;  // Divide by 16
       4'b0101 : divcfg_dec[7:0] = 8'b00100000;  // Divide by 32
       4'b0110 : divcfg_dec[7:0] = 8'b01000000;  // Divide by 64
       4'b0111 : divcfg_dec[7:0] = 8'b10000000;  // Divide by 128
       default : divcfg_dec[7:0] = 8'b00000000;  // others (divide by 1)
     endcase

   // divcfg change detector
   always @ (posedge clk)
     divcfg_reg[3:0]<=divcfg[3:0];
   assign cfg_reset = (|(divcfg_reg[3:0] ^ divcfg[3:0]));
   
   // synchronous edge counter
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       counter[7:0] <= 8'b00000001;
     else if(posedge_match | cfg_reset)
       counter[7:0] <= 8'b00000001;// Self resetting
     else
       counter[7:0] <= (counter[7:0] + 8'b00000001);
   
   assign posedge_match    = (counter[7:0]==divcfg_dec[7:0]);
   assign negedge_match    = (counter[7:0]=={1'b0,divcfg_dec[7:1]}); 
   assign posedge90_match  = (counter[7:0]=={2'b0,divcfg_dec[7:2]});
   assign negedge90_match  = (counter[7:0]=={2'b0,divcfg_dec[7:2]}+{1'b0,divcfg_dec[7:1]}); 
      
   // clkout
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       clkout_reg <= 1'b0;   
     else if(posedge_match)
       clkout_reg <= 1'b1;
     else if(negedge_match)
       clkout_reg <= 1'b0;
 
   // divide by one special case
   assign clkout  = (divcfg[3:0]==4'b0000) ? clk : clkout_reg;

   // clkout90
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       clkout90_reg <= 1'b0;   
     else if(posedge90_match)
       clkout90_reg <= 1'b1;
     else if(negedge90_match)
       clkout90_reg <= 1'b0;

   // special div2 case, using negedge of clk to delay by 90 deg
   always @ (negedge clk)
     clkout90_div2 <= clkout_reg;
   
   // divide by one and two special cases
   assign clkout90  = (divcfg[3:0]==4'b0000) ? clk           : 
		      (divcfg[3:0]==4'b0001) ? clkout90_div2 :
                             		        clkout90_reg;
      
endmodule // oh_clockdiv

    
