
----------------------------------------
## How to create a "hello world" in verilog?

----------------------------------------
## How to run a simulation?

----------------------------------------
## How to write a testbench?

----------------------------------------
## How to create a synchronous flip-flop?

----------------------------------------
## How to create an asynchronous flip-flop?

----------------------------------------
## How to synchronize a reset across clock domains?

----------------------------------------
## How to pass parameters at run time?

----------------------------------------
## How to parametrize a module?

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
----------------------------------------
## How to create a memory?
```

```

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








