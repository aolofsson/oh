###########################################################
# IPI
###########################################################

create_project -force project_ipi ./project_ipi -part xc7z020clg400-1

set_property target_language Verilog [current_project]


###########################################################
# Create Report/Results Directory
###########################################################

set report_dir  ./reports
set results_dir ./results

if ![file exists $report_dir]  {file mkdir $report_dir}
if ![file exists $results_dir] {file mkdir $results_dir}


###########################################################
# Add Interfaces to IP Repository
###########################################################

set interfaces_repo_dir ../interfaces_repository

set ip_repo_paths [get_property ip_repo_paths [current_project]]
set_property  ip_repo_paths  "$interfaces_repo_dir $ip_repo_paths" [current_project]

update_ip_catalog


###########################################################
# Add HLS IPs to IP Repository
###########################################################

set hls_ip_repo_dir ../hls_ip_repository

set ip_repo_paths [get_property ip_repo_paths [current_project]]
set_property  ip_repo_paths  "$hls_ip_repo_dir $ip_repo_paths" [current_project]

update_ip_catalog


###########################################################
# Add eLink IP to IP Repository
###########################################################

set elink_ip_repo_dir ../elink_ip_repository

set ip_repo_paths [get_property ip_repo_paths [current_project]]
set_property  ip_repo_paths  "$elink_ip_repo_dir $ip_repo_paths" [current_project]

update_ip_catalog


###########################################################
# Add ADI IPs to IP Repository
###########################################################

set adi_ip_repo_dir ../adi_ip_repository

set ip_repo_paths [get_property ip_repo_paths [current_project]]
set_property  ip_repo_paths  "$adi_ip_repo_dir $ip_repo_paths" [current_project]

update_ip_catalog


###########################################################
# Create Block Design
###########################################################
   
create_bd_design "parallella_bd"

source ./scripts/parallella_elink_base_bd.tcl

validate_bd_design


###########################################################
# Write BD TCL
###########################################################

write_bd_tcl -force ${results_dir}/parallella_elink_base_bd.tcl


###########################################################
# Create HDL Wrapper
###########################################################

make_wrapper -files [get_files C:/Parallella/ipi_parallella_elink_base/project_ipi/project_ipi.srcs/sources_1/bd/parallella_bd/parallella_bd.bd] -top

##
add_files -norecurse C:/Parallella/ipi_parallella_elink_base/project_ipi/project_ipi.srcs/sources_1/bd/parallella_bd/hdl/parallella_bd_wrapper.v
add_files -fileset constrs_1 -norecurse C:/Parallella/ipi_parallella_elink_base/sources/parallella_io.xdc
add_files -fileset constrs_1 -norecurse C:/Parallella/ipi_parallella_elink_base/sources/parallella_timing.xdc


###########################################################
# Implement Design
###########################################################
launch_runs synth_1
wait_on_run synth_1
launch_runs impl_1
wait_on_run impl_1




