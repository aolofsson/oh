#!/bin/bash

#Linting in Verilator
#verilator --lint-only -F elink.cmd -DTARGET_VERILATOR dv_elink.v

#a sorry hack, too tired to get it right, please fix...
TRANS=$(wc -l test.memh)
TRANS=${TRANS:0:3}
#RANDOM TEST
iverilog -I../hdl -I../../emailbox/hdl -f elink.cmd -DMANUAL -DTRANS=$TRANS -DTESTNAME=test.memh -DTARGET_XILINX -DSIM
#iverilog -f elink.cmd -DAUTO

#Running sim
./a.out
