`timescale 10ns/100ps

`include "config_soc.v"
`ifdef USE_RI5CY
  `include "config_ri5cy.v"
  `ifdef USE_RI5CY_JTAG
    import dm::*;
  `endif
`endif

module riscv_soc (
  input   clk,
  input   reset_n,
  input   [31:0] boot_addr_i,
  input   fetch_enable_i,
  input   sim_jtag_tck,
  input   sim_jtag_tms,
  input   sim_jtag_tdi,
  output  sim_jtag_tdo,
  input   sim_jtag_trstn
);
  logic gpio_out;

  logic cpu_boot_addr;

  logic [`N_OF_HARTS-1:0]      dm_debug_req;

  /**********************
    AHB WIREUP SIGNALS
  **********************/
  logic HCLK;
  logic HRESETn;
  logic [`AHB_HADDR_SIZE-1:0] ahb_slv_addr_mask [`AHB_SLAVES_NUM];
  logic [`AHB_HADDR_SIZE-1:0] ahb_slv_addr_base [`AHB_SLAVES_NUM];
  logic [`APB_PADDR_SIZE-1:0] apb_slv_addr_mask [`APB_SLAVES_NUM];
  logic [`APB_PADDR_SIZE-1:0] apb_slv_addr_base [`APB_SLAVES_NUM];
  logic [`AHB_HADDR_SIZE-1:0] mst_HADDR     [`AHB_MASTERS_NUM], slv_HADDR   [`AHB_SLAVES_NUM];
  logic [`AHB_HDATA_SIZE-1:0] mst_HWDATA    [`AHB_MASTERS_NUM], slv_HWDATA  [`AHB_SLAVES_NUM];
  logic [`AHB_HDATA_SIZE-1:0] mst_HRDATA    [`AHB_MASTERS_NUM], slv_HRDATA  [`AHB_SLAVES_NUM];
  logic mst_HSEL    [`AHB_MASTERS_NUM], slv_HSEL    [`AHB_SLAVES_NUM ];
  logic mst_HWRITE  [`AHB_MASTERS_NUM], slv_HWRITE  [`AHB_SLAVES_NUM ];
  logic [$clog2(`AHB_MASTERS_NUM-1):0] mst_priority  [`AHB_MASTERS_NUM];
  logic [2:0] mst_HSIZE     [`AHB_MASTERS_NUM], slv_HSIZE     [`AHB_SLAVES_NUM ];
  logic [2:0] mst_HBURST    [`AHB_MASTERS_NUM], slv_HBURST    [`AHB_SLAVES_NUM ];
  logic [3:0] mst_HPROT     [`AHB_MASTERS_NUM], slv_HPROT     [`AHB_SLAVES_NUM ];
  logic [1:0] mst_HTRANS    [`AHB_MASTERS_NUM], slv_HTRANS    [`AHB_SLAVES_NUM ];
  logic mst_HMASTLOCK       [`AHB_MASTERS_NUM], slv_HMASTLOCK [`AHB_SLAVES_NUM ];
  logic mst_HREADY          [`AHB_MASTERS_NUM], slv_HREADY    [`AHB_SLAVES_NUM ];
  logic mst_HREADYOUT       [`AHB_MASTERS_NUM], slv_HREADYOUT [`AHB_SLAVES_NUM ];
  logic mst_HRESP           [`AHB_MASTERS_NUM], slv_HRESP     [`AHB_SLAVES_NUM ];
  logic slv_apb_PSEL [`APB_SLAVES_NUM];
  logic slv_apb_PREADY [`APB_SLAVES_NUM];
  logic slv_apb_PSLVERR [`APB_SLAVES_NUM];
  logic [`APB_PADDR_SIZE-1:0] slv_apb_PRDATA [`APB_SLAVES_NUM];

  ahb3lite_if #(`AHB_HADDR_SIZE, `AHB_HDATA_SIZE) ahb_slave [`AHB_SLAVES_NUM] ();
  ahb3lite_if #(`AHB_HADDR_SIZE, `AHB_HDATA_SIZE) ahb_master [`AHB_MASTERS_NUM] ();
  apb4_if #(`APB_PADDR_SIZE, `APB_PDATA_SIZE) apb_ahb_bridge ();
  apb4_if #(`APB_PADDR_SIZE, `APB_PDATA_SIZE) apb_slaves [`APB_SLAVES_NUM] ();

  assign HCLK = clk;
  assign HRESETn = reset_n;

  assign mst_priority[0] = 2; // IBus
  assign mst_priority[1] = 1; // DBus
  assign mst_priority[2] = 3; // Debug

  // AHB Slave addressing
  assign ahb_slv_addr_base[0] = `AHB_SL_BASE_ADDR_0;
  assign ahb_slv_addr_base[1] = `AHB_SL_BASE_ADDR_1;
  assign ahb_slv_addr_base[2] = `AHB_SL_BASE_ADDR_2;
  assign ahb_slv_addr_base[3] = `AHB_SL_BASE_ADDR_3;
  assign ahb_slv_addr_base[4] = `AHB_SL_BASE_ADDR_4;
  assign ahb_slv_addr_base[5] = `AHB_SL_BASE_ADDR_5;

  assign ahb_slv_addr_mask[0] = `AHB_SL_MASK_ADDR_0;
  assign ahb_slv_addr_mask[1] = `AHB_SL_MASK_ADDR_1;
  assign ahb_slv_addr_mask[2] = `AHB_SL_MASK_ADDR_2;
  assign ahb_slv_addr_mask[3] = `AHB_SL_MASK_ADDR_3;
  assign ahb_slv_addr_mask[4] = `AHB_SL_MASK_ADDR_4;
  assign ahb_slv_addr_mask[5] = `AHB_SL_MASK_ADDR_5;

  // APB Slave addressing
  assign apb_slv_addr_base[0] = `APB_SL_BASE_ADDR_0;
  assign apb_slv_addr_base[1] = `APB_SL_BASE_ADDR_1;
  // assign apb_slv_addr_base[2] = `APB_SL_BASE_ADDR_2;
  // assign apb_slv_addr_base[3] = `APB_SL_BASE_ADDR_3;

  assign apb_slv_addr_mask[0] = `APB_SL_MASK_ADDR_0;
  assign apb_slv_addr_mask[1] = `APB_SL_MASK_ADDR_1;
  // assign apb_slv_addr_mask[2] = `APB_SL_MASK_ADDR_2;
  // assign apb_slv_addr_mask[3] = `APB_SL_MASK_ADDR_3;

  genvar m, s;
  generate
    for (m=0;m<`AHB_MASTERS_NUM;m++)
      begin
        assign mst_HSEL     [m] = ahb_master[m].HSEL;
        assign mst_HADDR    [m] = ahb_master[m].HADDR;
        assign mst_HWDATA   [m] = ahb_master[m].HWDATA;
        assign mst_HWRITE   [m] = ahb_master[m].HWRITE;
        assign mst_HSIZE    [m] = ahb_master[m].HSIZE;
        assign mst_HBURST   [m] = ahb_master[m].HBURST;
        assign mst_HPROT    [m] = ahb_master[m].HPROT;
        assign mst_HTRANS   [m] = ahb_master[m].HTRANS;
        assign mst_HMASTLOCK[m] = ahb_master[m].HMASTLOCK;
        assign mst_HREADY   [m] = ahb_master[m].HREADY;

        assign ahb_master[m].HREADYOUT = mst_HREADYOUT[m];
        assign ahb_master[m].HRDATA = mst_HRDATA[m];
        assign ahb_master[m].HRESP  = mst_HRESP [m];
      end

    for (s=0;s<`AHB_SLAVES_NUM;s++)
      begin
        assign ahb_slave[s].HSEL      = slv_HSEL     [s];
        assign ahb_slave[s].HADDR     = slv_HADDR    [s];
        assign ahb_slave[s].HWDATA    = slv_HWDATA   [s];
        assign ahb_slave[s].HWRITE    = slv_HWRITE   [s];
        assign ahb_slave[s].HSIZE     = slv_HSIZE    [s];
        assign ahb_slave[s].HBURST    = slv_HBURST   [s];
        assign ahb_slave[s].HPROT     = slv_HPROT    [s];
        assign ahb_slave[s].HTRANS    = slv_HTRANS   [s];
        assign ahb_slave[s].HMASTLOCK = slv_HMASTLOCK[s];
        assign ahb_slave[s].HREADY    = slv_HREADYOUT[s];

        assign slv_HRDATA[s] = ahb_slave[s].HRDATA;
        assign slv_HREADY[s] = ahb_slave[s].HREADYOUT;
        assign slv_HRESP [s] = ahb_slave[s].HRESP;
      end
  endgenerate

`ifdef USE_RI5CY
  ri5cy_ahb_wrapper # (
    .AHB_ADDR_WIDTH(`AHB_HADDR_SIZE),
    .AHB_DATA_WIDTH(`AHB_HDATA_SIZE),
    .INSTR_RDATA_WIDTH(`INSTR_RDATA_WIDTH),
    .PULP_SECURE(`PULP_SECURE),
    .N_EXT_PERF_COUNTERS(`N_EXT_PERF_COUNTERS),
    .N_PMP_ENTRIES(`N_PMP_ENTRIES),
    .USE_PMP(`USE_PMP),
    .PULP_CLUSTER(`PULP_CLUSTER),
    .FPU(`FPU),
    .Zfinx(`Zfinx),
    .FP_DIVSQRT(`FP_DIVSQRT),
    .SHARED_FP(`SHARED_FP),
    .SHARED_DSP_MULT(`SHARED_DSP_MULT),
    .SHARED_INT_DIV(`SHARED_INT_DIV),
    .SHARED_FP_DIVSQRT(`SHARED_FP_DIVSQRT),
    .WAPUTYPE(`WAPUTYPE),
    .APU_NARGS_CPU(`APU_NARGS_CPU),
    .APU_WOP_CPU(`APU_WOP_CPU),
    .APU_NDSFLAGS_CPU(`APU_NDSFLAGS_CPU),
    .APU_NUSFLAGS_CPU(`APU_NUSFLAGS_CPU),
    .DM_HaltAddress(`DM_HaltAddress)
  ) riscv_cpu (
    // Core control
    .core_clk(clk),
    .core_rstn(ndmreset_n),
    // Control signals
    .clk_en_i('1),
    .boot_addr_i(boot_addr_i),
    .core_id_i(`CORE_ID),
    .cluster_id_i(`CLUSTER_ID),
    .fetch_enable_i(fetch_enable_i),
    .core_busy_o(),
    .ext_perf_counters_i('0),
    .debug_req_i(dm_debug_req[`CORE_MHARTID]),
    .sec_lvl_o(),
    // IRQ Signals
    .irq_i('0),
    .irq_id_i('0),
    .irq_ack_o(),
    .irq_id_o(),
    .irq_sec_i('0),
    // APU Signals
    .apu_master_req_o       (    ),
    .apu_master_ready_o     (    ),
    .apu_master_gnt_i       ( '0 ),
    .apu_master_operands_o  (    ),
    .apu_master_op_o        (    ),
    .apu_master_type_o      (    ),
    .apu_master_flags_o     (    ),
    .apu_master_valid_i     ( '0 ),
    .apu_master_result_i    ( '0 ),
    .apu_master_flags_i     ( '0 ),
    // AHB Master instruction interface
    .instr_hsel_o(ahb_master[0].HSEL),
    .instr_haddr_o(ahb_master[0].HADDR),
    .instr_hwdata_o(ahb_master[0].HWDATA),
    .instr_hwrite_o(ahb_master[0].HWRITE),
    .instr_hsize_o(ahb_master[0].HSIZE),
    .instr_hburst_o(ahb_master[0].HBURST),
    .instr_hprot_o(ahb_master[0].HPROT),
    .instr_htrans_o(ahb_master[0].HTRANS),
    .instr_hmastlock_o(ahb_master[0].HMASTLOCK),
    .instr_hready_o(ahb_master[0].HREADY),
    .instr_hrdata_i(ahb_master[0].HRDATA),
    .instr_hreadyout_i(ahb_master[0].HREADYOUT),
    .instr_hresp_i(ahb_master[0].HRESP),
    // AHB Master data interface
    .data_hsel_o(ahb_master[1].HSEL),
    .data_haddr_o(ahb_master[1].HADDR),
    .data_hwdata_o(ahb_master[1].HWDATA),
    .data_hwrite_o(ahb_master[1].HWRITE),
    .data_hsize_o(ahb_master[1].HSIZE),
    .data_hburst_o(ahb_master[1].HBURST),
    .data_hprot_o(ahb_master[1].HPROT),
    .data_htrans_o(ahb_master[1].HTRANS),
    .data_hmastlock_o(ahb_master[1].HMASTLOCK),
    .data_hready_o(ahb_master[1].HREADY),
    .data_hrdata_i(ahb_master[1].HRDATA),
    .data_hreadyout_i(ahb_master[1].HREADYOUT),
    .data_hresp_i(ahb_master[1].HRESP)
  );

  `ifdef USE_RI5CY_JTAG
    localparam logic [`N_OF_HARTS-1:0] SELECTABLE_HARTS = 1 << `CORE_MHARTID;

    // jtag openocd bridge signals
    logic                        sim_jtag_tck;
    logic                        sim_jtag_tms;
    logic                        sim_jtag_tdi;
    logic                        sim_jtag_trstn;
    logic                        sim_jtag_tdo;

    // signals for debug unit
    logic                        debug_req_ready;
    dm::dmi_resp_t               debug_resp;
    logic                        jtag_req_valid;
    dm::dmi_req_t                jtag_dmi_req;
    logic                        jtag_resp_ready;
    logic                        jtag_resp_valid;
    logic                        ndmreset, ndmreset_n;

    // debug unit slave interface
    logic                        dm_grant;
    logic                        dm_rvalid;
    logic                        dm_req;
    logic                        dm_we;
    logic [31:0]                 dm_addr;
    logic [31:0]                 dm_wdata;
    logic [31:0]                 dm_rdata;
    logic [3:0]                  dm_be;

    // debug unit master interface (system bus access)
    logic                        sb_req;
    logic [31:0]                 sb_addr;
    logic                        sb_we;
    logic [31:0]                 sb_wdata;
    logic [3:0]                  sb_be;
    logic                        sb_gnt;
    logic                        sb_rvalid;
    logic [31:0]                 sb_rdata;

    // debug subsystem
    dmi_jtag #(
      .IdcodeValue          ( `JTAG_DECODE_ID )
    ) i_dmi_jtag (
      .clk_i                ( clk             ),
      .rst_ni               ( reset_n         ),
      .testmode_i           ( 1'b0            ),
      .dmi_req_o            ( jtag_dmi_req    ),
      .dmi_req_valid_o      ( jtag_req_valid  ),
      .dmi_req_ready_i      ( debug_req_ready ),
      .dmi_resp_i           ( debug_resp      ),
      .dmi_resp_ready_o     ( jtag_resp_ready ),
      .dmi_resp_valid_i     ( jtag_resp_valid ),
      .dmi_rst_no           (                 ), // not connected
      .tck_i                ( sim_jtag_tck    ),
      .tms_i                ( sim_jtag_tms    ),
      .trst_ni              ( sim_jtag_trstn  ),
      .td_i                 ( sim_jtag_tdi    ),
      .td_o                 ( sim_jtag_tdo    ),
      .tdo_oe_o             (                 )
    );

    dm_top #(
      .NrHarts           ( `N_OF_HARTS       ),
      .BusWidth          ( `AHB_HADDR_SIZE   ),
      .SelectableHarts   ( `SELECTABLE_HARTS )
    ) i_dm_top (
      .clk_i             ( clk               ),
      .rst_ni            ( reset_n           ),
      .testmode_i        ( 1'b0              ),
      .ndmreset_o        ( ndmreset          ),
      .dmactive_o        (                   ), // active debug session TODO
      .debug_req_o       ( dm_debug_req      ),
      .unavailable_i     ( ~(`SELECTABLE_HARTS)),
      .hartinfo_i        ( '0                ),

      .slave_req_i       ( dm_req            ),
      .slave_we_i        ( dm_we             ),
      .slave_addr_i      ( dm_addr           ),
      .slave_be_i        ( dm_be             ),
      .slave_wdata_i     ( dm_wdata          ),
      .slave_rdata_o     ( dm_rdata          ),

      .master_req_o      ( sb_req            ),
      .master_add_o      ( sb_addr           ),
      .master_we_o       ( sb_we             ),
      .master_wdata_o    ( sb_wdata          ),
      .master_be_o       ( sb_be             ),
      .master_gnt_i      ( sb_gnt            ),
      .master_r_valid_i  ( sb_rvalid         ),
      .master_r_rdata_i  ( sb_rdata          ),

      .dmi_rst_ni        ( reset_n           ),
      .dmi_req_valid_i   ( jtag_req_valid    ),
      .dmi_req_ready_o   ( debug_req_ready   ),
      .dmi_req_i         ( jtag_dmi_req      ),
      .dmi_resp_valid_o  ( jtag_resp_valid   ),
      .dmi_resp_ready_i  ( jtag_resp_ready   ),
      .dmi_resp_o        ( debug_resp        )
    );

    // grant in the same cycle
    assign dm_gnt = dm_req;
    // valid read/write in the next cycle
    always_ff @(posedge clk or negedge reset_n) begin : dm_valid_handler
      if(~reset_n) begin
        dm_rvalid <= '0;
      end else begin
        dm_rvalid <= dm_gnt;
      end
    end

    // reset handling with ndmreset
    rstgen i_rstgen_main (
      .clk_i        ( clk                   ),
      .rst_ni       ( reset_n & (~ndmreset) ),
      .test_mode_i  ( '0                    ),
      .rst_no       ( ndmreset_n            ),
      .init_no      (                       ) // keep open
    );

    ri5cy_to_ahb # (
      .AHB_ADDR_WIDTH(`AHB_HADDR_SIZE),
      .AHB_DATA_WIDTH(`AHB_HDATA_SIZE)
    ) debug_unit_ahb_master (
      .clk(clk),
      .rstn(reset_n),
      // Custom RI5CY memory interface
      .req_i(sb_req),
      .we_i(sb_we),
      .be_i(sb_be),
      .addr_i(sb_addr),
      .wdata_i(sb_wdata),
      .gnt_o(sb_gnt),
      .rvalid_o(sb_rvalid),
      .rdata_o(sb_rdata),
      // AHB master signals
      .hsel_o(ahb_master[2].HSEL),
      .haddr_o(ahb_master[2].HADDR),
      .hwdata_o(ahb_master[2].HWDATA),
      .hwrite_o(ahb_master[2].HWRITE),
      .hsize_o(ahb_master[2].HSIZE),
      .hburst_o(ahb_master[2].HBURST),
      .hprot_o(ahb_master[2].HPROT),
      .htrans_o(ahb_master[2].HTRANS),
      .hmastlock_o(ahb_master[2].HMASTLOCK),
      .hready_o(ahb_master[2].HREADY),
      .hrdata_i(ahb_master[2].HRDATA),
      .hreadyout_i(ahb_master[2].HREADYOUT),
      .hresp_i(ahb_master[2].HRESP)
    );

    ahb_to_ri5cy # (
      .AHB_ADDR_WIDTH(`AHB_HADDR_SIZE),
      .AHB_DATA_WIDTH(`AHB_HDATA_SIZE)
    ) ahb_slave_debug_unit (
      .clk(clk),
      .rstn(reset_n),
      // Custom RI5CY memory interface
      .req_o(dm_req),
      .we_o(dm_we),
      .be_o(dm_be),
      .addr_o(dm_addr),
      .wdata_o(dm_wdata),
      .rdata_i(dm_rdata),
      // AHB slave signals
      .hsel_i(ahb_slave[4].HSEL),
      .haddr_i(ahb_slave[4].HADDR),
      .hwdata_i(ahb_slave[4].HWDATA),
      .hwrite_i(ahb_slave[4].HWRITE),
      .hsize_i(ahb_slave[4].HSIZE),
      .hburst_i(ahb_slave[4].HBURST),
      .hprot_i(ahb_slave[4].HPROT),
      .htrans_i(ahb_slave[4].HTRANS),
      .hmastlock_i(ahb_slave[4].HMASTLOCK),
      .hready_i(ahb_slave[4].HREADY),
      .hrdata_o(ahb_slave[4].HRDATA),
      .hreadyout_o(ahb_slave[4].HREADYOUT),
      .hresp_o(ahb_slave[4].HRESP)
    );

    ahb_ri5cy_rom # (
      .AHB_ADDR_WIDTH(`AHB_HADDR_SIZE),
      .AHB_DATA_WIDTH(`AHB_HDATA_SIZE)
    ) ahb_riscv_rom (
      .clk(clk),
      .rstn(reset_n),
      // AHB slave signals
      .hsel_i(ahb_slave[5].HSEL),
      .haddr_i(ahb_slave[5].HADDR),
      .hwdata_i(ahb_slave[5].HWDATA),
      .hwrite_i(ahb_slave[5].HWRITE),
      .hsize_i(ahb_slave[5].HSIZE),
      .hburst_i(ahb_slave[5].HBURST),
      .hprot_i(ahb_slave[5].HPROT),
      .htrans_i(ahb_slave[5].HTRANS),
      .hmastlock_i(ahb_slave[5].HMASTLOCK),
      .hready_i(ahb_slave[5].HREADY),
      .hrdata_o(ahb_slave[5].HRDATA),
      .hreadyout_o(ahb_slave[5].HREADYOUT),
      .hresp_o(ahb_slave[5].HRESP)
    );
  `endif
`else
  // riscorvo_ahb_top # (
  //   .AHB_ADDR_WIDTH(`AHB_HADDR_SIZE),
  //   .AHB_DATA_WIDTH(`AHB_HDATA_SIZE),
  //   .FIFO_SLOTS(8),
  //   .TRAP_BASE_ADDR(`SYSTEM_TRAP_VECTOR),
  //   .ENABLE_COMPRESSED_ISA(1),
  //   .ENABLE_MULT_DIV_ISA(1),
  //   .ENABLE_MISALIGN_ADDR(1),
  //   .ENABLE_CUSTOM_ISA(1),
  //   .SW_NESTED_INT_EN(1)
  // ) riscv_cpu (
  //   .clk(clk),
  //   .reset_n(reset_n),
  //   .boot_addr_i(boot_addr_i),
  //   .sync_trap_o(),
  //   .irq_soft_i(1'b0),
  //   .irq_i(1'b0),
  //   .irq_id_i(5'd0),
  //   .irq_id_ack_o(),
  //   .irq_ack_o(),
  //   // Custom instruction interface
  //   .xs_valid_o(),
  //   .xs_custom_o(),
  //   .xs_funct7_o(),
  //   .xs_rs1_o(),
  //   .xs_rs2_o(),
  //   // AHB Master instruction interface
  //   .instr_hsel_o(ahb_master[0].HSEL),
  //   .instr_haddr_o(ahb_master[0].HADDR),
  //   .instr_hwdata_o(ahb_master[0].HWDATA),
  //   .instr_hwrite_o(ahb_master[0].HWRITE),
  //   .instr_hsize_o(ahb_master[0].HSIZE),
  //   .instr_hburst_o(ahb_master[0].HBURST),
  //   .instr_hprot_o(ahb_master[0].HPROT),
  //   .instr_htrans_o(ahb_master[0].HTRANS),
  //   .instr_hmastlock_o(ahb_master[0].HMASTLOCK),
  //   .instr_hready_o(ahb_master[0].HREADY),
  //   .instr_hrdata_i(ahb_master[0].HRDATA),
  //   .instr_hreadyout_i(ahb_master[0].HREADYOUT),
  //   .instr_hresp_i(ahb_master[0].HRESP),
  //   // AHB Master data interface
  //   .data_hsel_o(ahb_master[1].HSEL),
  //   .data_haddr_o(ahb_master[1].HADDR),
  //   .data_hwdata_o(ahb_master[1].HWDATA),
  //   .data_hwrite_o(ahb_master[1].HWRITE),
  //   .data_hsize_o(ahb_master[1].HSIZE),
  //   .data_hburst_o(ahb_master[1].HBURST),
  //   .data_hprot_o(ahb_master[1].HPROT),
  //   .data_htrans_o(ahb_master[1].HTRANS),
  //   .data_hmastlock_o(ahb_master[1].HMASTLOCK),
  //   .data_hready_o(ahb_master[1].HREADY),
  //   .data_hrdata_i(ahb_master[1].HRDATA),
  //   .data_hreadyout_i(ahb_master[1].HREADYOUT),
  //   .data_hresp_i(ahb_master[1].HRESP)
  // );
`endif

  ahb3lite_interconnect #(
    .HADDR_SIZE(`AHB_HADDR_SIZE),
    .HDATA_SIZE(`AHB_HDATA_SIZE),
    .MASTERS(`AHB_MASTERS_NUM),
    .SLAVES(`AHB_SLAVES_NUM)
  ) ahb_interconnect (
    .slv_addr_base(ahb_slv_addr_base),
    .slv_addr_mask(ahb_slv_addr_mask),
    .*
  );

  ahb3lite_sram1rw #(
    .MEM_SIZE(0),
    .MEM_DEPTH(`IRAM_SIZE),               // Need to receive number of words = (KB*1024)/4 bytes
    .HADDR_SIZE(`AHB_IRAM_ADDR_WIDTH),
    .HDATA_SIZE(32),
    .TECHNOLOGY("GENERIC"),
    .REGISTERED_OUTPUT("NO")
  ) instr_ram (
    .HRESETn(reset_n),
    .HCLK(clk),
    .HSEL(ahb_slave[0].HSEL),
    .HADDR(ahb_slave[0].HADDR),
    .HWDATA(ahb_slave[0].HWDATA),
    .HRDATA(ahb_slave[0].HRDATA),
    .HWRITE(ahb_slave[0].HWRITE),
    .HSIZE(ahb_slave[0].HSIZE),
    .HBURST(ahb_slave[0].HBURST),
    .HPROT(ahb_slave[0].HPROT),
    .HTRANS(ahb_slave[0].HTRANS),
    .HREADYOUT(ahb_slave[0].HREADYOUT),
    .HREADY(ahb_slave[0].HREADY),
    .HRESP(ahb_slave[0].HRESP)
  );

  ahb3lite_sram1rw #(
    .MEM_SIZE(0),
    .MEM_DEPTH(`DRAM_SIZE),
    .HADDR_SIZE(`AHB_DRAM_ADDR_WIDTH),
    .HDATA_SIZE(32),
    .TECHNOLOGY("GENERIC"),
    .REGISTERED_OUTPUT("NO")
  ) data_ram (
    .HRESETn(reset_n),
    .HCLK(clk),
    .HSEL(ahb_slave[1].HSEL),
    .HADDR(ahb_slave[1].HADDR),
    .HWDATA(ahb_slave[1].HWDATA),
    .HRDATA(ahb_slave[1].HRDATA),
    .HWRITE(ahb_slave[1].HWRITE),
    .HSIZE(ahb_slave[1].HSIZE),
    .HBURST(ahb_slave[1].HBURST),
    .HPROT(ahb_slave[1].HPROT),
    .HTRANS(ahb_slave[1].HTRANS),
    .HREADYOUT(ahb_slave[1].HREADYOUT),
    .HREADY(ahb_slave[1].HREADY),
    .HRESP(ahb_slave[1].HRESP)
  );

  ahb3lite_apb_bridge #(
    .HADDR_SIZE(`AHB_HADDR_SIZE),
    .HDATA_SIZE(`AHB_HDATA_SIZE),
    .PADDR_SIZE(`APB_PADDR_SIZE),
    .PDATA_SIZE(`APB_PDATA_SIZE),
    .SYNC_DEPTH(3)
  ) ahb_to_apb (
    //AHB Slave Interface
    .HRESETn(reset_n),
    .HCLK(clk),
    .HSEL(ahb_slave[2].HSEL),
    .HADDR(ahb_slave[2].HADDR),
    .HWDATA(ahb_slave[2].HWDATA),
    .HRDATA(ahb_slave[2].HRDATA),
    .HWRITE(ahb_slave[2].HWRITE),
    .HSIZE(ahb_slave[2].HSIZE),
    .HBURST(ahb_slave[2].HBURST),
    .HPROT(ahb_slave[2].HPROT),
    .HTRANS(ahb_slave[2].HTRANS),
    .HMASTLOCK(ahb_slave[2].HMASTLOCK),
    .HREADYOUT(ahb_slave[2].HREADYOUT),
    .HREADY(ahb_slave[2].HREADY),
    .HRESP(ahb_slave[2].HRESP),
    //APB Master Interface
    .PRESETn(reset_n),
    .PCLK(clk),
    .PSEL(apb_ahb_bridge.PSEL),
    .PENABLE(apb_ahb_bridge.PENABLE),
    .PPROT(apb_ahb_bridge.PPROT),
    .PWRITE(apb_ahb_bridge.PWRITE),
    .PSTRB(apb_ahb_bridge.PSTRB),
    .PADDR(apb_ahb_bridge.PADDR),
    .PWDATA(apb_ahb_bridge.PWDATA),
    .PRDATA(apb_ahb_bridge.PRDATA),
    .PREADY(apb_ahb_bridge.PREADY),
    .PSLVERR(apb_ahb_bridge.PSLVERR)
  );

  ahb_dummy#(
    .HADDR_SIZE(`AHB_HADDR_SIZE),
    .HDATA_SIZE(`AHB_HDATA_SIZE)
  ) printf_verilator (
    .HRESETn(reset_n),
    .HCLK(clk),
    .HSEL(ahb_slave[3].HSEL),
    .HADDR(ahb_slave[3].HADDR),
    .HWDATA(ahb_slave[3].HWDATA),
    .HRDATA(ahb_slave[3].HRDATA),
    .HWRITE(ahb_slave[3].HWRITE),
    .HSIZE(ahb_slave[3].HSIZE),
    .HBURST(ahb_slave[3].HBURST),
    .HPROT(ahb_slave[3].HPROT),
    .HTRANS(ahb_slave[3].HTRANS),
    .HREADYOUT(ahb_slave[3].HREADYOUT),
    .HREADY(ahb_slave[3].HREADY),
    .HRESP(ahb_slave[3].HRESP)
  );

  apb_mux #(
    .PADDR_SIZE(`APB_PADDR_SIZE),
    .PDATA_SIZE(`APB_PDATA_SIZE),
    .SLAVES(`APB_SLAVES_NUM)
  ) apb_bus (
    .PRESETn(reset_n),
    .PCLK(clk),
    .MST_PSEL(apb_ahb_bridge.PSEL),
    .MST_PADDR(apb_ahb_bridge.PADDR),
    .MST_PRDATA(apb_ahb_bridge.PRDATA),
    .MST_PREADY(apb_ahb_bridge.PREADY),
    .MST_PSLVERR(apb_ahb_bridge.PSLVERR),
    .slv_addr(apb_slv_addr_base),
    .slv_mask(apb_slv_addr_mask),
    .SLV_PSEL(slv_apb_PSEL),
    .SLV_PRDATA(slv_apb_PRDATA),
    .SLV_PREADY(slv_apb_PREADY),
    .SLV_PSLVERR(slv_apb_PSLVERR)
  );

  genvar l;
  generate
    for (l=0;l<`APB_SLAVES_NUM;l++)
      begin
        assign apb_slaves[l].PSEL = slv_apb_PSEL[l];
        assign slv_apb_PRDATA[l]  = apb_slaves[l].PRDATA;
        assign slv_apb_PREADY[l]  = apb_slaves[l].PREADY;
        assign slv_apb_PSLVERR[l] = apb_slaves[l].PSLVERR;
      end
  endgenerate

  apb_gpio #(
    .APB_ADDR_WIDTH(12)
  ) gpio_0 (
    .HCLK(clk),
    .HRESETn(reset_n),
    .dft_cg_enable_i(1'b0),
    .PADDR(apb_ahb_bridge.PADDR[11:0]),
    .PWDATA(apb_ahb_bridge.PWDATA),
    .PWRITE(apb_ahb_bridge.PWRITE),
    .PSEL(apb_slaves[0].PSEL),
    .PENABLE(apb_ahb_bridge.PENABLE),
    .PRDATA(apb_slaves[0].PRDATA),
    .PREADY(apb_slaves[0].PREADY),
    .PSLVERR(apb_slaves[0].PSLVERR),
    .gpio_in('0),
    .gpio_in_sync(),
    .gpio_out(),
    .gpio_dir(),
    .gpio_padcfg(),
    .interrupt()
  );

  apb_gpio #(
    .APB_ADDR_WIDTH(12)
  ) gpio_1 (
    .HCLK(clk),
    .HRESETn(reset_n),
    .dft_cg_enable_i(1'b0),
    .PADDR(apb_ahb_bridge.PADDR[11:0]),
    .PWDATA(apb_ahb_bridge.PWDATA),
    .PWRITE(apb_ahb_bridge.PWRITE),
    .PSEL(apb_slaves[1].PSEL),
    .PENABLE(apb_ahb_bridge.PENABLE),
    .PRDATA(apb_slaves[1].PRDATA),
    .PREADY(apb_slaves[1].PREADY),
    .PSLVERR(apb_slaves[1].PSLVERR),
    .gpio_in('0),
    .gpio_in_sync(),
    .gpio_out(),
    .gpio_dir(),
    .gpio_padcfg(),
    .interrupt()
  );

`ifdef VERILATOR
  function [7:0] getbufferReq;
    /* verilator public */
    begin
      getbufferReq = (ahb_master[1].HWDATA);
    end
  endfunction

  function printfbufferReq;
    /* verilator public */
    begin
      printfbufferReq = ((ahb_master[1].HADDR == 32'h2000_0000) && ahb_master[1].HWRITE);
    end
  endfunction

  function writeWordIRAM;
    /* verilator public */
    input [31:0] addr_val;
    input [31:0] word_val;
    begin
      instr_ram.ram_inst.genblk2.genblk2.ram_inst.mem_array[addr_val] = word_val;
    end
  endfunction

  function writeWordDRAM;
    /* verilator public */
    input [31:0] addr_val;
    input [31:0] word_val;
    begin
      data_ram.ram_inst.genblk2.genblk2.ram_inst.mem_array[addr_val] = word_val;
    end
  endfunction
`endif

endmodule
