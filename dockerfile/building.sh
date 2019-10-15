#!/bin/bash

cd /root
RUN git clone --recursive https://github.com/aignacio/riscv_verilator_model rv
cd rv
make verilator JTAG_BOOT=1 JTAG_PORT=8080
