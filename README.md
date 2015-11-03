=======
# OH!

An Open Hardware Model Library for Chip and FPGA Designers

The library is written in vanilla Verilog. Pull requests accepted.

| Spec                | Status | Description                                 |
|---------------------|--------|---------------------------------------------|
| [eaxi](eaxi)        |        | AXI network interface stuff                 |
| [common](common)    |        | Common modules (synchronizer etc)          |
| [edma](edma)        |        | Basic DMA module                            |
| [emesh](emesh)      |        | Epiphany emesh related circuits             |
| [elink](elink)      |        | Epiphany point to point LVDS link           |
| [emailbox](emailbox)|        | Simple mailbox with interrupt output        |
| [emmu](emmu)        |        | Simple memory transaction translation unit  |
| [memory](memory)    |        | Various simple memory structures (RAM/FIFO) |
| [rand](rand)        |        | Random number generators                    |
| [xilibs](xilibs)    |        | Simulation modules for Xilinx primitives    |

## LICENSE

This library is made available with a GPL V3 copyleft license with the added condition that the Verilog code herein is to be considered software and physical chips and FPGA bitstreams are the hardware equivalent of a binary program.

