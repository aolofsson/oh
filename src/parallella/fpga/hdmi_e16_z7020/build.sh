#!/bin/bash
rm system_wrapper.bit.bin bit2bin.bin
vivado -mode batch -source run.tcl
bootgen -image bit2bin.bif -split bin 
cp system_wrapper.bit.bin parallella_e16_hdmi_gpiose_7020.bit.bin
#archive results based on time stamp
