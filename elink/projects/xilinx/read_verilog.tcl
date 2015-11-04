set pwd [file dirname [info script]]
source $pwd/../../../include/oh.tcl

#ONLY FOR REFERENCE EXAMPLE
read_verilog $top_srcdir/elink/hdl/axi_elink.v

#ELINK
read_verilog $top_srcdir/elink/hdl/elink_constants.v
read_verilog $top_srcdir/elink/hdl/elink_regmap.v
read_verilog $top_srcdir/elink/hdl/elink.v
read_verilog $top_srcdir/elink/hdl/eclocks.v
read_verilog $top_srcdir/elink/hdl/ereset.v
read_verilog $top_srcdir/elink/hdl/ecfg_elink.v
read_verilog $top_srcdir/elink/hdl/ecfg_if.v
read_verilog $top_srcdir/elink/hdl/erx.v
read_verilog $top_srcdir/elink/hdl/erx_clocks.v
read_verilog $top_srcdir/elink/hdl/erx_core.v
read_verilog $top_srcdir/elink/hdl/erx_fifo.v
read_verilog $top_srcdir/elink/hdl/erx_cfg.v
read_verilog $top_srcdir/elink/hdl/erx_arbiter.v
read_verilog $top_srcdir/elink/hdl/erx_protocol.v
read_verilog $top_srcdir/elink/hdl/erx_remap.v
read_verilog $top_srcdir/elink/hdl/erx_io.v
read_verilog $top_srcdir/elink/hdl/etx.v
read_verilog $top_srcdir/elink/hdl/etx_core.v
read_verilog $top_srcdir/elink/hdl/etx_clocks.v
read_verilog $top_srcdir/elink/hdl/etx_fifo.v
read_verilog $top_srcdir/elink/hdl/etx_cfg.v
read_verilog $top_srcdir/elink/hdl/etx_arbiter.v
read_verilog $top_srcdir/elink/hdl/etx_protocol.v
read_verilog $top_srcdir/elink/hdl/etx_remap.v
read_verilog $top_srcdir/elink/hdl/etx_io.v
read_verilog $top_srcdir/elink/hdl/esaxi.v
read_verilog $top_srcdir/elink/hdl/emaxi.v

#COMMON
read_verilog $top_srcdir/common/hdl/toggle2pulse.v
read_verilog $top_srcdir/common/hdl/synchronizer.v
read_verilog $top_srcdir/common/hdl/pulse_stretcher.v
read_verilog $top_srcdir/common/hdl/clock_divider.v
read_verilog $top_srcdir/common/hdl/arbiter_priority.v

#EMESH
read_verilog $top_srcdir/emesh/hdl/emesh2packet.v
read_verilog $top_srcdir/emesh/hdl/packet2emesh.v

#MEMORY/FIFO
read_verilog $top_srcdir/memory/hdl/fifo_async.v
read_verilog $top_srcdir/memory/hdl/fifo_sync.v
read_verilog $top_srcdir/memory/hdl/fifo_cdc.v
read_verilog $top_srcdir/memory/hdl/memory_dp.v
read_verilog $top_srcdir/memory/hdl/memory_sp.v
read_verilog $top_srcdir/memory/hdl/fifo_full_block.v
read_verilog $top_srcdir/memory/hdl/fifo_empty_block.v

#MMU
read_verilog $top_srcdir/emmu/hdl/emmu.v
read_verilog $top_srcdir/emailbox/hdl/emailbox.v
read_verilog $top_srcdir/edma/hdl/edma.v

