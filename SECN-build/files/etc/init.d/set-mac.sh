#!/bin/sh

# /etc/init.d/set-mac
# This script looks for a MAC address conflict between AdHoc wifi interface and br-lan.
# If there is a conflict, the MAC address of the AdHoc interface is changed in the third octet,
# and is explictly set in the wireless config file.
# This avoids batman-adv receiving packets on own MAC address
# A MAC conflict will be resolved after first restart.


WLAN="wlan0-1"
AH="ah_0"

# Get the current MAC addresses
if [ -e /sys/class/net/$WLAN ]; then
	MACADDR=`cat /sys/class/net/$WLAN/address`
fi
if [ -e /sys/class/net/br-lan ]; then
	BRLANMAC=`cat /sys/class/net/br-lan/address`
else 
	BRLANMAC="0"
fi

# Check if there is a MAC addr conflict and change if reqd.
if [ $MACADDR = $BRLANMAC ]; then
	# Split up the MAC address
	MAC1=`cat /sys/class/net/$WLAN/address | cut -c1-7`
	MAC2=`cat /sys/class/net/$WLAN/address | cut -c8`
	MAC3=`cat /sys/class/net/$WLAN/address | cut -c9-17`
	# Change the third octet
	if [ $MAC2 = "0" ]; then 
		MAC2="1"
	else
		MAC2="0"
	fi
	# Save the new MAC
	uci set wireless.$AH.macaddr=$MAC1$MAC2$MAC3
	uci commit wireless
fi

exit

