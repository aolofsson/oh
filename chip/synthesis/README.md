Vanilla chip synthesis flow
=====================================

The following TCL mush be defined before running the flow. Also, clearly the vendor specific files must be in place.

# SYNTHESIS FLOW

| STEP   | FUNCTION        | NOTES                                       |
|--------|-----------------|---------------------------------------------| 
| 00     | setup_process   | Setup tech files + libraries                |
| 01     | setup_tool      | Setup synthesis tool                        | 
| 02     | read_design     | Read in design files                        | 
| 03     | read_constraints| Read in design constaints                   | 
| 04     | setup_corners   | Setup up operating conditions               | 
| 05     | floorplan       | Read floorplan information                  | 
| 06     | check_design    | Check design integrity                      | 
| 07     | compile         | Comile HDL to gates                         | 
| 08     | dft             | Insert test features (scan)                 | 
| 09     | optimize        | Seconday optimization step                  | 
| 10     | write_netlist   | Write out netlists and reports              | 
                
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
