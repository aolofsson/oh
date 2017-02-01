#Design name ("system" recommended)
set design system

#Project directory ("." recommended)
set projdir ./

#Device name
#set partname "xczu9eg-ffvb1156-2L-e-es1"
set partname "xczu9eg-ffvb1156-2L-e-es2"

#Paths to all IP blocks to use in Vivado "system.bd"

set ip_repos [list "../zcu102_base"]

#All source files
set hdl_files []

#All constraints files
set constraints_files [list \
			   ../zcu102_timing.xdc \
			   ../zcu102_io.xdc \
			  ]

###########################################################
# PREPARE FOR SYNTHESIS
###########################################################
set oh_synthesis_options "-verilog_define CFG_ASIC=0"
