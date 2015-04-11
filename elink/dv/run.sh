#!/bin/bash

#Linting in Verilator
#verilator --lint-only -F elink.cmd -DTARGET_VERILATOR

#Compiling sim
iverilog -f elink.cmd

#Running sim
./a.out
