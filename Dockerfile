FROM debian:bullseye

LABEL maintainer="Anderson Ignacio da Silva <anderson@aignacio.com>"
RUN apt-get update && \
    apt-get install -y verilator git gtkwave make build-essential

COPY . /rv
RUN cd /rv && \
    make JTAG_BOOT=1 JTAG_PORT=8080 MAX_THREAD=12 verilator
EXPOSE 8080/tcp
WORKDIR /rv/output_verilator
CMD ./riscv_soc

