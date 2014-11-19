# Runtime Tcl commands to interact with - emaxi_v1_0

# Sourcing design address info tcl
set bd_path [get_property DIRECTORY [current_project]]/[current_project].srcs/[current_fileset]/bd
source ${bd_path}/emaxi_v1_0_include.tcl

# jtag axi master interface hardware name, change as per your design.
set jtag_axi_master hw_axi_1
set ec 0

# hw test script
# Delete all previous axis transactions
if { [llength [get_hw_axi_txns -quiet]] } {
	delete_hw_axi_txn [get_hw_axi_txns -quiet]
}


# Master Tests..
# CIP Master performs write and read transaction followed by data comparison. 
# To initiate the master "init_axi_txn" port needs to be asserted high. The same assertion is done by axi_gpio_out driven by jtag_axi_lite master.
# Writing 32'b1 to axi_gpio_out reg will initiate the first master. Subsequent masters will take following gpio bits.
# Master 0 init_axi_txn is controlled by bit_0 of axi_gpio_out while bit_1 initiates Master 1.

# To monitor the result of the data comparison by Master 0, error and done flags are being monitored by axi_gpio_in.
# Reading bit 0 of gpio_1_reg gives the done status of the master transaction while bit 1 gives the error
# status of the transaction initiated by the master. bit_0 being '1' means the transaction is complete 
# while bit_1 being 1 means the transaction is completed with error. The status of subsequent masters 
# will take up higher order bits in the same order. Master 1 has bit_2 as done bit, bit_3 as error bit. 

# Utility procs
proc get_done_and_error_bit { rdata totmaster position } {
	# position can be 0 1 2 3 ...
	# Always Done is at sequence of bit 0 & error is at bit 1 position.
	set hexdata [string range $rdata 0 7 ]
	# In case of 64 bit data width 
	#set hexdata [string range $rdata 8 15 ]
	binary scan [binary format H* $hexdata] B* bindata
	set bindata [string range $bindata [expr 32 - $totmaster * 2] 31 ]
	set DE [string range $bindata [ expr ($totmaster - ($position + 1) ) * 2 ] [expr ($totmaster - ($position + 1) ) * 2 + 1] ]
	return $DE
}

proc bin2hex {bin} {
	set result ""
	set prepend [string repeat 0 [expr (4-[string length $bin]%4)%4]]
	foreach g [regexp -all -inline {[01]{4}} $prepend$bin] {
		foreach {b3 b2 b1 b0} [split $g ""] {
			append result [format %X [expr {$b3*8+$b2*4+$b1*2+$b0}]]
		}
	}
	return $result
}

proc get_init_data { position } {
	# position can be 0, 1, 2, 3, 4...15
	set initbit 00000000000000000000000000000000
	set position [ expr 31 - $position ]
	set newinitbit [string replace $initbit $position $position 1]
	set hexdata [bin2hex $newinitbit]
	return $hexdata
}

# Test: M00_AXI
set wdata_m00_axi [get_init_data 0]
create_hw_axi_txn w_m00_axi_addr [get_hw_axis $jtag_axi_master] -type write -address $axi_gpio_out_addr -data ${wdata_m00_axi}
create_hw_axi_txn r_m00_axi_addr [get_hw_axis $jtag_axi_master] -type read -address $axi_gpio_in_addr 
# Initiate transactions
run_hw_axi r_m00_axi_addr
run_hw_axi w_m00_axi_addr
run_hw_axi r_m00_axi_addr
set rdata_tmp [get_property DATA [get_hw_axi_txn r_m00_axi_addr]]
set DE [ get_done_and_error_bit $rdata_tmp 1 0 ]
# Compare read data
if { $DE == 01 } {
	puts "Data comparison test pass for - M00_AXI"
} else {
	puts "Data comparison test fail for - M00_AXI, rdata-$rdata_tmp expected-01 actual-$DE"
	inc ec
}

# Check error flag
if { $ec == 0 } {
	 puts "PTGEN_TEST: PASSED!" 
} else {
	 puts "PTGEN_TEST: FAILED!" 
}

