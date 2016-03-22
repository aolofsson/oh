
----
## How to create a "Hello world" in verilog?

```verilog

module hello();

   initial
     begin
        $display ("Hello World!");
     end
   
endmodule
```

----
## How to write a verilog testbench?

EXAMPLE

----
## How to run a verilog simulation?

```

EXAMPLE

----
## How to write a state machine?

EXAMPLE

----
## How to create a synchronous reset flip-flop?
```
always @ (posedge clk)
  if(reset)
    q <= 1'b0;
  else
    q <= d;
```

EXAMPLE

----
## How to create an asynchronous reset flip-flop?
```
always @ (posedge clk or posedge reset)
  if(reset)
    q <= 1'b0;
  else
    q <= d;
```
----
## How to synchronize a reset across clock domains?
[EXAMPLE](http://github.com/parallella/oh/common/hdl/oh_dsync.v)

----
## How to print a number/string with no leading white space?
```
$display("%0s\n", mystring);
```
----
## How to check for 'X' in test environments?
```
if(fail===1'bX)
```
[REFERENCE](http://www.sutherland-hdl.com/papers/2013-DVCon_In-love-with-my-X_paper.pdf)

----------------------------------------
## How to access hierarchical signals?
Use "."

----------------------------------------
## How to dump a waveform?
```
initial
begin
	$dumpfile("test.vcd"); //file name to dump into
	$dumpvars(0, top);     //dump top level module
	#10000
    $finish;               //end simulation
end
```

To dump the waves in .lxt2 format for gtkwave, set the following at the command line.

```
setenv IVERILOG_DUMPER lxt2

----------------------------------------
## How to initialize a memory from a file?

----------------------------------------
## How to view a waveform?
```
sudo apt-get install gtkwave
gtkwave test.vcd
```

-----------------------------------------
## How to reduce typing in emacs?
Use Verilog mode

-----------------------------------------
## What are the most important emacs mode keywords?

* /*AUTOARG*/
* /*AUTOINST*/
* /*AUTOWIRE*/
* /*AUTOINPUT*/
* /*AUTOOUTPUT*/
* /*AUTOTEMPLATE*/




