=======
# OH!

An Open Hardware Modle Library for Chip and FPGA Designers

The library is written in vanilla Verilog. Pull requests accepted.

| Spec                | Status | Description                                 |
|---------------------|--------|---------------------------------------------|
| [axi](axi)          |        | AXI network interface stuff                 |
| [common](common)    |        | Common moini modules (syncrhonziers etc)    |
| [edma](edma)        |        | A bare metal DMA module                     |
| [elink](elink)      |        | The Epiphany point to point LVDS link       |
| [emailbox](emailbox)|        | A simple mailnox with interrupt output      |
| [emmu](elink)       |        | A simple memory map translation unit        |
| [memory](memory)    |        | Various simple memory structures (RAM/FIFO) |
| [emesh](edma)       |        | Epiphany emesh packet related circuits      |
| [xilibs](edma)      |        | Simulation modules for Xilinx primitives    |


## Building
```
git clone https://github.com/parallella/oh.git
cd oh
mkdir build
cd build
../configure
make elink
```
