OH!: Synthesis Flow
=====================================

This guide documents the OH! fron end synthesis flow that compiles Verilog HDL into a gate level netlist. The flow requires certain TCL and Shell variables to be setup, as defined [HERE](../README.md).

The synthesis flow scripts call EDA specific scipts as needed. 

# SYNTHESIS FLOW

| FILE             | NOTES                                       |
|------------------|---------------------------------------------| 
| 01_setup.tcl     | Setup synthesis tool                        | 
| 02_hdl.tcl       | Read in design files                        | 
| 03_constrain.tcl | Read in design constraints                  | 
| 04_floorplan.tcl | Setup floorplan                             | 
| 05_compile.tcl   | Comile HDL to gates                         | 
| 06_dft.tcl       | Insert test features (scan)                 | 
| 07_optimize.tcl  | Seconday optimization step                  | 
| 08_signoff.tcl   | Write out netlists and reports              | 
                
## Example Setup File ("example.tcl")

```tcl
set OH_VENDOR     "synopsys"

set OH_TOOl       "dc"

set OH_DESIGN     "ecore"

set OH_LIBS       "svtlib"

set OH_MACROS     "sram64x1024"

set OH_FILES      "../../../hdl/$OH_DESIGN.v             \
                   -y $env(OH_HOME)/emesh/hdl            \
                   -y $env(OH_HOME)/common/hdl           \
                   -y $env(EPIPHANY_HOME)/chip/hdl       \
                   -y $env(EPIPHANY_HOME)/ecore/hdl      \
                   -y $env(EPIPHANY_HOME)/emesh/hdl      \
                   -y $env(EPIPHANY_HOME)/edma/hdl       \
                   -y $env(EPIPHANY_HOME)/compute/hdl    \
                   -y $env(EPIPHANY_HOME)/memory/hdl     \
                   -y $env(EPIPHANY_HOME)/fpumm/hdl      \
                   +incdir+$env(EPIPHANY_HOME)/emesh/hdl \
                   +incdir+$env(EPIPHANY_HOME)/ecore/hdl \
                   +incdir+$env(EPIPHANY_HOME)/edma/hdl"

set OH_CONSTRAINTS  "${OH_DESIGN}.sdc"

set OH_FLOORPLAN    "${OH_DESIGN}_floorplan.tcl"

```

## Usage

```
>> cd 
>> dc_shell -topographical_mode
dc_shell> source $env(OH_HOME)/chip/synthesis/example.tcl
```
