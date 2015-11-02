
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
## How to create a synchronous flip-flop?
```
always @ (posedge clk)
  if(reset)
    q <= 1'b0;
  else
   q <= d;
```

EXAMPLE

----
## How to create an asynchronous flip-flop?
```
always @ (posedge clk or posedge reset)
  if(reset)
    q <= 1'b0;
  else
   q <= d;
```
----
## How to synchronize a reset across clock domains?
```
always @ (posedge tx_lclk_div4 or posedge tx_reset)
      if(tx_reset)
	reset_pipe_lclk_div4b[1:0] <= 2'b00;
      else
	reset_pipe_lclk_div4b[1:0]  <= {reset_pipe_lclk_div4b[0],1'b1};   

   assign etx_reset  = ~reset_pipe_lclk_div4b[1];
```
[EXAMPLE](http://github.com/parallella/oh/elink/hdl/etx_clocks.v)

----
## How to pass parameters at run time?

----
## How to parametrize a module?

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

http://www.sutherland-hdl.com/papers/2013-DVCon_In-love-with-my-X_paper.pdf

----------------------------------------
## What is the difference between a reg and a wire?

----------------------------------------
## How to access hierarchical signals?



Warning: only works in simulation, not in real designs.

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



```
initial
begin
	
end
```
----------------------------------------
## How to view a waveform?
```
sudo apt-get install gtkwave
gtkwave test.vcd
```


-----------------------------------------
## How to reduce typing in emacs?

[Use verilog mode](Use verilog mode)

-----------------------------------------
## What are the most important emacs mode keywords?

* /*AUTOARG*/
* /*AUTOINST*/
* /*AUTOWIRE*/
* /*AUTOINPUT*/
* /*AUTOOUTPUT*/
* /*AUTOTEMPLATE*/

----------------------------------------
## How do I implement function "X"?

Single ported memory
Dual ported memory
Synchronous FIFO
Asynchronous FIFO
Mux2
Mux4
Carry Save Adder
Synchronizer
Clock divider


