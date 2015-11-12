#!/bin/bash
#
#
#
#
#
#
#
dut="elink"
top="../../common/dv/dv_top.v"
iverilog -g2005 -DTARGET_SIM=1 -DTARGET_XILINX=1  ../../memory/fpga/fifo_generator_v12_0/simulation/fifo_generator_vlog_beh.v  ../../memory/fpga/sim/fifo_async_104x32.v  $top dut_${dut}.v -f ../../common/dv/libs.cmd -o ${dut}.vvp

#PUT TARGET_SIM 

#-pfileline=1
#-Wall

