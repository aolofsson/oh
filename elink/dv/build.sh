#!/bin/bash

dut="elink"
top="../../common/dv/dv_top.v"
iverilog -g2005 -DTARGET_SIM=1 -DTARGET_XILINX=1 $top dut_${dut}.v -f ../../common/dv/libs.cmd -o ${dut}.vvp 

#-Wtimescale

#PUT TARGET_SIM 

#-pfileline=1
#-Wall

