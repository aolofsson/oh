#SET PATH
set LOCALPATH [file dirname [ info script ]]

set OH_VENDOR synopsys
set OH_TOOL   dc

################################
# STEP1: SETUP PROCESS
################################

source $LOCALPATH/01_setup_process.tcl

################################
# STEP2: SETUP LIBRARIES
################################

source $LOCALPATH/02_setup_libs.tcl

################################
# STEP3: CONFIGURE TOOL
################################

source $LOCALPATH/03_configure_tool.tcl

################################
# STEP4: READ DESIGN FILES
################################

source $LOCALPATH/04_read_design.tcl

################################
# STEP5: READ CONSTRAINTS 
################################

source $LOCALPATH/05_read_constraints.tcl

################################
# STEP6: SETUP CORNERS
################################

source $LOCALPATH/06_setup_corners.tcl

################################
# STEP7: READ FLROOPLAN
################################

source $LOCALPATH/07_floorplan.tcl

################################
# STEP8: CHECK DESIGN
################################

source $LOCALPATH/08_check_design.tcl

################################
# STEP9: COMPILE
################################

source $LOCALPATH/09_compile.tcl

################################
# STEP10: DFT
################################

source $LOCALPATH/10_dft.tcl

################################
# STEP11: OPTIMIZE 
################################

source $LOCALPATH/11_optimize.tcl

################################
# STEP12: WRITE NETLIST (AND OTHER FILES)
################################

source $LOCALPATH/12_write_netlist.tcl

exit

