CODING METHODOLOGY
========================================================

## STANDARD
* Verilog 2005

## STYLE
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

## METHODLOGY
* Use `include files for constants
* Use `ifndef _CONSTANTS_V to include file only once
* No timescales in design files (only in testbench)
* No delay statements in design
* No logic statements in top level design structures
* One module per file
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
* Allowed keywords: assign, always, input, output, wire, reg, module, endmodule, if/else, case, casez, ~,|,&,^,==, >>, <<, >, <,?,posedge, negedge, generate, for(...), begin, end, $signed,




