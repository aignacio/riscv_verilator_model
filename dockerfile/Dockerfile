FROM debian:bullseye

LABEL maintainer="Anderson Ignacio da Silva <anderson@aignacio.com>"
RUN apt-get update && \
    apt-get install -y verilator git gtkwave make build-essential
COPY building.sh /root
RUN "chmod +x building.sh"
EXPOSE 8080/tcp

CMD "./root/rv/output_verilator/riscv_soc"

