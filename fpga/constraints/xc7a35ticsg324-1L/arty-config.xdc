set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]

## Clock signal
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk_100M]

#create_clock -add -name sys_clk_pin -period 25.00 -waveform {0 5} [get_ports { clk }]; # 40MHz

#set_clock_groups -asynchronous #  -group [list #     [get_clocks -include_generated_clocks -of_objects [get_ports jtag_tck_io]]] #  -group [list #     [get_clocks -of_objects [get_pins ip_mmcm/inst/mmcm_adv_inst/CLKOUT0]]] #  -group [list #     [get_clocks -of_objects [get_pins ip_mmcm/inst/mmcm_adv_inst/CLKOUT1]] #     [get_clocks -of_objects [get_pins ip_mmcm/inst/mmcm_adv_inst/CLKOUT2]]]

