module ri5cy_ahb_wrapper #(
  parameter AHB_ADDR_WIDTH      = 32,
  parameter AHB_DATA_WIDTH      = 32,
  parameter N_EXT_PERF_COUNTERS =  0,
  parameter INSTR_RDATA_WIDTH   = 32,
  parameter PULP_SECURE         =  0,
  parameter N_PMP_ENTRIES       = 16,
  parameter USE_PMP             =  1,
  parameter PULP_CLUSTER        =  1,
  parameter FPU                 =  0,
  parameter Zfinx               =  0,
  parameter FP_DIVSQRT          =  0,
  parameter SHARED_FP           =  0,
  parameter SHARED_DSP_MULT     =  0,
  parameter SHARED_INT_DIV      =  0,
  parameter SHARED_FP_DIVSQRT   =  0,
  parameter WAPUTYPE            =  0,
  parameter APU_NARGS_CPU       =  3,
  parameter APU_WOP_CPU         =  6,
  parameter APU_NDSFLAGS_CPU    = 15,
  parameter APU_NUSFLAGS_CPU    =  5,
  parameter DM_HaltAddress      = 32'h1A110800
)(
  input   core_clk,
  input   core_rstn,
  // Control signals
  input   clk_en_i,
  input   [31:0] boot_addr_i,
  input   [3:0] core_id_i,
  input   [5:0] cluster_id_i,
  input   fetch_enable_i,
  output  core_busy_o,
  input   [N_EXT_PERF_COUNTERS-1:0] ext_perf_counters_i,
  input   debug_req_i,
  output  sec_lvl_o,
  // IRQ Signals
  input   irq_i,
  input   [4:0] irq_id_i,
  output  irq_ack_o,
  output  [4:0] irq_id_o,
  input   irq_sec_i,
  // APU interface signals
  output  apu_master_req_o,
  output  apu_master_ready_o,
  input   apu_master_gnt_i,
  // APU request channel
  output  [APU_NARGS_CPU-1:0][31:0] apu_master_operands_o,
  output  [APU_WOP_CPU-1:0] apu_master_op_o,
  output  [WAPUTYPE-1:0] apu_master_type_o,
  output  [APU_NDSFLAGS_CPU-1:0] apu_master_flags_o,
  // APU response channel
  input   apu_master_valid_i,
  input   [31:0] apu_master_result_i,
  input   [APU_NUSFLAGS_CPU-1:0] apu_master_flags_i,
  // AHB Master instruction interface
  output  instr_hsel_o,
  output  [AHB_ADDR_WIDTH-1:0] instr_haddr_o,
  output  [AHB_DATA_WIDTH-1:0] instr_hwdata_o,
  output  instr_hwrite_o,
  output  [2:0] instr_hsize_o,
  output  [2:0] instr_hburst_o,
  output  [3:0] instr_hprot_o,
  output  [1:0] instr_htrans_o,
  output  instr_hmastlock_o,
  output  instr_hready_o,
  input   [AHB_DATA_WIDTH-1:0] instr_hrdata_i,
  input   instr_hreadyout_i,
  input   instr_hresp_i,
  // AHB Master data interface
  output  data_hsel_o,
  output  [AHB_ADDR_WIDTH-1:0] data_haddr_o,
  output  [AHB_DATA_WIDTH-1:0] data_hwdata_o,
  output  data_hwrite_o,
  output  [2:0] data_hsize_o,
  output  [2:0] data_hburst_o,
  output  [3:0] data_hprot_o,
  output  [1:0] data_htrans_o,
  output  data_hmastlock_o,
  output  data_hready_o,
  input   [AHB_DATA_WIDTH-1:0] data_hrdata_i,
  input   data_hreadyout_i,
  input   data_hresp_i
);
  logic instr_hsel;
  logic data_hsel;
  logic error_instr_oor;
  logic error_data_oor;

  logic [31:0] instr_addr;
  logic instr_req;
  logic [31:0] instr_rdata;
  logic instr_gnt;
  logic instr_rvalid;

  logic data_req;
  logic data_gnt;
  logic data_rvalid;
  logic data_we;
  logic [3:0] data_be;
  logic [31:0] data_addr;
  logic [31:0] data_wdata;
  logic [31:0] data_rdata;

  filter_oor ahb_instr_filter(
    .addr_i(instr_haddr_o),
    .input_sel_i(instr_hsel),
    .valid_o(instr_hsel_o),
    .error_o(error_instr_oor)
  );

  filter_oor ahb_data_filter(
    .addr_i(data_haddr_o),
    .input_sel_i(data_hsel),
    .valid_o(data_hsel_o),
    .error_o(error_data_oor)
  );

  ri5cy_to_ahb # (
    .AHB_ADDR_WIDTH(AHB_ADDR_WIDTH),
    .AHB_DATA_WIDTH(AHB_DATA_WIDTH)
  ) instr_ahb (
    .clk(core_clk),
    .rstn(core_rstn),
    // Custom RI5CY memory interface
    .req_i(instr_req),
    .we_i('0),
    .be_i('hf),
    .addr_i(instr_addr),
    .wdata_i('0),
    .gnt_o(instr_gnt),
    .rvalid_o(instr_rvalid),
    .rdata_o(instr_rdata),
    // AHB master signals
    .hsel_o(instr_hsel),
    .haddr_o(instr_haddr_o),
    .hwdata_o(instr_hwdata_o),
    .hwrite_o(instr_hwrite_o),
    .hsize_o(instr_hsize_o),
    .hburst_o(instr_hburst_o),
    .hprot_o(instr_hprot_o),
    .htrans_o(instr_htrans_o),
    .hmastlock_o(instr_hmastlock_o),
    .hready_o(instr_hready_o),
    .hrdata_i(instr_hrdata_i),
    .hreadyout_i(instr_hreadyout_i),
    .hresp_i(instr_hresp_i)
  );

  ri5cy_to_ahb # (
    .AHB_ADDR_WIDTH(AHB_ADDR_WIDTH),
    .AHB_DATA_WIDTH(AHB_DATA_WIDTH)
  ) data_ahb (
    .clk(core_clk),
    .rstn(core_rstn),
    // Custom RI5CY memory interface
    .req_i(data_req),
    .we_i(data_we),
    .be_i(data_be),
    .addr_i(data_addr),
    .wdata_i(data_wdata),
    .gnt_o(data_gnt),
    .rvalid_o(data_rvalid),
    .rdata_o(data_rdata),
    // AHB master signals
    .hsel_o(data_hsel),
    .haddr_o(data_haddr_o),
    .hwdata_o(data_hwdata_o),
    .hwrite_o(data_hwrite_o),
    .hsize_o(data_hsize_o),
    .hburst_o(data_hburst_o),
    .hprot_o(data_hprot_o),
    .htrans_o(data_htrans_o),
    .hmastlock_o(data_hmastlock_o),
    .hready_o(data_hready_o),
    .hrdata_i(data_hrdata_i),
    .hreadyout_i(data_hreadyout_i),
    .hresp_i(data_hresp_i)
  );

  riscv_core #(
    .INSTR_RDATA_WIDTH(INSTR_RDATA_WIDTH),
    .PULP_SECURE(PULP_SECURE),
    .N_EXT_PERF_COUNTERS(N_EXT_PERF_COUNTERS),
    .N_PMP_ENTRIES(N_PMP_ENTRIES),
    .USE_PMP(USE_PMP),
    .PULP_CLUSTER(PULP_CLUSTER),
    .FPU(FPU),
    .Zfinx(Zfinx),
    .FP_DIVSQRT(FP_DIVSQRT),
    .SHARED_FP(SHARED_FP),
    .SHARED_DSP_MULT(SHARED_DSP_MULT),
    .SHARED_INT_DIV(SHARED_INT_DIV),
    .SHARED_FP_DIVSQRT(SHARED_FP_DIVSQRT),
    .WAPUTYPE(WAPUTYPE),
    .APU_NARGS_CPU(APU_NARGS_CPU),
    .APU_WOP_CPU(APU_WOP_CPU),
    .APU_NDSFLAGS_CPU(APU_NDSFLAGS_CPU),
    .APU_NUSFLAGS_CPU(APU_NUSFLAGS_CPU),
    .DM_HaltAddress(DM_HaltAddress)
  ) riscv_core_i (
    .clk_i                  ( core_clk              ),
    .rst_ni                 ( core_rstn             ),

    .clock_en_i             ( clk_en_i              ),
    .fregfile_disable_i     ( '0                    ),
    .test_en_i              ( '0                    ),

    .boot_addr_i            ( boot_addr_i           ),
    .core_id_i              ( core_id_i             ),
    .cluster_id_i           ( cluster_id_i          ),

    .instr_addr_o           ( instr_addr            ),
    .instr_req_o            ( instr_req             ),
    .instr_rdata_i          ( instr_rdata           ),
    .instr_gnt_i            ( instr_gnt             ),
    .instr_rvalid_i         ( instr_rvalid          ),

    .data_addr_o            ( data_addr             ),
    .data_wdata_o           ( data_wdata            ),
    .data_we_o              ( data_we               ),
    .data_req_o             ( data_req              ),
    .data_be_o              ( data_be               ),
    .data_rdata_i           ( data_rdata            ),
    .data_gnt_i             ( data_gnt              ),
    .data_rvalid_i          ( data_rvalid           ),

    .apu_master_req_o       ( apu_master_req_o      ),
    .apu_master_ready_o     ( apu_master_ready_o    ),
    .apu_master_gnt_i       ( apu_master_gnt_i      ),
    .apu_master_operands_o  ( apu_master_operands_o ),
    .apu_master_op_o        ( apu_master_op_o       ),
    .apu_master_type_o      ( apu_master_type_o     ),
    .apu_master_flags_o     ( apu_master_flags_o    ),
    .apu_master_valid_i     ( apu_master_valid_i    ),
    .apu_master_result_i    ( apu_master_result_i   ),
    .apu_master_flags_i     ( apu_master_flags_i    ),

    .irq_i                  ( irq_i                 ),
    .irq_id_i               ( irq_id_i              ),
    .irq_ack_o              ( irq_ack_o             ),
    .irq_id_o               ( irq_id_o              ),
    .irq_sec_i              ( irq_sec_i             ),

    .sec_lvl_o              ( sec_lvl_o             ),

    .debug_req_i            ( debug_req_i           ),

    .fetch_enable_i         ( fetch_enable_i        ),
    .core_busy_o            ( core_busy_o           ),

    .ext_perf_counters_i    (                       )
  );
endmodule
