#!/bin/bash

dut="spi"
top="../../common/dv/dv_top.v"
iverilog -g2005 -DTARGET_SIM=1 -DTARGET_XILINX=1 $top dut_${dut}.v -f ../../common/dv/libs.cmd -o ${dut}.vvp $1 

#-pfileline=1
#-Wall
