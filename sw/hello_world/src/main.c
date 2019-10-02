#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include "riscv_soc_utils.h"
#include "gpio.h"
#include "spi.h"
#include "i2c.h"
#include "uart.h"
#include "encoding.h"

extern uint32_t  _start_vector;
volatile uint32_t* const printf_buffer = (uint32_t*) PRINTF_VERILATOR;

ssize_t _write(int fildes, const void *buf, size_t nbyte) {
    const uint8_t* cbuf = (const uint8_t*) buf;
    for (size_t i = 0; i < nbyte; ++i) {
        *printf_buffer = cbuf[i];
    }
    return nbyte;
}

int main(void) {
    int test = 0;

    while(1){
        printf("\nHello World...%d", test++);
        // printf("\nHello World... %d %p %x", test++, &test, test);
    };
}
