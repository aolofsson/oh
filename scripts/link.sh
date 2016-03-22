#!/bin/bash

##############################
#Create directory of all links
##############################
if [ -d "symlinks" ]
then
    rm -r symlinks
fi
mkdir -p $OH_HOME/symlinks/hdl
mkdir -p $OH_HOME/symlinks/dv
pushd $OH_HOME/symlinks/hdl > /dev/null
ln -s ../../src/*/hdl/*.{v,vh} .
cd ../dv
ln -s ../../src/*/dv/*.v .
popd > /dev/null

