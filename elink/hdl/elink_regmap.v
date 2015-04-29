//MEMORY MAP

//[31:20] = LINKID
//[19:16] = GROUP SELECT
//[15]    = MMU SELECT (for RX/TX)
//[14:6]  = USED BY MMU ONLY
//[7:6]   = 16 register blocks
//[5:2]   = REGISTER ADDRESS (0..15)
//[1:0]   = IGNORED (no byte access)

//Link register groups addr[19:16]
`define EGROUP_CHIP   4'hF //reserved for chip MMR
`define EGROUP_TX     4'hE 
`define EGROUP_RX     4'hD

//REG BLOCK [7:6]
`define EBLOCK0       2'h0
`define EBLOCK1       2'h1
`define EBLOCK2       2'h2
`define EBLOCK3       2'h3

//BLOCK0
`define ELRESET       4'h0 //E0040-reset
`define ELCLK         4'h1 //E0044-clock configuration
`define ELCHIPID      4'h2 //E0048-Epiphany chip id for colid/rowid pins 
`define ELVERSION     4'h3 //E004c-version #

//ELINK TX registers
//BLOCK1
`define ELTXCFG       4'h0 //E0000-config
`define ELTXSTATUS    4'h1 //E0004-tx status
`define ELTXGPIO      4'h2 //E0008-direct data for tx pins
`define ELTXRES       4'h3 //E000C-reservec
`define ELTXTEST      4'h4 //E0020-control for driving SERDES directly
`define ELTXDSTADDR   4'h5 //E0024-static addr (for testing)
`define ELTXDATA      4'h6 //E0028-static data (for testing)
`define ELTXSRCADDR   4'h7 //E002c-static source addr (for testing)

//ELINK RX registers
//BLOCK0
`define ELRXCFG       4'h0 //D0000-config
`define ELRXSTATUS    4'h1 //D0004-status register
`define ELRXGPIO      4'h2 //D0008-sampled data
`define ELRXRR        4'h3 //D000C-read response address
`define ELRXBASE      4'h4 //D0010-memory base for remap
`define ELRESERVED    4'h5 //D0014-reserved

//BLOCK1
`define EMAILBOXLO    4'h0 //D0018-mailbox
`define EMAILBOXHI    4'h1 //D001c-mailbox

//BLOCk2
`define EDMACFG       4'h0 //D0020-dma
`define EDMACOUNT     4'h1 //D0024-dma
`define EDMASTRIDE    4'h2 //D0028-dma 
`define EDMASRCADDR   4'h3 //D002c-dma
`define EDMADSTADDR   4'h4 //D0028-dma
`define EDMASTATUS    4'h5 //D0030-dma 
