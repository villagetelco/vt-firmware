#!/bin/sh

# /etc/init.d/set-mac
# This script looks for a MAC address conflict between Mesh wifi interface and Ethernet LAN.
# If there is a conflict, the MAC address of the LAN interface is changed in the third octet.
# This avoids batman-adv receiving packets on own MAC address.

WLAN="wlan0-1"
LAN="eth0"
BRIDGE="br-lan"

# Get the current MAC addresses
if [ -e /sys/class/net/$WLAN ]; then
	WLANMAC=`cat /sys/class/net/$WLAN/address`
else
	WLANMAC="1"
fi
if [ -e /sys/class/net/$LAN ]; then
	LANMAC=`cat /sys/class/net/$LAN/address`
else 
	LANMAC="0"
fi

# Check if there is a MAC addr conflict and change if reqd.
if [ $WLANMAC = $LANMAC ]; then
	# Split up the MAC address
	MAC1=`cat /sys/class/net/$LAN/address | cut -c1-7`
	MAC2=`cat /sys/class/net/$LAN/address | cut -c8`
	MAC3=`cat /sys/class/net/$LAN/address | cut -c9-17`
	# Change the third octet
	if [ $MAC2 = "0" ]; then 
		MAC2="1"
	else
		MAC2="0"
	fi

	# Set the new MAC for the Eth port and bridge.
	ifconfig $LAN    down
	ifconfig $LAN    hw ether $MAC1$MAC2$MAC3
	ifconfig $BRIDGE hw ether $MAC1$MAC2$MAC3
	ifconfig $LAN    up
fi

exit

