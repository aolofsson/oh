#!/bin/bash
if [ -e "test_0.memh" ]
then
    rm test_0.memh
fi
cp $1 test_0.memh
./e16ref.vvp
