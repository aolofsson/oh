#!/bin/bash

state=$1

SCRIPT=$(readlink -f "$0")
EXEPATH=$(dirname "$SCRIPT")
echo $EXEPATH
echo $state

echo "--Set EAST routing ctrlmode in FPGA--"
$EXEPATH/../bin/e-access 00000000_00000150_810f0210_05

echo "--Set EAST Epiphany link to half speed--"
$EXEPATH/../bin/e-access 00000000_00000001_88bf0300_05

echo "--Clear ctrlmode in FPGA--"
$EXEPATH/../bin/e-access 00000000_00000000_810f0210_05

echo "--Set NORTH routing ctrlmode in FPGA--"
$EXEPATH/../bin/e-access 00000000_00000110_810f0210_05

echo "--Write to North IO config register--"
$EXEPATH/../bin/e-access 00000000_03FFFFFF_80AF030C_05

echo "--Write to North IO data register--"
$EXEPATH/../bin/e-access 00000000_0000000${state}_80AF0318_05

echo "--Set back config register--"
$EXEPATH/../bin/e-access 00000000_00000000_810f0210_05

