//These constants are mutually exclusive
`define TARGET_CLEAN
`define CFG_FAKECLK   1      /*verilator doesn't get clock gating*/
`define CFG_AW 32
`define CFG_DW 32
`define CFG_LW 8
`define CFG_NW        13     /*Number of bytes in the transmission*/
