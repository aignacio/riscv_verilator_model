FROM debian:bullseye
MAINTAINER Anderson Ignacio da Silva <anderson@aignacio.com>

EXPOSE 8080/tcp

ARG ssh_prv_key
ARG ssh_pub_key

RUN apt-get update && \
    apt-get install -y verilator git gtkwave make build-essential

# Authorize SSH Host
RUN mkdir -p /root/.ssh && \
    chmod 0700 /root/.ssh && \
    ssh-keyscan github.com > /root/.ssh/known_hosts

# Add the keys and set permissions
RUN echo "$ssh_prv_key" > /root/.ssh/id_rsa && \
    echo "$ssh_pub_key" > /root/.ssh/id_rsa.pub && \
    chmod 600 /root/.ssh/id_rsa && \
    chmod 600 /root/.ssh/id_rsa.pub

WORKDIR /rv_model/

RUN git clone --recursive https://github.com/aignacio/riscv_verilator_model rv && \
    cd rv && \
    make verilator JTAG_BOOT=1 JTAG_PORT=8080

CMD "./rv/output_verilator/riscv_soc"
