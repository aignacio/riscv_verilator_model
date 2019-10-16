`ifndef CONFIG_SOC_V
`define CONFIG_SOC_V
  `define AHB_MASTERS_NUM     3  // Number of masters AHB
  `define AHB_SLAVES_NUM      6  // Number of slaves AHB
  `define AHB_HADDR_SIZE      32 // bit-width AHB address haddr
  `define AHB_HDATA_SIZE      32 // bit-width AHB data

  `define APB_SLAVES_NUM      5  // Number of slaves APB
  `define APB_PADDR_SIZE      32 // bit-width APB address
  `define APB_ADDR_WIDTH      16 // Effective address
  `define APB_PDATA_SIZE      32 // bit-width APB data
  `define APB_BASE_ADDR_ALL   32'h4000_0000

  `define DRAM_SIZE           `DRAM_KB_SIZE*1024/4
  `define AHB_DRAM_ADDR_WIDTH $clog2((`DRAM_KB_SIZE*1024/4)*4)

  `define IRAM_SIZE           `IRAM_KB_SIZE*1024/4
  `define AHB_IRAM_ADDR_WIDTH $clog2((`IRAM_KB_SIZE*1024/4)*4)

  `define USE_RI5CY
  `define USE_RI5CY_JTAG

  localparam [31:0] ahb_addr [2][`AHB_SLAVES_NUM] = '{
    '{32'h1A00_0000,
      32'h1B00_0000,
      32'h1C00_0000,
      32'h2000_0000,
      32'h3000_0000,
      32'h4000_0000},
    '{32'h1A00_FFFF,
      32'h1B00_FFFF,
      32'h1C00_FFFF,
      32'h200F_FFFF,
      32'h300F_FFFF,
      32'h400F_FFFF}
  };

  localparam [31:0] apb_addr [2][`APB_SLAVES_NUM] = '{
    '{`APB_BASE_ADDR_ALL+32'h0000_0000,
      `APB_BASE_ADDR_ALL+32'h0001_0000,
      `APB_BASE_ADDR_ALL+32'h0002_0000,
      `APB_BASE_ADDR_ALL+32'h0003_0000,
      `APB_BASE_ADDR_ALL+32'h0004_0000},
    '{`APB_BASE_ADDR_ALL+32'h0000_FFFF,
      `APB_BASE_ADDR_ALL+32'h0001_FFFF,
      `APB_BASE_ADDR_ALL+32'h0002_FFFF,
      `APB_BASE_ADDR_ALL+32'h0003_FFFF,
      `APB_BASE_ADDR_ALL+32'h0004_FFFF}
  };
`endif
