#!/bin/bash


# LFSR
iverilog -DOH_CTRL="8'h12" -DOH_N=5  sim.v tb_oh_lfsr.v -y ../rtl/ -y . ; ./a.out
iverilog -DOH_CTRL="8'h9"  -DOH_N=4  sim.v tb_oh_lfsr.v -y ../rtl/ -y . ; ./a.out
