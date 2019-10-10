set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVCMOS33} [get_ports reset_n]
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk_sys]

## Pmod Header JD
## JD1 - tdi
## JD2 - tdo
## JD3 - tck
## JD4 - tms
set_property -dict {PACKAGE_PIN D4 IOSTANDARD LVCMOS33} [get_ports jtag_tdi]
set_property -dict {PACKAGE_PIN D3 IOSTANDARD LVCMOS33} [get_ports jtag_tdo]
set_property -dict {PACKAGE_PIN F4 IOSTANDARD LVCMOS33} [get_ports jtag_tck]
set_property -dict {PACKAGE_PIN F3 IOSTANDARD LVCMOS33} [get_ports jtag_tms]

## Switches
set_property -dict {PACKAGE_PIN A8 IOSTANDARD LVCMOS33}  [get_ports {gpio_in[0]}]
set_property -dict {PACKAGE_PIN C11 IOSTANDARD LVCMOS33} [get_ports {gpio_in[1]}]
set_property -dict {PACKAGE_PIN C10 IOSTANDARD LVCMOS33} [get_ports {gpio_in[2]}]
set_property -dict {PACKAGE_PIN A10 IOSTANDARD LVCMOS33} [get_ports {gpio_in[3]}]

## RGB LEDs
set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS33} [get_ports {gpio_out[11]}]
set_property -dict {PACKAGE_PIN F6 IOSTANDARD LVCMOS33} [get_ports {gpio_out[10]}]
set_property -dict {PACKAGE_PIN G6 IOSTANDARD LVCMOS33} [get_ports {gpio_out[9]}]

set_property -dict {PACKAGE_PIN G4 IOSTANDARD LVCMOS33} [get_ports {gpio_out[8]}]
set_property -dict {PACKAGE_PIN J4 IOSTANDARD LVCMOS33} [get_ports {gpio_out[7]}]
set_property -dict {PACKAGE_PIN G3 IOSTANDARD LVCMOS33} [get_ports {gpio_out[6]}]

set_property -dict {PACKAGE_PIN H4 IOSTANDARD LVCMOS33} [get_ports {gpio_out[5]}]
set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS33} [get_ports {gpio_out[4]}]
set_property -dict {PACKAGE_PIN J3 IOSTANDARD LVCMOS33} [get_ports {gpio_out[3]}]

set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVCMOS33} [get_ports {gpio_out[2]}]
set_property -dict {PACKAGE_PIN H6 IOSTANDARD LVCMOS33} [get_ports {gpio_out[1]}]
set_property -dict {PACKAGE_PIN K1 IOSTANDARD LVCMOS33} [get_ports {gpio_out[0]}]

set_property -dict { PACKAGE_PIN H5    IOSTANDARD LVCMOS33 } [get_ports { led[0] }]
set_property -dict { PACKAGE_PIN J5    IOSTANDARD LVCMOS33 } [get_ports { led[1] }]
set_property -dict { PACKAGE_PIN T9    IOSTANDARD LVCMOS33 } [get_ports { led[2] }]
set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33 } [get_ports { led[3] }]

## USB-UART Interface
# set_property -dict {PACKAGE_PIN D10 IOSTANDARD LVCMOS33} [get_ports uart_tx_mirror]
# set_property -dict {PACKAGE_PIN A9 IOSTANDARD LVCMOS33} [get_ports uart_rx_mirror]
