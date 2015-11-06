###########################################################
# SAVE GUI CHANGES
###########################################################
write_bd_tcl -force ./system_bd.tcl
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


