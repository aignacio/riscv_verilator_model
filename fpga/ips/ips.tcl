create_ip -vendor xilinx.com -library ip -name clk_wiz -module_name mmcm -dir $ipdir -force
set_property -dict [list \
	CONFIG.PRIMITIVE {MMCM} \
	CONFIG.RESET_TYPE {ACTIVE_LOW} \
    CONFIG.PRIMARY_PORT {clk_in} \
	CONFIG.CLKOUT1_USED {true} \
    CONFIG.CLKOUT2_USED {true} \
    CONFIG.CLKOUT3_USED {true} \
    CONFIG.CLK_OUT1_PORT {core_clk} \
    CONFIG.CLK_OUT2_PORT {periph_clk} \
    CONFIG.CLK_OUT3_PORT {status_clk} \
	CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {40} \
    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {20} \
    CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {10} \
	] [get_ips mmcm]
