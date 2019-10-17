`include "config_soc.v"

module artix_wrapper (
  input   clk_sys,
  input   reset_n,
  // JTAG Interface
  input   jtag_tck,
  input   jtag_tms,
  input   jtag_tdi,
  output  jtag_tdo,
  // Peripherals
  output  [11:0] gpio_out,
  input   [3:0] gpio_in,
  input   rx_i,
  output  tx_o,
  input   rx_mirror_i,
  output  tx_mirror_o,
  // Status
  output  clk_locked
);
  logic core_clk;
  logic periph_clk;
  logic status_clk;
  logic locked;
  logic fetch_enable;
  logic rx, tx;

  assign fetch_enable = locked;
  assign clk_locked = locked;
  assign tx_o = tx;
  assign tx_mirror_o = tx;
  assign rx = rx_i;

  mmcm clk_mmcm (
    // Clock in ports
    .clk_in(clk_sys),
    // Clock out ports
    .core_clk(core_clk),
    .periph_clk(periph_clk),
    // Status and control signals
    .resetn(reset_n),
    .locked(locked)
  );

  riscv_soc #(
    .USE_SAME_CLOCK_CORE_PERIPH(0)
  ) riscv (
    .core_clk(core_clk),
    .periph_clk(periph_clk),
    .reset_n(reset_n),
    .fetch_enable_i(fetch_enable),
    .gpio_out(gpio_out),
    .gpio_in(gpio_in),
    .rx_i(rx),
    .tx_o(tx),
    .jtag_tck(jtag_tck),
    .jtag_tms(jtag_tms),
    .jtag_tdi(jtag_tdi),
    .jtag_tdo(jtag_tdo),
    .jtag_trstn(reset_n)
  );
endmodule
