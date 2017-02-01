#######################
# Configuration Pins
#######################
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

#####################
# Epiphany Reset
#####################
set_property IOSTANDARD LVCMOS25 [get_ports {chip_nreset}]
set_property PACKAGE_PIN G14 [get_ports {chip_nreset}]

#####################
# Epiphany Clock
#####################
set_property IOSTANDARD LVDS_25 [get_ports {cclk*}]
set_property PACKAGE_PIN H17 [get_ports cclk_n]

#####################
# Epiphany TX
#####################
set_property IOSTANDARD LVDS_25 [get_ports {txo*}]
set_property IOSTANDARD LVDS_25 [get_ports {txi*}]
set_property PACKAGE_PIN F17 [get_ports txo_lclk_n]
set_property PACKAGE_PIN A20 [get_ports {txo_data_n[0]}]
set_property PACKAGE_PIN B20 [get_ports {txo_data_n[1]}]
set_property PACKAGE_PIN D20 [get_ports {txo_data_n[2]}]
set_property PACKAGE_PIN E19 [get_ports {txo_data_n[3]}]
set_property PACKAGE_PIN D18 [get_ports {txo_data_n[4]}]
set_property PACKAGE_PIN F20 [get_ports {txo_data_n[5]}]
set_property PACKAGE_PIN G18 [get_ports {txo_data_n[6]}]
set_property PACKAGE_PIN G20 [get_ports {txo_data_n[7]}]
set_property PACKAGE_PIN G15 [get_ports txo_frame_n]
set_property PACKAGE_PIN H18 [get_ports txi_wr_wait_n]

#####################
# Wait signals
#####################
set_property IOSTANDARD LVCMOS25 [get_ports {txi_rd_wait_*}]
set_property PACKAGE_PIN J15 [get_ports txi_rd_wait_p]


#####################
# Epiphany RX 
#####################
set_property IOSTANDARD LVDS_25 [get_ports {rx*}]
set_property PACKAGE_PIN K18 [get_ports rxi_lclk_n]
set_property PACKAGE_PIN J19 [get_ports {rxi_data_n[0]}]
set_property PACKAGE_PIN L15 [get_ports {rxi_data_n[1]}]
set_property PACKAGE_PIN L17 [get_ports {rxi_data_n[2]}]
set_property PACKAGE_PIN M15 [get_ports {rxi_data_n[3]}]
set_property PACKAGE_PIN L20 [get_ports {rxi_data_n[4]}]
set_property PACKAGE_PIN M20 [get_ports {rxi_data_n[5]}]
set_property PACKAGE_PIN M18 [get_ports {rxi_data_n[6]}]
set_property PACKAGE_PIN N16 [get_ports {rxi_data_n[7]}]
set_property PACKAGE_PIN H20 [get_ports rxi_frame_n]
set_property PACKAGE_PIN J14 [get_ports rxo_rd_wait_n]
set_property PACKAGE_PIN J16 [get_ports rxo_wr_wait_n]
