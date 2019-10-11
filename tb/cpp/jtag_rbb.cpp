#include <iostream>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <fcntl.h>
#include <string.h>
#include "jtag_rbb.hpp"

using namespace std;

jtag_rbb::jtag_rbb (int portnum){
    int opt = 1;
    port_value = portnum;

    // Creating socket file descriptor
    if ((server_fd = socket(AF_INET, SOCK_STREAM, 0)) == 0) {
        perror("Error on socket creation for JTAG adapter");
        exit(EXIT_FAILURE);
    }

    fcntl(server_fd, F_SETFL, O_NONBLOCK);

    if (setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(int)) == -1) {
        fprintf(stderr, "remote_bitbang failed setsockopt: %s (%d)\n",
            strerror(errno), errno);
        abort();
    }

    memset(&address, 0, sizeof(address));
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons( portnum );

    if (bind(server_fd, (struct sockaddr *)&address, sizeof(address))<0) {
        fprintf(stderr, "remote_bitbang failed to bind socket: %s (%d)\n",
            strerror(errno), errno);
        abort();
    }

    if (listen(server_fd, 1) == -1) {
        fprintf(stderr, "remote_bitbang failed to listen on socket: %s (%d)\n",
            strerror(errno), errno);
        abort();
    }

    if (getsockname(server_fd, (struct sockaddr *) &address, &addrlen) == -1) {
        fprintf(stderr, "remote_bitbang getsockname failed: %s (%d)\n",
            strerror(errno), errno);
        abort();
    }

    // // Blocking method to wait for client connection
    // this->accept_client();
}

void jtag_rbb::reset(char trst, char srst){
    *trst_pin = trst;
    *srst_pin = srst;

    if (trst == 1)
        *trstn_pin = 0;
    else
        *trstn_pin = 1;
}

void jtag_rbb::set_pins(char tck, char tms, char tdi){
    // printf("\n\tTCK=%d \tTMS=%d \tTDI=%d", tck, tms, tdi);
    *tck_pin = tck;
    *tms_pin = tms;
    *tdi_pin = tdi;
}

void jtag_rbb::read_cmd(bool block_or_nonblocking){
    char tosend = '?';
    int dosend = 0;
    int again = 1;

    // Non-blocking read
    if (block_or_nonblocking == true) {
    // Blocking wait for command
        while (again) {
            auto num_read = read(client_sck, &cmd_bb, sizeof(cmd_bb));
            if (num_read == -1) {
                if (errno == EAGAIN) {
                // We'll try again the next call.
                //fprintf(stderr, "Received no command. Will try again on the next call\n");
                } else {
                fprintf(stderr, "remote_bitbang failed to read on socket: %s (%d)\n",
                        strerror(errno), errno);
                again = 0;
                abort();
                }
            } else if (num_read == 0) {
                fprintf(stderr, "No Command Received.\n");
                again = 1;
            } else {
                again = 0;
            }
        }
    }
    else {
        auto num_read = read(client_sck, &cmd_bb, sizeof(cmd_bb));
        if (num_read <= 0) return;
    }

    dosend = 0;

    // Implemented protocol following this file:
    // >>>> https://github.com/ntfreak/openocd/blob/8b8b66559d5fbfeb1dd408a1af17dc0be52b5a9f/doc/manual/jtag/drivers/remote_bitbang.txt
    switch (cmd_bb) {
        case 'B': break; //printf("\nRBB: B = No LEDs available to blink..."); break;
        case 'b': break; //printf("\nRBB: b = No LEDs available to blink..."); break;
        case 'r': this->reset(0, 0); break;
        case 's': this->reset(0, 1); break;
        case 't': this->reset(1, 0); break;
        case 'u': this->reset(1, 1); break;
        case '0': this->set_pins(0, 0, 0); break;
        case '1': this->set_pins(0, 0, 1); break;
        case '2': this->set_pins(0, 1, 0); break;
        case '3': this->set_pins(0, 1, 1); break;
        case '4': this->set_pins(1, 0, 0); break;
        case '5': this->set_pins(1, 0, 1); break;
        case '6': this->set_pins(1, 1, 0); break;
        case '7': this->set_pins(1, 1, 1); break;
        case 'R': dosend = 1; tosend = *tdo_pin ? '1' : '0'; break;
        case 'Q': quit = 1; break;
        default:
            fprintf(stderr, "Remote_bitbang got unsupported command '%c'\n", cmd_bb);
    }

    if (dosend){
        while (1) {
            // printf("\nWaiting TDO...");
            ssize_t bytes = write(client_sck, &tosend, sizeof(tosend));
            if (bytes == -1) {
                fprintf(stderr, "failed to write to socket: %s (%d)\n", strerror(errno), errno);
                abort();
            }
            if (bytes > 0) {
                break;
            }
        }
    }

    if (quit) {
        // The remote disconnected.
        fprintf(stderr, "\nRemote end disconnected\n");
        close(client_sck);
        client_sck = 0;
    }
}

void jtag_rbb::accept_client(){
    int again = 1;

    printf("\nWaiting for connection from OpenOCD RBB tcp:%d\n",port_value);

    while (again != 0) {
        client_sck = accept(server_fd, NULL, NULL);
        if (client_sck == -1) {
            if (errno == EAGAIN) {
            // No client waiting to connect right now.
            } else {
                fprintf(stderr, "failed to accept on socket: %s (%d)\n", strerror(errno),errno);
                again = 0;
                abort();
            }
        } else {
            fcntl(client_sck, F_SETFL, O_NONBLOCK);
            fprintf(stderr, "Accepted successfully.");
            again = 0;
        }
    }
}
