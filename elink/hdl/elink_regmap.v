//MEMORY MAP

//[31:20] = LINKID
//[19:16] = GROUP SELECT
//[15]    = MMU SELECT (for RX/TX)
//[14:6]  = USED BY MMU ONLY 
//[5:2]   = REGISTER ADDRESS (0..15)
//[1:0]   = IGNORED (no byte access)

//Link register groups addr[19:16]
`define EGROUP_CFG     4'hE
`define EGROUP_TX      4'hD
`define EGROUP_RX      4'hC
`define EGROUP_READTAG 4'hB

//ELINK CONFIG REGISTERS 
`define ELRESET       4'h0 //E0000-reset
`define ELCLK         4'h1 //E0004-clock configuration
`define ELCOREID      4'h2 //E0008-core id
`define ELVERSION     4'h3 //E000C-version

//ELINK TX registers
`define ELTXCFG       4'h0 //D0000-config
`define ELTXSTATUS    4'h1 //D0004-tx status
`define ELTXDOUT      4'h2 //D0008-data for pins

//ELINK RX registers
`define ELRXCFG      4'h0 //C0000-config
`define ELRXSTATUS   4'h1 //C0004-status register
`define ELRXBASE     4'h2 //C0008-memory base
`define ELRXREMAP    4'h2 //C000c-memory base
`define ELRXDIN      4'h3 //C0010-sampled data
`define EMAILBOXLO   4'h4 //C0014-mailbox
`define EMAILBOXHI   4'h5 //C0018-mailbox
`define EXXX0        4'h6 //C001c-reserved
`define EXXX1        4'h7 //C0020-reserved
`define EDMACFG      4'h8 //C0024-dma
`define EDMASTATUS   4'h9 //C0028-dma
`define EDMASRC      4'hA //C002C-dma
`define EDMADST      4'hB //C0030-dma
`define EDMACOUNT    4'hC //C0034-dma 

