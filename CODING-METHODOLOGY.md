CODING METHODOLOGY
========================================================

## STANDARD
* Verilog 2005

## STYLE
* Max 80 chars per line
* One input/output statement per line
* Only single line // comments, no /*..*/
* Use vector size index on every statement, ie "assign a[7:0] = myvec[7:0];"
* Use parameters for reusability and readability
* Use many short statements in place of one big one
* Define wires/regs at beginning of file
* Align input names/comments in column like fashion
* Avoid redundant begin..end statements
* Capitalize macros and constants
* Use lower case for all signal names
* Use y down to x vectors
* Use a naming methodology and document it
* Comment every module port
* Do not hard code numerical values in body of code

## METHODLOGY
* Use `include files for constants
* Use `ifndef _CONSTANTS_V to include file only once
* No timescales in design files (only in testbench)
* No delay statements (not even in flops/latches)
* No logic at top level design structures
* One module per file
* Prefer parameters in place of global defines
* Do not use casex
* Use active low reset
* Avoid redundant resets
* Don't use defparam
* Place a useful comment every 5-10 lines
* If you are going to use async reset, use oh_rsync.v
* Use for loops and generate to improve readability
* If you have to mix clock edges, isolate to discrete modules
* Only use nonblocking assignments in always stataments
* Use default statements in all case statements
* Don't use EDA tool pragmas
* Only use synthesizable constructs
* Allowed keywords: assign, always, input, output, wire, reg, module, endmodule, if/else, case, casez, ~,|,&,^,==, >>, <<, >, <,?,posedge, negedge, generate, for(...), begin, end, $signed,




