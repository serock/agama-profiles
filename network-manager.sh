#!/bin/bash
nmcli connection modify \
wired-home \
connection.autoconnect-priority 0 \
connection.type 802-3-ethernet \
connection.zone home \
802-3-ethernet.wake-on-lan ignore \
ipv4.ignore-auto-dns yes

nmcli connection modify \
wired-public \
connection.autoconnect-priority 0 \
connection.type 802-3-ethernet \
connection.zone public \
802-3-ethernet.wake-on-lan ignore

nmcli connection delete id "Wired connection 1"

nmcli radio all off
