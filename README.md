=======
# OH! Open hardware for Chips and FPGAs

## PHILOSOPHY

1. Make it work
2. Make it simple
3. Make it modular

![alt tag](common/docs/lego.jpg)

## CONTENT

| FOLDER                   | STATUS| DESCRIPTION                           |
|--------------------------|-------|---------------------------------------|
|[accelerator](accelerator)| FPGA  | Accelerator tutorial                  |
|[axi](axi)                | FPGA  | AXI master and slave interfaces       |
|[c2c](c2c)                | HH    | Protocol agnostic chip to chip link   |
|[chip](chip)              | SI    | Chip design reference flow            |
|[common](common)          | SI    | Library of basic components           |
|[elink](elink)            | SI    | Point to point LVDS link              |
|[emailbox](emailbox)      | FPGA  | Mailbox with interrupt output         |
|[emesh](emesh)            | SI    | Emesh interface utility circuits      |
|[emmu](emmu)              | FPGA  | Memory transaction translation unit   |
|[etrace](etrace)          | HH    | Logic Analyzer                        |
|[gpio](gpio)              | HH    | General Purpose IO                    |
|[mio](mio)                | HH    | Mini-IO: lightweight parallel link    |
|[pic](pic)                | SI    | Programmable interrupt controller     |
|[parallella](parallella)  | FPGA  | Parallella FPGA logic                 |
|[risc-v](risc-v)          | HH    | RISC-V implementation                 |
|[spi](spi)                | HH    | SPI master/slave                      |
|[verilog](verilog)        | HH    | Verilog referenca material            |
|[xilibs](xilibs)          | FPGA  | Xilinx simulation models              |

**NOTES:**
* "SI"= Silicon validated
* "FPGA" =  FPGA validated
* "HH" =  Hard hat area (work in progress)

## HOW TO SIMULATE

```sh
./build.sh gpio/dv/dut_gpio.v         # compile gpio testbench (example)
./sim.sh gpio/dv/tests/test_regs.emf  # run a simulation with "test_regs.emf"
./view.sh                             # open the waveform with gtkwave
```

## LICENSE
The OH! repository source code is licensed under the MIT license unless otherwise specified. See [LICENSE](LICENSE) for MIT copyright terms. Design specific licenses can be found in the folder root (eg: aes/LICENSE) 

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

# VERILOG CODING METHODOLOGY

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

## DESIGN GUIDELINES

* Separate the configuration from the design
* Separate the design from the testbench
* Separate the test from the testbench
* When possible/reasonable use 64b boundaries for scalable registers
* When posible place multi bit fields on nibble boundaries
* All registers should have "0" as default value on reset
* Only include reset values if absolutely needed
* More to come...

## DOCUMENTATION GUIDELINES

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

## MODULE SIGNOFF CHECKLIST

* Is the block datasheet complete and accurate?
* Is there a user guide?
* Is there a script/make file for building/testing the design?
* Is there a self testing testbench?
* Is there an auotomated synthesis script?
* Is the driver written?
* Is there a demo example?
* Is the the block Silicon and FPGA validated?

----
[picture-license](https://commons.wikimedia.org/wiki/File:Lego_Color_Bricks.jpg)

