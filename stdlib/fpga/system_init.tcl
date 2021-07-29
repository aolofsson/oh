###########################################################
# OH! Specific constants
###########################################################

###########################################################
# CREATE PROJECT
###########################################################
create_project -force $design $projdir -part $partname
set_property target_language Verilog [current_project]

if {[info exists board_part]} {
    set_property board_part $board_part [current_project]
}

###########################################################
# Create Report/Results Directory
###########################################################
set report_dir  $projdir/reports
set results_dir $projdir/results
if ![file exists $report_dir]  {file mkdir $report_dir}
if ![file exists $results_dir] {file mkdir $results_dir}

###########################################################
# Add IP Repositories to search path
###########################################################

set other_repos [get_property ip_repo_paths [current_project]]
set_property  ip_repo_paths  "$ip_repos $other_repos" [current_project]

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

if {[llength $hdl_files] != 0} {
    add_files -norecurse -fileset [get_filesets sources_1] $hdl_files
}

#CONSTRAINTS
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}
if {[llength $constraints_files] != 0} {
    add_files -norecurse -fileset [get_filesets constrs_1] $constraints_files
}



