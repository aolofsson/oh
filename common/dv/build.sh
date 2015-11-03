#!/bin/bash
dut=$1
n=$2
rm -r *.trace
iverilog -g2005 -DCFG_N=${n} -f ../../common/dv/libs.cmd dut_${dut}.v -pRECURSIVE_MOD_LIMIT=10 -o ${dut}_model.elf 

#-Wall

