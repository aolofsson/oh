#!/bin/bash
verilator -cc --debug -sv oh_mult.v -GN=16 -pvalue+N=16 --top-module oh_mult
