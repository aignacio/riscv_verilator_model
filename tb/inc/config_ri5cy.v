`ifndef CONFIG_RI5CY_V
`define CONFIG_RI5CY_V
  `define N_EXT_PERF_COUNTERS 0
  `define INSTR_RDATA_WIDTH   32
  `define PULP_SECURE         1
  `define N_PMP_ENTRIES       16
  `define USE_PMP             0
  `define PULP_CLUSTER        1
  `define FPU                 0
  `define Zfinx               0
  `define FP_DIVSQRT          0
  `define SHARED_FP           0
  `define SHARED_DSP_MULT     0
  `define SHARED_INT_DIV      0
  `define SHARED_FP_DIVSQRT   0
  `define WAPUTYPE            0
  `define APU_NARGS_CPU       3
  `define APU_WOP_CPU         6
  `define APU_NDSFLAGS_CPU    15
  `define APU_NUSFLAGS_CPU    5
  `define DM_HaltAddress      32'h1A110800
  `define CORE_ID             4'd0
  `define CLUSTER_ID          6'd0
  `define CORE_MHARTID        {`CLUSTER_ID, 1'b0, `CORE_ID}
  // Debug Parameters
  `define SELECTABLE_HARTS    1
  `define N_OF_HARTS          1
  `define JTAG_DECODE_ID      32'h249511C3
  `define JTAG_BOOT           `JTAG_LOOP_BOOT
`endif
