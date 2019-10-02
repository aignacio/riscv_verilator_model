#ifndef JTAG_RBB_HPP
#define JTAG_RBB_HPP

#include <sys/socket.h>
#include <netinet/in.h>

class jtag_rbb{
    int server_fd, client_sck;
    struct sockaddr_in address;
    char cmd_bb;
    int port_value;
    socklen_t addrlen = sizeof(address);
    char buffer[1024] = {0};

public:
    unsigned char   *tck_pin,
                    *tms_pin,
                    *tdi_pin,
                    *tdo_pin,
                    *trst_pin,
                    *trstn_pin,
                    *srst_pin;

    jtag_rbb(int portnum);
    void accept_client();
    void read_cmd(bool block_or_nonblocking);
    void reset(char trst, char srst);
    void set_pins(char tck, char tms, char tdi);
};

#endif
