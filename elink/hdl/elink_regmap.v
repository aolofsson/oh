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
`define ELCHIPID      4'h2 //E0008-Epiphany chip id for colid/rowid pins 
`define ELVERSION     4'h3 //E000C-version

//ELINK TX registers
`define ELTXCFG       4'h0 //D0000-config
`define ELTXSTATUS    4'h1 //D0004-tx status
`define ELTXGPIO      4'h2 //D0008-direct data for tx pins
`define ELTXTEST      4'h3 //D000C-control for driving SERDES directly
`define ELTXDSTADDR   4'h5 //D0014-static addr (for testing)
`define ELTXDATA      4'h4 //D0010-static data (for testing)
`define ELTXSRCADDR   4'h6 //D0014-static source addr (for testing)

//ELINK RX registers
`define ELRXCFG      4'h0 //C0000-config
`define ELRXSTATUS   4'h1 //C0004-status register
`define ELRXGPIO     4'h2 //C0008-sampled data
`define ELRXBASE     4'h3 //C000c-memory base for remap
`define EMAILBOXLO   4'h4 //C0010-mailbox
`define EMAILBOXHI   4'h5 //C0014-mailbox
`define EDMACFG      4'h6 //C0018-dma
`define EDMASTATUS   4'h7 //C001C-dma
`define EDMASRC      4'h8 //C0020-dma
`define EDMADST      4'h9 //C0024-dma
`define EDMACOUNT    4'hA //C0028-dma 

