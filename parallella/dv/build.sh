#!/bin/bash
top="../hdl/parallella_basic.v"
iverilog -g2005 -DTARGET_SIMPLE=1 -DTARGET_XILINX=1 $top -f ../../common/dv/libs.cmd -o ${dut}.vvp 

#-pfileline=1
#-Wall

