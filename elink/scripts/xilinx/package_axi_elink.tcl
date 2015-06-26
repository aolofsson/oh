########################################################
set oh_path "../.."

set_msg_config -id {ip_flow 19-459} -suppress

########################################################
#create a project
set block axi_elink
create_project $block . -force

#######################################################
#add files
add_files -norecurse $oh_path/common/hdl
add_files -norecurse $oh_path/emesh/hdl
add_files -norecurse $oh_path/emmu/hdl/emmu.v
add_files -norecurse $oh_path/edma/hdl/edma.v
add_files -norecurse $oh_path/emailbox/hdl/emailbox.v
add_files -norecurse $oh_path/elink/hdl

#######################################################
#Package IP
ipx::package_project -root_dir .

#######################################################
#Vendor settings
set_property vendor {www.parallella.org} [ipx::current_core]
set_property library {user} [ipx::current_core]
set_property taxonomy {{/AXI_Infrastructure}} [ipx::current_core]
set_property vendor_display_name {OH!} [ipx::current_core]
set_property company_url {www.parallella.org} [ipx::current_core]

#######################################################
#Device Families Supported
set_property supported_families \
    {
     {virtex7}    {Production} \
     {kintex7}    {Production} \
     {artix7}     {Production} \
     {zynq}       {Production}} \
  [ipx::current_core]

#######################################################
#Save files
ipx::save_core [ipx::current_core]


