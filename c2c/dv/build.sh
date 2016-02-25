#!/bin/bash

# Compiles all dut*.v files in this directory

DV=../../common/dv/dv_top.v
DUT=dut_c2c.v
LIBS=$OH_HOME/common/dv/libs.cmd
CFG="../hdl/cfg_c2c.v"

root=${DUT%%.*}
iverilog -g2005 -DTARGET_SIM=1 $CFG $DUT $DV -f $LIBS -o $root.bin   

