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

#define SW_0    1 << 28
#define SW_1    1 << 29
#define SW_2    1 << 30
#define SW_3    1 << 31

bool run_leds = false;

extern uint32_t  _start;
volatile uint32_t* const printf_buffer = (uint32_t*) PRINTF_VERILATOR;

size_t _write(int fildes, const void *buf, size_t nbyte) {
    const uint8_t* cbuf = (const uint8_t*) buf;
    for (size_t i = 0; i < nbyte; ++i) {
    #if VERILATOR == 1
        #warning "[PLEASE READ] PRINTF output will be redirected to verilator dump peripheral"
        *printf_buffer = cbuf[i];
    #else
        #warning "[PLEASE READ] PRINTF output will be redirected to UART peripheral"
        uart_sendchar((char)cbuf[i]);
    #endif
    }
    return nbyte;
}

void loop_leds(){
    run_leds = false;
    // greens = 1,4,7,10
    // blues = 2,5,8,11
    // red = 0,3,6,9
    for (int j = 0; j<3;j++){
        for (int i = j;i<12;i+=3){
            set_gpio_pin_value(i,true);
            for (int t=0;t<100000;t++);
        }
        for (int i = j;i<12;i+=3){
            set_gpio_pin_value(i,false);
            for (int t=0;t<100000;t++);
        }
    }
}

void isr_gpio(void) {
    int_periph_clear(GPIO_EVENT);
    printf("\n\rGPIO ISR!");
    run_leds = true;
}

void isr_uart(void) {
    uint8_t uart_rx = *(volatile int*) UART_REG_RBR;

    int_periph_clear(UART_EVENT);
    printf("\n\rUART ISR received = %c",uart_rx);
    if (uart_rx == 'a')
        run_leds = true;
}

void isr_m_timer(void) {
    int_periph_clear(TIMER_A_OUTPUT_CMP);
    printf("\n\rTimer ISR!");
}

void setup_irqs(){
    int_periph_clear(UART_EVENT);
    int_periph_clear(TIMER_A_OUTPUT_CMP);
    int_periph_clear(GPIO_EVENT);

    for (int i = 28;i<32;i++)
        set_gpio_pin_irq_en(i, 1);

    for (int i = 28;i<32;i++)
        set_gpio_pin_irq_type(i, GPIO_IRQ_LEV1);

    #if VERILATOR == 0
    set_cmp(20000000);
    #else
    set_cmp(10000);
    #endif

    int_periph_enable(GPIO_EVENT);
    int_periph_enable(TIMER_A_OUTPUT_CMP);
    int_periph_enable(UART_EVENT);
    #if VERILATOR == 0
        int_periph_enable(UART_EVENT);
    #endif
    cfg_int(true);
}

void setup_gpios(){
    for (int i = 0;i<12;i++)
        set_gpio_pin_direction(i,DIR_OUT);
    for (int i = 28;i<32;i++)
        set_gpio_pin_direction(i,DIR_IN);
    for (int i = 0;i<12;i+=1)
        set_gpio_pin_value(i,false);

    enable_gpio_pins_read(SW_0|SW_1|SW_2|SW_3);
}

int main(void) {
    // Set the reset address to the entry point
    volatile uint32_t *address_rst = (uint32_t *)RST_CTRL_BASE_ADDR;
    int test = 0;

    *(address_rst) = (uint32_t )&_start;

    // To calculate uart speed,
    // consider the following:
    // baud_rate = periph_clk / 2^(parameter)
    // uart_set_cfg(0, 7);
    // 7 => 117187 ~> 115200
    uart_set_cfg(0, 7);

    setup_gpios();
    setup_irqs();
    start_timer();

    while(1){
        if (run_leds)
            loop_leds();
    }
}
