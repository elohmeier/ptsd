#!/usr/bin/env bash

pwgen -s 3 -A -1 200 |
  while read -r line; do
    domain="${line}.de"
    whois "$domain" | egrep -q 'Status: free' && echo "$domain is available"
  done
