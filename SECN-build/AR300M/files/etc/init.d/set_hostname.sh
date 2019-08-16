#!/bin/sh

# Set the host name prefix
HOST="AR300M"

# Build the hostname ($HOST-nnn) from the device IP address last octet
OCTET_D=`uci get network.lan.ipaddr | cut -d = -f2 | cut -d . -f4`

HOSTNAME="$HOST-$OCTET_D"

# Set the hostname
uci set system.@system[0].hostname=$HOSTNAME
uci commit system

# Set the hostname as the Common Name in the SSL certificate for the web server.
uci set uhttpd.px5g.commonname=$HOSTNAME
uci commit uhttpd

# Set the system hostname
echo $HOSTNAME > /proc/sys/kernel/hostname

# Put hostname in hosts file to ensure it can be resolved.
sed -i '/127.0.0.1 localhost/d' /etc/hosts
echo "127.0.0.1 localhost $HOSTNAME" >> /etc/hosts

