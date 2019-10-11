FROM debian:bullseye
MAINTAINER Anderson Ignacio da Silva <anderson@aignacio.com>
RUN apt-get update && apt-get install -y verilator git gtkwave make build-essential
ENTRYPOINT ["/bin/bash", "/run_rbb.sh"]
CMD ["cd riscv_verilator_model/ && ./output_verilator/riscv_soc"]
EXPOSE 8080/tcp
