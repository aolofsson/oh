#!/bin/bash

#ARGUMENTS
#$1=name of "dut*.bin" to simulate
#$2=path to test to run

#Uses BASH $RANDOM variable to set seed

rm test_0.emf
ln -s $2 test_0.emf
./$1 +SEED=$RANDOM


