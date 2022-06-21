/*******************************************************************************
 * Function:  EMESH Command Decoder
 * Author:    Andreas Olofsson
 * License:   MIT (see LICENSE file in OH! repository)
 *
 * see ./emesh_pack.v
 *
 ******************************************************************************/
module emesh_decode
  (
   //Packet Command
   input [15:0] cmd_in,
   //Write
   output 	cmd_write,
   output 	cmd_write_stop,
   //Read
   output 	cmd_read,
   output 	cmd_atomic_add,
   output 	cmd_atomic_and,
   output 	cmd_atomic_or,
   output 	cmd_atomic_xor,
   output 	cmd_cas,
   //Fields
   output [3:0] cmd_opcode,
   output [3:0] cmd_length,
   output [2:0] cmd_size,
   output [7:0] cmd_user
   );

   //############################################
   // Command Decode
   //############################################

   //Writes
   assign cmd_write        = ~cmd_in[3];
   assign cmd_write_stop   = cmd_in[3:0]==1001;

   //Reads/atomics
   assign cmd_read         = cmd_in[3:0]==1000;
   assign cmd_atomic_cas   = cmd_in[3:0]==1011;
   assign cmd_atomic_add   = cmd_in[3:0]==1100;
   assign cmd_atomic_and   = cmd_in[3:0]==1101;
   assign cmd_atomic_or    = cmd_in[3:0]==1110;
   assign cmd_atomic_xor   = cmd_in[3:0]==1111;

   //Field Decode
   assign cmd_opcode[3:0]  = cmd_in[3:0];
   assign cmd_length[3:0]  = cmd_in[7:4];
   assign cmd_size[2:0]    = cmd_in[10:8];
   assign cmd_user[7:0]    = cmd_in[15:8];

endmodule // enoc_decode
