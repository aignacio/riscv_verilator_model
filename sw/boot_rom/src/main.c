#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include "riscv_soc_utils.h"
#include "gpio.h"
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
     for (int i = 0;i<12;i++)
            set_gpio_pin_value(i,false);

    while(1){
        // greens = 1,4,7,10
        // blues = 2,5,8,11
        // red = 0,3,6,9
        for (int j = 0; j<3;j++){
            for (int i = j;i<12;i+=3){
                set_gpio_pin_value(i,true);
                for (int i=0;i<100000;i++);
            }
            for (int i = j;i<12;i+=3){
                set_gpio_pin_value(i,false);
                for (int i=0;i<100000;i++);
            }
        }
    }
}
