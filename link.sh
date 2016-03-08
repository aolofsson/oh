#!/bin/bash

############################################################################
# Icarus Verilog build script for OH! 
# Requires $OH_HOME variable to be set
# Input argument should be the "device under test". In general this 
# would be something like "elink/hdl/dut_elink.v"
############################################################################

DUT=$1
./link.sh
##############################
#Create directory of all links
##############################
if [ -d "symlinks" ]
then
    rm -r symlinks
fi
mkdir -p $OH_HOME/symlinks/hdl
mkdir -p $OH_HOME/symlinks/dv
pushd $OH_HOME/symlinks/hdl
ln -s ../../*/hdl/*.{v,vh} .
cd ../dv
ln -s ../../*/dv/*.v .
popd
##############################
#Build
###############################
iverilog -g2005\
 -DTARGET_SIM=1\
 $DUT\
 $OH_HOME/symlinks/dv/dv_top.v\
 -y .\
 -y $OH_HOME/symlinks/hdl\
 -y $OH_HOME/symlinks/dv\
 -I $OH_HOME/symlinks/hdl\
 -o dut.bin\
