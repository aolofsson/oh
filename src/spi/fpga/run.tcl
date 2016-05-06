
#STEP1: DEFINE KEY PARAMETERS
source ./run_params.tcl

#STEP2: CREATE PROJECT AND READ IN FILES
source ../../common/fpga/system_init.tcl

#STEP 3 (OPTIONAL): EDIT system.bd in VIVADO gui, then go to STEP 4.
##...

#STEP 4: SYNTEHSIZE AND CREATE BITSTRAM
source ../../common/fpga/system_build.tcl
