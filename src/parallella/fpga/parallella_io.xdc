#######################
# Configuration Pins
#######################
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

#######################
# HDMI constraints
#######################
#TODO: Include for hdmi design
set_property IOSTANDARD LVCMOS25 [get_ports {hdmi_*}]
set_property PACKAGE_PIN Y18 [get_ports {hdmi_d[0]}]
set_property PACKAGE_PIN W18 [get_ports {hdmi_d[1]}]
set_property PACKAGE_PIN V18 [get_ports {hdmi_d[2]}]
set_property PACKAGE_PIN V15 [get_ports {hdmi_d[3]}]
set_property PACKAGE_PIN R18 [get_ports {hdmi_d[4]}]
set_property PACKAGE_PIN P18 [get_ports {hdmi_d[5]}]
set_property PACKAGE_PIN Y19 [get_ports {hdmi_d[6]}]
set_property PACKAGE_PIN W19 [get_ports {hdmi_d[7]}]
set_property PACKAGE_PIN W15 [get_ports {hdmi_d[8]}]
set_property PACKAGE_PIN T19 [get_ports {hdmi_d[9]}]
set_property PACKAGE_PIN R19 [get_ports {hdmi_d[10]}]
set_property PACKAGE_PIN P19 [get_ports {hdmi_d[11]}]
set_property PACKAGE_PIN W20 [get_ports {hdmi_d[12]}]
set_property PACKAGE_PIN V20 [get_ports {hdmi_d[13]}]
set_property PACKAGE_PIN U20 [get_ports {hdmi_d[14]}]
set_property PACKAGE_PIN T20 [get_ports {hdmi_d[15]}]
set_property PACKAGE_PIN R17 [get_ports hdmi_clk]
set_property PACKAGE_PIN V17 [get_ports hdmi_vsync]
set_property PACKAGE_PIN T17 [get_ports hdmi_hsync]
set_property PACKAGE_PIN Y17 [get_ports hdmi_de]
set_property PACKAGE_PIN Y16 [get_ports hdmi_spdif]
set_property PACKAGE_PIN P20 [get_ports hdmi_int]

#####################
# I2C
#####################
set_property IOSTANDARD LVCMOS25 [get_ports {i2c_*}]
set_property PACKAGE_PIN N18 [get_ports i2c_scl]
set_property PACKAGE_PIN N17 [get_ports i2c_sda]

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

#######################
# GPIO
#  First 12 pairs are present on all parts, next 12 on 7020 only
#######################
set_property IOSTANDARD LVCMOS25 [get_ports {gpio*}]
set_property PACKAGE_PIN T16 [get_ports {gpio_p[0]}] 
set_property PACKAGE_PIN U17 [get_ports {gpio_n[0]}]
set_property PACKAGE_PIN V16 [get_ports {gpio_p[1]}]
set_property PACKAGE_PIN W16 [get_ports {gpio_n[1]}]
set_property PACKAGE_PIN P15 [get_ports {gpio_p[2]}]
set_property PACKAGE_PIN P16 [get_ports {gpio_n[2]}]
set_property PACKAGE_PIN U18 [get_ports {gpio_p[3]}]
set_property PACKAGE_PIN U19 [get_ports {gpio_n[3]}]
set_property PACKAGE_PIN P14 [get_ports {gpio_p[4]}]
set_property PACKAGE_PIN R14 [get_ports {gpio_n[4]}]
set_property PACKAGE_PIN T14 [get_ports {gpio_p[5]}]
set_property PACKAGE_PIN T15 [get_ports {gpio_n[5]}]
set_property PACKAGE_PIN U14 [get_ports {gpio_p[6]}]
set_property PACKAGE_PIN U15 [get_ports {gpio_n[6]}]
set_property PACKAGE_PIN W14 [get_ports {gpio_p[7]}]
set_property PACKAGE_PIN Y14 [get_ports {gpio_n[7]}]
set_property PACKAGE_PIN U13 [get_ports {gpio_p[8]}]
set_property PACKAGE_PIN V13 [get_ports {gpio_n[8]}]
set_property PACKAGE_PIN V12 [get_ports {gpio_p[9]}]
set_property PACKAGE_PIN W13 [get_ports {gpio_n[9]}]
set_property PACKAGE_PIN T12 [get_ports {gpio_p[10]}]
set_property PACKAGE_PIN U12 [get_ports {gpio_n[10]}]
set_property PACKAGE_PIN T11 [get_ports {gpio_p[11]}]
set_property PACKAGE_PIN T10 [get_ports {gpio_n[11]}]





