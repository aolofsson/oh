# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"

}

proc update_PARAM_VALUE.AW { PARAM_VALUE.AW } {
	# Procedure called to update AW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AW { PARAM_VALUE.AW } {
	# Procedure called to validate AW
	return true
}

proc update_PARAM_VALUE.DW { PARAM_VALUE.DW } {
	# Procedure called to update DW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DW { PARAM_VALUE.DW } {
	# Procedure called to validate DW
	return true
}

proc update_PARAM_VALUE.ETYPE { PARAM_VALUE.ETYPE } {
	# Procedure called to update ETYPE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ETYPE { PARAM_VALUE.ETYPE } {
	# Procedure called to validate ETYPE
	return true
}

proc update_PARAM_VALUE.ID { PARAM_VALUE.ID } {
	# Procedure called to update ID when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ID { PARAM_VALUE.ID } {
	# Procedure called to validate ID
	return true
}

proc update_PARAM_VALUE.IOSTD_ELINK { PARAM_VALUE.IOSTD_ELINK } {
	# Procedure called to update IOSTD_ELINK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IOSTD_ELINK { PARAM_VALUE.IOSTD_ELINK } {
	# Procedure called to validate IOSTD_ELINK
	return true
}

proc update_PARAM_VALUE.M_IDW { PARAM_VALUE.M_IDW } {
	# Procedure called to update M_IDW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.M_IDW { PARAM_VALUE.M_IDW } {
	# Procedure called to validate M_IDW
	return true
}

proc update_PARAM_VALUE.PW { PARAM_VALUE.PW } {
	# Procedure called to update PW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PW { PARAM_VALUE.PW } {
	# Procedure called to validate PW
	return true
}

proc update_PARAM_VALUE.S_IDW { PARAM_VALUE.S_IDW } {
	# Procedure called to update S_IDW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S_IDW { PARAM_VALUE.S_IDW } {
	# Procedure called to validate S_IDW
	return true
}


proc update_MODELPARAM_VALUE.AW { MODELPARAM_VALUE.AW PARAM_VALUE.AW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AW}] ${MODELPARAM_VALUE.AW}
}

proc update_MODELPARAM_VALUE.DW { MODELPARAM_VALUE.DW PARAM_VALUE.DW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DW}] ${MODELPARAM_VALUE.DW}
}

proc update_MODELPARAM_VALUE.PW { MODELPARAM_VALUE.PW PARAM_VALUE.PW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PW}] ${MODELPARAM_VALUE.PW}
}

proc update_MODELPARAM_VALUE.ID { MODELPARAM_VALUE.ID PARAM_VALUE.ID } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ID}] ${MODELPARAM_VALUE.ID}
}

proc update_MODELPARAM_VALUE.S_IDW { MODELPARAM_VALUE.S_IDW PARAM_VALUE.S_IDW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S_IDW}] ${MODELPARAM_VALUE.S_IDW}
}

proc update_MODELPARAM_VALUE.M_IDW { MODELPARAM_VALUE.M_IDW PARAM_VALUE.M_IDW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.M_IDW}] ${MODELPARAM_VALUE.M_IDW}
}

proc update_MODELPARAM_VALUE.IOSTD_ELINK { MODELPARAM_VALUE.IOSTD_ELINK PARAM_VALUE.IOSTD_ELINK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IOSTD_ELINK}] ${MODELPARAM_VALUE.IOSTD_ELINK}
}

proc update_MODELPARAM_VALUE.ETYPE { MODELPARAM_VALUE.ETYPE PARAM_VALUE.ETYPE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ETYPE}] ${MODELPARAM_VALUE.ETYPE}
}

