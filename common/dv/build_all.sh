#!/bin/bash

DV=../../common/dv/dv_top.v
LIBS=$OH_HOME/common/dv/libs.cmd

declare -a core_arr=("dut_oh_debouncer")
declare -a cfg_arr=("")

for core in "${core_arr[@]}"
do
    for cfg in "${cfg_arr[@]}"
    do
	iverilog -g2005 -DTARGET_SIM=1 $cfg $core.v $DV -f $LIBS -o $core.bin
    done

done
