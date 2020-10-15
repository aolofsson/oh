/*******************************************************************************
 * Function:  ENOC Command Decoder
 * Author:    Andreas Olofsson                                                
 * License:   MIT (see LICENSE file in OH! repository)
 *
 * see ./enoc_pack.v
 * 
 ******************************************************************************/
module enoc_decode
  (
   //Emesh signal bundle
   input [15:0] cmd_in,
   //Writes
   output 	cmd_write,
   output 	cmd_write_start,
   output 	cmd_write_stop,
   output 	cmd_write_multicast,
   //Read commands
   output 	cmd_read,
   output 	cmd_cas,
   output 	cmd_atomic_add,
   output 	cmd_atomic_and,
   output 	cmd_atomic_or,
   output 	cmd_atomic_xor
   );
   
   //############################################
   // Command Decode
   //############################################

   //Writes
   assign cmd_write           = ~cmd_in[3];   
   assign cmd_write_start     = cmd_in[3:0]==1000;
   assign cmd_write_stop      = cmd_in[3:0]==1001;
   assign cmd_write_multicast = cmd_in[3:0]==1011;
   
   //Reads/atomics
   assign cmd_read         = cmd_in[3:0]==1000;
   assign cmd_atomic_cas   = cmd_in[3:0]==1011;
   assign cmd_atomic_add   = cmd_in[3:0]==1100;
   assign cmd_atomic_and   = cmd_in[3:0]==1101;
   assign cmd_atomic_or    = cmd_in[3:0]==1110;
   assign cmd_atomic_xor   = cmd_in[3:0]==1111;

endmodule // enoc_decode



