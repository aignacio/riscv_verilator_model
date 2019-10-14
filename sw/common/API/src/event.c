#include <event.h>
#include <stdbool.h>
#include "encoding.h"

void cfg_int(bool int_en){
    int mstatus_csr = read_csr(mstatus);

    if (int_en)
        write_csr(mstatus, mstatus_csr|0x8);
    else
        write_csr(mstatus, mstatus_csr&0xFFFFFFF7);
}

void int_periph_enable(unsigned int periph_mask) {
    IER |= (periph_mask);
}

void int_periph_disable(unsigned int periph_mask) {
    IER &= ~(periph_mask);
}

void int_periph_clear(unsigned int periph_mask) {
    ICP |= (periph_mask);
}
