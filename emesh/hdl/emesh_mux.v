/*
 * This module performs a mux operation between a read and a write operation
 */

module emesh_mux (/*AUTOARG*/
   // Outputs
   rd_wait, wr_wait, emesh_access, emesh_packet,
   // Inputs
   rd_access, rd_packet, wr_access, wr_packet, emesh_wait
   );

   parameter PW = 99;  

   //Read mesh transaction
   input 	  rd_access;
   input [PW-1:0] rd_packet;
   output 	  rd_wait;

   //Read mesh transaction
   input 	  wr_access;
   input [PW-1:0] wr_packet;
   output 	  wr_wait;

   //Muxed emesh transacton
   output 	   emesh_access;
   output [PW-1:0] emesh_packet;
   input 	   emesh_wait;

   assign emesh_access = rd_access | wr_access;

   assign wr_wait = emesh_wait;
   assign rd_wait = emesh_wait | wr_access;

   assign emesh_packet[PW-1:0] = wr_access ? wr_packet[PW-1:0] :
				             rd_packet[PW-1:0];
   
endmodule // emesh_mux



