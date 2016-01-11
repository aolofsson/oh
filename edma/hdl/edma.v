module edma (/*AUTOARG*/
   // Outputs
   reg_rdata, access_out, packet_out,
   // Inputs
   nreset, clk, reg_access, reg_packet, wait_in
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
   input 	     reg_access;
   input [PW-1:0]    reg_packet;
   output [31:0]     reg_rdata;
  
   /*****************************/
   /*DMA TRANSACTION            */
   /*****************************/
   output 	     access_out;
   output [PW-1:0]   packet_out;
   input 	     wait_in;

   //Tieoffs for now
   assign access_out = 'b0;
   assign packet_out = 'd0;
   
endmodule // edma
// Local Variables:
// verilog-library-directories:("." "../../common/hdl")
// End:

