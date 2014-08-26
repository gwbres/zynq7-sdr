# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
	set Page0 [ipgui::add_page $IPINST -name "Page 0" -layout vertical]
	set Component_Name [ipgui::add_param $IPINST -parent $Page0 -name Component_Name]
	set USE_CORE_CLOCK [ipgui::add_param $IPINST -parent $Page0 -name USE_CORE_CLOCK]
	set NB_COEFF [ipgui::add_param $IPINST -parent $Page0 -name NB_COEFF]
	set COEFF_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name COEFF_WIDTH]
	set DATA_IN_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name DATA_IN_WIDTH]
	set DATA_OUT_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name DATA_OUT_WIDTH]
	set C_S00_AXI_DATA_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name C_S00_AXI_DATA_WIDTH]
	set_property tooltip {Width of S_AXI data bus} $C_S00_AXI_DATA_WIDTH
	set C_S00_AXI_ADDR_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name C_S00_AXI_ADDR_WIDTH]
	set_property tooltip {Width of S_AXI address bus} $C_S00_AXI_ADDR_WIDTH
	set C_S00_AXI_BASEADDR [ipgui::add_param $IPINST -parent $Page0 -name C_S00_AXI_BASEADDR]
	set C_S00_AXI_HIGHADDR [ipgui::add_param $IPINST -parent $Page0 -name C_S00_AXI_HIGHADDR]
}

proc update_PARAM_VALUE.USE_CORE_CLOCK { PARAM_VALUE.USE_CORE_CLOCK } {
	# Procedure called to update USE_CORE_CLOCK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.USE_CORE_CLOCK { PARAM_VALUE.USE_CORE_CLOCK } {
	# Procedure called to validate USE_CORE_CLOCK
	return true
}

proc update_PARAM_VALUE.NB_COEFF { PARAM_VALUE.NB_COEFF } {
	# Procedure called to update NB_COEFF when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NB_COEFF { PARAM_VALUE.NB_COEFF } {
	# Procedure called to validate NB_COEFF
	return true
}

proc update_PARAM_VALUE.COEFF_WIDTH { PARAM_VALUE.COEFF_WIDTH } {
	# Procedure called to update COEFF_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.COEFF_WIDTH { PARAM_VALUE.COEFF_WIDTH } {
	# Procedure called to validate COEFF_WIDTH
	return true
}

proc update_PARAM_VALUE.DATA_IN_WIDTH { PARAM_VALUE.DATA_IN_WIDTH } {
	# Procedure called to update DATA_IN_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_IN_WIDTH { PARAM_VALUE.DATA_IN_WIDTH } {
	# Procedure called to validate DATA_IN_WIDTH
	return true
}

proc update_PARAM_VALUE.DATA_OUT_WIDTH { PARAM_VALUE.DATA_OUT_WIDTH } {
	# Procedure called to update DATA_OUT_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_OUT_WIDTH { PARAM_VALUE.DATA_OUT_WIDTH } {
	# Procedure called to validate DATA_OUT_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to update C_S00_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S00_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to update C_S00_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_S00_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_BASEADDR { PARAM_VALUE.C_S00_AXI_BASEADDR } {
	# Procedure called to update C_S00_AXI_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_BASEADDR { PARAM_VALUE.C_S00_AXI_BASEADDR } {
	# Procedure called to validate C_S00_AXI_BASEADDR
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_HIGHADDR { PARAM_VALUE.C_S00_AXI_HIGHADDR } {
	# Procedure called to update C_S00_AXI_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_HIGHADDR { PARAM_VALUE.C_S00_AXI_HIGHADDR } {
	# Procedure called to validate C_S00_AXI_HIGHADDR
	return true
}


proc update_MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.USE_CORE_CLOCK { MODELPARAM_VALUE.USE_CORE_CLOCK PARAM_VALUE.USE_CORE_CLOCK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.USE_CORE_CLOCK}] ${MODELPARAM_VALUE.USE_CORE_CLOCK}
}

proc update_MODELPARAM_VALUE.NB_COEFF { MODELPARAM_VALUE.NB_COEFF PARAM_VALUE.NB_COEFF } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NB_COEFF}] ${MODELPARAM_VALUE.NB_COEFF}
}

proc update_MODELPARAM_VALUE.COEFF_WIDTH { MODELPARAM_VALUE.COEFF_WIDTH PARAM_VALUE.COEFF_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.COEFF_WIDTH}] ${MODELPARAM_VALUE.COEFF_WIDTH}
}

proc update_MODELPARAM_VALUE.DATA_IN_WIDTH { MODELPARAM_VALUE.DATA_IN_WIDTH PARAM_VALUE.DATA_IN_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_IN_WIDTH}] ${MODELPARAM_VALUE.DATA_IN_WIDTH}
}

proc update_MODELPARAM_VALUE.DATA_OUT_WIDTH { MODELPARAM_VALUE.DATA_OUT_WIDTH PARAM_VALUE.DATA_OUT_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_OUT_WIDTH}] ${MODELPARAM_VALUE.DATA_OUT_WIDTH}
}

