set oh_path "../.."
# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

# Set the directory path for the original project from where this script was exported
set orig_proj_dir "[file normalize "$origin_dir"]"

# Create project
create_project axi_elink_v1_0 .

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [get_projects axi_elink_v1_0]
set_property "default_lib" "xil_defaultlib" $obj
set_property "part" "xc7z030sbg485-1" $obj
set_property "simulator_language" "Mixed" $obj

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Set IP repository paths
set obj [get_filesets sources_1]
set_property "ip_repo_paths" "[file normalize "$origin_dir"] [file normalize "$origin_dir"]" $obj

# Rebuild user ip_repo's index before adding any source files
update_ip_catalog -rebuild

# Set 'sources_1' fileset object
set obj [get_filesets sources_1]
set files [list \
 "[file normalize "$oh_path/xilibs/ip/fifo_async_104x16.xci"]"\
 "[file normalize "$oh_path/memory/hdl/fifo_async.v"]"\
 "[file normalize "$oh_path/memory/hdl/memory_dp.v"]"\
 "[file normalize "$oh_path/emesh/hdl/packet2emesh.v"]"\
 "[file normalize "$oh_path/emesh/hdl/emesh2packet.v"]"\
 "[file normalize "$oh_path/common/hdl/arbiter_priority.v"]"\
 "[file normalize "$oh_path/common/hdl/synchronizer.v"]"\
 "[file normalize "$oh_path/emmu/hdl/emmu.v"]"\
 "[file normalize "$oh_path/memory/hdl/fifo_cdc.v"]"\
 "[file normalize "$oh_path/emailbox/hdl/emailbox.v"]"\
 "[file normalize "$oh_path/edma/hdl/edma.v"]"\
 "[file normalize "$oh_path/elink/hdl/elink_regmap.v"]"\
 "[file normalize "$oh_path/elink/hdl/erx_arbiter.v"]"\
 "[file normalize "$oh_path/common/hdl/pulse_stretcher.v"]"\
 "[file normalize "$oh_path/elink/hdl/etx_protocol.v"]"\
 "[file normalize "$oh_path/elink/hdl/ecfg_if.v"]"\
 "[file normalize "$oh_path/elink/hdl/etx_remap.v"]"\
 "[file normalize "$oh_path/elink/hdl/erx_protocol.v"]"\
 "[file normalize "$oh_path/elink/hdl/etx_arbiter.v"]"\
 "[file normalize "$oh_path/elink/hdl/etx_cfg.v"]"\
 "[file normalize "$oh_path/elink/hdl/erx_cfg.v"]"\
 "[file normalize "$oh_path/elink/hdl/erx_remap.v"]"\
 "[file normalize "$oh_path/elink/hdl/erx_io.v"]"\
 "[file normalize "$oh_path/elink/hdl/etx_io.v"]"\
 "[file normalize "$oh_path/elink/hdl/etx_fifo.v"]"\
 "[file normalize "$oh_path/elink/hdl/erx_core.v"]"\
 "[file normalize "$oh_path/elink/hdl/etx_core.v"]"\
 "[file normalize "$oh_path/elink/hdl/erx_fifo.v"]"\
 "[file normalize "$oh_path/elink/hdl/ecfg_elink.v"]"\
 "[file normalize "$oh_path/elink/hdl/etx.v"]"\
 "[file normalize "$oh_path/elink/hdl/ereset.v"]"\
 "[file normalize "$oh_path/elink/hdl/erx.v"]"\
 "[file normalize "$oh_path/memory/hdl/fifo_sync.v"]"\
 "[file normalize "$oh_path/elink/hdl/elink.v"]"\
 "[file normalize "$oh_path/elink/hdl/emaxi.v"]"\
 "[file normalize "$oh_path/elink/hdl/esaxi.v"]"\
 "[file normalize "$oh_path/elink/hdl/eclocks.v"]"\
 "[file normalize "$oh_path/elink/hdl/axi_elink.v"]"\
 "[file normalize "$origin_dir/component.xml"]"\
]
add_files -norecurse -fileset $obj $files

# Set 'sources_1' fileset file properties for remote files
set file "$oh_path/xilibs/ip/fifo_async_104x16.xci"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
if { ![get_property "is_locked" $file_obj] } {
  set_property "synth_checkpoint_mode" "Singular" $file_obj
}
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/memory/hdl/fifo_async.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/memory/hdl/memory_dp.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/emesh/hdl/packet2emesh.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/emesh/hdl/emesh2packet.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/common/hdl/arbiter_priority.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/common/hdl/synchronizer.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/emmu/hdl/emmu.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/memory/hdl/fifo_cdc.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/emailbox/hdl/emailbox.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/edma/hdl/edma.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/elink/hdl/elink_regmap.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/elink/hdl/erx_arbiter.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/common/hdl/pulse_stretcher.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/elink/hdl/etx_protocol.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/elink/hdl/ecfg_if.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/elink/hdl/etx_remap.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/elink/hdl/erx_protocol.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/elink/hdl/etx_arbiter.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/elink/hdl/etx_cfg.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/elink/hdl/erx_cfg.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/elink/hdl/erx_remap.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/elink/hdl/erx_io.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/elink/hdl/etx_io.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/elink/hdl/etx_fifo.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/elink/hdl/erx_core.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/elink/hdl/etx_core.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/elink/hdl/erx_fifo.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/elink/hdl/ecfg_elink.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/elink/hdl/etx.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/elink/hdl/ereset.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/elink/hdl/erx.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/memory/hdl/fifo_sync.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/elink/hdl/elink.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/elink/hdl/emaxi.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/elink/hdl/esaxi.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/elink/hdl/eclocks.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$oh_path/elink/hdl/axi_elink.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj

set file "$origin_dir/component.xml"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "IP-XACT" $file_obj


# Set 'sources_1' fileset file properties for local files
# None

# Set 'sources_1' fileset properties
set obj [get_filesets sources_1]
set_property "top" "axi_elink" $obj

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]

# Empty (no sources present)

# Set 'constrs_1' fileset properties
set obj [get_filesets constrs_1]

# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}

# Set 'sim_1' fileset object
set obj [get_filesets sim_1]
# Empty (no sources present)

# Set 'sim_1' fileset properties
set obj [get_filesets sim_1]
set_property "top" "axi_elink" $obj
set_property "xelab.nosort" "1" $obj
set_property "xelab.unifast" "" $obj

# Create 'synth_1' run (if not found)
if {[string equal [get_runs -quiet synth_1] ""]} {
  create_run -name synth_1 -part xc7z030sbg485-1 -flow {Vivado Synthesis 2015} -strategy "Vivado Synthesis Defaults" -constrset constrs_1
} else {
  set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
  set_property flow "Vivado Synthesis 2015" [get_runs synth_1]
}
set obj [get_runs synth_1]
set_property "part" "xc7z030sbg485-1" $obj

# set the current synth run
current_run -synthesis [get_runs synth_1]

# Create 'impl_1' run (if not found)
if {[string equal [get_runs -quiet impl_1] ""]} {
  create_run -name impl_1 -part xc7z030sbg485-1 -flow {Vivado Implementation 2015} -strategy "Vivado Implementation Defaults" -constrset constrs_1 -parent_run synth_1
} else {
  set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
  set_property flow "Vivado Implementation 2015" [get_runs impl_1]
}
set obj [get_runs impl_1]
set_property "part" "xc7z030sbg485-1" $obj
set_property "steps.write_bitstream.args.readback_file" "0" $obj
set_property "steps.write_bitstream.args.verbose" "0" $obj

# set the current impl run
current_run -implementation [get_runs impl_1]

puts "INFO: Project created:axi_elink_v1_0_project"
