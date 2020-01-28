#!/bin/bash

#Script to collect view from all the directories

#DOCS
mkdir -p links/docs
cd links/docs
ln -s ../../proprietary/*/TSMCHOME/digital/Documentation/documents/* .
cd ../../

#VERILOG
mkdir -p links/verilog
cd links/verilog
ln -s ../../proprietary/*/TSMCHOME/digital/Front_End/verilog/* .
cd ../../

#SPICE
mkdir -p links/spice
cd links/spice
ln -s ../../proprietary/*/TSMCHOME/digital/Back_End/lpe_spice/* .
cd ../../

#GDS
mkdir -p links/gds
cd links/gds
ln -s ../../proprietary/*/GDS/TSMCHOME/digital/Back_End/gds/* .
cd ../../

#LEF
mkdir -p links/lef
cd links/lef
ln -s ../../proprietary/*/LEF/TSMCHOME/digital/Back_End/lef/* .
cd ../../


