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

size_t _write(int fildes, const void *buf, size_t nbyte) {
    const uint8_t* cbuf = (const uint8_t*) buf;
    for (size_t i = 0; i < nbyte; ++i) {
        #warning "[PLEASE READ] PRINTF output will be redirected to UART peripheral"
        uart_send((const char *)&cbuf[i],1);
    }
    return nbyte;
}

int main(void) {
    int test = 0;
    bool toggle = false;

    for (int i = 0;i<11;i++)
        set_gpio_pin_direction(i,DIR_OUT);
    for (int i = 12;i<16;i++)
        set_gpio_pin_direction(i,DIR_IN);

    uart_set_cfg(0, 49);

    while(1){
        toggle = !toggle;
        for (int i = 0;i<12;i++)
            set_gpio_pin_value(i,toggle);

        for (int i=0;i<1000000;i++);
        printf("\n[BOOT ROM]");
    };
}
