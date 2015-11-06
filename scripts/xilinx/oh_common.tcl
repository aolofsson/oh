

set top_srcdir  [file dirname [info script]]/../../
set top_builddir $top_srcdir

# TODO: Support building out of tree
#if [info exists ::env(top_builddir)] {
#    set top_builddir $::env(top_builddir)
#}


namespace eval oh {
namespace eval ip {



### ADD FILES
proc add_files {ip_name ip_files} {
    set fileset [::get_filesets sources_1]
    ::add_files -fileset $fileset -norecurse -scan_for_includes $ip_files
    ::set_property "top" "$ip_name" $fileset
}

### ADD CONSTRAINTS
proc add_constraints {ip_constr_files {processing_order late}} {
}

### IP SETTINGS

proc set_properties {ip_dir} {
   
    
    set c ::ipx::current_core
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
