#!/bin/bash
#
#
#
#
#
#
#
dut="e16ref"
top="../../common/dv/dv_top.v"
iverilog -g2005 -DTARGET_SIM=1 -DTARGET_XILINX=1 elink_e16_model.v $top dut_${dut}.v -f ../../common/dv/libs.cmd -o ${dut}.vvp 


#-pfileline=1
#-Wall

