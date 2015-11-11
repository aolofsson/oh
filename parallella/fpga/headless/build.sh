#!/bin/bash
vivado -mode batch -source run.tcl
rm system_wrapper.bit.bin bit2bin.bin
bootgen -image bit2bin.bif -split bin 
cp system_wrapper.bit.bin parallella.bit.bin
