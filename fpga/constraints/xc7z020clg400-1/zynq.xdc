set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets jtag_tck]

## Clock signal
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0.000 4.000} [get_ports { clk_sys }];
