#!/bin/bash
nmcli connection add \
connection.id wired-home \
connection.autoconnect-priority 0 \
connection.type 802-3-ethernet \
connection.zone home \
802-3-ethernet.wake-on-lan ignore \
ipv4.method auto \
ipv6.method disabled

nmcli connection add \
connection.id wired-public \
connection.autoconnect no \
connection.autoconnect-priority 0 \
connection.type 802-3-ethernet \
connection.zone public \
802-3-ethernet.wake-on-lan ignore \
ipv4.dns "208.67.222.222 208.67.220.220" \
ipv4.ignore-auto-dns yes \
ipv4.method auto \
ipv6.dns "2620:119:35::35 2620:119:53::53" \
ipv6.ignore-auto-dns yes \
ipv6.method auto

nmcli connection delete id "Wired connection 1"

nmcli radio all off
