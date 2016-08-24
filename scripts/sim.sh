#!/bin/bash
if [ -L "test_0.emf" ]
then
    unlink test_0.emf
fi
ln -s $1 test_0.emf
./dut.bin
