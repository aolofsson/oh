#!/bin/bash

./scripts/build.sh src/$1/dv/dut_$1.v
./scripts/sim.sh src/$1/dv/tests/test_basic.emf


