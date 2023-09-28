#!/usr/bin/env nix-shell
#!nix-shell -i bash -p pwgen -p whois

pwgen -s 2 -A -1 200 |
  while read -r line; do
    domain="${line}42.de"
    whois "$domain" | egrep -q 'Status: free' && echo "$domain is available"
  done
