#!/bin/bash
#Compiling sim
iverilog -f elink.cmd

#Running sim
./a.out
