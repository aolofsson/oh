#######################
# Configuration Pins
#######################
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

#######################
# HDMI constraints
#######################

#set_property IOSTANDARD LVCMOS25 [get_ports {HDMI_*}]

#set_property PACKAGE_PIN Y18 [get_ports {HDMI_D[8]}]
#set_property PACKAGE_PIN W18 [get_ports {HDMI_D[9]}]
#set_property PACKAGE_PIN V18 [get_ports {HDMI_D[10]}]
#set_property PACKAGE_PIN V15 [get_ports {HDMI_D[11]}]
#set_property PACKAGE_PIN R18 [get_ports {HDMI_D[12]}]
#set_property PACKAGE_PIN P18 [get_ports {HDMI_D[13]}]
#set_property PACKAGE_PIN Y19 [get_ports {HDMI_D[14]}]
#set_property PACKAGE_PIN W19 [get_ports {HDMI_D[15]}]
#set_property PACKAGE_PIN W15 [get_ports {HDMI_D[16]}]
#set_property PACKAGE_PIN T19 [get_ports {HDMI_D[17]}]
#set_property PACKAGE_PIN R19 [get_ports {HDMI_D[18]}]
#set_property PACKAGE_PIN P19 [get_ports {HDMI_D[19]}]
#set_property PACKAGE_PIN W20 [get_ports {HDMI_D[20]}]
#set_property PACKAGE_PIN V20 [get_ports {HDMI_D[21]}]
#set_property PACKAGE_PIN U20 [get_ports {HDMI_D[22]}]
#set_property PACKAGE_PIN T20 [get_ports {HDMI_D[23]}]
#set_property PACKAGE_PIN R17 [get_ports HDMI_CLK]
#set_property PACKAGE_PIN V17 [get_ports HDMI_VSYNC]
#set_property PACKAGE_PIN T17 [get_ports HDMI_HSYNC]
#set_property PACKAGE_PIN Y17 [get_ports HDMI_DE]
#set_property PACKAGE_PIN Y16 [get_ports HDMI_SPDIF]
#set_property PACKAGE_PIN P20 [get_ports HDMI_INT]

#####################
# I2C
#####################
set_property PACKAGE_PIN N18 [get_ports I2C_SCL]
set_property IOSTANDARD LVCMOS25 [get_ports I2C_SCL]
set_property PACKAGE_PIN N17 [get_ports I2C_SDA]
set_property IOSTANDARD LVCMOS25 [get_ports I2C_SDA]

#####################
# MISC
#####################
#set_property PACKAGE_PIN R16 [get_ports TURBO_MODE]
#set_property IOSTANDARD LVCMOS25 [get_ports TURBO_MODE]
#set_property PACKAGE_PIN N20 [get_ports PROG_IO]
#set_property IOSTANDARD LVCMOS25 [get_ports PROG_IO]

#####################
# Epiphany Interface
#####################
set_property PACKAGE_PIN G14 [get_ports {DSP_RESET_N[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {DSP_RESET_N[0]}]
set_property DRIVE 4 [get_ports {DSP_RESET_N[0]}]

set_property PACKAGE_PIN H17 [get_ports CCLK_N]
set_property PACKAGE_PIN F17 [get_ports TX_lclk_n]
set_property PACKAGE_PIN A20 [get_ports {TX_data_n[0]}]
set_property PACKAGE_PIN B20 [get_ports {TX_data_n[1]}]
set_property PACKAGE_PIN D20 [get_ports {TX_data_n[2]}]
set_property PACKAGE_PIN E19 [get_ports {TX_data_n[3]}]
set_property PACKAGE_PIN D18 [get_ports {TX_data_n[4]}]
set_property PACKAGE_PIN F20 [get_ports {TX_data_n[5]}]
set_property PACKAGE_PIN G18 [get_ports {TX_data_n[6]}]
set_property PACKAGE_PIN G20 [get_ports {TX_data_n[7]}]
set_property PACKAGE_PIN G15 [get_ports TX_frame_n]
set_property PACKAGE_PIN J15 [get_ports TX_rd_wait_p]
set_property IOSTANDARD LVCMOS25 [get_ports TX_rd_wait_p]
#NET "RXO_RD_WAIT_N" LOC = "H17";
set_property PACKAGE_PIN H18 [get_ports TX_wr_wait_n]
set_property PACKAGE_PIN K18 [get_ports RX_lclk_n]
set_property PACKAGE_PIN J19 [get_ports {RX_data_n[0]}]
set_property PACKAGE_PIN L15 [get_ports {RX_data_n[1]}]
set_property PACKAGE_PIN L17 [get_ports {RX_data_n[2]}]
set_property PACKAGE_PIN M15 [get_ports {RX_data_n[3]}]
set_property PACKAGE_PIN L20 [get_ports {RX_data_n[4]}]
set_property PACKAGE_PIN M20 [get_ports {RX_data_n[5]}]
set_property PACKAGE_PIN M18 [get_ports {RX_data_n[6]}]
set_property PACKAGE_PIN N16 [get_ports {RX_data_n[7]}]
set_property PACKAGE_PIN H20 [get_ports RX_frame_n]
set_property PACKAGE_PIN J14 [get_ports RX_rd_wait_n]
set_property PACKAGE_PIN J16 [get_ports RX_wr_wait_n]

#######################
# GPIO
#  First 12 pairs are present on all parts, next 12 on 7020 only
#######################
set_property PACKAGE_PIN T16 [get_ports {GPIO_P[0]}]
set_property PACKAGE_PIN U17 [get_ports {GPIO_N[0]}]
set_property PACKAGE_PIN V16 [get_ports {GPIO_P[1]}]
set_property PACKAGE_PIN W16 [get_ports {GPIO_N[1]}]
set_property PACKAGE_PIN P15 [get_ports {GPIO_P[2]}]
set_property PACKAGE_PIN P16 [get_ports {GPIO_N[2]}]
set_property PACKAGE_PIN U18 [get_ports {GPIO_P[3]}]
set_property PACKAGE_PIN U19 [get_ports {GPIO_N[3]}]
set_property PACKAGE_PIN P14 [get_ports {GPIO_P[4]}]
set_property PACKAGE_PIN R14 [get_ports {GPIO_N[4]}]
set_property PACKAGE_PIN T14 [get_ports {GPIO_P[5]}]
set_property PACKAGE_PIN T15 [get_ports {GPIO_N[5]}]
set_property PACKAGE_PIN U14 [get_ports {GPIO_P[6]}]
set_property PACKAGE_PIN U15 [get_ports {GPIO_N[6]}]
set_property PACKAGE_PIN W14 [get_ports {GPIO_P[7]}]
set_property PACKAGE_PIN Y14 [get_ports {GPIO_N[7]}]
set_property PACKAGE_PIN U13 [get_ports {GPIO_P[8]}]
set_property PACKAGE_PIN V13 [get_ports {GPIO_N[8]}]
set_property PACKAGE_PIN V12 [get_ports {GPIO_P[9]}]
set_property PACKAGE_PIN W13 [get_ports {GPIO_N[9]}]
set_property PACKAGE_PIN T12 [get_ports {GPIO_P[10]}]
set_property PACKAGE_PIN U12 [get_ports {GPIO_N[10]}]
set_property PACKAGE_PIN T11 [get_ports {GPIO_P[11]}]
set_property PACKAGE_PIN T10 [get_ports {GPIO_N[11]}]





