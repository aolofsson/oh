#!/bin/bash


list=(accelerator elink emailbox emmu gpio mio pic spi) 

for dut in ${list[*]}
do
    echo "**Building $dut"
    ./build.sh $dut/dv/dut_$dut.v
done
cd ../

