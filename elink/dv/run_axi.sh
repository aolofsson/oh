#!/bin/bash
if [ -e "test_0.emf" ]
then
    rm test_0.emf
fi
cp $1 test_0.emf
./axi_elink.vvp
