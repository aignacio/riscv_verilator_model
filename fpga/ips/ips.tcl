create_ip -vendor xilinx.com -library ip -name clk_wiz -module_name mmcm -dir $ipdir -force

set fpga_board $::env(FPGA_BOARD)

if { $fpga_board == "pynq" } {
    puts "Using clock synthesis for PYNQ board...."
    set_property -dict [list \
        CONFIG.PRIMITIVE {MMCM} \
        CONFIG.PRIM_IN_FREQ {125} \
        CONFIG.CLKOUT2_USED {true} \
        CONFIG.PRIMARY_PORT {clk_in} \
        CONFIG.CLK_OUT1_PORT {core_clk} \
        CONFIG.CLK_OUT2_PORT {periph_clk} \
        CONFIG.CLK_OUT3_PORT {status_clk} \
        CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {25} \
        CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {12.5}  \
        CONFIG.RESET_TYPE {ACTIVE_LOW} \
        CONFIG.CLKIN1_JITTER_PS {80.0} \
        CONFIG.CLKOUT1_DRIVES {BUFG} \
        CONFIG.CLKOUT2_DRIVES {BUFG} \
        CONFIG.CLKOUT4_DRIVES {BUFG} \
        CONFIG.CLKOUT5_DRIVES {BUFG} \
        CONFIG.CLKOUT6_DRIVES {BUFG} \
        CONFIG.CLKOUT7_DRIVES {BUFG} \
        CONFIG.FEEDBACK_SOURCE {FDBK_AUTO} \
        CONFIG.MMCM_DIVCLK_DIVIDE {1} \
        CONFIG.MMCM_CLKFBOUT_MULT_F {8.000} \
        CONFIG.MMCM_CLKIN1_PERIOD {8.000} \
        CONFIG.MMCM_COMPENSATION {ZHOLD} \
        CONFIG.MMCM_CLKOUT0_DIVIDE_F {40.000} \
        CONFIG.MMCM_CLKOUT1_DIVIDE {80} \
        CONFIG.MMCM_CLKOUT2_DIVIDE {100} \
        CONFIG.NUM_OUT_CLKS {3} \
        CONFIG.RESET_PORT {resetn} \
        CONFIG.CLKOUT1_JITTER {165.419} \
        CONFIG.CLKOUT1_PHASE_ERROR {96.948} \
        CONFIG.CLKOUT2_JITTER {189.342} \
        CONFIG.CLKOUT2_PHASE_ERROR {96.948}] [get_ips mmcm]
} else {
    set_property -dict [list \
        CONFIG.PRIMITIVE {MMCM} \
        CONFIG.RESET_TYPE {ACTIVE_LOW} \
        CONFIG.PRIMARY_PORT {clk_in} \
        CONFIG.CLKOUT1_USED {true} \
        CONFIG.CLKOUT2_USED {true} \
        CONFIG.CLK_OUT1_PORT {core_clk} \
        CONFIG.CLK_OUT2_PORT {periph_clk} \
        CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {35} \
        CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {20} \
        ] [get_ips mmcm]
}

