# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  set Component_Name  [  ipgui::add_param $IPINST -name "Component_Name" -display_name {Component Name}]
  set_property tooltip {Component Name} ${Component_Name}
  #Adding Page
  set Page_0  [  ipgui::add_page $IPINST -name "Page 0" -display_name {Page 0}]
  set_property tooltip {Page 0} ${Page_0}
  set RFAW  [  ipgui::add_param $IPINST -name "RFAW" -parent ${Page_0} -display_name {Rfaw}]
  set_property tooltip {Rfaw} ${RFAW}
  set IDW  [  ipgui::add_param $IPINST -name "IDW" -parent ${Page_0} -display_name {Idw}]
  set_property tooltip {Idw} ${IDW}
  set E_VERSION  [  ipgui::add_param $IPINST -name "E_VERSION" -parent ${Page_0} -display_name {E Version}]
  set_property tooltip {E Version} ${E_VERSION}


}

proc update_PARAM_VALUE.RFAW { PARAM_VALUE.RFAW } {
	# Procedure called to update RFAW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RFAW { PARAM_VALUE.RFAW } {
	# Procedure called to validate RFAW
	return true
}

proc update_PARAM_VALUE.IDW { PARAM_VALUE.IDW } {
	# Procedure called to update IDW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IDW { PARAM_VALUE.IDW } {
	# Procedure called to validate IDW
	return true
}

proc update_PARAM_VALUE.E_VERSION { PARAM_VALUE.E_VERSION } {
	# Procedure called to update E_VERSION when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.E_VERSION { PARAM_VALUE.E_VERSION } {
	# Procedure called to validate E_VERSION
	return true
}


proc update_MODELPARAM_VALUE.E_VERSION { MODELPARAM_VALUE.E_VERSION PARAM_VALUE.E_VERSION } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.E_VERSION}] ${MODELPARAM_VALUE.E_VERSION}
}

proc update_MODELPARAM_VALUE.IDW { MODELPARAM_VALUE.IDW PARAM_VALUE.IDW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IDW}] ${MODELPARAM_VALUE.IDW}
}

proc update_MODELPARAM_VALUE.RFAW { MODELPARAM_VALUE.RFAW PARAM_VALUE.RFAW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RFAW}] ${MODELPARAM_VALUE.RFAW}
}

