#!/bin/bash

# Compiles all dut*.v files in this directory

DV=../../common/dv/dv_top.v
LIBS=$OH_HOME/common/dv/libs.cmd
CFG="cfg_random.v"

for file in dut*.v
do
    root=${file%%.*}
    iverilog -g2005 -DTARGET_SIM=1 $CFG $file $DV -f $LIBS -o $root.bin   
done
