Vanilla chip synthesis flow
=====================================

The following TCL mush be defined before running the flow. Also, clearly the vendor specific files must be in place.

## Required Shell Variables

| SHELL VARIABLE   | DESCRIPTION                         |
|------------------|-------------------------------------|
| $PROCESS_HOME    | Path to foundry process             |
| $OH_HOME         | Path to OH repo home                |

## Required TCL Variables

| TCL VARIABLE     | DESCRIPTION                         |
|------------------|-------------------------------------|
| $OH_VENDOR       | synopsys, cadence, etc              |
| $OH_TOOL         | dc, rc, etc                         |
| $OH_DESIGN       | Name of top level module            |
| $OH_FILES        | Design files                        |
| $OH_LIBS         | Synthesis libraries (ex: my_svtlib) |
| $OH_MACROS       | Hard macros in design (ex: my_sram) |
| $OH_FLOORPLAN    | Floorplanning file (tcl)            |
| $OH_CONSTRAINTS  | Timing constraints file             |
                
## Example: (my_vars.tcl)**

```tcl
set OH_VENDOR     "synopsys"

set OH_TOOl       "dc"

set OH_DESIGN     "ecore"

set OH_LIBS       ""

set OH_MACROS     ""

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

set OH_CONSTRAINTS       ${OH_DESIGN}.sdc

set OH_FLOORPLAN         ${OH_DESIGN}_floorplan.tcl

```

## Usage

```
>> cd 
>> dc_shell -topographical_mode
dc_shell> source $EPIPHANY_HOME/ecore/chip/synthesis/my_vars.tcl
dc_shell> source $OH_HOME/chip/common/synthesis/run.tcl
```
