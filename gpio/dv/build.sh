#!/bin/bash

DV="../../common/dv/dv_top.v"
DUT="dut_gpio.v"
ROOT="gpio"
iverilog -o $ROOT.bin -g2005 -DTARGET_SIM=1 \
$DV \
$DUT \
-y ../hdl \
-y ../../common/hdl/ \
-y ../../common/dv/ \
-y ../../emesh/hdl/ \
-y ../../emesh/dv/ \
-I ../hdl


