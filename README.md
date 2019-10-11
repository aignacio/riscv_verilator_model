|   Description   | Start Address |  End Adress | Size | Slave ID |
|:---------------:|:-------------:|:-----------:|:----:|:--------:|
|       ROM       |  0x1A00_0000  | 0x1A00_FFFF | 64KB |  0 (AHB) |
|   Debug Module  |  0x1B00_0000  | 0x1B00_FFFF | 64KB |  1 (AHB) |
|  Verilator Dump |  0x1C00_0000  | 0x1C00_FFFF | 64KB |  2 (AHB) |
|       IRAM      |  0x2000_0000  | 0x200F_FFFF |  1MB |  3 (AHB) |
|       DRAM      |  0x3000_0000  | 0x300F_FFFF |  1MB |  4 (AHB) |
|  AHB_APB Bridge |  0x4000_0000  | 0x400F_FFFF |  1MB |  5 (AHB) |
|       GPIO      |  0x4000_0000  | 0x4000_FFFF | 64KB |  0 (APB) |
|       UART      |  0x4001_0000  | 0x4001_FFFF | 64KB |  1 (APB) |
|       SPI       |  0x4002_0000  | 0x4002_FFFF | 64KB |  2 (APB) |
|       I2C       |  0x4003_0000  | 0x4003_FFFF | 64KB |  3 (APB) |
| Int. Controller |  0x4004_0000  | 0x4004_FFFF | 64KB |  4 (APB) |
