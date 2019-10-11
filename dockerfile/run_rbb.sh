#!/bin/bash
git clone --recursive https://github.com/aignacio/riscv_verilator_model rv_model
cd rv_model
make verilator JTAG_BOOT=1 JTAG_PORT=8080
