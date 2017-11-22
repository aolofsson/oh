#!/bin/bash

############################################################################
# Icarus Verilog build script for OH! 
#
# Requires $OH_HOME variable to be set
#
# Example: ./scripts/build.sh elink/hdl/dut_elink.v
#
############################################################################

DUT=$1

##############################
#Create directory of all links
##############################
$OH_HOME/scripts/link.sh

##############################
#Build
###############################
iverilog -g2005\
 -DTARGET_SIM=1\
 -DCFG_ASIC=0\
 -DCFG_PLATFORM=\"ZYNQ\"\
 $DUT\
 $OH_HOME/symlinks/dv/dv_top.v\
 -y .\
 -y $OH_HOME/symlinks/hdl\
 -y $OH_HOME/symlinks/dv\
 -I $OH_HOME/symlinks/hdl\
 -o dut.bin\
