# NOTE: See UG1118 for more information

#########################################
# VARIABLES
#########################################
set design axi_elink
set root "../../.."
set partname "xc7z020clg400-1"
set archive [concat $design.zip]

set hdl_files [list \
		   $root/common/hdl \
		   $root/memory/hdl \
		   $root/emesh/hdl \
		   $root/emmu/hdl \
		   $root/emailbox/hdl \
		   $root/edma/hdl \
	           $root/elink/hdl \
		   $root/elink/hdl/axi_elink.v \
		  ]

set ip_files   [list \
		    $root/memory/ip/xilinx/fifo_async_104x32.xci \
		   ]

set constraints_files []

###########################################################
# Create Managed IP Project
###########################################################
close_project
create_project -force $design -part $partname 
set_property target_language Verilog [current_project]

###########################################################
# Create filesets and add files to project
###########################################################

#HDL
if {[string equal [get_filesets -quiet sources_1] ""]} {
    create_fileset -srcset sources_1
}

add_files -norecurse -fileset [get_filesets sources_1] $hdl_files

#CONSTRAINTS
if {[string equal [get_filesets -quiet constraints_1] ""]} {
  create_fileset -constrset constraints_1
}
if {[llength $constraints_files] != 0} {
    add_files -norecurse -fileset [get_filesets constraints_1] $constraints_files
}

#ADDING IP
if {[string equal [get_filesets -quiet ip_1] ""]} {
  create_fileset -srcset ip_1
}
if {[llength $ip_files] != 0} {
    add_files -norecurse -fileset [get_filesets ip_1] $ip_files
}

#RERUN/UPGRADE IP
upgrade_ip -srcset ip_1  [get_ips]
foreach file $ip_files {
    generate_target all [get_files $file]
    set obj  [create_ip_run -force [get_files $file]]
    launch_run -jobs 2 $obj
}

###########################################################
# SYNTHESIZE
###########################################################
set_property top $design [current_fileset]
launch_runs synth_1 -jobs 2

###########################################################
# Package
###########################################################


ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
ipx::check_integrity -quiet [ipx::current_core]


::ipx::package_project -force -root_dir $design
set c ::ipx::current_core
::set_property vendor              {www.parallella.org}    [$c]
::set_property library             {user}                  [$c]
::set_property taxonomy            {{/AXI_Infrastructure}} [$c]
::set_property vendor_display_name {OH!}                   [$c]
::set_property company_url         {www.parallella.org}    [$c]
ipx::archive_core $archive [ipx::current_core]


###########################################################
# Exit
###########################################################
exit
