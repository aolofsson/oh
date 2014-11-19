# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  set Component_Name  [  ipgui::add_param $IPINST -name "Component_Name" -display_name {Component Name}]
  set_property tooltip {Component Name} ${Component_Name}
  #Adding Page
  set Page_0  [  ipgui::add_page $IPINST -name "Page 0" -display_name {Page 0}]
  set_property tooltip {Page 0} ${Page_0}
  set IOSTD_ELINK  [  ipgui::add_param $IPINST -name "IOSTD_ELINK" -parent ${Page_0} -display_name {Iostd Elink}]
  set_property tooltip {Iostd Elink} ${IOSTD_ELINK}
  set FEATURE_CCLK_DIV  [  ipgui::add_param $IPINST -name "FEATURE_CCLK_DIV" -parent ${Page_0} -display_name {Feature Cclk Div}]
  set_property tooltip {Feature Cclk Div} ${FEATURE_CCLK_DIV}
  set LCLK_DIVIDE  [  ipgui::add_param $IPINST -name "LCLK_DIVIDE" -parent ${Page_0} -display_name {Lclk Divide}]
  set_property tooltip {Lclk Divide} ${LCLK_DIVIDE}
  set CCLK_DIVIDE  [  ipgui::add_param $IPINST -name "CCLK_DIVIDE" -parent ${Page_0} -display_name {Cclk Divide}]
  set_property tooltip {Cclk Divide} ${CCLK_DIVIDE}
  set VCO_MULT  [  ipgui::add_param $IPINST -name "VCO_MULT" -parent ${Page_0} -display_name {Vco Mult}]
  set_property tooltip {Vco Mult} ${VCO_MULT}
  set CLKIN_DIVIDE  [  ipgui::add_param $IPINST -name "CLKIN_DIVIDE" -parent ${Page_0} -display_name {Clkin Divide}]
  set_property tooltip {Clkin Divide} ${CLKIN_DIVIDE}
  set CLKIN_PERIOD  [  ipgui::add_param $IPINST -name "CLKIN_PERIOD" -parent ${Page_0} -display_name {Clkin Period}]
  set_property tooltip {Clkin Period} ${CLKIN_PERIOD}


}

proc update_PARAM_VALUE.IOSTD_ELINK { PARAM_VALUE.IOSTD_ELINK } {
	# Procedure called to update IOSTD_ELINK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IOSTD_ELINK { PARAM_VALUE.IOSTD_ELINK } {
	# Procedure called to validate IOSTD_ELINK
	return true
}

proc update_PARAM_VALUE.FEATURE_CCLK_DIV { PARAM_VALUE.FEATURE_CCLK_DIV } {
	# Procedure called to update FEATURE_CCLK_DIV when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FEATURE_CCLK_DIV { PARAM_VALUE.FEATURE_CCLK_DIV } {
	# Procedure called to validate FEATURE_CCLK_DIV
	return true
}

proc update_PARAM_VALUE.LCLK_DIVIDE { PARAM_VALUE.LCLK_DIVIDE } {
	# Procedure called to update LCLK_DIVIDE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.LCLK_DIVIDE { PARAM_VALUE.LCLK_DIVIDE } {
	# Procedure called to validate LCLK_DIVIDE
	return true
}

proc update_PARAM_VALUE.CCLK_DIVIDE { PARAM_VALUE.CCLK_DIVIDE } {
	# Procedure called to update CCLK_DIVIDE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CCLK_DIVIDE { PARAM_VALUE.CCLK_DIVIDE } {
	# Procedure called to validate CCLK_DIVIDE
	return true
}

proc update_PARAM_VALUE.VCO_MULT { PARAM_VALUE.VCO_MULT } {
	# Procedure called to update VCO_MULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.VCO_MULT { PARAM_VALUE.VCO_MULT } {
	# Procedure called to validate VCO_MULT
	return true
}

proc update_PARAM_VALUE.CLKIN_DIVIDE { PARAM_VALUE.CLKIN_DIVIDE } {
	# Procedure called to update CLKIN_DIVIDE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CLKIN_DIVIDE { PARAM_VALUE.CLKIN_DIVIDE } {
	# Procedure called to validate CLKIN_DIVIDE
	return true
}

proc update_PARAM_VALUE.CLKIN_PERIOD { PARAM_VALUE.CLKIN_PERIOD } {
	# Procedure called to update CLKIN_PERIOD when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CLKIN_PERIOD { PARAM_VALUE.CLKIN_PERIOD } {
	# Procedure called to validate CLKIN_PERIOD
	return true
}


proc update_MODELPARAM_VALUE.CLKIN_PERIOD { MODELPARAM_VALUE.CLKIN_PERIOD PARAM_VALUE.CLKIN_PERIOD } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CLKIN_PERIOD}] ${MODELPARAM_VALUE.CLKIN_PERIOD}
}

proc update_MODELPARAM_VALUE.CLKIN_DIVIDE { MODELPARAM_VALUE.CLKIN_DIVIDE PARAM_VALUE.CLKIN_DIVIDE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CLKIN_DIVIDE}] ${MODELPARAM_VALUE.CLKIN_DIVIDE}
}

proc update_MODELPARAM_VALUE.VCO_MULT { MODELPARAM_VALUE.VCO_MULT PARAM_VALUE.VCO_MULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.VCO_MULT}] ${MODELPARAM_VALUE.VCO_MULT}
}

proc update_MODELPARAM_VALUE.CCLK_DIVIDE { MODELPARAM_VALUE.CCLK_DIVIDE PARAM_VALUE.CCLK_DIVIDE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CCLK_DIVIDE}] ${MODELPARAM_VALUE.CCLK_DIVIDE}
}

proc update_MODELPARAM_VALUE.LCLK_DIVIDE { MODELPARAM_VALUE.LCLK_DIVIDE PARAM_VALUE.LCLK_DIVIDE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.LCLK_DIVIDE}] ${MODELPARAM_VALUE.LCLK_DIVIDE}
}

proc update_MODELPARAM_VALUE.FEATURE_CCLK_DIV { MODELPARAM_VALUE.FEATURE_CCLK_DIV PARAM_VALUE.FEATURE_CCLK_DIV } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FEATURE_CCLK_DIV}] ${MODELPARAM_VALUE.FEATURE_CCLK_DIV}
}

proc update_MODELPARAM_VALUE.IOSTD_ELINK { MODELPARAM_VALUE.IOSTD_ELINK PARAM_VALUE.IOSTD_ELINK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IOSTD_ELINK}] ${MODELPARAM_VALUE.IOSTD_ELINK}
}

