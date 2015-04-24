//MEMORY MAP
//Group set with bits 19:16

//Epiphany Register Memory Map
`define EGROUP_MMR     4'hE
`define EGROUP_RXMMU   4'hD
`define EGROUP_TXMMU   4'hC
`define EGROUP_READTAG 4'hB

//ELINK REGISTERS addr[6:2]
`define ELRESET    5'h0 //E0000
`define ELCLK      5'h1 //E0004
`define ELTX       5'h2 //E0008 
`define ELRX       5'h3 //E000C
`define ELCOREID   5'h4 //E0010
`define ELVERSION  5'h5 //E0014
`define ELDATAIN   5'h6 //E0018
`define ELDATAOUT  5'h7 //E001C
`define ELDEBUG    5'h8 //E0020
`define EMAILBOXLO 5'h9 //E0024
`define EMAILBOXHI 5'hA //E0028
`define EDMACFG    5'hB //E002C
`define EDMASTATUS 5'hC //E0030
`define EDMASRC    5'hD //E0034
`define EDMADST    5'hE //E0038
`define EDMACOUNT  5'hF //E0053C 



