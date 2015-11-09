###########################################################
# Create Managed IP Project
###########################################################
create_project -force $design $projdir -part $partname 
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
#foreach file $ip_files {
#    generate_target all [get_files $file]
#    set obj  [create_ip_run -force [get_files $file]]
#    launch_run -jobs 2 $obj
#    wait_on_run $obj
#}

###########################################################
# SYNTHESIZE (FOR SANITY)
###########################################################
#set_property top $design [current_fileset]
#launch_runs synth_1 -jobs 2
#wait_on_run synth_1


###########################################################
# Package
###########################################################

ipx::package_project -import_files -force -root_dir $projdir
ipx::remove_memory_map {s_axi} [ipx::current_core]
ipx::add_memory_map {s_axi} [ipx::current_core]
ipx::associate_bus_interfaces -busif s_axi -clock sys_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi -clock sys_clk [ipx::current_core]

set_property slave_memory_map_ref {s_axi} [ipx::get_bus_interface s_axi [ipx::current_core]]

ipx::add_address_block {axi_lite} [ipx::get_memory_map s_axi [ipx::current_core]]
set_property range {65536} [ipx::get_address_block axi_lite \
    [ipx::get_memory_map s_axi [ipx::current_core]]]

set_property vendor              {www.parallella.org}    [ipx::current_core]
set_property library             {user}                  [ipx::current_core]
set_property taxonomy            {{/AXI_Infrastructure}} [ipx::current_core]
set_property vendor_display_name {ADAPTEVA}              [ipx::current_core]
set_property company_url         {www.parallella.org}    [ipx::current_core]
set_property supported_families  { \
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
					 {azynq}      {Production} \
				     }   [ipx::current_core]

### Write ZIP archive
ipx::archive_core [concat $design.zip] [ipx::current_core]

###########################################################
# Exit
###########################################################
exit
