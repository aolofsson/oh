#######################
# Configuration Pins
#######################
#set_property CFGBVS VCCO [current_design]
#set_property CONFIG_VOLTAGE 3.3 [current_design]

#####################
# Epiphany Reset
# Schematic RESETB
#####################
set_property IOSTANDARD LVCMOS18 [get_ports {chip_nreset}]
set_property PACKAGE_PIN AC7 [get_ports {chip_nreset}]

##########################
# AD9523 clock power down
# (active low)
# Schematic CLKPD_1P8V
##########################
set_property IOSTANDARD LVCMOS18 [get_ports {clkpd_1p8v}]
set_property PACKAGE_PIN AC6 [get_ports {clkpd_1p8v}]

#####################
# Epiphany Clocks (Tile 0-7)
# Schematic CLKIN_[PN]01
# Connected to clock distributor chip.
# Assume pass through will work.
#####################
set_property IOSTANDARD LVDS [get_ports {cclk*}]
# (Tile 0-7)
set_property PACKAGE_PIN W6 [get_ports cclk0_n]
set_property PACKAGE_PIN W7 [get_ports cclk0_p]
# (Tile 8-15)
#set_property PACKAGE_PIN AA12 [get_ports cclk1_n]
#set_property PACKAGE_PIN Y12 [get_ports cclk1_p]

#########################
# FPGA Elink TX (chip RX)
#########################
set_property IOSTANDARD LVDS [get_ports {txo*}]
set_property IOSTANDARD LVDS [get_ports {txi*}]
set_property PACKAGE_PIN N11 [get_ports txo_lclk_n]
set_property PACKAGE_PIN N8  [get_ports {txo_data_n[0]}]
set_property PACKAGE_PIN K13 [get_ports {txo_data_n[1]}]
set_property PACKAGE_PIN M13 [get_ports {txo_data_n[2]}]
set_property PACKAGE_PIN N12 [get_ports {txo_data_n[3]}]
set_property PACKAGE_PIN M14 [get_ports {txo_data_n[4]}]
set_property PACKAGE_PIN K16 [get_ports {txo_data_n[5]}]
set_property PACKAGE_PIN K12 [get_ports {txo_data_n[6]}]
set_property PACKAGE_PIN L11 [get_ports {txo_data_n[7]}]
set_property PACKAGE_PIN K15 [get_ports txo_frame_n]
set_property PACKAGE_PIN T6  [get_ports txi_wr_wait_n]

#####################
# Wait signals
#####################
# ??? Parallella board has LVCMOS25 and a DIFF LINE RECEIVER
set_property IOSTANDARD LVDS [get_ports {txi_rd_wait_*}]
set_property PACKAGE_PIN L10 [get_ports txi_rd_wait_n]


#########################
# FPGA ELink RX (chip TX)
#########################
set_property IOSTANDARD LVDS [get_ports {rx*}]
set_property PACKAGE_PIN Y3  [get_ports rxi_lclk_n]
set_property PACKAGE_PIN AC4 [get_ports {rxi_data_n[0]}]
set_property PACKAGE_PIN V1  [get_ports {rxi_data_n[1]}]
set_property PACKAGE_PIN Y1  [get_ports {rxi_data_n[2]}]
set_property PACKAGE_PIN AA1 [get_ports {rxi_data_n[3]}]
set_property PACKAGE_PIN AC3 [get_ports {rxi_data_n[4]}]
set_property PACKAGE_PIN AC1 [get_ports {rxi_data_n[5]}]
set_property PACKAGE_PIN U4  [get_ports {rxi_data_n[6]}]
set_property PACKAGE_PIN V3  [get_ports {rxi_data_n[7]}]
set_property PACKAGE_PIN W1  [get_ports rxi_frame_n]
set_property PACKAGE_PIN W4  [get_ports rxo_rd_wait_n]
set_property PACKAGE_PIN AB5 [get_ports rxo_wr_wait_n]

###################
# Pin Constraints #
###################
#
# Video Clock SI570
#
# PL Port      Pin  Schematic
#
# si570_clk_n  L28  USER_MGT_SI570_N
# si570_clk_p  L27  USER_MGT_SI570_P
#
set_property PACKAGE_PIN L28 [get_ports si570_clk_n]
