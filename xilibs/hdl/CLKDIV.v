module CLKDIV(/*AUTOARG*/
   // Outputs
   clkout,
   // Inputs
   clkin, divcfg, reset
   );

   input       clkin;    // Input clock
   input [3:0] divcfg;   // Divide factor (1-128)
   input       reset;    // Counter init
   output      clkout;   // Divided clock phase aligned with clkin 

   reg        clkout_reg;
   reg [7:0]  counter;   
   reg [7:0]  divcfg_dec;
   reg [3:0]  divcfg_reg;
   
   wire       div_bp;   
   wire       posedge_match;
   wire       negedge_match;  
   
   // ###################
   // # Decode divcfg
   // ###################

   always @ (divcfg[3:0])
     casez (divcfg[3:0])
       4'b0001 : divcfg_dec[7:0] = 8'b00000010;  // Divide by 2
       4'b0010 : divcfg_dec[7:0] = 8'b00000100;  // Divide by 4
       4'b0011 : divcfg_dec[7:0] = 8'b00001000;  // Divide by 8
       4'b0100 : divcfg_dec[7:0] = 8'b00010000;  // Divide by 16
       4'b0101 : divcfg_dec[7:0] = 8'b00100000;  // Divide by 32
       4'b0110 : divcfg_dec[7:0] = 8'b01000000;  // Divide by 64
       4'b0111 : divcfg_dec[7:0] = 8'b10000000;  // Divide by 128
       default : divcfg_dec[7:0] = 8'b00000000;   // others
     endcase
   
   always @ (posedge clkin or posedge reset)
     if(reset)
       counter[7:0] <= 8'b00000001;
     else if(posedge_match)
       counter[7:0] <= 8'b00000001;// Self resetting
     else
       counter[7:0] <= (counter[7:0] + 8'b00000001);
   
   assign posedge_match    = (counter[7:0]==divcfg_dec[7:0]);
   assign negedge_match    = (counter[7:0]=={1'b0,divcfg_dec[7:1]}); 
   
   always @ (posedge clkin or posedge reset)
     if(reset)
       clkout_reg <= 1'b0;   
     else if(posedge_match)
       clkout_reg <= 1'b1;
     else if(negedge_match)
       clkout_reg <= 1'b0;

   //Divide by one bypass
   assign div_bp  = (divcfg[3:0]==4'b0000);
   assign clkout  = div_bp ? clkin : clkout_reg;
 
endmodule // CLKDIV


    
