#!/bin/bash
cp /usr/share/doc/packages/chrony/examples/chrony.nm-dispatcher.dhcp /etc/NetworkManager/dispatcher.d/20-chrony-dhcp
chmod 755 /etc/NetworkManager/dispatcher.d/20-chrony-dhcp
