//MEMORY MAP
//Group set with bits 19:16

//Epiphany Register Memory Map
`define EGROUP_MMR   4'hF
`define EGROUP_RXMMU 4'hE
`define EGROUP_TXMMU 4'hD
`define EGROUP_EMBOX 4'hC

//ELINK REGISTERS addr[6:2]
`define ESYSRESET    5'h0
`define ESYSTX       5'h1
`define ESYSRX       5'h2
`define ESYSCLK      5'h3
`define ESYSCOREID   5'h4
`define ESYSVERSION  5'h5
`define ESYSDATAIN   5'h6
`define ESYSDATAOUT  5'h7
`define ESYSDEBUG    5'h8

//MESSAGE BOX
`define EMBOXLO      5'h0
`define EMBOXHI      5'h1

//RX MMU addr[15:0]

//TX MMU addr[15:0]


