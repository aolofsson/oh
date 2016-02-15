Vendor agnostic synthesis wrappers
=====================================

The following TCL mush be defined before running the flow. Also, clearly the vendor specific files must be in place.


| VARIABLE         | DESCRIPTION                         |
|------------------|-------------------------------------|
| $OH_VENDOR       | synopsys, cadence, etc              |
| $OH_TOOL         | dc, rc, etc                         |
| $OH_DESIGN       | Name of top level module            |
| $OH_FILES        | Design files                        |
| $OH_FLOORPLAN    | Floorplanning file (tcl)            |
| $OH_CONSTRAINTS  | Timing constraints file             |
                
## Example
```tcl
set OH_DESIGN            "ecore"                      ; # top level module
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
                   +incdir+$env(EPIPHANY_HOME)/edma/hdl"; # verilog libraries

set OH_CONSTRAINTS       ${OH_DESIGN}.sdc           ; # constraints 
set OH_FLOORPLAN         ${OH_DESIGN}_floorplan.tcl ; # floorplan script

```

