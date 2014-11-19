# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  set Component_Name  [  ipgui::add_param $IPINST -name "Component_Name" -display_name {Component Name}]
  set_property tooltip {Component Name} ${Component_Name}
  #Adding Page
  set Page_0  [  ipgui::add_page $IPINST -name "Page 0" -display_name {Page 0}]
  set_property tooltip {Page 0} ${Page_0}
  set IOSTD_ELINK  [  ipgui::add_param $IPINST -name "IOSTD_ELINK" -parent ${Page_0} -display_name {Iostd Elink}]
  set_property tooltip {Iostd Elink} ${IOSTD_ELINK}


}

proc update_PARAM_VALUE.IOSTD_ELINK { PARAM_VALUE.IOSTD_ELINK } {
	# Procedure called to update IOSTD_ELINK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IOSTD_ELINK { PARAM_VALUE.IOSTD_ELINK } {
	# Procedure called to validate IOSTD_ELINK
	return true
}


proc update_MODELPARAM_VALUE.IOSTD_ELINK { MODELPARAM_VALUE.IOSTD_ELINK PARAM_VALUE.IOSTD_ELINK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IOSTD_ELINK}] ${MODELPARAM_VALUE.IOSTD_ELINK}
}

