create_ip -vendor xilinx.com -library ip -name clk_wiz -module_name mmcm -dir $ipdir -force
set_property -dict [list \
	CONFIG.PRIMITIVE {MMCM} \
	CONFIG.RESET_TYPE {ACTIVE_LOW} \
    CONFIG.PRIMARY_PORT {clk_in} \
	CONFIG.CLKOUT1_USED {true} \
    CONFIG.CLKOUT2_USED {true} \
    CONFIG.CLK_OUT1_PORT {core_clk} \
    CONFIG.CLK_OUT2_PORT {periph_clk} \
	CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {50} \
    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {25} \
	] [get_ips mmcm]
