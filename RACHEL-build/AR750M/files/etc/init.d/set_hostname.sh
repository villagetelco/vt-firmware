#!/bin/sh

HOSTNAME="VTRACHEL"

# Set the hostname
uci set system.@system[0].hostname=$HOSTNAME
uci commit system

# Set the hostname as the Common Name in the SSL certificate for the web server.
uci set uhttpd.px5g.commonname=$HOSTNAME
uci commit uhttpd

# Set the system hostname
echo $(uci get system.@system[0].hostname) > /proc/sys/kernel/hostname


