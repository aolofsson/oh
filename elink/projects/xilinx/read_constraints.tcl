set pwd [file dirname [info script]]
source $pwd/../../../include/oh.tcl

read_xdc $pwd/elink_pins.xdc
read_xdc $pwd/elink_timing.xdc

# Do we need this?
#read_xdc $pwd/elink_clocks.xdc


