# !/usr/bin/env nix-shell
# !nix-shell -i python3 -p python3Packages.pyserial

# adapted from https://github.com/marcelomd/mux_serial/blob/master/mux_server.py

import argparse
import logging
import select
import serial
import socket

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("serialmux")

_READ_ONLY = select.POLLIN | select.POLLPRI


class Mux:
    def __init__(self):
        self.clients = []
        self.poller = select.poll()
        self.fd_to_socket = {}

    def add_client(self, client):
        logger.info("New connection from %s", client.getpeername())
        client.setblocking(0)
        self.fd_to_socket[client.fileno()] = client
        self.clients.append(client)
        self.poller.register(client, _READ_ONLY)

    def remove_client(self, client, reason="?"):
        try:
            name = client.getpeername()
        except Exception:
            name = "client %d" % client.fileno()
        logger.info("Closing %s: %s", name, reason)
        self.poller.unregister(client)
        self.clients.remove(client)
        client.close()

    def run(self, serial_device, listen_host, listen_port):
        srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

        try:
            tty = serial.Serial(serial_device, 115200, timeout=0)
            tty.flushInput()
            tty.flushOutput()
            self.poller.register(tty, _READ_ONLY)
            self.fd_to_socket[tty.fileno()] = tty
            logger.info("Serial: %s", serial_device)

            srv.setblocking(0)
            srv.bind((listen_host, listen_port))
            srv.listen(5)
            self.poller.register(srv, _READ_ONLY)
            self.fd_to_socket[srv.fileno()] = srv
            logger.info("Server: %s:%d", *srv.getsockname())
            logger.info("Use CTRL+C to stop")

            while True:
                events = self.poller.poll(500)
                for fd, flag in events:
                    s = self.fd_to_socket[fd]

                    if flag & select.POLLHUP:
                        self.remove_client(s, "HUP")

                    elif flag & select.POLLERR:
                        self.remove_client(s, "Received error")

                    elif flag & _READ_ONLY:
                        # A readable server socket is ready to accept a connection
                        if s is srv:
                            conn, addr = s.accept()
                            self.add_client(conn)

                        # Data from serial port
                        elif s is tty:
                            data = s.read(80)  # TODO: check max message size
                            logger.debug("serial: %s", data)
                            for client in self.clients:
                                client.send(data)

                        # Data from client
                        else:
                            data = s.recv(80)  # TODO: check max message size
                            logger.debug("client: %s", data)
                            # Client has data
                            if data:
                                tty.write(
                                    data.replace(b"\n", b"\r\n")
                                )  # fix line endings for Carberry

                            # Interpret empty result as closed connection
                            else:
                                self.remove_client(s, "Got no data")

        except serial.SerialException:
            logger.exception("Serial error")

        except socket.error:
            logger.exception("Socket error")

        except (KeyboardInterrupt, SystemExit):
            pass

        finally:
            logger.info("closing...")
            for client in self.clients:
                client.close()
            tty.close()
            srv.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--device", default="/dev/ttyS0")
    parser.add_argument("--listen", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=5000)
    args = parser.parse_args()

    mux = Mux()
    mux.run(args.device, args.listen, args.port)
