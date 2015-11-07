
#Design name ("system" recommended)
set design system

#Project directory ("." recommended)
set projdir ./

#Device name
set partname "xc7z020clg400-1"

#Paths to all IP blocks to use in Vivado "system.bd"

set ip_repos [list "../parallella_base"]

#All source files
set hdl_files []

#All constraints files
set constraints_files [list \
			   ../parallella_timing.xdc \
			   ../parallella_io.xdc \
			   ../parallella_7020_io.xdc \
			  ]
