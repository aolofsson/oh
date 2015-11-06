###############################################################
##  Location constraints for the Parallella-I board
##  3/12/14 F. Huettig
##  Updated to XDC format 7/1/14 F. Huettig
####
## This file defines pin locations & standards for the Parallella-I
##   and Zynq 7020.  See the file parallella_z70x0_loc.ucf
##    for all other pins.
###############################################################

##################################
# IOs to be used with zc7020 ONLY
##################################
set_property PACKAGE_PIN Y12 [get_ports {GPIO_P[12]}]
set_property PACKAGE_PIN Y13 [get_ports {GPIO_N[12]}]
set_property PACKAGE_PIN W11 [get_ports {GPIO_P[13]}]
set_property PACKAGE_PIN Y11 [get_ports {GPIO_N[13]}]
set_property PACKAGE_PIN V11 [get_ports {GPIO_P[14]}]
set_property PACKAGE_PIN V10 [get_ports {GPIO_N[14]}]
set_property PACKAGE_PIN T9 [get_ports {GPIO_P[15]}]
set_property PACKAGE_PIN U10 [get_ports {GPIO_N[15]}]
set_property PACKAGE_PIN W10 [get_ports {GPIO_P[16]}]
set_property PACKAGE_PIN W9 [get_ports {GPIO_N[16]}]
set_property PACKAGE_PIN U9 [get_ports {GPIO_P[17]}]
set_property PACKAGE_PIN U8 [get_ports {GPIO_N[17]}]
set_property PACKAGE_PIN V8 [get_ports {GPIO_P[18]}]
set_property PACKAGE_PIN W8 [get_ports {GPIO_N[18]}]
set_property PACKAGE_PIN Y9 [get_ports {GPIO_P[19]}]
set_property PACKAGE_PIN Y8 [get_ports {GPIO_N[19]}]
set_property PACKAGE_PIN Y7 [get_ports {GPIO_P[20]}]
set_property PACKAGE_PIN Y6 [get_ports {GPIO_N[20]}]
set_property PACKAGE_PIN U7 [get_ports {GPIO_P[21]}]
set_property PACKAGE_PIN V7 [get_ports {GPIO_N[21]}]
set_property PACKAGE_PIN V6 [get_ports {GPIO_P[22]}]
set_property PACKAGE_PIN W6 [get_ports {GPIO_N[22]}]
set_property PACKAGE_PIN T5 [get_ports {GPIO_P[23]}]
set_property PACKAGE_PIN U5 [get_ports {GPIO_N[23]}]
