#!/bin/bash

./build.sh $1/dv/dut_$1.v
./sim.sh $1/dv/tests/test_basic.emf

