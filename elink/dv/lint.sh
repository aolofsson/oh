#!/bin/bash
verilator --lint-only -f ../../common/dv/libs.cmd $1 -DTARGET_VERILATOR=1 -DTARGET_XILINX=1;
