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
# STEP4: SETUP CORNERS
################################

source $LOCALPATH/04_setup_corners.tcl

################################
# STEP5: READ FLROOPLAN
################################

source $LOCALPATH/05_floorplan.tcl

################################
# STEP6: CHECK DESIGN
################################

source $LOCALPATH/06_check_design.tcl

################################
# STEP7: COMPILE
################################

source $LOCALPATH/07_compile.tcl

################################
# STEP8: DFT
################################

source $LOCALPATH/08_dft.tcl

################################
# STEP9: OPTIMIZE 
################################

source $LOCALPATH/09_optimize.tcl

################################
# STEP10: WRITE NETLIST (AND OTHER FILES)
################################

source $LOCALPATH/10_write_netlist.tcl

#exit

