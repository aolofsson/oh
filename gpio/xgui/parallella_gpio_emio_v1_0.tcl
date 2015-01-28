# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  set Component_Name  [  ipgui::add_param $IPINST -name "Component_Name" -display_name {Component Name}]
  set_property tooltip {Component Name} ${Component_Name}
  #Adding Page
  set Page_0  [  ipgui::add_page $IPINST -name "Page 0" -display_name {Page 0}]
  set_property tooltip {Page 0} ${Page_0}
  set DIFF_GPIO  [  ipgui::add_param $IPINST -name "DIFF_GPIO" -parent ${Page_0} -display_name {DIFF_GPIO}]
  set_property tooltip {Set Differential (1) or Single-ended (0) GPIOs} ${DIFF_GPIO}
  set NUM_GPIO_PAIRS  [  ipgui::add_param $IPINST -name "NUM_GPIO_PAIRS" -parent ${Page_0} -display_name {NUM_GPIO_PAIRS}]
  set_property tooltip {Number of GPIO pairs P/N, or HALF the # of single-ended signals} ${NUM_GPIO_PAIRS}
  set NUM_PS_SIGS  [  ipgui::add_param $IPINST -name "NUM_PS_SIGS" -parent ${Page_0} -display_name {NUM_PS_SIGS}]
  set_property tooltip {Number of PS GPIO signals connected.} ${NUM_PS_SIGS}


}

proc update_PARAM_VALUE.NUM_PS_SIGS { PARAM_VALUE.NUM_PS_SIGS } {
	# Procedure called to update NUM_PS_SIGS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_PS_SIGS { PARAM_VALUE.NUM_PS_SIGS } {
	# Procedure called to validate NUM_PS_SIGS
	return true
}

proc update_PARAM_VALUE.DIFF_GPIO { PARAM_VALUE.DIFF_GPIO } {
	# Procedure called to update DIFF_GPIO when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DIFF_GPIO { PARAM_VALUE.DIFF_GPIO } {
	# Procedure called to validate DIFF_GPIO
	return true
}

proc update_PARAM_VALUE.NUM_GPIO_PAIRS { PARAM_VALUE.NUM_GPIO_PAIRS } {
	# Procedure called to update NUM_GPIO_PAIRS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_GPIO_PAIRS { PARAM_VALUE.NUM_GPIO_PAIRS } {
	# Procedure called to validate NUM_GPIO_PAIRS
	return true
}


proc update_MODELPARAM_VALUE.NUM_GPIO_PAIRS { MODELPARAM_VALUE.NUM_GPIO_PAIRS PARAM_VALUE.NUM_GPIO_PAIRS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_GPIO_PAIRS}] ${MODELPARAM_VALUE.NUM_GPIO_PAIRS}
}

proc update_MODELPARAM_VALUE.DIFF_GPIO { MODELPARAM_VALUE.DIFF_GPIO PARAM_VALUE.DIFF_GPIO } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DIFF_GPIO}] ${MODELPARAM_VALUE.DIFF_GPIO}
}

proc update_MODELPARAM_VALUE.NUM_PS_SIGS { MODELPARAM_VALUE.NUM_PS_SIGS PARAM_VALUE.NUM_PS_SIGS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_PS_SIGS}] ${MODELPARAM_VALUE.NUM_PS_SIGS}
}

