#!/bin/bash

# on real server
# to allow forwarding

sysctl net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -s 192.168.122.0/24 -j SNAT --to 192.168.32.20
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
service firewalld stop