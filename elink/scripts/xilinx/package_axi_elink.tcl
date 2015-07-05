set pwd [file dirname [info script]]
source $pwd/../../../include/oh.tcl

# ???
set_msg_config -id {ip_flow 19-459} -suppress

oh::ip::create axi_elink $top_builddir/axi_elink

set elink_src_files [list \
    "$top_srcdir/common/hdl" \
    "$top_srcdir/emesh/hdl" \
    "$top_srcdir/emmu/hdl/emmu.v" \
    "$top_srcdir/edma/hdl/edma.v" \
    "$top_srcdir/emailbox/hdl/emailbox.v" \
    "$top_srcdir/elink/hdl" ]
set elink_constr_files [list \
    "$top_srcdir/elink/scripts/xilinx/elink_clocks.xdc" \
    "$top_srcdir/elink/scripts/xilinx/elink_pins.xdc" \
    "$top_srcdir/elink/scripts/xilinx/elink_timing.xdc" ]
set elink_ip_files [concat $elink_src_files $elink_constr_files]

oh::ip::add_files axi_elink $elink_ip_files
# Does not work / is it needed ?
#oh::ip::add_constraints $elink_constr_files

oh::ip::set_properties $top_builddir/axi_elink

ipx::save_core [ipx::current_core]

