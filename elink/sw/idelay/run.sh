#!/bin/bash

set -e

SCRIPT=$(readlink -f "$0")
EXEPATH=$(dirname "$SCRIPT")




#dumping disassembly
e-objdump -D bin/e-task.elf > DUMP

#running program
cd $EXEPATH/bin
./e-main.elf e-task.elf

