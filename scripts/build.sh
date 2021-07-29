#!/bin/bash

############################################################################
# Icarus Verilog build script for OH! 
#
# Requires $OH_HOME variable to be set
#
# Example: ./scripts/build.sh elink/hdl/dut_elink.v
#
############################################################################

##############################
#Build
###############################
iverilog -g2005\
 -DTARGET_SIM=1\
 -DCFG_ASIC=0\
 -f $OH_HOME/scripts/libs.cmd \
 -o dut.bin $1


