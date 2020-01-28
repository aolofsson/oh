module r5_decoder
  (// INSTRUCTION TO DECODE
   input [31:0]  instr,
   // TYPES
   output 	 de_rv32i,
   output 	 de_rv64i,
   output 	 de_rv32m,
   output 	 de_rv64m,
   output 	 de_rv32a,
   output 	 de_rv64a,
   output 	 de_rv32f,
   output 	 de_rv32d,
   output 	 de_rv64d,
   // IMMEDIATES
   output [31:0] de_imm_data,
   output 	 de_imm_sel,
   // IALU
   output 	 de_and,
   output 	 de_sub, // subtract
   output 	 de_asr, // arithmetic shift right
   output 	 de_lsl, // logical shift left
   output 	 de_lsr, // logical shift right
   output 	 de_orr, // logical or
   output 	 de_eor, // logical xor
   output 	 de_sltu, // set if less than (unsigned)
   output 	 de_slt, // set if less than (signed)
   output 	 de_rs1_read,
   output [4:0]  de_rs1_addr,
   output 	 de_rs2_read,
   output [4:0]  de_rs2_addr,
   output 	 de_rd_write,
   output [4:0]  de_rd_addr, 
   // FPU
   output 	 de_fadd,
   output 	 de_fsub,
   output 	 de_fmul,
   output 	 de_fmadd,
   output 	 de_fnmadd,
   output 	 de_fmsub,
   output 	 de_fnmsub,
   output 	 de_fdiv,
   output 	 de_fmin,
   output 	 de_fmax,
   output 	 de_fsqrt,
   output 	 de_fix,
   output 	 de_float,
   output 	 de_fabs,
   output 	 de_fmin,
   output 	 de_fmax,
   output 	 de_feq, // floating point equal comparison
   output 	 de_flt, // floating point less than comparison
   output 	 de_fle, // floating point less than or equal comparison
   output 	 de_fmv_float2int, // move from  float reg to int reg file
   output 	 de_fmv_int2float, // move from int reg to float reg file
   output 	 de_flcass, // classifies floating point number
   output 	 de_fnegate, //negative floating point value
   output 	 de_fcopysign, // RD = RS1[30:0] | RS2[31]
   output 	 de_finvertsign,// RD = RS1[30:0] | ~RS2[31]
   output 	 de_fxorsign,// RD = RS1[31:0] | RS2[31]
   output 	 de_frs1_read,
   output [4:0]  de_frs1_addr,
   output 	 de_frs2_read,
   output [4:0]  de_frs2_addr,
   output 	 de_frs3_read,
   output [4:0]  de_frs3_addr,
   output 	 de_frd_write,
   output [4:0]  de_frd_addr,
   output [2:0]  de_frounding_mode,
   // BRANCHING
   output 	 de_branch,
   output 	 de_link,
   output [3:0]  de_branch_code, 
   output 	 de_jump_reg
   output 	 de_aupic, // RD=PC+IMM20
   // LOAD/STORE
   output 	 de_load, //load operation
   output 	 de_store, // store operation
   output [1:0]  de_datamode,//00=byte,01=half,10=word,11=double
   output 	 de_load_signed, // load signed data
   output 	 de_movi, // load immediate, ADDI RD, R0,IMM
   output 	 de_movi_hi, // load immediate, RD=RS | IMM <<12
   // ATOMICS
   output 	 de_fence, //memory fence operation
   output 	 de_atomic_lr,//atomic load conditional
   output 	 de_atomic_sc, //atomic store conditional
   output 	 de_atomic_swap, //atomic swap
   output 	 de_atomic_add, //atomic add
   output 	 de_atomic_xor, //atomic xor
   output 	 de_atomic_or,// atomic or
   output 	 de_atomic_and, //atomic and
   output 	 de_atomic_min,//signed atomic min operation
   output 	 de_atomic_max,//signed atomic max operation
   output 	 de_atomic_minu,//unsigned atomic min operation
   output 	 de_atomic_maxu//unsigned atomic max operation
);
   
endmodule // r5_decoder
