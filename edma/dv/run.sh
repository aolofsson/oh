#!/bin/bash
#Compiling sim
iverilog 
         -y ../hdl \
          dv_edma.v

#Running sim
./a.out
