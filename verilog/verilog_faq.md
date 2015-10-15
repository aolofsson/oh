
----
## How to write a verilog module?

----
## How to write a verilog testbench?

----
## How to run a verilog simulation?

----
## How to create a synchronous flip-flop?
```
always @ (posedge clk)
  if(reset)
    q <= 1'b0;
  else
   q <= d;
```
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

Use the 

```

```

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




