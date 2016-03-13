=======
# OH! Open Hardware

![alt tag](common/docs/lego.jpg)

## Content

1. [Philosophy](#philosophy)
2. [Modules](#modules)
3. [How to Simulate](#how-to-simulate)
5. [How to Build](#how-to-build)
4. [Design Guide](#design-guide)
5. [Coding Guide](#coding-guide)
6. [Documentation Guide](#documentation-guide)
7. [Design Checklist](#design-checklist)
7. [Recommended Reading](#recommended-reading)
8. [License](#license)

----

## Philosophy

1. Make it work
2. Make it simple
3. Make it modular

----

## Modules

| FOLDER                             | STATUS| DESCRIPTION                    |
|------------------------------------|-------|--------------------------------|
|[accelerator](accelerator/README.md)| FPGA  | Accelerator tutorial           |
|[axi](axi/README.md)                | FPGA  | AXI master and slave interfaces|
|[chip](chip/README.md)              | SI    | Chip design reference flow     |
|[common](common/README.md)          | SI    | Library of basic components    |
|[elink](elink/README.md)            | SI    | Point to point LVDS link       |
|[emailbox](emailbox/README.md)      | FPGA  | Mailbox with interrupt output  |
|[emesh](emesh/README.md)            | SI    | Emesh interface circuits       |
|[emmu](emmu/README.md)              | FPGA  | Memory translation unit        |
|[etrace](etrace/README.md)          | HH    | Logic Analyzer                 |
|[gpio](gpio/README.md)              | HH    | General Purpose IO             |
|[mio](mio/README.md)                | HH    | Lightweight parallel link      |
|[pic](pic/README.md)                | SI    | Interrupt controller           |
|[parallella](parallella/README.md)  | FPGA  | Parallella FPGA logic          |
|[risc-v](risc-v/README.md)          | HH    | RISC-V implementation          |
|[spi](spi/README.md)                | HH    | SPI master/slave               |
|[verilog](verilog/README.md)        | HH    | Verilog referenca material     |
|[xilibs](xilibs/README.md)          | FPGA  | Xilinx simulation models       |

**NOTES:**
* "SI"= Silicon validated
* "FPGA" =  FPGA validated
* "HH" =  Hard hat area (work in progress)

----

## How to simulate

```sh
./build.sh gpio/dv/dut_gpio.v         # compile gpio testbench (example)
./sim.sh gpio/dv/tests/test_basic.emf # run a simulation with "test_regs.emf"
./view.sh                             # open the waveform with gtkwave
```

**Short-cut:**

* Builds $name/dv/dut_$name.v
* Runs test $name/dv/tests/test_basic.emf

```sh
./run.sh accelerator
./run.sh elink
./run.sh emailbox
./run.sh emmu
./run.sh gpio
./run.sh spi
./run.sh pic
```

----

## How to build

TBD

----

## Design Guide

* Separate control from the datapath
* Separate configuration from design
* Separate design from testbench
* Separate testbench from test (data)
* Use 64b boundaries for scalable registers (when reasonable)
* Place multi bit fields on nibble boundaries (when reasonable)
* Make reset values "0"
* Only reset register if absolutely necessary
* More to come...

----

# Coding Guide

* Max 80 chars per line
* One input/output statement per line
* Only single line // comments, no /*..*/
* Use vector sizes in every statement, ie "assign a[7:0] = myvec[7:0];"
* Use parameters for reusability and readability
* Use many short statements in place of one big one
* Define wires/regs at beginning of file
* Align input names/comments in column like fashion
* Avoid redundant begin..end statements
* Capitalize macros and constants
* Use lower case for all signal names
* User upper case for all parameters and constants
* Use y down to x vectors
* Use a naming methodology and document it
* Comment every module port
* Do not hard code numerical values in body of code
* Keep parameter names short
* Use common names: nreset, clk, din, dout, en, rd, wr, addr, etc
* Make names descriptive, avoid non-common abbreviations 
* Make names as short as possible, but not shorter
* Use _ in constants over 4 bits (eg: 8'h1100_1100)
* One module per file
* Use ".vh" suffix for header files,
* yse ".v" for verilog source files
* Use `include files for constants
* Use `ifndef _CONSTANTS_V to include file only once
* No timescales in design files (only in testbench)
* No delay statements in design
* No logic statements in top level design structures
* Prefer parameters in place of global defines
* Do not use casex
* Use active low reset
* Avoid redundant resets
* Avoid heavily nested if, else statements
* Don't use defparams, place #(.DW(DW)) in module instantation
* Always use connection by name (not by order) in module instantiatoin
* Parametrize as much as possible but not more
* Place a useful comment every 5-20 lines
* If you are going to use async reset, use oh_rsync.v
* Use for loops to reduce bloat and to improve readability
* If you have to mix clock edges, isolate to discrete modules
* Use nonblocking (<=) in all sequential statements
* Use default statements in all case statements
* Don't use proprietary EDA tool pragmas (use parameters)
* Only use synthesizable constructs
* Use $signed() for arithmetic operations on signed types
* Allowed keywords: assign, always, input, output, wire, reg, module, endmodule, if/else, case, casez, ~,|,&,^,==, >>, <<, >, <,?,posedge, negedge, generate, for(...), begin, end, $signed,



----

## Documentation Guide

* Write docs in markdown
* Specify which registers are reset
* Put lsb on right side, lsb is bit zero
* Indicate type (read/write/etc)
* Indicate what 
* All signal should be summarized in a table (markdown)
* All signals should have waveforms (wavedrom)
* List internal block hierarhcy (need script for this)
* Unused/reserved bits in all register should be written as zero
* In tables, place registers in address order
* In description section, place registeres in alphabetical order
* Include links in table to descriptions
* Include "internal register map" 
* Base address of chip/block
* Table of interrupts..
* Show how to compile..
* Show how to simulate...
* Show how to synthesize/build..
* Show how to use..

----

## Design Checklist

* Is the block datasheet complete and accurate?
* Is there a user guide?
* Is there a script/make file for building/testing the design?
* Is there a self testing testbench?
* Is there an auotomated synthesis script?
* Is the driver written?
* Is there a demo example?
* Is the the block Silicon and FPGA validated?

----

## Recommended Reading

* [Verilog Reference](verilog/verilog_reference.md)
* [Glossary](chip/docs/glossary.md)
* [Chip constants](chip/docs/constants.md)
* [Verilator Simulator](http://www.veripool.org/wiki/verilator)
* [Emacs Verilog Mode](http://www.veripool.org/wiki/verilog-mode)
* [Icarus Simulator](http://iverilog.icarus.com)
* [GTKWave](http://gtkwave.sourceforge.net)
* [Wavedrom](http://wavedrom.com/editor.html)
* [FuseSoC](https://github.com/olofk/fusesoc)

## License
The OH! repository source code is licensed under the MIT license unless otherwise specified. See [LICENSE](LICENSE) for MIT copyright terms. Design specific licenses can be found in the folder root (eg: aes/LICENSE) 

----

[picture-license](https://commons.wikimedia.org/wiki/File:Lego_Color_Bricks.jpg)

