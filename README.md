=======
# OH! Open hardware for Chips and FPGAs

![alt tag](common/docs/lego.jpg)

## CONTENT

| FOLDER                   | STATUS| DESCRIPTION                          |
|--------------------------|-------|--------------------------------------|
|[accelerator](accelerator)| FPGA  | Accelerator tutorial                 |
|[axi](axi)                | FPGA  | AXI master and slave interfaces      |
|[chip](chip)              | SI    | Chip design reference flow           |
|[common](common)          | SI    | Library of basic components          |
|[elink](elink)            | SI    | Point to point LVDS link             |
|[emailbox](emailbox)      | FPGA  | Mailbox with interrupt output        |
|[emesh](emesh)            | SI    | Emesh interface utility circuits     |
|[emmu](emmu)              | FPGA  | Memory transaction translation unit  |
|[etrace](etrace)          | HH    | Logic Analyzer                       |
|[gpio](gpio)              | HH    | General Purpose IO                   |
|[irqc](irqc)              | SI    | Epiphany nested interrupt controller |
|[parallella](parallella)  | FPGA  | Parallella FPGA logic                |
|[risc-v](risc-v)          | HH    | RISC-V implementation                |
|[spi](spi)                | HH    | SPI master/slave                     |
|[verilog](verilog)        | HH    | Verilog referenca material           |
|[xilibs](xilibs)          | FPGA  | Xilinx simulation models             |

**NOTES:**
* "SI"= Silicon validated
* "FPGA" =  FPGA validated
* "HH" =  Hard hat area (work in progress)

## LICENSE
The OH! repository source code is licensed under the MIT license unless otherwise specified. See [LICENSE](LICENSE) for MIT copyright terms. Design specific licenses can be found in the folder root (eg: aes/LICENSE) 

## CONTRIBUTING
Instructions for contributing can be found [HERE](CONTRIBUTING.md).

## REFERENCES MANUALS
* [Verilog Reference](verilog/verilog_reference.md)
* [Verilog Coding Methodology](https://github.com/parallella/oh/blob/master/CODING-METHODOLOGY.md)
* [Glossary](chip/docs/glossary.md)
* [Chip constants](chip/docs/constants.md)

## RECOMMENDED TOOLS

* [Verilator Simulator](http://www.veripool.org/wiki/verilator)
* [Emacs Verilog Mode](http://www.veripool.org/wiki/verilog-mode)
* [Icarus Simulator](http://iverilog.icarus.com)
* [GTKWave](http://gtkwave.sourceforge.net)
* [Wavedrom](http://wavedrom.com/editor.html)
* [FuseSoC](https://github.com/olofk/fusesoc)


----
[picture-license](https://commons.wikimedia.org/wiki/File:Lego_Color_Bricks.jpg)

