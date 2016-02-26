#!/bin/bash

dut="elink"
top="../../common/dv/dv_top.v"
CFG="../hdl/elink_constants.vh"
iverilog -g2005 -DTARGET_SIM=1 $CFG $top dut_${dut}.v -f ../../common/dv/libs.cmd -o ${dut}.vvp $1

#-Wtimescale

#PUT TARGET_SIM 

#-pfileline=1
#-Wall

