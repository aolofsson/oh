###########################################################
# DEFINITIONS
###########################################################
set design system
set projdir parallella_headless
set root "../../.."
set partname "xc7z020clg400-1"
set archive [concat $design.zip]
set report_dir  $projdir/reports
set results_dir $projdir/results

#Make this a list (+foreach)
set local_repos ./

set hdl_files [list \
                   ../../hdl/parallella_headless.v \
                  ]

set constraints_files [list \
			   ./parallella_timing.xdc \
			   ./parallella_io.xdc \
			   ./parallella_7020_io.xdc \
		      ]

###########################################################
# CREATE PROJECT
###########################################################
create_project -force $design $projdir -part $partname
set_property target_language Verilog [current_project]

###########################################################
# Create Report/Results Directory
###########################################################
if ![file exists $report_dir]  {file mkdir $report_dir}
if ![file exists $results_dir] {file mkdir $results_dir}

###########################################################
# Add eLink IP to IP Repository
###########################################################

set other_repos [get_property ip_repo_paths [current_project]]
set_property  ip_repo_paths  "$local_repos $other_repos" [current_project]

update_ip_catalog

###########################################################
# CREATE BLOCK DESIGN (GUI/TCL COMBO)
###########################################################
   
create_bd_design "system"

source $projdir/system_bd.tcl
make_wrapper -files [get_files $projdir/${design}.srcs/sources_1/bd/system/system.bd] -top

###########################################################
# ADD FILES
###########################################################

#HDL
if {[string equal [get_filesets -quiet sources_1] ""]} {
    create_fileset -srcset sources_1
}
set top_wrapper $projdir/${design}.srcs/sources_1/bd/system/hdl/system_wrapper.v
add_files -norecurse -fileset [get_filesets sources_1] $top_wrapper
add_files -norecurse -fileset [get_filesets sources_1] $hdl_files

#CONSTRAINTS
if {[string equal [get_filesets -quiet constraints_1] ""]} {
  create_fileset -constrset constraints_1
}
if {[llength $constraints_files] != 0} {
    add_files -norecurse -fileset [get_filesets constraints_1] $constraints_files
}


