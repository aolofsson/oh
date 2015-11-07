// Standardized "DUT"
module dut (/*AUTOARG*/
   // Outputs
   dut_active, access_out, packet_out, wait_out,
   // Inputs
   clk, nreset, vdd, vss, access_in, packet_in, wait_in
   );
 
   parameter PW = 99;
   parameter N  = 99;
   
   //#######################################
   //# CLOCK AND RESET
   //#######################################
   input            clk;
   input            nreset;
   input [N*N-1:0]  vdd;
   input 	    vss;
   output 	    dut_active; //dut ready to go after reset
      
   //#######################################
   //#EMESH INTERFACE 
   //#######################################
   
   //North side
   input [N-1:0]     access_in;
   input [N*PW-1:0]  packet_in;
   input [N-1:0]     wait_in;
   output [N-1:0]    access_out;
   output [N*PW-1:0] packet_out;
   output [N-1:0]    wait_out;
    
   /*AUTOINPUT*/
   /*AUTOINPUT*/
   /*AUTOWIRE*/
   
   //Drive dummy interface
   //This module should be replaced with actual device under test
   assign access_out  ='b0;
   assign packet_out  ='b0;
   assign wait_out    ='b0;
   assign reset_done  = 1'b1;
   
endmodule // dut

