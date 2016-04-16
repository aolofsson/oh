OH!: Place and Route Flow
=====================================

This guide documents the OH! back end place and route flow that takes the design from netlist to GDS. The flow requires certain TCL and Shell variables to be setup, as defined [HERE](../README.md).

The synthesis flow scripts call EDA specific scipts as needed. 

# SYNTHESIS FLOW

| FILE              | NOTES                                            |
|-------------------|--------------------------------------------------| 
| 01_setup.tcl      | Setup synthesis tool                             | 
| 02_netlist.tcl    | Read in netlist                                  | 
| 03_constrain.tcl  | Constrain design                                 | 
| 04_floorplan.tcl  | Read floorplan information                       |
| 05_place.tcl      | Place design                                     |
| 06_clock.tcl      | Place and route clock nets                       |
| 07_route.tcl      | Route all other nets                             |
| 08_cleanup.tcl    | Cleanup (antenna, fill, etc)                     |
| 09_signoff.tcl    | DRC/LVS signoff, reports, final GDS out          | 
                
## Example Setup File ("example.tcl")

```tcl
set OH_VENDOR     "synopsys"

set OH_TOOl       "icc"

set OH_DESIGN     "ecore"

set OH_LIBS       "svtlib"

set OH_MACROS     "sram64x1024"

set OH_FILES      "${OH_DESIGN}_syn.vg"

set OH_CONSTRAINTS  "${OH_DESIGN}.sdc"

set OH_FLOORPLAN    "${OH_DESIGN}_floorplan.tcl"

```

## Usage

```
>> cd 
>> dc_shell -topographical_mode
dc_shell> source $env(OH_HOME)/chip/synthesis/example.tcl
```
