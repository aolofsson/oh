set LOCALPATH [file dirname [ info script ]]

######################################
# DESIGN SPECIFIC 
######################################

set OH_DESIGN     "ecore"

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

set OH_LIBS       "svtlib lvtlib";      # ip library names 

set OH_MACROS     "sram_macro";         # hard macro library names
 
set OH_VENDOR     "synopsys";           # eda vendor name   

set OH_TOOL       "dc";                 # name of eda vendor synthesis tool

######################################
# RUN SYNTHESIS
#####################################
source  $LOCALPATH/run.tcl

