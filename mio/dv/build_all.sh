#!/bin/bash

DV=../../common/dv/dv_top.v
LIBS=$OH_HOME/common/dv/libs.cmd

declare -a core_arr=("dut_c2c")
declare -a cfg_arr=("../hdl/cfg_c2c.v")

for core in "${core_arr[@]}"
do
    for cfg in "${cfg_arr[@]}"
    do
	iverilog -g2005 -DTARGET_SIM=1 $cfg $core.v $DV -f $LIBS -o $core.bin
    done

done
