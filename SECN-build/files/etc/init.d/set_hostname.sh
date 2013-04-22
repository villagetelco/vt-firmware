#!/bin/sh

# Set the host name prefix
HOST="TP"

# Build the hostname ($HOST-nnn) from the device IP address last octet
OCTET_D=`uci show network.lan.ipaddr | cut -d = -f2 | cut -d . -f4`

# Set the hostname
uci set system.@system[0].hostname=$HOST-$OCTET_D
uci commit system

# Set the hostname as the Common Name in the SSL certificate for the web server.
uci set uhttpd.px5g.commonname=$HOST-$OCTET_D
uci commit uhttpd

# Set the system hostname
echo $(uci get system.@system[0].hostname) > /proc/sys/kernel/hostname


