/*******************************************************************************
 * Function:  ENOC Command Decoder
 * Author:    Andreas Olofsson                                                
 * License:   MIT (see LICENSE file in OH! repository)
 *
 *
 ******************************************************************************/
module enoc_decode
  (
   //Emesh signal bundle
   input [3:0] opcode,
   //Writes
   output      cmd_write_start,
   output      cmd_write_stop,
   output      cmd_write_multicast,
   //Read commands
   output      cmd_read,
   output      cmd_cas,
   output      cmd_atomic_add,
   output      cmd_atomic_and,
   output      cmd_atomic_or,
   output      cmd_atomic_xor
   );
   
   //############################################
   // Command Decode
   //############################################

   //Writes
   assign cmd_write           = ~opcode[3];   
   assign cmd_write_start     = opcode[3:0]==1000;
   assign cmd_write_stop      = opcode[3:0]==1001;
   assign cmd_write_multicast = opcode[3:0]==1011;
   
   //Reads/atomics
   assign cmd_read         = opcode[3:0]==1000;
   assign cmd_atomic_cas   = opcode[3:0]==1011;
   assign cmd_atomic_add   = opcode[3:0]==1100;
   assign cmd_atomic_and   = opcode[3:0]==1101;
   assign cmd_atomic_or    = opcode[3:0]==1110;
   assign cmd_atomic_xor   = opcode[3:0]==1111;

endmodule // enoc_decode


