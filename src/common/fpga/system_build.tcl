###########################################################
# Save any gui changes
###########################################################
validate_bd_design
write_bd_tcl -force ./system_bd.tcl
make_wrapper -files [get_files $projdir/${design}.srcs/sources_1/bd/system/system.bd] -top

###########################################################
# Add generated wrapper file
###########################################################
remove_files -fileset sources_1 $projdir/${design}.srcs/sources_1/bd/system/hdl/system_wrapper.v
add_files -fileset sources_1 -norecurse $projdir/${design}.srcs/sources_1/bd/system/hdl/system_wrapper.v

###########################################################
# PREPARE FOR SYNTHESIS
###########################################################
if {[info exists oh_synthesis_options]} {
    puts "INFO: Synthesis with following options: $oh_synthesis_options"
    set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value $oh_synthesis_options -objects [get_runs synth_1]
}

###########################################################
# SYNTHESIS
###########################################################
launch_runs synth_1
wait_on_run synth_1
#report_timing_summary -file synth_timing_summary.rpt

###########################################################
# PLACE AND ROUTE
###########################################################
launch_runs impl_1
wait_on_run impl_1
#report_timing_summary -file impl_timing_summary.rpt

###########################################################
# CREATE NETLIST + REPORTS
###########################################################
#write_verilog ./system.v

###########################################################
# Write Bitstream
###########################################################
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1



