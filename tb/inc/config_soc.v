`ifndef CONFIG_SOC_V
`define CONFIG_SOC_V
  `define SYSTEM_RESET_VECTOR 32'h00AA_0000
  `define SYSTEM_TRAP_VECTOR  32'h00AA_0000

  // To define the AHB mask  -->  mask = ~(FINAL ADDRESS - BASE ADDRESS)

  `define AHB_MASTERS_NUM     3  // Number of masters AHB
  `define AHB_SLAVES_NUM      6  // Number of slaves AHB
  `define AHB_HADDR_SIZE      32 // bit-width AHB address haddr
  `define AHB_HDATA_SIZE      32 // bit-width AHB data
  `define AHB_SL_BASE_ADDR_0  32'hA000_0000 // IRAM Base address 1C00_0000
  `define AHB_SL_MASK_ADDR_0  32'hFF00_0000 // Final address 1CFF_FFFF
  `define AHB_SL_BASE_ADDR_1  32'hB000_0000
  `define AHB_SL_MASK_ADDR_1  32'hF000_0000 // To define the mask  -->  mask = ~(FINAL ADDRESS - BASE ADDRESS)
  `define AHB_SL_BASE_ADDR_2  32'h5000_0000
  `define AHB_SL_MASK_ADDR_2  32'hF000_0000 // To define the mask  -->  mask = ~(FINAL ADDRESS - BASE ADDRESS)
  `define AHB_SL_BASE_ADDR_3  32'h2000_0000
  `define AHB_SL_MASK_ADDR_3  32'hFFFF_0000 // To define the mask  -->  mask = ~(FINAL ADDRESS - BASE ADDRESS)
  `define AHB_SL_BASE_ADDR_4  32'h1A11_0000 // Debug address space:
  `define AHB_SL_MASK_ADDR_4  32'hFFFF_0000 // -> 1A11_0000 to 1A11_FFFF
  `define AHB_SL_BASE_ADDR_5  32'h1A00_0080 // ROM address space:
  `define AHB_SL_MASK_ADDR_5  32'hFFFF_0000 // -> 1A00_0000 to 1A00_FFFF

  `define APB_SLAVES_NUM      2  // Number of slaves APB
  `define APB_PADDR_SIZE      32 // bit-width APB address
  `define APB_PDATA_SIZE      32 // bit-width APB data
  `define APB_SL_BASE_ADDR_0  32'h500A_0000
  `define APB_SL_MASK_ADDR_0  32'hFFFF_0000 // To define the mask  -->  mask = ~(FINAL ADDRESS - BASE ADDRESS)
  `define APB_SL_BASE_ADDR_1  32'h500B_0000
  `define APB_SL_MASK_ADDR_1  32'hFFFF_0000 // To define the mask  -->  mask = ~(FINAL ADDRESS - BASE ADDRESS)
  `define APB_SL_BASE_ADDR_2  32'h500C_0000
  `define APB_SL_MASK_ADDR_2  32'hFFFF_0000 // To define the mask  -->  mask = ~(FINAL ADDRESS - BASE ADDRESS)
  `define APB_SL_BASE_ADDR_3  32'h500D_0000
  `define APB_SL_MASK_ADDR_3  32'hFFFF_0000 // To define the mask  -->  mask = ~(FINAL ADDRESS - BASE ADDRESS)

  `define DRAM_SIZE           `DRAM_KB_SIZE*1024/4
  `define AHB_DRAM_ADDR_WIDTH $clog2((`DRAM_KB_SIZE*1024/4)*4)

  `define IRAM_SIZE           `IRAM_KB_SIZE*1024/4
  `define AHB_IRAM_ADDR_WIDTH $clog2((`IRAM_KB_SIZE*1024/4)*4)

  `define GPIO_NUM_EACH_SLV   8
  `define USE_RI5CY
  `define USE_RI5CY_JTAG
`endif
