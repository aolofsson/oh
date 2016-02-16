#SET PATH
#set LOCALPATH [file dirname [ info script ]]
set LOCALPATH "."
################################
# STEP1: SETUP PROCESS
################################

source $LOCALPATH/01_setup_process.tcl

################################
# STEP2: SETUP TOOL
################################

source $LOCALPATH/02_setup_tool.tcl

################################
# STEP3: READ DESIGN FILES
################################

source $LOCALPATH/03_read_design.tcl

################################
# STEP4: READ CONSTRAINTS 
################################

source $LOCALPATH/04_read_constraints.tcl

################################
# STEP5: SETUP CORNERS
################################

source $LOCALPATH/05_setup_corners.tcl

################################
# STEP6: READ FLROOPLAN
################################

source $LOCALPATH/06_floorplan.tcl

################################
# STEP7: CHECK DESIGN
################################

source $LOCALPATH/07_check_design.tcl

################################
# STEP8: COMPILE
################################

source $LOCALPATH/08_compile.tcl

################################
# STEP9: DFT
################################

source $LOCALPATH/09_dft.tcl

################################
# STEP10: OPTIMIZE 
################################

source $LOCALPATH/10_optimize.tcl

################################
# STEP11: WRITE NETLIST (AND OTHER FILES)
################################

source $LOCALPATH/11_write_netlist.tcl

#exit

