#ifndef RISCV_SOC_UTILS_H
#define RISCV_SOC_UTILS_H

#define BOOT_ROM                0X1A000000
#define DEBUG_MODULE            0x1B000000
#define PRINTF_VERILATOR        0x1C000000
#define IRAM_ADDR               0x20000000
#define DRAM_ADDR               0x30000000
#define APB_BUS_ADDR            0x40000000

#define GPIO_BASE_ADDR          (APB_BUS_ADDR+0x00000)
#define UART_BASE_ADDR          (APB_BUS_ADDR+0x10000)
#define TIMER_BASE_ADDR         (APB_BUS_ADDR+0x20000)
#define EVENT_UNIT_BASE_ADDR    (APB_BUS_ADDR+0x30000)
#define SOC_CTRL_BASE_ADDR      (APB_BUS_ADDR+0x40000)

#endif
