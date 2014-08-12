#!/bin/sh

# Set the host name prefix
HOST="MP"

# Build the hostname ($HOST-nnn) from the device IP address last octet
OCTET_D=`uci show network.lan.ipaddr | cut -d = -f2 | cut -d . -f4`

HOSTNAME="$HOST-$OCTET_D"

# Set the hostname
uci set system.@system[0].hostname=$HOSTNAME
uci commit system

# Set the hostname as the Common Name in the SSL certificate for the web server.
uci set uhttpd.px5g.commonname=$HOSTNAME
uci commit uhttpd

# Set the system hostname
echo $HOSTNAME > /proc/sys/kernel/hostname

# Add hostname to /etc/hosts
echo "127.0.0.1  $HOSTNAME" >> /etc/hosts
