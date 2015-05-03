//MEMORY MAP

//[31:20] = LINKID
//[19:16] = GROUP SELECT
//[15]    = MMU SELECT (for RX/TX)
//[14:11]  = USED BY MMU ONLY
//[10:8]  = register group
//[7:2]   = REGISTER ADDRESS (0..63)
//[1:0]   = IGNORED (no byte access)

//Link register groups addr[19:16]
`define EGROUP_MMR     4'hF //reserved for registers
`define EGROUP_MMU     4'hE // RX & TX MMU

//ETX-REGS
`define E_RESET        6'd0 //F0200-reset
`define E_CLK          6'd1 //F0204-clock configuration
`define E_CHIPID       6'd2 //F0208-Epiphany chip id for colid/rowid pins 
`define E_VERSION      6'd3 //F020C-version #
`define ETX_CFG        6'd4 //F0210-config
`define ETX_STATUS     6'd5 //F0214-tx status
`define ETX_GPIO       6'd6 //F0218-direct data for tx pins

//ERX-REGS
`define ERX_CFG        6'd0 //F0300-config
`define ERX_STATUS     6'd1 //F0304-status register
`define ERX_GPIO       6'd2 //F0308-sampled data
`define ERX_RR         6'd3 //F030C-read response address
`define ERX_OFFSET     6'd4 //F0310-memory base for remap
`define E_MAILBOXLO    6'd5 //F0314-reserved-->move?
`define E_MAILBOXHI    6'd6 //F0318-reserved

//DMA (same numbering as in Epiphany, limit to 4 channels)
`define DMACFG         5'd0 //F0500/F0520
`define DMACOUNT       5'd1 //F0504/F0524
`define DMASTRIDE      5'd2 //F0508/F0528
`define DMASRCADDR     5'd3 //F050C/F052c
`define DMADSTADDR     5'd4 //F0510/F0530
`define DMAAUTO0       5'd5 //F0514/F0534
`define DMAAUTO1       5'd6 //F0518/F0538
`define DMASTATUS      5'd7 //F051C/F053c

//DMA descriptors (limited to 4 channels)
`define DMADESCR0      5'd0 //F0580/F05A0
`define DMADESCR1      5'd1 //F0584/F05A4
`define DMADESCR2      5'd2 //F0588/F05A8
`define DMADESCR3      5'd3 //F058c/F05Ac
`define DMADESCR4      5'd4 //F0590/F05B0
`define DMADESCR5      5'd5 //F0594/F05B4
