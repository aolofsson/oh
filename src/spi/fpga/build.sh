#!/bin/bash

#clean up
rm system_wrapper.bit.bin bit2bin.bin

#package IP
vivado -mode batch -source package.tcl

#create bit stream
vivado -mode batch -source run.tcl

#xilinx stuff...
bootgen -image bit2bin.bif -split bin 
cp system_wrapper.bit.bin parallella.bit.bin

