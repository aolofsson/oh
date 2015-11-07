###########################################################
# DEFINITIONS
###########################################################
set design parallella_headless
set projdir $design
set root "../../.."
set partname "xc7z020clg400-1"
set archive [concat $design.zip]
set report_dir  $projdir/reports
set results_dir $projdir/results

#Make this a list (+foreach)
set local_ip_repo ./

###########################################################
# CREATE PROJECT
###########################################################
create_project -force $design $projdir -part $partname
set_property target_language Verilog [current_project]

###########################################################
# Create Report/Results Directory
###########################################################
if ![file exists $report_dir]  {file mkdir -p $report_dir}
if ![file exists $results_dir] {file mkdir -p $results_dir}

###########################################################
# Add eLink IP to IP Repository
###########################################################

set ip_repo_paths [get_property ip_repo_paths [current_project]]
set_property  ip_repo_paths  "$elink_ip_repo_dir $ip_repo_paths" [current_project]

update_ip_catalog

###########################################################
# CREATE BLOCK DESIGN (GUI/TCL COMBO)
###########################################################
   
create_bd_design "system"

source 

validate_bd_design

write_bd_tcl -force $projdir/system_bd.tcl

make_wrapper -files [get_files $projdir/${design}.srcs/sources_1/bd/system/system.bd] -top

###########################################################
# ADD FILES
###########################################################

add_files -norecurse $projdir/${design}.srcs/sources_1/bd/system/hdl/system_wrapper.v

add_files -fileset constrs_1 -norecurse ./${design}_io.xdc
add_files -fileset constrs_1 -norecurse ./${design}_timing.xdc

###########################################################
# Implement Design
###########################################################
launch_runs synth_1
wait_on_run synth_1
launch_runs impl_1
wait_on_run impl_1

###########################################################
# Write Bitstream
###########################################################
launch_runs impl_1 -to_step write_bitstream


