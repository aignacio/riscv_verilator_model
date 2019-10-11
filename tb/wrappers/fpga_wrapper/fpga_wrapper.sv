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
  // Status
  output  [3:0] led
);
  logic core_clk;
  logic periph_clk;
  logic status_clk;
  logic fetch_enable;

  assign led[0] = status_clk;
  assign led[1] = status_clk;
  assign led[2] = status_clk;
  assign led[3] = status_clk;

  mmcm clk_mmcm (
    // Clock in ports
    .clk_in(clk_sys),
    // Clock out ports
    .core_clk(core_clk),
    .periph_clk(periph_clk),
    .status_clk(status_clk),
    // Status and control signals
    .resetn(reset_n),
    .locked(fetch_enable)
  );

  riscv_soc #(
    .USE_SAME_CLOCK_CORE_PERIPH(0)
  ) riscv (
    .core_clk(core_clk),
    .periph_clk(periph_clk),
    .reset_n(reset_n),
    .boot_addr_i(32'h1A00_0000),    // Fixed in boot loop
    .fetch_enable_i(fetch_enable),
    .gpio_out(gpio_out),
    .gpio_in(gpio_in),
    .jtag_tck(jtag_tck),
    .jtag_tms(jtag_tms),
    .jtag_tdi(jtag_tdi),
    .jtag_tdo(jtag_tdo),
    .jtag_trstn(reset_n)
  );
endmodule
