#!/bin/bash

set -e

EINCS=../include
SCRIPT=$(readlink -f "$0")
EXEPATH=$(dirname "$SCRIPT")
cd $EXEPATH

# Create the binaries directory
mkdir -p bin

# Build all tests
gcc src/e-access.c -o bin/e-access -I ${EINCS}


