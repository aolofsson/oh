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

source $LOCALPATH/01_setup.tcl

################################
# STEP2: READ NETLIST
################################

source $LOCALPATH/02_nelist.tcl

################################
# STEP3: CONSTRAIN DESIGN
################################

source $LOCALPATH/03_constrain.tcl

################################
# STEP4: READ FLOORPLAN
################################

source $LOCALPATH/04_floorplan.tcl

################################
# STEP5: PLACE DESIGN
################################

source $LOCALPATH/05_place.tcl

################################
# STEP6: CLOCKS
################################

source $LOCALPATH/06_clock.tcl

################################
# STEP7: ROUTE
################################

source $LOCALPATH/07_route.tcl

################################
# STEP8: CLEANUP
################################

source $LOCALPATH/08_cleanup.tcl

################################
# STEP8: SIGNOFF
################################

source $LOCALPATH/09_signoff.tcl

#exit

