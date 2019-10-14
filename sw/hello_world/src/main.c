#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include "riscv_soc_utils.h"
#include "gpio.h"
#include "event.h"
#include "uart.h"
#include "encoding.h"
#include "timer.h"

extern uint32_t  _start_vector;
volatile uint32_t* const printf_buffer = (uint32_t*) PRINTF_VERILATOR;

size_t _write(int fildes, const void *buf, size_t nbyte) {
    const uint8_t* cbuf = (const uint8_t*) buf;
    for (size_t i = 0; i < nbyte; ++i) {
    #if VERILATOR == 1
        #warning "[PLEASE READ] PRINTF output will be redirected to verilator dump peripheral"
        *printf_buffer = cbuf[i];
    #else
        #warning "[PLEASE READ] PRINTF output will be redirected to UART peripheral"
        uart_send((const char *)&cbuf[i],1);
    #endif
    }
    return nbyte;
}

void loop_leds(){
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

void isr_m_external(void) {
    // write_csr(mip, (0 << IRQ_M_EXT));
    printf("\nTrap Timer!\n");
    int_periph_clear(1 << TIMER_A_OUTPUT_CMP);
    return;
    while(1);
}

int main(void) {
    int test = 0;

    for (int i = 0;i<11;i++)
        set_gpio_pin_direction(i,DIR_OUT);
    for (int i = 12;i<16;i++)
        set_gpio_pin_direction(i,DIR_IN);
    for (int i = 0;i<12;i+=1)
        set_gpio_pin_value(i,false);

    // To calculate uart speed clk_clounter,
    // consider the following:
    // clk_counter = periph_clk / baud_rate
    // clk_counter = 80 = 250k
    // clk_counter = 174 ~115200
    uart_set_cfg(0, 174);

    cfg_int(true);

    int_periph_clear(1 << TIMER_A_OUTPUT_CMP);

    int_periph_enable(1 << TIMER_A_OUTPUT_CMP);

    set_cmp(30000);

    start_timer();

    while(1){
        #if VERILATOR == 1
            printf("\nHello World = %d", get_time());
        #else
            loop_leds();
            int mtvec = read_csr(mtvec);
            int mtimer = get_time();
            printf("\nMTVEC %x", mtvec);
            printf("\nHello World %d %p %x", test, &test, test);
        #endif
    };
}
