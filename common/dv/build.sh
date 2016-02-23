#!/bin/bash

DV_FILE=$1
DUT_FILE=$2
CFG=$3
LIBS=$OH_HOME/common/dv/libs.cmd

iverilog -g2005 -DTARGET_SIM=1 $CFG $DV_FILE $DUT_FILE -f $LIBS -o dut.bin



