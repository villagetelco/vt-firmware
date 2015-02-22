#! /bin/sh

# Set up RPi host in /etc/hosts

# Give the RPi time to startup and get DHCP IP
sleep 10

# Find the IP address of the RPi device from the MAC address "b8:27..."
RPI=`cat /proc/net/arp | grep b8:27 | cut -d " " -f 1`

# Replace the line in /etc/hosts for "rachelpi"
sed -i 's/.* rachelpi/'"$RPI"' rachelpi/'  /etc/hosts 

# Restart DNS
/etc/init.d/dnsmasq restart


