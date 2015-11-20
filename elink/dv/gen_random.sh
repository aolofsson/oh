#!/bin/bash
#generate test
../../emesh/dv/egen.pl -rand -n $1 -bl $2 -32 > ./tmp.test
#take split
egrep    "READ|WRITE" ./tmp.test > tests/test_random.memh
egrep -v "READ|WRITE" ./tmp.test > tests/test_random.exp

