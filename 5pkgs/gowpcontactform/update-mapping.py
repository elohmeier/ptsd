#!/usr/bin/env python3

import re

import mysql.connector
import sshtunnel

with sshtunnel.open_tunnel(
    ssh_address_or_host=("htz3.host.fraam.de", 1022),
    remote_bind_address=("192.168.100.15", 22),
    ssh_username="root",
) as tun_htz3:

    with sshtunnel.open_tunnel(
        ssh_address_or_host=("localhost", tun_htz3.local_bind_port),
        remote_bind_address=("127.0.0.1", 3306),
        ssh_username="root",
    ) as tun_wpjail:

        with mysql.connector.connect(
            user="root",
            host="localhost",
            database="wordpress",
            port=tun_wpjail.local_bind_port,
        ) as conn:

            with conn.cursor() as cursor:
                cursor.execute(
                    "select ID, post_title, post_content from wp_posts where post_type = 'wpcf7_contact_form'"
                )
                data = cursor.fetchall()

parsed = [
    (d[0], d[1], re.search(r"wordpress@fraam.de\n(.+)", d[2]).group(1))
    for d in data
    if "wordpress@fraam.de" in d[2]
]

print(parsed)

gomap = (
    """package main

func GetRcpts() map[int]string {
\treturn map[int]string{\n"""
    + "\n".join([f'\t\t{x[0]}: "{x[2]}",' for x in parsed])
    + "\n\t}\n}"
)
print(gomap)

with open("rcpts.go", "w") as f:
    f.write(gomap)
