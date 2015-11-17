#!/bin/bash
n=$1
#generate test
../../emesh/dv/egen.pl -rand -n $n  > ./tmp.test
#take split
egrep    "READ|WRITE" ./tmp.test > tests/test_random.memh
egrep -v "READ|WRITE" ./tmp.test > tests/test_random.exp

