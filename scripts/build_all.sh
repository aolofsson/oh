#!/bin/bash

common/hdl/*.v

list=(accelerator elink emailbox emmu gpio mio pic spi) 

for dut in ${list[*]}
do
    echo "**Building $dut"
    $OH_HOME/scripts/build.sh $OH_HOME/src/$dut/dv/dut_$dut.v
done
cd ../

