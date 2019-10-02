`ifndef CONFIG_SOC_V
`define CONFIG_SOC_V
  `define SYSTEM_RESET_VECTOR 32'h00AA_0000
  `define SYSTEM_TRAP_VECTOR  32'h00AA_0000

  `define AHB_MASTERS_NUM     2  // Number of masters AHB
  `define AHB_SLAVES_NUM      4  // Number of slaves AHB
  `define AHB_HADDR_SIZE      32 // bit-width AHB address haddr
  `define AHB_HDATA_SIZE      32 // bit-width AHB data
  `define AHB_SL_BASE_ADDR_0  32'hA000_0000
  `define AHB_SL_MASK_ADDR_0  32'hF000_0000 // To define the mask  -->  mask = ~(FINAL ADDRESS - BASE ADDRESS)
  `define AHB_SL_BASE_ADDR_1  32'hB000_0000
  `define AHB_SL_MASK_ADDR_1  32'hF000_0000 // To define the mask  -->  mask = ~(FINAL ADDRESS - BASE ADDRESS)
  `define AHB_SL_BASE_ADDR_2  32'h1000_0000
  `define AHB_SL_MASK_ADDR_2  32'hF000_0000 // To define the mask  -->  mask = ~(FINAL ADDRESS - BASE ADDRESS)
  `define AHB_SL_BASE_ADDR_3  32'h2000_0000
  `define AHB_SL_MASK_ADDR_3  32'hFFFF_0000 // To define the mask  -->  mask = ~(FINAL ADDRESS - BASE ADDRESS)

  `define APB_SLAVES_NUM      2  // Number of slaves APB
  `define APB_PADDR_SIZE      32 // bit-width APB address
  `define APB_PDATA_SIZE      32 // bit-width APB data
  `define APB_SL_BASE_ADDR_0  32'h100A_0000
  `define APB_SL_MASK_ADDR_0  32'hFFFF_0000 // To define the mask  -->  mask = ~(FINAL ADDRESS - BASE ADDRESS)
  `define APB_SL_BASE_ADDR_1  32'h100B_0000
  `define APB_SL_MASK_ADDR_1  32'hFFFF_0000 // To define the mask  -->  mask = ~(FINAL ADDRESS - BASE ADDRESS)
  `define APB_SL_BASE_ADDR_2  32'h100C_0000
  `define APB_SL_MASK_ADDR_2  32'hFFFF_0000 // To define the mask  -->  mask = ~(FINAL ADDRESS - BASE ADDRESS)
  `define APB_SL_BASE_ADDR_3  32'h100D_0000
  `define APB_SL_MASK_ADDR_3  32'hFFFF_0000 // To define the mask  -->  mask = ~(FINAL ADDRESS - BASE ADDRESS)

  `define DRAM_SIZE           `DRAM_KB_SIZE*1024/4
  `define AHB_DRAM_ADDR_WIDTH $clog2((`DRAM_KB_SIZE*1024/4)*4)

  `define IRAM_SIZE           `IRAM_KB_SIZE*1024/4
  `define AHB_IRAM_ADDR_WIDTH $clog2((`IRAM_KB_SIZE*1024/4)*4)

  `define GPIO_NUM_EACH_SLV   8
  `define USE_RI5CY
  `define USE_RI5CY_JTAG
`endif
