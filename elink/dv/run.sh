#!/bin/bash

#Linting in Verilator
#verilator --lint-only -F elink.cmd -DTARGET_VERILATOR

#a sorry hack, too tired to get it right, please fix...
TRANS=$(wc -l test.memh)
TRANS=${TRANS:0:3}
#RANDOM TEST
iverilog -f elink.cmd -DMANUAL -DTRANS=$TRANS -DTESTNAME=test.memh
#iverilog -f elink.cmd -DAUTO

#Running sim
./a.out
