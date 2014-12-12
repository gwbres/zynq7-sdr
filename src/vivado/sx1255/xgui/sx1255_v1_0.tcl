# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
	set Page0 [ipgui::add_page $IPINST -name "Page 0" -layout vertical]
	set Component_Name [ipgui::add_param $IPINST -parent $Page0 -name Component_Name]
	set SPI_DATA_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name SPI_DATA_WIDTH]
	set I2S_DATA_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name I2S_DATA_WIDTH]
	set C_S00_AXI_ADDR_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name C_S00_AXI_ADDR_WIDTH]
	set C_S00_AXI_DATA_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name C_S00_AXI_DATA_WIDTH]
}

proc update_PARAM_VALUE.SPI_DATA_WIDTH { PARAM_VALUE.SPI_DATA_WIDTH } {
	# Procedure called to update SPI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SPI_DATA_WIDTH { PARAM_VALUE.SPI_DATA_WIDTH } {
	# Procedure called to validate SPI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.I2S_DATA_WIDTH { PARAM_VALUE.I2S_DATA_WIDTH } {
	# Procedure called to update I2S_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.I2S_DATA_WIDTH { PARAM_VALUE.I2S_DATA_WIDTH } {
	# Procedure called to validate I2S_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to update C_S00_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_S00_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to update C_S00_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S00_AXI_DATA_WIDTH
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

proc update_MODELPARAM_VALUE.I2S_DATA_WIDTH { MODELPARAM_VALUE.I2S_DATA_WIDTH PARAM_VALUE.I2S_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.I2S_DATA_WIDTH}] ${MODELPARAM_VALUE.I2S_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.SPI_DATA_WIDTH { MODELPARAM_VALUE.SPI_DATA_WIDTH PARAM_VALUE.SPI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SPI_DATA_WIDTH}] ${MODELPARAM_VALUE.SPI_DATA_WIDTH}
}

