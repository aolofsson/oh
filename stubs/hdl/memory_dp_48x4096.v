
module memory_dp_48x4096 (/*AUTOARG*/
   // Outputs
   doutb,
   // Inputs
   clka, ena, wea, addra, dina, clkb, enb, addrb
   );


   //write
   input        clka;
   input        ena;
   input [5:0]  wea;
   input [11:0] addra;
   input [47:0] dina;

   //read
   input 	 clkb;
   input 	 enb;
   input [11:0]  addrb;
   output [47:0] doutb;
   
   assign doutb[47:0]=48'b0;
      
endmodule // memory_dp_48x4096




