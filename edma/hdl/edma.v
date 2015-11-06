module edma (/*AUTOARG*/
   // Outputs
   mi_dout, edma_access, edma_packet,
   // Inputs
   nreset, clk, mi_en, mi_we, mi_addr, mi_din, edma_wait
   );

   /******************************/
   /*Compile Time Parameters     */
   /******************************/
   parameter RFAW            = 6;
   parameter AW              = 32;
   parameter DW              = 32;
   parameter PW              = 104;

   /******************************/
   /*HARDWARE RESET (EXTERNAL)   */
   /******************************/
   input 	     nreset; //async reset
   input 	     clk;

   /*****************************/
   /*REGISTER INTERFACE         */
   /*****************************/      
   input 	     mi_en;         
   input 	     mi_we; 
   input [RFAW+1:0]  mi_addr;
   input [63:0]      mi_din;
   output [31:0]     mi_dout;   
  
   /*****************************/
   /*DMA TRANSACTION            */
   /*****************************/
   output 	     edma_access;
   output [PW-1:0]   edma_packet;
   input 	     edma_wait;

   //Tieoffs for now
   assign edma_access = 'b0;
   assign edma_packet = 'd0;
   assign mi_dout     = 'd0;
   
endmodule // edma
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:

