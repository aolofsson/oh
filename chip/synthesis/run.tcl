#SET PATH
#set LOCALPATH [file dirname [ info script ]]
set LOCALPATH "."
################################
# SETUP PROCESS
################################

source $LOCALPATH/setup_process.tcl

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

