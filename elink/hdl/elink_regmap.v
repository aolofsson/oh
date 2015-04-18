//MEMORY MAP
//Group set with bits 19:16

//Epiphany Register Memory Map
`define EGROUP_MMR   4'hE
`define EGROUP_RXMMU 4'hD
`define EGROUP_TXMMU 4'hC

//ELINK REGISTERS addr[6:2]
`define ELRESET    5'h0
`define ELCLK      5'h1
`define ELTX       5'h2
`define ELRX       5'h3
`define ELCOREID   5'h4
`define ELVERSION  5'h5
`define ELDATAIN   5'h6
`define ELDATAOUT  5'h7
`define ELDEBUG    5'h8
`define EMBOXLO    5'h9
`define EMBOXHI    5'hA

//RX MMU addr[15:0]

//TX MMU addr[15:0]


