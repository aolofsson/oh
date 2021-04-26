
ETRACE INTRODUCTION
=====================================

The "etrace" module is a simple parametrized logic analyzer that captures a set of input signals in dual ported memory. Captured values can be read out through a memory mapped interface. Each sampled value is stored together with a counter time stamp. The vector is sampled on the rising edge of "trace_clk".

## USAGE
1. Instantiate in block and hook up signals. Use the dv/dut_etrace.v as an example

2. Enable the tracer by setting the trace_trigger to high AND setting bit[0] of the ETRACE_CFG register(810F00000).

3. (sample signals for as long as you want)

4. Read back values through the mi interface: 810A00000,810A00004,etc







