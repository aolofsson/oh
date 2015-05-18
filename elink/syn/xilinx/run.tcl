###########################################################
#STEP0: Define variables
set OUTDIR ./tmp
set PART xc7z010clg400-1
set TOP elink_example

file mkdir $OUTDIR

###########################################################
#STEP1: Read sources, constraints, IP files
create_project -in_memory -part $PART -force my_project
source read_verilog.tcl
source read_constraints.tcl
source read_ip.tcl

###########################################################
#STEP2: SYNTHESIS
###########################################################
upgrade_ip [get_ips]
generate_target all [get_ips]
synth_ip [get_ips]
synth_design -top $TOP -part $PART

#create a checkpoint
write_checkpoint -force $OUTDIR/post_syn.dcp

#report timing
check_timing -verbose -file $OUTDIR/check_timing.rpt
report_clocks -file $OUTDIR/clock_basic.rpt
report_clock_interaction -delay_type min_max -significant_digits 3 -file $OUTDIR/clock_cdc.rpt
report_clock_networks -file $OUTDIR/clock_networks.rpt
report_timing_summary -file $OUTDIR/post_syn_timing_summary.rpt
report_utilization -file $OUTDIR/post_syn_util.rpt

###########################################################
#STEP3: PLACEMENT
###########################################################
#optimize design
opt_design

#place design
place_design

#optimzier design
phys_opt_design

#create a checkpoint
write_checkpoint -force $OUTDIR/post_place.dcp

#post placement repororts


report_clock_utilization -file $OUTDIR/clock_util.rpt
report_utilization -file $OUTDIR/post_place_util.rpt
report_timing_summary -file $OUTDIR/post_place_timing_summary.rpt

###########################################################
#STEP4: ROUTING
###########################################################

#route design
route_design

#create checkpoint
write_checkpoint -force $OUTDIR/post_route.dcp

#create reports
report_route_status -file $OUTDIR/post_route_status.rpt
report_timing_summary -file $OUTDIR/post_route_timing_summary.rpt
report_timing -sort_by group -max_paths 100 -path_type summary -file $OUTDIR/post_route_timing.rpt
report_power -file $OUTDIR/post_route_power.rpt
report_drc -file $OUTDIR/post_imp_drc.rpt

###########################################################
#STEP5: GENERATE BITSTREAM AND NETLIST
###########################################################
write_verilog -force $OUTDIR/$TOP.v

write_xdc -no_fixed_only -force $OUTDIR/$TOP.xdc

write_bitstream -force $OUTDIR/$TOP.bit









