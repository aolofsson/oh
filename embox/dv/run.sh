#!/bin/bash
#Compiling sim
iverilog -y ../../fifos/hdl/ \
         -y ../../common/hdl \
         -y ../../memory/hdl \
         -y ../hdl \
          dv_embox.v

#Running sim
./a.out
