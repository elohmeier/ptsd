#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3 python3Packages.requests

import ipaddress
import json

import requests

AS_LIST = []
AS_LIST.append("AS3209")  # Vodafone
AS_LIST.append("AS3320")  # Telekom

ip4 = set()
ip6 = set()

for asnum in AS_LIST:
    print(f"Fetching {asnum}...")
    r = requests.get(
        f"https://stat.ripe.net/data/announced-prefixes/data.json?resource={asnum}",
        timeout=10,
    )
    r.raise_for_status()
    data = r.json()
    for p in data["data"]["prefixes"]:
        addr = ipaddress.ip_network(p["prefix"])
        if addr.version == 4:
            ip4.add(addr)
        elif addr.version == 6:
            ip6.add(addr)

print(f"Found {len(ip4)} IPv4 and {len(ip6)} IPv6 prefixes")

with open("ip-allowlist.json", "w") as f:
    json.dump(
        {
            "ipv4": sorted([str(ip) for ip in ip4]),
            "ipv6": sorted([str(ip) for ip in ip6]),
        },
        f,
        indent=4,
    )
