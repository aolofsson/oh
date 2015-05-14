/*WARNING: INCOMPLETE MODEL, DON'T USE. I RECOMMEND AGAINST USING THIS
 *BLOCK ALL TOGETHER. NOT OPEN SOURCE FRIENDLY /AO
 */

module ISERDESE2 (/*AUTOARG*/
   // Outputs
   O, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, SHIFTOUT1, SHIFTOUT2,
   // Inputs
   BITSLIP, CE1, CE2, CLK, CLKB, CLKDIV, CLKDIVP, D, DDLY,
   DYNCLKDIVSEL, DYNCLKSEL, OCLK, OCLKB, OFB, RST, SHIFTIN1, SHIFTIN2
   );

   parameter DATA_RATE         = 0; // "DDR" or "SDR"
   parameter DATA_WIDTH        = 0; // 4,2,3,5,6,7,8,10,14
   parameter DYN_CLK_INV_EN    = 0; // "FALSE", "TRUE"
   parameter DYN_CLKDIV_INV_EN = 0; // "FALSE", "TRUE"
   parameter INIT_Q1           = 0; // 1'b0 to 1'b1
   parameter INIT_Q2           = 0; // 1'b0 to 1'b1
   parameter INIT_Q3           = 0; // 1'b0 to 1'b1
   parameter INIT_Q4           = 0; // 1'b0 to 1'b1
   parameter INTERFACE_TYPE    = 0; // "MEMORY","MEMORY_DDR3", "MEMORY_QDR", 
                                    // "NETWORKING", "OVERSAMPLE"
   parameter IOBDELAY          = 0; // "NONE", "BOTH", "IBUF", "IFD"  
   parameter NUM_CE            = 0; // 2,1
   parameter OFB_USED          = 0; // "FALSE", "TRUE"
   parameter SERDES_MODE       = 0; // "MASTER" or "SLAVE"
   parameter SRVAL_Q1          = 0; // 1'b0 or 1'b1 
   parameter SRVAL_Q2          = 0; // 1'b0 or 1'b1 
   parameter SRVAL_Q3          = 0; // 1'b0 or 1'b1 
   parameter SRVAL_Q4          = 0; // 1'b0 or 1'b1 
  
   input  BITSLIP;        // performs bitslip operation
   input  CE1;            // clock enable 
   input  CE2;            // clock enable
   input  CLK;            // high speed clock input
   input  CLKB;           // high speed clock input (inverted)
   input  CLKDIV;         // divided clock (for bitslip and CE module)
   input  CLKDIVP;        // for MIG only
   input  D;              // serial input data pin
   input  DDLY;           // serial input data from IDELAYE2
   input  DYNCLKDIVSEL;   // dynamically select CLKDIV inversion
   input  DYNCLKSEL;      // dynamically select CLK and CLKB inversion.
   input  OCLK;           // clock for strobe based memory interfaces  
   input  OCLKB;          // clock for strobe based memory interfaces 
   input  OFB;            // data feebdack from OSERDESE2?
   input  RST;            // asynchronous reset
   input  SHIFTIN1;       // slave of multie serdes
   input  SHIFTIN2;       // slave of multie serdes
     
   //outputs
   output O;              // pass through from D or DDLY
   output Q1;             // parallel data out (last bit)
   output Q2;
   output Q3;
   output Q4;   
   output Q5;
   output Q6;
   output Q7;
   output Q8;             // first bit of D appears here
   output SHIFTOUT1;      // master of multi serdes
   output SHIFTOUT2;      // master of multi serdes


   reg [3:0] even_samples;
   reg [3:0] odd_samples;
   reg 	     Q1; 
   reg 	     Q2;
   reg 	     Q3;
   reg 	     Q4;   
   reg 	     Q5;
   reg 	     Q6;
   reg 	     Q7;
   reg 	     Q8;           
   always @ (posedge CLK)
     odd_samples[3:0] <=   {odd_samples[2:0],D};//#0.1

   always @ (negedge CLK)
     even_samples[3:0] <=  {even_samples[2:0],D};//#0.1

   always @ (posedge CLKDIV)
     begin
	 Q1 <=  odd_samples[0];
	 Q2 <=  even_samples[0];
	 Q3 <=  odd_samples[1];
	 Q4 <=  even_samples[1];
	 Q5 <=  odd_samples[2];
	 Q6 <=  even_samples[2];
	 Q7 <=  odd_samples[3];
	 Q8 <=  even_samples[3];
     end
   

   //pass through
   assign O=D;

   //not implemented
   assign SHIFTOUT1=1'b0;
   assign SHIFTOUT2=1'b0;
   	
endmodule // ISERDESE2


