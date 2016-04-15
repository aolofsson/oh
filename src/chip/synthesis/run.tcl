#SET PATH
set LOCALPATH [file dirname [ info script ]]

################################
# SETUP PROCESS
################################

source $env(PROCESS_HOME)/eda/$OH_VENDOR/setup_process.tcl

################################
# CHECK ENVIRONMENT VARIABLES
################################

set OH_VENDOR "synopsys"
set OH_MACROS ""
set OH_TARGET ""

if {[string match synopsys $OH_VENDOR]} {
    set OH_TOOL "dc"
} elseif {[string match cadence $OH_VENDOR]} {
    set OH_TOOL "rc"
} elseif {[string match xilinx $OH_VENDOR]} {
    set OH_TOOL "vivado"
}

# Check that all variabls are defined
# If not defined exit!
puts $OH_DESIGN
puts $OH_TOP
puts $OH_CFG
puts $OH_LIBS
puts $OH_FLOORPLAN
puts $OH_VENDOR
puts $OH_TOOL
puts $OH_TARGET
puts $OH_MACROS
puts $OH_LAYER_MIN
puts $OH_LAYER_MAX
puts $OH_LIBPATH
puts $OH_TECHFILE
puts $OH_MAP
puts $OH_RCMODEL_MAX
puts $OH_RCMODEL_MIN

################################
# STEP1: SETUP TOOL
################################

source $LOCALPATH/01_setup_tool.tcl

################################
# STEP2: READ DESIGN FILES
################################

source $LOCALPATH/02_read_design.tcl

################################
# STEP3: READ CONSTRAINTS 
################################

source $LOCALPATH/03_read_constraints.tcl

################################
# STEP4: READ FLROOPLAN
################################

source $LOCALPATH/04_floorplan.tcl

################################
# STEP5: COMPILE
################################

source $LOCALPATH/05_compile.tcl

################################
# STEP6: DFT
################################

source $LOCALPATH/06_dft.tcl

################################
# STEP7: OPTIMIZE 
################################

source $LOCALPATH/07_optimize.tcl

################################
# STEP8: WRITE NETLIST/REPORTS
################################

source $LOCALPATH/08_signoff.tcl

#exit

