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
| [emmu](emmu)        |        | A simple memory map translation unit        |
| [memory](memory)    |        | Various simple memory structures (RAM/FIFO) |
| [emesh](emesh)      |        | Epiphany emesh packet related circuits      |
| [xilibs](xilibs)    |        | Simulation modules for Xilinx primitives    |


## Building
```
git clone https://github.com/parallella/oh.git
cd oh
mkdir build
cd build
../configure
make elink
```

## License
``
This library is made available with a LGPL V3 copyleft license. By our interpretation, Verilog is software and chips/bitstreams are the hardware equivalent of a binary program. We will look into this issue further in the future, but in the meantime, please consider this a strict copyleft library. 
```
