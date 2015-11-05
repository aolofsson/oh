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
if {[llength $ip_files] != 0} {
    add_files -norecurse -fileset [get_filesets sources_1] $ip_files
}
foreach file $ip_files {
    #TODO: is this needed?
    set file_obj [get_files -of_objects [get_filesets sources_1] $file]
    set_property "synth_checkpoint_mode" "Singular" $file_obj
}
#RERUN/UPGRADE IP
upgrade_ip [get_ips]

#TODO: How to check for this status of previous command?
foreach file $ip_files {
    generate_target all [get_files $file]
    set obj  [create_ip_run -force [get_files $file]]
    launch_run -jobs 2 $obj
    wait_on_run $obj
}

###########################################################
# SYNTHESIZE (FOR SANITY)
###########################################################
set_property top $design [current_fileset]
launch_runs synth_1 -jobs 2
wait_on_run synth_1


###########################################################
# Package
###########################################################

::ipx::package_project -force -root_dir $design
::set_property vendor              {www.parallella.org}    [ipx::current_core]
::set_property library             {user}                  [ipx::current_core]
::set_property taxonomy            {{/AXI_Infrastructure}} [ipx::current_core]
::set_property vendor_display_name {OH!}                   [ipx::current_core]
::set_property company_url         {www.parallella.org}    [ipx::current_core]
::set_property supported_families  {{kintexu}    {Pre-Production} \
				{virtexu}    {Pre-Production} \
				{virtex7}    {Production} \
				{qvirtex7}   {Production} \
				{kintex7}    {Production} \
				{kintex7l}   {Production} \
				{qkintex7}   {Production} \
				{qkintex7l}  {Production} \
				{artix7}     {Production} \
				{artix7l}    {Production} \
				{aartix7}    {Production} \
				{qartix7}    {Production} \
				{zynq}       {Production} \
				{qzynq}      {Production} \
				{azynq}      {Production}}   [ipx::current_core]

### Write ZIP archive
ipx::archive_core $archive [ipx::current_core]

###########################################################
# Exit
###########################################################
exit
