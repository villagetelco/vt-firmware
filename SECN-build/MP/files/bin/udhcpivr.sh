#!/bin/sh

# /bin.udhcpd.sh

# This script runs a temporary DHCP service on the br-lan interface.
# It is intended to be run from an IVR command DHCP (3427)
# It provides only a single IP address (172.31.255.253) to a client
# so that the client can access the MP on the Fallback address (172.31.255.254)
# for the purpose of setting up the MP configuration immediately after 
# flashing with the SECN firmware.
# The DHCP service only runs until the MP is restarted or the udhcpd daemon is terminated manually.

# Terminate any currently running instances of udhcpd
killall udhcpd > /dev/null

# Make a new lease file
rm /tmp/udhcpd.leases > /dev/null
touch /tmp/udhcpd.leases

# Set up log file
date > /tmp/udhcpd.log

# Start the server with IVR conf and log activity
udhcpd -f /etc/udhcpd.ivr.conf >> /tmp/udhcpd.log &

