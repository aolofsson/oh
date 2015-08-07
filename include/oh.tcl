set top_srcdir  [file dirname [info script]]/..
set top_builddir $top_srcdir

# Alias, some scripts use this atm.
# TODO: Remove
set oh_path $top_srcdir

# TODO: Support building out of tree
if [info exists ::env(top_builddir)] {
    set top_builddir $::env(top_builddir)
}

namespace eval oh {
namespace eval ip {

proc create {ip_name ip_dir} {
#    ::create_project $ip_name $ip_dir -force
    ::create_project -in_memory

    ::update_ip_catalog
}

proc add_files {ip_name ip_files} {
    set fileset [::get_filesets sources_1]
    ::add_files -fileset $fileset -norecurse -scan_for_includes $ip_files
    ::set_property "top" "$ip_name" $fileset
}

# TODO: Does not work. filegroup is empty
proc add_constraints {ip_constr_files {processing_order late}} {
#    set filegroup [::ipx::get_file_groups xilinx_v*synthesis -of_objects [::ipx::current_core]]
#    puts $filegroup
#    set f [::ipx::add_file $ip_constr_files $filegroup]
#    ::set_property -dict \
#        [list \
#            type xdc \
#            library_name {} \
#            processing_order $processing_order \
#        ] \
#        $f
}

proc set_properties {ip_dir} {
    set c ::ipx::current_core
    ::ipx::package_project -root_dir $ip_dir
    ::set_property vendor              {www.parallella.org}    [$c]
    ::set_property library             {user}                  [$c]
    ::set_property taxonomy            {{/AXI_Infrastructure}} [$c]
    ::set_property vendor_display_name {OH!}                   [$c]
    ::set_property company_url         {www.parallella.org}    [$c]

    ::set_property supported_families \
        {
            {virtex7}    {Production} \
            {kintex7}    {Production} \
            {artix7}     {Production} \
            {zynq}       {Production} \
        } \
        [$c]
}

}; # namespace ip
}; # namespace oh
