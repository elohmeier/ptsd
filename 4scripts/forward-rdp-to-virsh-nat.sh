#!/usr/bin/env bash

sysctl net.ipv4.conf.eth0.forwarding=1
sysctl net.ipv4.conf.virsh-nat.forwarding=1

iptables -A PREROUTING -t nat -p tcp -i eth0 --dport 3389 -j DNAT --to-destination 192.168.197.210:3389
iptables -A POSTROUTING -t nat -p tcp -d 192.168.197.210 --dport 3389 -j MASQUERADE
iptables -A FORWARD -p tcp -d 192.168.197.210 --dport 3389 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

systemctl stop firewall

